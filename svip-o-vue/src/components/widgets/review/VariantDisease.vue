<template>
    <div :key="renderKey">
        <div v-if="review_cycle > 1">
            <br />
            <b-form-checkbox
                id="checkbox-1"
                v-model="only_conflicting"
                name="checkbox-1"
                value="yes"
                unchecked-value="no">
                {{ $t("Show only conflicting entries")}}
            </b-form-checkbox>

            <br />

        </div>

        <div v-for="(submissionEntry, idx) in submissionEntries" :key="submissionEntry[0] + idx">
            <b-card class="shadow-sm mb-3" align="left" no-body>
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="expander_array[idx].disease" />
                    {{ submissionEntry[0] }}
                </h6>

                <div v-for="(type, index) in submissionEntry[1]" :key="type.type_of_evidence + index">
                    <b-card-body class="p-0">
                        <transition name="slide-fade">
                            <div v-if="expander_array[idx].disease">
                                <b-card-text
                                    class="p-2 m-0"
                                    :class="
                                        only_conflicting === 'yes' && !type.if_conflicting_reviews
                                            ? 'hidden'
                                            : ''
                                    ">
                                    <b-row align-v="center">
                                        <b-col align="left" cols="2">
                                            <div class="ml-1">
                                                <expander
                                                    v-model="expander_array[idx].curation_entries[index]" />
                                                {{ type.type_of_evidence }}
                                                {{ type.drug && ` - ${type.drug}` }}
                                                <br />

                                                <p style="color: red" v-if="type.if_conflicting_reviews">
                                                    {{ $t("Conflicting entry!")}}
                                                </p>
                                            </div>
                                        </b-col>
                                        <b-col cols="2">
                                            <p
                                                class="mb-2"
                                                v-for="(effect, effect_idx) in getCurationEntriesProperties(
                                                    type.curation_entries,
                                                    'effect'
                                                )"
                                                :key="'effect' + effect_idx">
                                                {{ effect.value }} :
                                                {{ effect.number ? effect.number : 'no' }} {{ $t("evidence(s)")}}
                                            </p>
                                            <p
                                                class="mb-2"
                                                v-for="(effect, effect_idx) in getCurationEntriesProperties(
                                                    type.curation_entries,
                                                    'tier_level_criteria'
                                                )"
                                                :key="'tier' + effect_idx">
                                                {{ effect.value }} :
                                                {{ effect.number ? effect.number : 'no' }} {{ $t("evidence(s)")}}
                                            </p>
                                        </b-col>
                                        <b-col cols="2">
                                            <b-row class="p-2">
                                                <b-input v-model="type.effect" readonly />
                                            </b-row>
                                            <b-row class="p-2">
                                                <b-input v-model="type.tier" readonly />
                                            </b-row>
                                        </b-col>
                                        <b-col cols="2">
                                            <b-row class="p-2">
                                                <select-prognostic-outcome
                                                    v-if="type.type_of_evidence === 'Prognostic'"
                                                    v-model="currentReviews.data[idx][1][index].effect"
                                                    @input="
                                                        onChange(
                                                            {
                                                                annotatedEffect: type.effect,
                                                                annotatedTier: type.tier,
                                                            },
                                                            currentReviews.data[idx][1][index]
                                                        )
                                                    "
                                                    :disabled="
                                                        not_annotated || submitted
                                                    "></select-prognostic-outcome>
                                                <select-diagnostic-outcome
                                                    v-if="type.type_of_evidence === 'Diagnostic'"
                                                    v-model="currentReviews.data[idx][1][index].effect"
                                                    @input="
                                                        onChange(
                                                            {
                                                                annotatedEffect: type.effect,
                                                                annotatedTier: type.tier,
                                                            },
                                                            currentReviews.data[idx][1][index]
                                                        )
                                                    "
                                                    :disabled="
                                                        not_annotated || submitted
                                                    "></select-diagnostic-outcome>
                                                <select-predictive-therapeutic-outcome
                                                    v-if="
                                                        type.type_of_evidence === 'Predictive / Therapeutic'
                                                    "
                                                    v-model="currentReviews.data[idx][1][index].effect"
                                                    @input="
                                                        onChange(
                                                            {
                                                                annotatedEffect: type.effect,
                                                                annotatedTier: type.tier,
                                                            },
                                                            currentReviews.data[idx][1][index]
                                                        )
                                                    "
                                                    :disabled="
                                                        not_annotated || submitted
                                                    "></select-predictive-therapeutic-outcome>
                                            </b-row>
                                            <b-row class="p-2">
                                                <select-tier
                                                    v-if="
                                                        ['Prognostic', 'Diagnostic'].includes(
                                                            type.type_of_evidence
                                                        )
                                                    "
                                                    v-model="currentReviews.data[idx][1][index].tier"
                                                    @input="
                                                        onChange(
                                                            {
                                                                annotatedEffect: type.effect,
                                                                annotatedTier: type.tier,
                                                            },
                                                            currentReviews.data[idx][1][index]
                                                        )
                                                    "
                                                    :disabled="not_annotated || submitted"></select-tier>
                                                <select-therapeutic-tier
                                                    v-if="
                                                        type.type_of_evidence === 'Predictive / Therapeutic'
                                                    "
                                                    v-model="currentReviews.data[idx][1][index].tier"
                                                    @input="
                                                        onChange(
                                                            {
                                                                annotatedEffect: type.effect,
                                                                annotatedTier: type.tier,
                                                            },
                                                            currentReviews.data[idx][1][index]
                                                        )
                                                    "
                                                    :disabled="
                                                        not_annotated || submitted
                                                    "></select-therapeutic-tier>
                                            </b-row>
                                        </b-col>
                                        <b-col cols="1" align="center">
                                            <b-row class="justify-content-center">{{ $t("Review status")}}</b-row>
                                            <b-row class="justify-content-center">
                                                <span
                                                    v-for="(review, review_idx) in type.curation_reviews"
                                                    :key="'review' + review_idx">
                                                    <br />

                                                    <span
                                                        v-if="
                                                            review.acceptance !== null &&
                                                            review.reviewer === user.user_id &&
                                                            submitted
                                                        ">
                                                        <b-icon
                                                            class="h4 mb-2 m-1"
                                                            :style="displayColor(review.acceptance)"
                                                            :icon="displayIcon(review.acceptance)"></b-icon>
                                                    </span>
                                                </span>

                                                <!--  delete '&& !submitted' here and set showOnlyOwnReviewStatus to false if you want to show the review status of all reviewers-->
                                                <b-icon
                                                    v-if="
                                                        (type.curation_reviews.length < 3 && !submitted) ||
                                                        (type.curation_reviews.length <= 3 && draft)
                                                    "
                                                    class="h4 mb-2 m-1"
                                                    :style="
                                                        displayColor(
                                                            currentReviews.data[idx][1][index].acceptance,
                                                            detectOwnReviews()
                                                        )
                                                    "
                                                    :icon="
                                                        displayIcon(
                                                            currentReviews.data[idx][1][index].acceptance,
                                                            detectOwnReviews()
                                                        )
                                                    "></b-icon>
                                                <span
                                                    v-if="
                                                        type.curation_reviews.length < 3 &&
                                                        !showOnlyOwnReviewStatus
                                                    ">
                                                    <span
                                                        v-for="i in 3 - type.curation_reviews.length - 1"
                                                        :key="i + ' icon'">
                                                        <span>
                                                            <b-icon
                                                                class="h4 mb-2 m-1"
                                                                :style="displayColor(null)"
                                                                :icon="displayIcon(null)"></b-icon>
                                                        </span>
                                                    </span>
                                                </span>
                                            </b-row>
                                        </b-col>
                                        <b-col cols="3">
                                            <b-textarea
                                                @blur="handleBlur"
                                                :disabled="
                                                    currentReviews.data[idx][1][index].acceptance ||
                                                    not_annotated ||
                                                    submitted
                                                "
                                                :class="` ${
                                                    currentReviews.data[idx][1][index].acceptance ||
                                                    (currentReviews.data[idx][1][index].comment !== null &&
                                                        currentReviews.data[idx][1][index].comment !== '')
                                                        ? 'summary-box'
                                                        : 'summary-box alert-border'
                                                }`"
                                                rows="3"
                                                placeholder="Comment"
                                                v-model="
                                                    currentReviews.data[idx][1][index].comment
                                                "></b-textarea>
                                        </b-col>
                                    </b-row>
                                </b-card-text>

                                <transition name="slide-fade">
                                    <div v-if="expander_array[idx].curation_entries[index]">
                                        <b-card-footer class="pt-0 pb-0 pl-3 pr-3 fluid">
                                            <table class="table table-responsive-lg">
                                                <th class="bg-light">{{ $t("PMID")}}</th>
                                                <th class="bg-light">Effect</th>
                                                <th class="bg-light">{{ $t("Tier level")}}</th>
                                                <th class="bg-light">{{ $t("Support")}}</th>
                                                <th class="bg-light">{{ $t("ID")}}</th>
                                                <th class="bg-light">Comment</th>

                                                <tr v-for="(curation, i) in type.curation_entries" :key="i">
                                                    <td>
                                                        <b-link
                                                            target="_blank"
                                                            active
                                                            :href="`https://pubmed.ncbi.nlm.nih.gov/${
                                                                curation.references.split(':')[1]
                                                            }`">
                                                            {{ curation.references }}
                                                        </b-link>
                                                    </td>
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
                                                            {{ $t("Curation entry #")}}{{ curation.id }}
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
                            idx < submissionEntry[1].length - 1 &&
                            !expander_array[idx].curation_entries[index]
                        " />
                </div>
            </b-card>
        </div>
        <div class="float-right">
            <b-button variant="warning" @click="submitReviews(true)" :disabled="not_annotated || submitted">
                {{ $t("Finish later")}}
            </b-button>

            <b-button class="footer-btn" @click="submitOptions()" :disabled="not_annotated || submitted">
                {{ $t("Submit review")}}
            </b-button>
        </div>
        <b-navbar-text v-if="not_annotated" class="fixed-bottom submitted-bar" align="center">
            {{ $t("THIS VARIANT HASN'T YET BEEN SUBMITTED FOR REVIEW.")}}
        </b-navbar-text>
        <b-navbar-text class="fixed-bottom submitted-bar" align="center" v-if="submitted && !draft">
            {{ $t("YOU HAVE SUBMITTED A REVIEW FOR THIS VARIANT.")}}
        </b-navbar-text>
    </div>
</template>

<script>
/* eslint-disable */
// import fields from "@/data/curation/evidence/fields.js";
import {HTTP} from '@/router/http';
import BroadcastChannel from 'broadcast-channel';
import {BIcon, BIconCheckSquareFill, BIconSquare, BIconXSquareFill} from 'bootstrap-vue';
import ulog from 'ulog';
import SelectPrognosticOutcome from '@/components/widgets/review/forms/SelectPrognosticOutcome';
import SelectDiagnosticOutcome from '@/components/widgets/review/forms/SelectDiagnosticOutcome';
import SelectPredictiveTherapeuticOutcome from '@/components/widgets/review/forms/SelectPredictiveTherapeuticOutcome';
import SelectTier from '@/components/widgets/review/forms/SelectTier';
import SelectTherapeuticTier from '@/components/widgets/review/forms/SelectTherapeuticTier';
import {mapGetters} from 'vuex';
import {groupBy} from 'lodash';

const log = ulog('VariantDisease');

export default {
    name: 'VariantDisease',
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
    },
    props: ['variant_id', 'gene_id'],
    data() {
        return {
            only_conflicting: 'no',
            renderKey: 0,
            submissionEntries: [],
            selfReviewedEvidences: {},
            summary: null,
            history_entry_id: null,
            loading: false,
            error: null,
            channel: new BroadcastChannel('curation-update'),
            expander_array: [],
            not_annotated: false,
            submitted: false,
            currentReviews: {
                data: [],
            },
            draftReviews: {
                data: [],
            },
            draft: false,
            showOnlyOwnReviewStatus: true,
            review_cycle: 0,
        };
    },
    created() {
        // Watch if user is going to leave the page
        window.addEventListener('beforeunload', this.beforeWindowUnload);

        if (this.variant.submission_entries.length > 0) {
            this.review_cycle = this.variant.submission_entries[0].review_cycle;
        }

        this.submissionEntries = Object.entries(
            groupBy(
                this.variant.submission_entries //
                    .filter(i =>
                        ['Prognostic', 'Diagnostic', 'Predictive / Therapeutic'].includes(i.type_of_evidence)
                    ),
                item => {
                    return item.disease && item.disease.name ? item.disease.name : 'Unspecified';
                }
            )
        );

        this.getExpanderArray();

        // Check that this page is appropriate regarding current review stage of variant
        if (['none', 'loaded', 'ongoing_curation'].includes(this.variant.stage)) {
            this.not_annotated = true;
        } else if (['approved', 'unapproved', 'on_hold', 'fully_approved'].includes(this.variant.stage)) {
            this.submitted = true;
        }

        this.channel.onmessage = () => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };
        this.createCurrentReviews();
        this.getDraftReviews();
        this.detectOwnReviews();
        if (this.draftReviews.data.length > 0) {
            this.currentReviews = this.draftReviews;
            this.draft = true;
        }
    },

    computed: {
        ...mapGetters({
            user: 'currentUser',
            variant: 'variant',
        }),
    },

    methods: {
        // groupSubmissionsEntries(submissionEntriesUngrouped) {
        //     return Object.entries(
        //         groupBy(
        //             submissionEntriesUngrouped.filter(i =>
        //                 ['Prognostic', 'Diagnostic', 'Predictive / Therapeutic'].includes(i.type_of_evidence)
        //             ),
        //             item => {
        //                 return item.disease && item.disease.name ? item.disease.name : 'Unspecified';
        //             }
        //         )
        //     );
        // },

        numberOfEmptySquares(length) {
            switch (length) {
                case 0:
                    return 2;
                case 1:
                    return 1;
                case 2:
                    return 0;
                case 3:
                    return 0;
            }
        },
        getDraftReviews() {
            if (
                this.submissionEntries[0][1][0].curation_reviews.length > 0 &&
                this.submissionEntries[0][1][0].curation_reviews.filter(
                    rev => rev.reviewer === this.user.user_id
                ).length > 0 &&
                this.submissionEntries[0][1][0].curation_reviews.filter(
                    rev => rev.reviewer === this.user.user_id
                )[0].draft
            ) {
                this.draftReviews.data = this.submissionEntries.map(i => {
                    let types = i[1].map(item => {
                        return {
                            submission_entry: parseInt(item.id),
                            id: item.curation_reviews.filter(rev => rev.reviewer === this.user.user_id)[0].id,
                            effect: item.curation_reviews.filter(rev => rev.reviewer === this.user.user_id)[0]
                                .annotated_effect,
                            tier: item.curation_reviews.filter(rev => rev.reviewer === this.user.user_id)[0]
                                .annotated_tier,
                            reviewer: this.user.user_id,
                            acceptance: item.curation_reviews.filter(
                                rev => rev.reviewer === this.user.user_id
                            )[0].acceptance,
                            comment: item.curation_reviews.filter(
                                rev => rev.reviewer === this.user.user_id
                            )[0].comment,
                            draft: true,
                        };
                    });
                    return [i[0], types];
                });
            }
        },
        createCurrentReviews() {
            this.currentReviews.data = this.submissionEntries.map(i => {
                let types = i[1].map(item => {
                    return {
                        submission_entry: parseInt(item.id),
                        effect: item.effect,
                        tier: item.tier,
                        reviewer: this.user.user_id,
                        acceptance: true,
                        comment: null,
                        draft: true,
                    };
                });
                return [i[0], types];
            });
        },

        getCurationEntriesProperties(curation_entries, property) {
            let grouped_curation_entries = groupBy(curation_entries, entry => entry[property]);
            return Object.entries(grouped_curation_entries).map(i => {
                return {value: i[0], number: i[1].length};
            });
        },
        getExpanderArray() {
            this.submissionEntries.map(entry => {
                let curation_entries = [];
                for (const i of entry[1]) {
                    curation_entries.push(false);
                }
                this.expander_array.push({disease: true, curation_entries: curation_entries});
            });
        },
        beforeWindowUnload(e) {
            // Cancel the event
            e.preventDefault();
            // Chrome requires returnValue to be set
            e.returnValue = '';
        },

        submitOptions() {
            this.$confirm({
                message: `You are about to submit permanently the reviews for the evidences of this variant. Are you sure?`,
                button: {
                    yes: 'Submit permanently',
                    no: 'Cancel',
                },
                /**
                 * Callback Function
                 * @param {Boolean} confirm
                 */
                callback: confirm => {
                    if (confirm) {
                        // save as a draft
                        this.submitReviews(false);
                    }
                },
            });
        },
        displayIcon(acceptance, ownSubmitted = false) {
            return acceptance === true && !ownSubmitted
                ? 'check-square-fill'
                : acceptance === false && !ownSubmitted
                ? 'x-square-fill'
                : 'square';
        },
        displayColor(acceptance, ownSubmitted = false) {
            return acceptance === true && !ownSubmitted
                ? 'color:blue;'
                : acceptance === false && !ownSubmitted
                ? 'color:red;'
                : '';
        },
        onChange(curatorValues, reviewerValues) {
            reviewerValues.acceptance =
                curatorValues.annotatedEffect === reviewerValues.effect &&
                curatorValues.annotatedTier === reviewerValues.tier;
            this.handleBlur(true);
        },

        detectOwnReviews() {
            // Check if the current clinician has already submitted their review

            if (this.variant.reviewers) {
                console.log('Draft', this.draftReviews.data);
                if (
                    this.variant.reviewers.includes(this.user.user_id) &&
                    this.draftReviews.data.length === 0
                ) {
                    this.submitted = true;
                    return true;
                }
            }
            return false;
        },
        missingComment() {
            const regExp = /[a-zA-Z]/g;
            // return true if at least one reviewed evidence doesn't match the curator's annotation while no comment has been written by the current reviewer
            for (const [index, entry] of this.submissionEntries.entries()) {
                for (const [i, type] of entry[1].entries()) {
                    if (
                        (type.effect !== this.currentReviews.data[index][1][i].effect ||
                            type.tier !== this.currentReviews.data[index][1][i].tier) &&
                        (this.currentReviews.data[index][1][i].comment === null ||
                            !regExp.test(this.currentReviews.data[index][1][i].comment))
                    ) {
                        return true;
                    }
                }
            }
            return false;
        },
        submitReviews(draft, auto = false) {
            // draft is a boolean that indicates whether the data is to be saved as a draft
            if (!draft && this.missingComment()) {
                this.$snotify.error(
                    'Please enter a comment for every review conflicting with that of curators',
                    '',
                    {timeout: 5000}
                );
                return false;
            }
            let payload = this.currentReviews;

            for (let item of payload.data) {
                for (let entry of item[1]) {
                    entry.draft = draft;
                }
            }

            console.log('payload', payload);

            HTTP.post(`/reviews/bulk_submit`, payload)
                .then(response => {
                    if (draft) {
                        this.currentReviews.data = response.data.newCurrentReviews;
                        if (!auto) {
                            this.$snotify.success('Your review is saved as a draft.');
                        }
                        this.draft = true;
                    } else {
                        this.$snotify.success('Your reviews for this variant have been submitted.');
                        this.submitted = true;
                        this.draft = false;
                    }
                })
                .catch(err => {
                    log.warn(err);
                    this.$snotify.error('Failed to submit review');
                });
        },

        handleBlur() {
            this.submitReviews(true);
        },

        reRender() {
            this.renderKey++;
        },
    },
};
</script>

<style scoped>
.pub-status {
    justify-content: flex-start;
    display: flex;
    align-items: center;
}

.pub-status > .fa-icon {
    margin-right: 0.4rem;
}

.action-tray {
    display: flex;
    justify-content: flex-end;
}

.action-tray .btn {
    margin-left: 5px;
    margin-bottom: 5px;
    display: flex;
    align-items: center;
    justify-content: center;
}

#evidence_table >>> .table {
    margin-bottom: 0;
}

.summary-box {
    color: black !important;
}

.footer-btn {
    margin-left: 1.2rem;
}

.submitted-bar {
    background-color: rgb(194, 45, 0);
    color: white;
    font-weight: bold;
    text-align: center;
    padding: 0.4rem;
}

.alert-border {
    border-color: red;
}

.hidden {
    visibility: hidden;
}
</style>
