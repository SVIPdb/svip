<template>
    <div>
        <div v-for="(review) in diseases" :key="review">
            <b-card class="shadow-sm mb-3" align="left" no-body>
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="showDisease"/>
                    {{ review.disease }}
                </h6>
                <div v-for="(evidence,index) in review.evidences" :key="index">
                    <b-card-body class="p-0">
                        <transition name="slide-fade">
                            <div v-if="showDisease">
                                <b-card-text class="p-2 m-0">
                                    <b-row align-v="center">
                                        <b-col align="center" cols="1">
                                            <expander v-model="evidence.isOpen"/>
                                            {{ evidence.fullType }}
                                        </b-col>
                                        <b-col cols="2">
                                            <p class="mb-2" v-for="(effect,i) in evidence.effectOfVariant" :key="i">
                                                {{ effect.label }} ({{ effect.count ? effect.count : 'no' }}
                                                evidence(s))</p>
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
                                                <select-prognostic-outcome v-if="evidence.typeOfEvidence === 'Prognostic'"
                                                                        v-model="evidence.currentReview.annotatedEffect"
                                                                        @input="onChange(evidence.curator, evidence.currentReview)"></select-prognostic-outcome>
                                                <select-diagnostic-outcome v-if="evidence.typeOfEvidence === 'Diagnostic'"
                                                                        v-model="evidence.currentReview.annotatedEffect"
                                                                        @input="onChange(evidence.curator, evidence.currentReview)"></select-diagnostic-outcome>
                                                <select-predictive-therapeutic-outcome
                                                    v-if="evidence.typeOfEvidence === 'Predictive / Therapeutic'"
                                                    v-model="evidence.currentReview.annotatedEffect"
                                                    @input="onChange(evidence.curator, evidence.currentReview)"></select-predictive-therapeutic-outcome>
                                            </b-row>
                                            <b-row class="p-2">
                                                <select-tier v-model="evidence.currentReview.annotatedTier"
                                                            @input="onChange(evidence.curator, evidence.currentReview)"></select-tier>
                                            </b-row>
                                        </b-col>
                                        <b-col cols="1" align="center">
                                            <b-row class="justify-content-center">
                                                Review status
                                            </b-row>
                                            <b-row class="justify-content-center">
                                                <b-icon class="h4 mb-2 m-1"
                                                        :style="displayColor(evidence.currentReview.status)"
                                                        :icon="displayIcon(evidence.currentReview.status)"></b-icon>
                                                <b-icon v-for="(review,key) in evidence.reviews" :key="key"
                                                        class="h4 mb-2 m-1" :style="displayColor(review.status)"
                                                        :icon="displayIcon(review.status)"></b-icon>
                                            </b-row>
                                        </b-col>
                                        <b-col cols="4">
                                            <b-textarea
                                                :disabled="evidence.currentReview.status"
                                                class="summary-box" 
                                                rows="3"
                                                placeholder="Comment..."
                                                v-model="evidence.currentReview.comment"
                                            >
                                            </b-textarea>
                                        </b-col>
                                    </b-row>
                                </b-card-text>
                            </div>
                        </transition>
                        <transition name="slide-fade">
                            <div v-if="evidence.isOpen">
                                <b-card-footer class="pt-0 pb-0 pl-3 pr-3 fluid">
                                    <b-row align-v="center" v-for="(curation,i) in evidence.curations" :key="i">
                                        <b-col class="border p-2">PMID:
                                            <b-link target="_blank" active
                                                    :href="`https://pubmed.ncbi.nlm.nih.gov/${curation.pmid}`">
                                                {{ curation.pmid }}
                                            </b-link>
                                        </b-col>
                                        <b-col class="border p-2">{{ curation.effect }}</b-col>
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
                    </b-card-body>
                    <hr v-if="showDisease"/>
                </div>
            </b-card>
        </div>
        <b-button class="float-right" @click="submitReviews()">
            Submit review
        </b-button>
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
            diseases_test: [
                {
                    disease: "Aggressive fibromatosis",
                    evidences: [
                        {
                            isOpen: false,
                            typeOfEvidence: "Prognostic",
                            effectOfVariant: [
                                {
                                    label: "Good outcome",
                                    count: 4
                                },
                                {
                                    label: "Intermediate",
                                    count: 2
                                },
                                {
                                    label: "Poor outcome",
                                    count: 1
                                }
                            ],
                            curations: [
                                {
                                    id: 1,
                                    pmid: 1,
                                    effect: "Good outcome",
                                    support: "Strong",
                                    comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed fringilla rutrum erat at consequat. Sed eu pellentesque massa, et molestie magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae sagittis est. Mauris sed quam vitae velit varius aliquam. In hac habitasse platea dictumst. Nam est metus, rhoncus non lacinia eget, rhoncus volutpat nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras ac posuere urna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque sit amet iaculis dui. In pharetra feugiat nisl, in maximus libero. Suspendisse potenti."
                                },
                                {
                                    id: 2,
                                    pmid: 2,
                                    effect: "Good outcome",
                                    support: "Low",
                                    comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed fringilla rutrum erat at consequat. Sed eu pellentesque massa, et molestie magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae sagittis est. Mauris sed quam vitae velit varius aliquam. In hac habitasse platea dictumst. Nam est metus, rhoncus non lacinia eget, rhoncus volutpat nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras ac posuere urna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque sit amet iaculis dui. In pharetra feugiat nisl, in maximus libero. Suspendisse potenti."
                                },
                                {
                                    id: 3,
                                    pmid: 3,
                                    effect: "Good outcome",
                                    support: "Low",
                                    comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed fringilla rutrum erat at consequat. Sed eu pellentesque massa, et molestie magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae sagittis est. Mauris sed quam vitae velit varius aliquam. In hac habitasse platea dictumst. Nam est metus, rhoncus non lacinia eget, rhoncus volutpat nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras ac posuere urna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque sit amet iaculis dui. In pharetra feugiat nisl, in maximus libero. Suspendisse potenti."
                                },
                                {
                                    id: 4,
                                    pmid: 4,
                                    effect: "Intermediate",
                                    support: "Low",
                                    comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed fringilla rutrum erat at consequat. Sed eu pellentesque massa, et molestie magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae sagittis est. Mauris sed quam vitae velit varius aliquam. In hac habitasse platea dictumst. Nam est metus, rhoncus non lacinia eget, rhoncus volutpat nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras ac posuere urna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque sit amet iaculis dui. In pharetra feugiat nisl, in maximus libero. Suspendisse potenti."
                                },
                                {
                                    id: 5,
                                    pmid: 5,
                                    effect: "Intermediate",
                                    support: "Low",
                                    comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed fringilla rutrum erat at consequat. Sed eu pellentesque massa, et molestie magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae sagittis est. Mauris sed quam vitae velit varius aliquam. In hac habitasse platea dictumst. Nam est metus, rhoncus non lacinia eget, rhoncus volutpat nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras ac posuere urna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque sit amet iaculis dui. In pharetra feugiat nisl, in maximus libero. Suspendisse potenti."
                                },
                                {
                                    id: 6,
                                    pmid: 6,
                                    effect: "Poor outcome",
                                    support: "Moderate",
                                    comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed fringilla rutrum erat at consequat. Sed eu pellentesque massa, et molestie magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae sagittis est. Mauris sed quam vitae velit varius aliquam. In hac habitasse platea dictumst. Nam est metus, rhoncus non lacinia eget, rhoncus volutpat nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras ac posuere urna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque sit amet iaculis dui. In pharetra feugiat nisl, in maximus libero. Suspendisse potenti."
                                }
                            ],
                            curator: {
                                annotatedEffect: "Unclear",
                                annotatedTier: "Tier IA: Included in Professional Guidelines"
                            },
                            currentReview: {
                                annotatedEffect: "Unclear", //Initial value should be the same as curator
                                annotatedTier: "Tier IA: Included in Professional Guidelines", //Initial value should be the same as curator
                                reviewer_id: "John Doe",
                                status: true,
                                comment: null
                            },
                            reviews: [
                                {
                                    reviewer_name: "Johnny Doe",
                                    status: false
                                },
                                {
                                    reviewer_name: "Jean Doe",
                                    status: null
                                }
                            ],
                            note: null
                        },
                        {
                            isOpen: false,
                            typeOfEvidence: "Diagnostic",
                            effectOfVariant: [
                                {
                                    label: "Associated with diagnosis",
                                    count: 1
                                },
                                {
                                    label: "Not associated with diagnosis",
                                    count: 1
                                },
                                {
                                    label: "Other",
                                    count: 0
                                }
                            ],
                            curations: [
                                {
                                    id: 7,
                                    pmid: 7,
                                    effect: "Associated with diagnosis",
                                    support: "Strong",
                                    comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed fringilla rutrum erat at consequat. Sed eu pellentesque massa, et molestie magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae sagittis est. Mauris sed quam vitae velit varius aliquam. In hac habitasse platea dictumst. Nam est metus, rhoncus non lacinia eget, rhoncus volutpat nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras ac posuere urna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque sit amet iaculis dui. In pharetra feugiat nisl, in maximus libero. Suspendisse potenti."
                                },
                                {
                                    id: 8,
                                    pmid: 8,
                                    effect: "Not associated with diagnosis",
                                    support: "Low",
                                    comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed fringilla rutrum erat at consequat. Sed eu pellentesque massa, et molestie magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae sagittis est. Mauris sed quam vitae velit varius aliquam. In hac habitasse platea dictumst. Nam est metus, rhoncus non lacinia eget, rhoncus volutpat nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras ac posuere urna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque sit amet iaculis dui. In pharetra feugiat nisl, in maximus libero. Suspendisse potenti."
                                }
                            ],
                            curator: {
                                annotatedEffect: "Associated with diagnosis",
                                annotatedTier: "Tier IA: Included in Professional Guidelines"
                            },
                            currentReview: {
                                annotatedEffect: "Associated with diagnosis", //Initial value should be the same as curator
                                annotatedTier: "Tier IA: Included in Professional Guidelines", //Initial value should be the same as curator
                                reviewer_name: "John Doe",
                                status: true,
                                comment: null
                            },
                            reviews: [
                                {
                                    reviewer_name: "Johnny Doe",
                                    status: true
                                },
                                {
                                    reviewer_name: "Jean Doe",
                                    status: null
                                }
                            ],
                            note: null
                        },
                        {
                            isOpen: false,
                            typeOfEvidence: "Predictive / Therapeutic",
                            effectOfVariant: [
                                {
                                    label: "Drug 1",
                                    count: 1
                                }
                            ],
                            curations: [
                                {
                                    id: 9,
                                    pmid: 9,
                                    effect: "Responsive",
                                    support: "Moderate",
                                    comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed fringilla rutrum erat at consequat. Sed eu pellentesque massa, et molestie magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae sagittis est. Mauris sed quam vitae velit varius aliquam. In hac habitasse platea dictumst. Nam est metus, rhoncus non lacinia eget, rhoncus volutpat nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras ac posuere urna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque sit amet iaculis dui. In pharetra feugiat nisl, in maximus libero. Suspendisse potenti."
                                }
                            ],
                            curator: {
                                annotatedEffect: "Responsive",
                                annotatedTier: "Tier IA: Included in Professional Guidelines"
                            },
                            currentReview: {
                                annotatedEffect: "Responsive", //Initial value should be the same as curator
                                annotatedTier: "Tier IID: Case report", //Initial value should be the same as curator
                                reviewer_name: "John Doe",
                                status: true,
                                comment: null
                            },
                            reviews: [
                                {
                                    reviewer_name: "Johnny Doe",
                                    status: true
                                },
                                {
                                    reviewer_name: "Jean Doe",
                                    status: null
                                }
                            ],
                            note: null
                        },
                        {
                            typeOfEvidence: "Predictive / Therapeutic",
                            effectOfVariant: [
                                {
                                    label: "Drug 2",
                                    count: 3
                                }
                            ],
                            curations: [
                                {
                                    id: 10,
                                    pmid: 10,
                                    effect: "Other",
                                    support: "Low",
                                    comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed fringilla rutrum erat at consequat. Sed eu pellentesque massa, et molestie magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Fusce vitae sagittis est. Mauris sed quam vitae velit varius aliquam. In hac habitasse platea dictumst. Nam est metus, rhoncus non lacinia eget, rhoncus volutpat nulla. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Cras ac posuere urna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque sit amet iaculis dui. In pharetra feugiat nisl, in maximus libero. Suspendisse potenti."
                                }
                            ],
                            curator: {
                                annotatedEffect: "Responsive",
                                annotatedTier: "Tier IA: Included in Professional Guidelines"
                            },
                            currentReview: {
                                annotatedEffect: "Responsive", //Initial value should be the same as curator
                                annotatedTier: "Tier IID: Case report", //Initial value should be the same as curator
                                reviewer_name: "John Doe",
                                status: true,
                                comment: null
                            },
                            reviews: [
                                {
                                    reviewer_name: "Johnny Doe",
                                    status: true
                                },
                                {
                                    reviewer_name: "Jean Doe",
                                    status: null
                                }
                            ],
                            note: null
                        }
                    ]
                }
            ],
            selfReviewedEvidences: {},
            summary: null,
            history_entry_id: null,

            sample_curation_id: null,

            loading: false,
            error: null,
            channel: new BroadcastChannel("curation-update"),

            showDisease: true,
        };
    },
    mounted() {
        this.diseases.map(disease => {
            disease.evidences.map(evidence => {
                evidence["currentReview"]["reviewer_id"] = this.user.user_id
            })
        });
    },
    created() {
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
    methods: {
        getReviewData() {
            const params={
                reviewer: this.user.user_id,
                var_id: this.variant.id
            }

            HTTP.post(`/review_data`, params)
                .then((response) => {
                    this.diseases = response.data.review_data
                    this.detectOwnReviews();
                    this.changeReviewStatusCheckboxes();
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
                    // select only evidences for which an option has been selected
                    if (
                        evidence.currentReview.annotatedEffect !== "Not yet annotated" && evidence.currentReview.annotatedTier !== "Not yet annotated"
                    ) {
                        this.onChange(evidence.curator, evidence.currentReview)
                    }
                })
            })
        },
        detectOwnReviews() {
            // iterate over every review to prefill inputs with current user's past reviews
            this.diseases.map(disease => {
                disease.evidences.map(evidence => {
                    evidence.reviews.map(review => {
                        if (review.reviewer_id === this.user.user_id) {
                            evidence.currentReview.annotatedEffect = review.annotatedEffect;
                            evidence.currentReview.annotatedTier = review.annotatedTier;
                            evidence.currentReview.comment = review.comment;

                            // store the evidence ID so when the user submit it, the request is a patch
                            this.selfReviewedEvidences[evidence.id] = review.id
                        }
                    })
                })
            })
        },
        submitReviews() {
            //let newReviews = [];
            //let modifiedReviews = []

            // iterate over every review
            this.diseases.map(disease => {
                disease.evidences.map(evidence => {
                    if (
                        // check that dropdown options have been selected
                        evidence.currentReview.annotatedEffect !== "Not yet annotated" && evidence.currentReview.annotatedTier !== "Not yet annotated"
                    ) {
                        if (evidence.id in this.selfReviewedEvidences) {

                            //const singleReviewJSON = {
                            //    id: this.selfReviewedEvidences[evidence.id],
                            //    curation_evidence: evidence.id,
                            //    reviewer: this.user.user_id,
                            //    annotated_effect: evidence.currentReview.annotatedEffect,
                            //    annotated_tier: evidence.currentReview.annotatedTier,
                            //    comment: evidence.currentReview.comment
                            //}
                            //modifiedReviews.push(singleReviewJSON)

                            let reviewID = this.selfReviewedEvidences[evidence.id]
                            HTTP.put(`/reviews/${reviewID}/`, this.reviewParams(evidence))
                                .then((response) => {
                                    this.getReviewData()
                                })
                                .catch((err) => {
                                    log.warn(err);
                                    this.$snotify.error("Failed to submit review");
                                })
                        } else {
                            //newReviews.push(this.reviewParams(evidence));

                            HTTP.post(`/reviews/`, this.reviewParams(evidence))
                                .then((response) => {
                                    this.getReviewData()
                                })
                                .catch((err) => {
                                    log.warn(err);
                                    this.$snotify.error("Failed to submit review");
                                })

                        }
                    }
                })
            })

            this.$snotify.success("Your review has been saved");
            // Reset fields
            this.isEditMode = false;
            

            //if (modifiedReviews.length > 0) {
            //    HTTP.put(`/reviews/`, modifiedReviews)
            //        .then((response) => {
            //        })
            //        .catch((err) => {
            //            log.warn(err);
            //            this.$snotify.error("Failed to submit review");
            //        })
            //}

            //if (newReviews.length > 0) {
            //    // post new review
            //    HTTP.post(`/reviews/`, newReviews)
            //        .then((response) => {
            //            // Reset fields
            //            this.isEditMode = false;
            //            this.$snotify.success("Your review has been saved");
            //            //this.detectOwnReviews();
            //            //this.changeReviewStatusCheckboxes()
            //            this.getReviewData()
            //        })
            //        .catch((err) => {
            //            log.warn(err);
            //            this.$snotify.error("Failed to submit review");
            //        })
            //} else {
            //    // Reset fields
            //    this.isEditMode = false;
            //    this.detectOwnReviews();
            //    this.changeReviewStatusCheckboxes()
            //}

        },
        reviewParams(evidence) {
            // prepare a JSON containing parameters for CurationReview model
            const singleReviewJSON = {
                curation_evidence: evidence.id,
                reviewer: this.user.user_id,
                annotated_effect: evidence.currentReview.annotatedEffect,
                annotated_tier: evidence.currentReview.annotatedTier,
                comment: evidence.currentReview.comment
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
</style>
