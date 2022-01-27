<template>
    <div>
        <div v-for="(review, idx) in diseases" :key="'disease'+ idx">
            <b-card class="shadow-sm mb-3" align="left" no-body>
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="expander_array[idx].disease"/>
                    {{ review.disease }}
                </h6>
                <div v-for="(evidence, index) in review.evidences" :key="'evidence' + index">
                    <b-card-body class="p-0">
                        <transition name="slide-fade">
                            <div v-if="expander_array[idx].disease">
                                <b-card-text class="p-2 m-0">
                                    <b-row align-v="center">
                                        <b-col align="center" cols="1">
                                            <expander v-model="expander_array[idx].evidences[index]"/>
                                            {{ evidence.fullType }}
                                        </b-col>
                                        <b-col cols="2">
                                            <p class="mb-2" v-for="(effect, effect_idx) in evidence.effectOfVariant" :key="'effect' + effect_idx">
                                                {{ effect.label }}: {{ effect.count ? effect.count : 'no' }} evidence(s)
                                            </p>
                                        </b-col>
                                        <b-col cols="2">
                                            <b-row class="p-2">
                                                <b-input v-model="evidence.curator.annotatedEffect" readonly/>
                                            </b-row>
                                            <b-row class="p-2">
                                                <b-input v-model="evidence.curator.annotatedTier" readonly/>
                                            </b-row>
                                        </b-col>
                                        <b-col cols="2">
                                            <b-row class="p-2">
                                                <select-prognostic-outcome 
                                                    v-if="evidence.typeOfEvidence === 'Prognostic'"
                                                    v-model="evidence.currentReview.annotatedEffect"
                                                    @input="onChange(evidence.curator, evidence.currentReview)"
                                                    :disabled="submitted"
                                                ></select-prognostic-outcome>
                                                <select-diagnostic-outcome 
                                                    v-if="evidence.typeOfEvidence === 'Diagnostic'"
                                                    v-model="evidence.currentReview.annotatedEffect"
                                                    @input="onChange(evidence.curator, evidence.currentReview)"
                                                    :disabled="submitted"
                                                ></select-diagnostic-outcome>
                                                <select-predictive-therapeutic-outcome
                                                    v-if="evidence.typeOfEvidence === 'Predictive / Therapeutic'"
                                                    v-model="evidence.currentReview.annotatedEffect"
                                                    @input="onChange(evidence.curator, evidence.currentReview)"
                                                    :disabled="submitted"
                                                ></select-predictive-therapeutic-outcome>
                                            </b-row>
                                            <b-row class="p-2">
                                                <select-tier 
                                                    v-model="evidence.currentReview.annotatedTier"
                                                    @input="onChange(evidence.curator, evidence.currentReview)"
                                                    :disabled="submitted"
                                                ></select-tier>
                                            </b-row>
                                        </b-col>
                                        <b-col cols="1" align="center">
                                            <b-row class="justify-content-center">
                                                Review status
                                            </b-row>
                                            <b-row class="justify-content-center">

                                                <span v-for="(review, review_idx) in evidence.reviews" :key="'review' + review_idx">
                                                    <span v-if="review.status !== null">
                                                        <b-icon
                                                            class="h4 mb-2 m-1" :style="displayColor(review.status)"
                                                            :icon="displayIcon(review.status)"
                                                        ></b-icon>
                                                    </span>
                                                </span>

                                                <b-icon class="h4 mb-2 m-1"
                                                        :style="displayColor(evidence.currentReview.status)"
                                                        :icon="displayIcon(evidence.currentReview.status)"></b-icon>

                                                <span v-for="(review, key) in evidence.reviews" :key="key">
                                                    <span v-if="review.status === null">
                                                        <b-icon
                                                            class="h4 mb-2 m-1" :style="displayColor(review.status)"
                                                            :icon="displayIcon(review.status)"
                                                        ></b-icon>
                                                    </span>
                                                </span>

                                            </b-row>
                                        </b-col>
                                        <b-col cols="4">
                                            <b-textarea
                                                :disabled="evidence.currentReview.status || submitted"
                                                class="summary-box" 
                                                rows="3"
                                                placeholder="Comment..."
                                                v-model="evidence.currentReview.comment"
                                            >
                                            </b-textarea>
                                        </b-col>
                                    </b-row>
                                </b-card-text>

                                <transition name="slide-fade">
                                    <div v-if="expander_array[idx].evidences[index]">
                                        <b-card-footer class="pt-0 pb-0 pl-3 pr-3 fluid">
                                            <b-row align-v="center" v-for="(curation, i) in evidence.curations" :key="'curation' + i">
                                                <b-col class="border p-2">PMID:
                                                    <b-link target="_blank" active
                                                            :href="`https://pubmed.ncbi.nlm.nih.gov/${curation.pmid}`">
                                                        {{ curation.pmid }}
                                                    </b-link>
                                                </b-col>
                                                <b-col class="border p-2">{{ curation.effect }}</b-col>
                                                <b-col class="border p-2">{{ curation.tier }}</b-col>
                                                <b-col class="border p-2">
                                                    Support: {{ curation.support }}
                                                </b-col>
                                                <b-col class="border p-2">
                                                    <b-link :to="{ name: 'view-evidence', params: { action: curation.id } }"
                                                            target="_blank"
                                                            alt="Link to evidence">Curation entry #{{ curation.id }}
                                                    </b-link>
                                                </b-col>

                                                <b-col class="border p-2" cols="6">{{ curation.comment }}</b-col>
                                            </b-row>
                                        </b-card-footer>
                                    </div>
                                </transition>

                            </div>
                        </transition>
                    </b-card-body>
                    <hr v-if="expander_array[idx].disease"/>
                </div>
            </b-card>
        </div>
        <div class="float-right">
        <b-button  variant="warning" @click="submitReviews(true)" :disabled="submitted">
            Finish later
        </b-button>
        <b-button class="footer-btn" @click="submitOptions()" :disabled="submitted">
            Submit review
        </b-button>
        </div>
        <b-navbar-text class="fixed-bottom submitted-bar" align="center">
            YOU HAVE SUBMITTED A REVIEW FOR THIS VARIANT.
        </b-navbar-text>
    </div>
</template>

<script>
/* eslint-disable */
// import fields from "@/data/curation/evidence/fields.js";
import {HTTP} from "@/router/http";
import BroadcastChannel from "broadcast-channel";
import {BIcon, BIconSquare, BIconCheckSquareFill, BIconXSquareFill} from "bootstrap-vue";
import ulog from "ulog";
import SelectPrognosticOutcome from "@/components/widgets/review/forms/SelectPrognosticOutcome";
import SelectDiagnosticOutcome from "@/components/widgets/review/forms/SelectDiagnosticOutcome";
import SelectPredictiveTherapeuticOutcome from "@/components/widgets/review/forms/SelectPredictiveTherapeuticOutcome";
import SelectTier from "@/components/widgets/review/forms/SelectTier";
import { mapGetters } from "vuex";

const log = ulog("VariantDisease");

export default {
    name: "VariantDisease",
    components: {
        SelectTier,
        BIcon,
        BIconSquare,
        BIconCheckSquareFill,
        BIconXSquareFill,
        SelectPrognosticOutcome,
        SelectDiagnosticOutcome,
        SelectPredictiveTherapeuticOutcome,
    },
    props: {
        variant: {type: Object, required: false},
    },
    data() {
        return {
            diseases: [],
            selfReviewedEvidences: {},
            summary: null,
            history_entry_id: null,

            sample_curation_id: null,

            loading: false,
            error: null,
            channel: new BroadcastChannel("curation-update"),
            expander_array: [],
            evidence_counter: 0,
            submitted: false
        };
    },
    created() {
        // Watch if whether is going to leave the page
        window.addEventListener('beforeunload', this.beforeWindowUnload)

        this.channel.onmessage = () => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };
        this.prognosticOutcomeSelected = this.prognosticOutcomePredicted;

        // TODO: this pulls a vaguely relevant curation entry, but it'll obviously be replaced later with a real reference
        HTTP.get(`/curation_entries?variant__gene__symbol=NRAS&page_size=1`).then((response) => {
            this.sample_curation_id = response.data.results[0].id;
        });

        this.getReviewData()
    },
    computed: {
        ...mapGetters({
            user: "currentUser"
        })
    },
    beforeRouteLeave (to, from, next) {
        console.log('beforeRouteLeave is run')
        this.$dialog.confirm('Do you want to proceed?')
        .then(function () {
            next(false);
        })
        .catch(function () {
            next(false);
        });
    },
    methods: {
        confirmLeave() {
            //return window.confirm('Do you really want to leave? You have unsaved changes.')
            return this.submitOptions()
        },
        confirmStayInDirtyForm() {
            //return this.form_dirty && !this.confirmLeave()
            return true && !this.confirmLeave()
        },
        beforeWindowUnload(e) {
            console.log('beforeWindowUnload is run')
            // Cancel the event
            e.preventDefault()
            // Chrome requires returnValue to be set
            e.returnValue = ''
        },
        submitOptions() {
            this.$confirm(
                {
                    message: `You are about to submit permanently the reviews for each of the ${this.evidence_counter} evidences of this variant. Are you sure?`,
                    button: {
                        yes: 'Submit permanently',
                        no: 'Continue to review'
                    },
                    /**
                     * Callback Function
                     * @param {Boolean} confirm 
                     */
                    callback: confirm => {
                        if (confirm) {
                            // save as a draft
                            this.submitReviews(false)
                        }
                    }
                }
            )
        },
        getReviewData() {
            const params={
                reviewer: this.user.user_id,
                var_id: this.variant.id,
            }
            HTTP.post(`/review_data`, params)
                .then((response) => {
                    //this.diseases = response.data.review_data
                    this.detectOwnReviews(response.data.review_data);
                    this.changeReviewStatusCheckboxes(this.diseases);
                })
                .catch((err) => {
                    log.warn(err);
                    //this.$snotify.error("Failed to fetch data");
                })
        },
        displayIcon(status) {
            if (status === true) {
                return "check-square-fill"
            }
            if (status === false) {
                return "x-square-fill"
            }
            return "square"
        },
        displayColor(status) {
            if (status === true) {
                return "color:blue;"
            }
            if (status === false) {
                return "color:red;"
            }
            return ""
        },
        onChange(curatorValues, reviewerValues) {
        // change review status (true if option matches that of curator, false if doesn't match)
            reviewerValues.status = curatorValues.annotatedEffect === reviewerValues.annotatedEffect && curatorValues.annotatedTier === reviewerValues.annotatedTier;
        },
        changeReviewStatusCheckboxes() {
            this.diseases.map(disease => {
                disease.evidences.map(evidence => {
                    this.onChange(evidence.curator, evidence.currentReview)
                })
            })
        },
        detectOwnReviews(diseases) {
            let evidence_counter = 0

            // iterate over every review to prefill inputs with current user's past reviews
            diseases.map(disease => {

                let evidences_expanders = []

                disease.evidences.map(evidence => {

                    evidence.reviews.map((review, index) => {
                        if (review.reviewer_id === this.user.user_id) {
                            if (review.draft === false) {this.submitted = true}
                            let currentReviewObj = {
                                "annotatedEffect": review.annotatedEffect,
                                "annotatedTier": review.annotatedTier,
                                "comment": review.comment,
                            }
                            evidence['currentReview'] = currentReviewObj

                            // store the evidence ID so when the user submit it, the request is a patch
                            this.selfReviewedEvidences[evidence.id] = review.id

                            // remove the review of current user so it is not displayed twice (already displayed currentReview from the currentReview object)
                            evidence.reviews.splice(index, 1)
                        }
                    })

                    if (evidence.reviews.length === 3) {
                        evidence.reviews.splice(2,1)
                    }

                    if (typeof evidence.currentReview === 'undefined') {
                        let currentReviewObj = {
                            "id": evidence.id,
                            "annotatedEffect": evidence.curator.annotatedEffect,
                            "annotatedTier": evidence.curator.annotatedTier,
                            "reviewer_id": this.user.user_id,
                            "status": null,
                            "comment": null,
                        }
                        evidence['currentReview'] = currentReviewObj
                    }

                    evidence_counter += 1
                    evidences_expanders.push(false)
                })
            
                this.expander_array.push({
                    'disease': true,
                    'evidences': evidences_expanders
                })
            
            })
            this.diseases = diseases
            this.evidence_counter = evidence_counter
        },
        missingComment() {
        // return true if at least one reviewed evidence doesn't match the curator's annotation while no comment has been written by the current reviewer
            for (var i = 0; i < this.diseases.length; i++) {
                const disease = this.diseases[i]
                for (var j = 0; j < disease["evidences"].length; j++) {
                    const evidence = disease["evidences"][j]
                    if (!evidence.currentReview.status) {
                    // review doesn't match curator's annotation
                        const regExp = /[a-zA-Z]/g;
                        if (evidence.currentReview.comment === null || ! regExp.test(evidence.currentReview.comment)) {
                        // no letter was found in the comment string
                            return true
                        }
                    }
                }
            }
            return false
        },
        submitReviews(draft) {

            // draft is a boolean that indicates whether the data is to be saved as a draft

            if (!draft && this.missingComment()) {
                this.$snotify.error(
                    "Please enter a comment for every review conflicting with that of curators", 
                    "",
                    { timeout: 5000 }
                );
                return false
            }

            // iterate over every review
            this.diseases.map(disease => {
                disease.evidences.map(evidence => {
                    if (
                        // check that dropdown options have been selected
                        evidence.currentReview.annotatedEffect !== "Not yet annotated" && evidence.currentReview.annotatedTier !== "Not yet annotated"
                    ) {
                        if (evidence.id in this.selfReviewedEvidences) {
                            let reviewID = this.selfReviewedEvidences[evidence.id]
                            HTTP.put(`/reviews/${reviewID}/`, this.reviewParams(evidence, draft))
                                .then((response) => {
                                    this.getReviewData()
                                    this.submitted = true
                                })
                                .catch((err) => {
                                    log.warn(err);
                                    this.$snotify.error("Failed to submit review");
                                })
                        } else {
                            //newReviews.push(this.reviewParams(evidence));
                            HTTP.post(`/reviews/`, this.reviewParams(evidence, draft))
                                .then((response) => {
                                    this.getReviewData()
                                    this.submitted = true
                                })
                                .catch((err) => {
                                    log.warn(err);
                                    this.$snotify.error("Failed to submit review");
                                })
                        }
                    }
                })
            })

            if (draft) {
                this.$snotify.success("Your review is saved as a draft.");
            } else {
                this.$snotify.success("Your reviews for this variant have been submitted.");
            }
            // Reset fields
            this.isEditMode = false;
        },
        reviewParams(evidence, draft) {
            // prepare a JSON containing parameters for CurationReview model
            const singleReviewJSON = {
                curation_evidence: evidence.id,
                reviewer: this.user.user_id,
                annotated_effect: evidence.currentReview.annotatedEffect,
                annotated_tier: evidence.currentReview.annotatedTier,
                comment: evidence.currentReview.comment,
                draft: draft
            }
            return singleReviewJSON
        }
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
    background-color: rgb(44, 62, 80);
    color: white;
    font-weight: bold;
    text-align: center;
    padding: 0.4rem;
}
</style>
