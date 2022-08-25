<template>
	<div class="p-0 m-0">
		<b-card class="shadow-sm mb-3" align="left" no-body>
			<b-card-header class="p-0">
				<h6 class="bg-primary text-light unwrappable-header p-2 m-0">
					<expander v-model="showReview" />
					<span>{{ label }}</span>
				</h6>
			</b-card-header>

			<transition name="slide-fade">
				<b-card-text v-if="showReview">
					<b-table :fields="fields" :items="raw_disease" class="mb-0" :bordered="true">
						<template v-slot:cell(type_of_evidence)="row">
							<row-expander :row="row" class="mr-2" />
							<span>{{ row.item.type_of_evidence }}</span>
							<span v-if="row.item.drug">- {{ row.item.drug }}</span>
						</template>

						<template v-slot:cell(list_of_evidences)="data">
							<p
								v-for="(effect, effect_idx) in getCurationEntriesProperties(
									data.item.curation_entries,
									'effect'
								)"
								:key="effect_idx">
								{{ effect.value }} : {{ effect.number ? effect.number : 'no' }} evidence(s)
								<br />
							</p>

							<p
								v-for="(tier, tier_idx) in getCurationEntriesProperties(
									data.item.curation_entries,
									'tier_level_criteria'
								)"
								:key="tier_idx + 'tier'">
								{{ tier.value }} : {{ tier.number ? tier.number : 'no' }} evidence(s)
								<br />
							</p>
						</template>

						<template v-slot:cell(curators_annotation)="data">
							<div class="pb-2">
								<b-form-select
									v-model="data.item.effect"
									v-if="data.item.type_of_evidence.includes('Prognostic')"
									:options="prognosticOutcomeOptions"
									class="form-control"
									:disabled="not_reviewed || annotated"></b-form-select>
								<b-form-select
									v-model="data.item.effect"
									v-if="data.item.type_of_evidence.includes('Diagnostic')"
									:options="diagnosticOutcomeOptions"
									class="form-control"
									:disabled="not_reviewed || annotated"></b-form-select>
								<b-form-select
									v-model="data.item.effect"
									v-if="data.item.type_of_evidence.includes('Predictive / Therapeutic')"
									:options="predictiveOutcomeOptions"
									class="form-control"
									:disabled="not_reviewed || annotated"></b-form-select>
							</div>
							<div class="pt-2">
								<b-form-select
									v-model="data.item.tier"
									v-if="data.item.type_of_evidence.includes('Prognostic')"
									:options="trustOptions"
									class="form-control"
									:disabled="not_reviewed || annotated"></b-form-select>
								<b-form-select
									v-model="data.item.tier"
									v-if="data.item.type_of_evidence.includes('Diagnostic')"
									:options="trustOptions"
									class="form-control"
									:disabled="not_reviewed || annotated"></b-form-select>
								<b-form-select
									v-model="data.item.tier"
									v-if="data.item.type_of_evidence.includes('Predictive / Therapeutic')"
									:options="trustOptions"
									class="form-control"
									:disabled="not_reviewed || annotated"></b-form-select>
							</div>
						</template>

						<template v-slot:cell(reviewer_annotation)="data">
							<b-row>
								<b-col
									cols="4"
									v-for="(review, index) in data.item.curation_reviews"
									:key="index">
									<h5 class="mb-3">
										<b-icon
											v-if="review.acceptance"
											style="color: blue"
											icon="check-square-fill"></b-icon>
										<b-icon v-else style="color: red" icon="x-square-fill"></b-icon>

										{{ review.reviewer_name }}
									</h5>

									<b-btn
										variant="info"
										block
										class="mt-3 w-50"
										:href="`mailto:${review.reviewer_email}`">
										Reply by mail
									</b-btn>
									<br />
									<p
										:class="
											review.annotated_effect !== data.item.effect
												? 'text-danger bold'
												: null
										">
										{{ review.annotated_effect }}
									</p>
									<p
										:class="
											review.annotated_tier !== data.item.tier
												? 'text-danger bold'
												: null
										">
										{{ review.annotated_tier }}
									</p>
									<small class="justify-around">
										{{ review.comment }}
									</small>
								</b-col>
							</b-row>
						</template>
					</b-table>
				</b-card-text>
			</transition>
		</b-card>
	</div>
</template>

<script>
/* eslint-disable */
import {mapGetters} from 'vuex';
import {pubmedURL} from '@/utils';
import BroadcastChannel from 'broadcast-channel';
import VariomesSearch from '@/components/widgets/curation/VariomesSearch';
import VariomesAbstract from '@/components/widgets/curation/VariomesAbstract';
import {BIcon, BIconCheckSquareFill, BIconSquare, BIconXSquareFill} from 'bootstrap-vue';
import {groupBy} from 'lodash';

export default {
	name: 'ModifyReview',
	components: {
		VariomesSearch,
		VariomesAbstract,
		BIcon,
		BIconSquare,
		BIconCheckSquareFill,
		BIconXSquareFill,
	},
	props: {
		raw_disease: {type: Array, required: false},
		//disease: {type: Object, required: false},
		label: {type: String, required: false},

		annotated: {type: Boolean, required: false},
		not_reviewed: {type: Boolean, required: false},
	},
	methods: {
		pubmedURL,
		created() {
			this.refreshReferences();
			this.channel.onmessage = () => {
				// update the list of references, since we likely added one
				this.refreshReferences();
			};
		},

		getCurationEntriesProperties(curation_entries, property) {
			let grouped_curation_entries = groupBy(curation_entries, entry => entry[property]);
			return Object.entries(grouped_curation_entries).map(i => {
				return {value: i[0], number: i[1].length};
			});
		},

		createListOfEvidences(curation_entries) {
			return [
				this.getCurationEntriesProperties('effect'),
				this.getCurationEntriesProperties('tier_level_criteria'),
			];
		},
	},
	data() {
		return {
			items: [],
			showReview: true,
			channel: new BroadcastChannel('curation-update'),
			fields: [
				{
					key: 'type_of_evidence',
					label: 'TYPE OF EVIDENCE',
					class: 'ten-percent-class',
				},
				{
					key: 'curators_annotation',
					label: 'CURATORS ANNOTATION',
					class: 'ten-percent-class',
				},
				{
					key: 'list_of_evidences',
					label: 'LIST OF EVIDENCES',
					class: 'fifteen-percent-class',
				},
				{
					key: 'reviewer_annotation',
					label: 'REVIEWERS ANNOTATIONS',
					class: 'fourty-five-percent-class',
				},
			],
			footer: [],
			prognosticOutcomeOptions: [
				'Good outcome',
				'Poor outcome',
				'Intermediate',
				'Unclear',
				'Context-dependent',
				'Conflicting Evidences',
			],
			diagnosticOutcomeOptions: ['Associated with diagnosis', 'Not associated with diagnosis', 'Other'],
			predictiveOutcomeOptions: [
				'Sensitive (in vitro)',
				'Responsive',
				'Resistant (in vitro)',
				'Reduced sensivity',
				'Not responsive',
				'Adverse response',
				'Other',
				'Conflicting Evidences',
			],
			trustOptions: [
				'Included in Professional Guidelines',
				'Well-powered studies with consensus from experts in the field',
				'Multiples small published studies with some consensus',
				'Clinical trial',
				'Pre-clinical trial',
				'Population study',
				'Small published studies with some consensus',
				'Case reports',
				'No convincing published evidence of drugs effect',
				'Author statement',
				'Reported evidence supportive of benign/likely benign effect',
				'Other criteria',
				'Not applicable',
			],
		};
	},
	mounted() {},
	computed: {
		...mapGetters({
			variant: 'variant',
			gene: 'gene',
		}),
	},
};
</script>

<style>
.table td {
	vertical-align: middle;
}

.ten-percent-class {
	width: 10%;
}

.fifteen-percent-class {
	width: 15%;
}

.twenty-percent-class {
	width: 20%;
}

.fourty-five-percent-class {
	width: 45%;
}

.slide-fade-enter-active {
	transition: all 1.5s ease;
}

.slide-fade-leave-active {
	transition: all 0.3s ease;
}

.slide-fade-enter-to,
.slide-fade-leave {
	max-height: 120px;
}

.slide-fade-enter, .slide-fade-leave-to
    /* .slide-fade-leave-active below version 2.1.8 */ {
	opacity: 0;
	max-height: 0;
}
</style>
<style scoped>
table >>> .thead-footer {
	display: none !important;
}
</style>
