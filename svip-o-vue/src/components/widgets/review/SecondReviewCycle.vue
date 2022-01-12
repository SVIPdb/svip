<template>
    <div>
        <div v-for="(review, review_index) in diseases" :key="'review' + review_index">
            <b-card class="shadow-sm mb-3" align="left" no-body>
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="showDisease"/>
                    {{ review.disease }}
                </h6>
                <div v-for="(evidence,evidence_index) in review.evidences" :key="'evidence' + evidence_index">
                    <b-card-body class="p-0">
                        <transition name="slide-fade">
                            <div v-if="showDisease">
                                <b-card-text class="p-2 m-0">
                                    <b-row align-v="center">
                                        <b-col align="center" cols="2">
                                            <expander v-model="evidence.isOpen"/>
                                            {{ evidence.fullType }}
                                        </b-col>
                                        <b-col cols="2">
                                            <p class="mb-2" v-for="(effect,i) in evidence.effectOfVariant" :key="i">
                                                {{ effect.label }}: {{ effect.count ? effect.count : 'no' }} evidence(s)
                                            </p>
                                        </b-col>
                                        <!--<b-col cols="2">
                                            <b-row class="p-2">
                                                <b-input v-model="evidence.curator.annotatedEffect" readonly/>
                                            </b-row>
                                            <b-row class="p-2">
                                                <b-input v-model="evidence.curator.annotatedTier" readonly/>
                                            </b-row>
                                        </b-col>-->

                                        <!--<b-col cols="2">
                                            <b-row class="p-2">
                                                <div v-if="evidence.myReview">
                                                    <b-input v-model="evidence.myReview.annotatedEffect" readonly/>
                                                </div>
                                            </b-row>
                                            <b-row class="p-2">
                                                <div v-if="evidence.myReview">
                                                    <b-input v-model="evidence.myReview.annotatedTier" readonly/>
                                                </div>
                                            </b-row>
                                        </b-col>-->

                                        <b-col cols="2">
                                            <!--Final curators' annotation:-->
                                            <b-row class="p-2">
                                                <b-input v-model="evidence.finalAnnotation.annotatedEffect" readonly/>
                                            </b-row>
                                            <b-row class="p-2">
                                                <b-input v-model="evidence.finalAnnotation.annotatedTier" readonly/>
                                            </b-row>
                                        </b-col>

                                        <b-col cols="6">
                                            <ReviewAgreementComment :value="evidence.newReview" @input="review => evidence.newReview = review"/>
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
import SelectAgreement from "@/components/widgets/review/forms/SelectAgreement";
import ReviewAgreementComment from "@/components/widgets/review/forms/reviewAgreementComment";
import { mapGetters } from "vuex";

const log = ulog("SecondReviewCycle");

export default {
    name: "SecondReviewCycle",
    components: {
        SelectAgreement,
        BIcon,
        BIconSquare,
        BIconCheckSquareFill,
        BIconXSquareFill,
        SelectPrognosticOutcome,
        SelectDiagnosticOutcome,
        SelectPredictiveTherapeuticOutcome,
        ReviewAgreementComment
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

            showDisease: true,
        };
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
                var_id: this.variant.id,
            }
            HTTP.post(`/review_data`, params)
                .then((response) => {
                    this.diseases = response.data.review_data
                    this.detectOwnReviews();
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
        detectOwnReviews() {
            // iterate over every review to prefill inputs with current user's past reviews
            this.diseases.map((disease, i) => {
                disease.evidences.map(evidence => {

                    evidence.reviews.map(review => {
                        if (review.reviewer_id === this.user.user_id) {
                            const myReview = {
                                'annotatedEffect': review.annotatedEffect,
                                'annotatedTier': review.annotatedTier,
                                'comment': review.comment
                            }
                            evidence['myReview'] = myReview
                        }
                    })

                    evidence.revised_reviews.map(rr => {
                        if (rr.reviewer_id === this.user.user_id) {
                            const newReview = {
                                "reviewer_id": this.user.user_id,
                                "agreement": rr.agreement,
                                'comment': rr.comment
                            }
                            evidence['newReview'] = newReview
                        }
                        // store the evidence ID so when the user submit it, the request is a patch
                        this.selfReviewedEvidences[evidence.id] = rr.id
                    })

                    if (typeof evidence['newReview'] === 'undefined') {
                        const newReview = {
                            "reviewer_id": this.user.user_id,
                            "agreement": 'I agree.',
                            'agree': true,
                            'comment': ''
                        }
                        evidence["newReview"] = newReview
                    }

                })
            })
        },
        missingComment() {
        // return true if a same evidence doesn't match the curators annotation and has not been given a comment
            for (var i = 0; i < this.diseases.length; i++) {
                const disease = this.diseases[i]
                for (var j = 0; j < disease["evidences"].length; j++) {
                    const evidence = disease["evidences"][j]
                    if (evidence.newReview.agreement === "I don't agree.") {
                    // review doesn't match curator's annotation
                        const regExp = /[a-zA-Z]/g;
                        if (evidence.newReview.comment === null || ! regExp.test(evidence.newReview.comment)) {
                        // no letter was found in the comment
                            return true
                        }
                    }
                }
            }
            return false
        },
        submitReviews() {

            //if (this.missingComment()) {
            //    this.$snotify.error(
            //        "Please enter a comment for every review conflicting with that of curators", 
            //        "",
            //        { timeout: 5000 }
            //    );
            //    return false
            //}

            // iterate over every review
            this.diseases.map(disease => {
                disease.evidences.map(evidence => {

                    if (evidence.id in this.selfReviewedEvidences) {
                        console.log('REREVIEWED')
                        let reviewID = this.selfReviewedEvidences[evidence.id]
                        HTTP.put(`/revised_reviews/${reviewID}/`, this.reviewParams(evidence))
                            .then((response) => {
                                this.getReviewData()
                            })
                            .catch((err) => {
                                log.warn(err);
                                this.$snotify.error("Failed to submit review");
                            })
                    } else {
                        console.log('FIRST REVIEW')
                        HTTP.post(`/revised_reviews/`, this.reviewParams(evidence))
                            .then((response) => {
                                this.getReviewData()
                            })
                            .catch((err) => {
                                log.warn(err);
                                this.$snotify.error("Failed to submit review");
                            })

                    }
                })
            })

            this.$snotify.success("Your review has been saved");
            // Reset fields
            this.isEditMode = false;
        },
        reviewParams(evidence) {
            // prepare a JSON containing parameters for CurationReview model
            const singleReviewJSON = {
                curation_evidence: evidence.id,
                reviewer: this.user.user_id,
                comment: evidence.newReview.comment,
                agree: evidence.newReview.agreement === 'I agree.'? true: false
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
