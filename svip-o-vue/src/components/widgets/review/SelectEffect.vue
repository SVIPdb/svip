<template>
	<div>
		{{ already_in_review }}
		{{ variant.stage }}
		<div v-if="submissionEntries.length > 0">
			<div v-for="(submissionEntry, index) in submissionEntries" :key="index">
				<b-card class="shadow-sm mb-3" align="left" no-body>
					<h6 class="bg-primary text-light unwrappable-header p-2 m-0">
						<expander v-model="expander_array[index].disease" />
						{{ submissionEntry.disease }}
					</h6>

					<div
						v-for="([type, typeInfo], idx) in Object.entries(submissionEntry.types)"
						:key="type + index">
						<b-card-body class="p-0">
							<transition name="slide-fade">
								<div v-if="expander_array[index].disease">
									<b-card-text class="p-2 mt-2">
										<b-row align-v="center" align-h="left">
											<b-col align="left" cols="3" class="ml-4">
												<expander
													v-model="expander_array[index].curation_entries[idx]" />
												{{ type }}
											</b-col>
											<b-col cols="2" align="center">
												<p
													class="mb-2"
													v-for="([effect, count], i) in Object.entries(
														typeInfo.effect
													)"
													:key="i">
													{{ effect }}:
													{{ count ? count : 'no' }}
													evidence(s)
												</p>
											</b-col>
											<b-col cols="6" align="center">
												<div>
													<b-row
														class="p-1 d-flex justify-content-end flex-row no-wrap">
														<select-prognostic-outcome
															v-if="type === 'Prognostic'"
															v-model="typeInfo.selectedEffect"
															:disabled="already_in_review"
															class="m-1 d-inline w-25"></select-prognostic-outcome>
														<select-diagnostic-outcome
															v-if="type === 'Diagnostic'"
															v-model="typeInfo.selectedEffect"
															:disabled="already_in_review"
															class="m-1 d-inline w-25"></select-diagnostic-outcome>
														<select-predictive-therapeutic-outcome
															v-if="type.includes('Predictive / Therapeutic')"
															v-model="typeInfo.selectedEffect"
															:disabled="already_in_review"
															class="m-1 d-inline w-25"></select-predictive-therapeutic-outcome>

														<select-various-outcome
															v-if="
																!type.includes('Prognostic') &&
																!type.includes('Diagnostic') &&
																!type.includes('Predictive / Therapeutic')
															"
															:evidenceType="type"
															fieldType="effect"
															:disabled="already_in_review"
															v-model="typeInfo.selectedEffect"
															class="m-1 d-inline w-25"></select-various-outcome>

														<select-tier
															v-if="['Prognostic', 'Diagnostic'].includes(type)"
															:disabled="already_in_review"
															v-model="typeInfo.selectedTierLevel"
															class="m-1 d-inline w-50" />
														<select-therapeutic-tier
															v-if="type.includes('Predictive / Therapeutic')"
															:disabled="already_in_review"
															v-model="typeInfo.selectedTierLevel"
															class="m-1 d-inline w-50" />

														<select-various-outcome
															v-if="
																!type.includes('Prognostic') &&
																!type.includes('Diagnostic') &&
																!type.includes('Predictive / Therapeutic')
															"
															:evidenceType="type"
															fieldType="tier"
															:disabled="already_in_review"
															v-model="typeInfo.selectedTierLevel"
															class="m-1 d-inline w-50" />
													</b-row>
												</div>
											</b-col>
										</b-row>
									</b-card-text>
									<transition name="fade">
										<div v-if="expander_array[index].curation_entries[idx]">
											<b-card-footer class="fluid">
												<table class="table table-responsive-lg">
													<th class="bg-light">PMID</th>
													<th class="bg-light">Effect</th>
													<th class="bg-light">Tier level</th>
													<th class="bg-light">Support</th>
													<th class="bg-light">ID</th>
													<th class="bg-light">Comment</th>

													<tr
														v-for="(curation, i) in typeInfo.curationEntries"
														:key="i">
														<td>{{ curation.pmid }}</td>
														<td>{{ curation.effect }}</td>
														<td>{{ curation.tier_level_criteria }}</td>
														<td>{{ curation.support }}</td>
														<td>
															<b-link
																:to="{
																	name: 'view-evidence',
																	params: {action: curation.id},
																}"
																target="_blank"
																alt="Link to evidence">
																Curation entry #{{ curation.id }}
															</b-link>
														</td>
														<td>{{ curation.comment }}</td>
													</tr>
												</table>
											</b-card-footer>
										</div>
									</transition>
								</div>
							</transition>
						</b-card-body>
						<hr
							v-if="
								idx < Object.entries(submissionEntry.types).length - 1 &&
								!expander_array[index].curation_entries[idx]
							" />
					</div>
				</b-card>
			</div>

			<b-button class="float-right" @click="submitCurations(true)" :disabled="already_in_review">
				Confirm annotation
			</b-button>
		</div>

		<b-navbar-text v-if="already_in_review" class="fixed-bottom submitted-bar" align="center">
			THE FIRST ROUND OF ANNOTATION HAS ALREADY BEEN CONFIRMED AND THE VARIANT HAS ALREADY RECEIVED
			REVIEW(S).
		</b-navbar-text>
	</div>
</template>

<script>
/* eslint-disable */
// import fields from "@/data/curation/evidence/fields.js";
import {HTTP} from '@/router/http';
import {aggregateSubmissionEntries, prepareForSubmission} from '../../../helpers/aggregateSubmissionEntries';
import BroadcastChannel from 'broadcast-channel';
import {BIcon, BIconSquare, BIconCheckSquareFill, BIconXSquareFill} from 'bootstrap-vue';
import ulog from 'ulog';
import SelectPrognosticOutcome from '@/components/widgets/review/forms/SelectPrognosticOutcome';
import SelectDiagnosticOutcome from '@/components/widgets/review/forms/SelectDiagnosticOutcome';
import SelectPredictiveTherapeuticOutcome from '@/components/widgets/review/forms/SelectPredictiveTherapeuticOutcome';
import SelectVariousOutcome from '@/components/widgets/review/forms/SelectVariousOutcome';
import SelectTier from '@/components/widgets/review/forms/SelectTier';
import SelectTherapeuticTier from '@/components/widgets/review/forms/SelectTherapeuticTier';
import {mapGetters} from 'vuex';

const log = ulog('SelectEffect');

export default {
	name: 'SelectEffect',
	components: {
		SelectTier,
		SelectTherapeuticTier,
		BIcon,
		BIconSquare,
		BIconCheckSquareFill,
		BIconXSquareFill,
		SelectPrognosticOutcome,
		SelectDiagnosticOutcome,
		SelectPredictiveTherapeuticOutcome,
		SelectVariousOutcome,
	},
	props: {
		variant: {type: Object, required: false},
	},
	data() {
		return {
			submissionEntries: [],
			diseases: [],
			selfReviewedEvidences: {},
			summary: null,
			loading: false,
			error: null,
			channel: new BroadcastChannel('curation-update'),
			already_in_review: false,
			expander_array: [],
		};
	},
	mounted() {
		this.submissionEntries = this.aggregate(
			this.variant.curation_entries.filter(item => item.status === 'ready_for_submission')
		);
		this.getExpanderArray();
	},
	created() {
		// Watch if use is going to leave the page
		window.addEventListener('beforeunload', this.beforeWindowUnload);
		if (
			['annotated', 'ongoing_review', 'unapproved', 'reannotated', 'on_hold', 'approved'].includes(
				this.variant.stage
			)
		) {
			this.already_in_review = true;
		}

		this.channel.onmessage = () => {
			if (this.$refs.paged_table) {
				this.$refs.paged_table.refresh();
			}
		};
	},
	computed: {
		...mapGetters({
			user: 'currentUser',
		}),
	},
	methods: {
		beforeWindowUnload(e) {
			// Cancel the event
			e.preventDefault();
			// Chrome requires returnValue to be set
			e.returnValue = '';
		},

		aggregate: aggregateSubmissionEntries,
		prepareForSubmission: prepareForSubmission,

		getExpanderArray() {
			this.submissionEntries.map(entry => {
				let curation_entries = [];
				for (const [key, value] of Object.entries(entry.types)) {
					curation_entries.push(false);
				}
				this.expander_array.push({
					disease: true,
					curation_entries: curation_entries,
				});
			});
		},

		submitCurations(notify) {
			let submission_data = prepareForSubmission(this.submissionEntries, this.variant, this.user);

			HTTP.post(`/submission_entries/bulk_submit`, submission_data)
				.then(response => {
					if (notify) {
						this.$snotify.success('Your curation(s) have been submitted to be reviewed');
					}
				})
				.catch(err => {
					log.warn(err);
					this.$snotify.error('Failed to submit curation');
				});
		},
	},
};
</script>

<style scoped>
.pub-status > .fa-icon {
	margin-right: 0.4rem;
}
</style>
