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
                                        <b-col align="center" cols="3">
                                            <expander v-model="evidence.isOpen"/>
                                            {{ evidence.fullType }}
                                        </b-col>
                                        <b-col cols="5">
                                            <p class="mb-2" v-for="(effect,i) in evidence.effectOfVariant" :key="i">
                                                {{ effect.label }}: {{ effect.count ? effect.count : 'no' }} evidence(s)
                                            </p>
                                        </b-col>
                                        <b-col cols="3">
                                            <!--<div v-if="evidence.curator">evidence.curator exists</div>
                                            <div v-if="evidence.reviews">evidence.reviews exists</div>-->
                                            <div v-if="evidence.curator">
                                                <b-row class="p-2">
                                                    <select-prognostic-outcome v-if="evidence.typeOfEvidence === 'Prognostic'"
                                                                            v-bind="evidence.curator.annotatedEffect"></select-prognostic-outcome>
                                                    <select-diagnostic-outcome v-if="evidence.typeOfEvidence === 'Diagnostic'"
                                                                            v-model="evidence.curator.annotatedEffect"></select-diagnostic-outcome>
                                                    <select-predictive-therapeutic-outcome
                                                        v-if="evidence.typeOfEvidence === 'Predictive / Therapeutic'"
                                                        v-model="evidence.curator.annotatedEffect"></select-predictive-therapeutic-outcome>
                                                </b-row>
                                                <b-row class="p-2">
                                                    <select-tier v-model="evidence.curator.annotatedTier"></select-tier>
                                                </b-row>
                                            </div>
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
        <b-button class="float-right" @click="submitCurations()">
            Confirm annotation
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

const log = ulog("SelectEffect");

export default {
    name: "SelectEffect",
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
        entryIDs: {type: String},
    },
    data() {
        return {
            temp: "Tier III: Author statement",
            diseases: [],
            selfReviewedEvidences: {},
            summary: null,
            history_entry_id: null,
            sample_curation_id: null,
            loading: false,
            error: null,
            channel: new BroadcastChannel("curation-update"),
            showDisease: true,
            support_fields: [
                "Strong",
                "Moderate",
                "Low"
            ],
            tier_fields: [
                "Tier IA: Included in Professional Guidelines",
                "Tier IA: FDA/EMA/Swissmedic approved therapy",
                "Tier IA: Therapy included in Professional Guidelines such as NCCN or CAP",
                "Tier IB: Well-powered studies with consensus from experts in the field",
                "Tier IIC: FDA/EMA/Swissmedic approved therapy for a different tumor type",
                "Tier IIC: Small published studies with some consensus",
                "Tier IID: Population study",
                "Tier IID: Clinical trial",
                "Tier IID: Pre-clinical trial",
                "Tier IID: Case reports",
                "Tier III: No convincing published evidence of drugs effect",
                "Tier IV: Reported evidence supportive of benign/likely benign effect",
                "Other criteria"
            ]
        };
    },
    mounted() {},
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
                entry_ids: this.entryIDs.split(/[ ,]+/)
            }
            HTTP.post(`/review_data`, params)
                .then((response) => {
                    this.diseases = response.data.review_data
                    this.prefillAnnotations();
                })
                .catch((err) => {
                    log.warn(err);
                    //this.$snotify.error("Failed to fetch data");
                })
        },
        prefillAnnotations() {
            this.diseases.map(disease => {
                disease.evidences.map(evidence => {

                    // Check whether SIBAnnotation1 objects already exist in the database
                    if (typeof evidence.curator === 'undefined') {
                        console.log('FLAG')

                        let effects = {}
                        evidence.curations.map(curation => {
                            let support_score = this.support_fields.length - this.support_fields.indexOf(curation.support)
                            let tier_score = this.tier_fields.length - this.tier_fields.indexOf(curation.tier)
                            if (curation.effect in effects) {
                                effects[curation.effect]["curations"] += 1
                                if (support_score > effects[curation.effect]["support_score"]) {
                                    effects[curation.effect]["support_score"] = support_score
                                }
                                if (tier_score > effects[curation.effect]["tier_score"]) {
                                    effects[curation.effect]["tier_score"] = tier_score
                                }
                            } else {
                                effects[curation.effect] = {
                                    "support_score": support_score,
                                    "tier_score": tier_score,
                                    "curations": 1,
                                    "effect": curation.effect
                                }
                            }
                        })
                        let trustedCuration = {'effect': '', 'support_score': 0, 'tier_score': 0, "curations": 0}
                        const scores = ['support_score', 'curations', 'tier_score']
                        const properties = [...scores, 'effect']

                        for (const effect in effects) {
                            for (var i = 0; i < scores.length; i++) {
                                const effect_scores = effects[effect]
                                if (effect_scores[scores[i]] > trustedCuration[scores[i]]) {
                                    
                                    properties.map(property => {
                                        trustedCuration[property] = effect_scores[property]
                                    })

                                    break;
                                } else if (effect_scores[scores[i]] < trustedCuration[scores[i]]) {
                                    break;
                                }
                            }
                        }
                        evidence.curator = []
                        evidence.curator.annotatedEffect = trustedCuration['effect']
                        evidence.curator.annotatedTier = this.tier_fields[this.tier_fields.length - trustedCuration['tier_score']]

                        //this.submitOneEvidence(evidence)
                    }






                    //if (evidence.curator.annotatedEffect === "Not yet annotated" || evidence.curator.annotatedTier === "Not yet annotated") {

                    //    let effects = {}
                    //    evidence.curations.map(curation => {
                    //        let support_score = this.support_fields.length - this.support_fields.indexOf(curation.support)
                    //        let tier_score = this.tier_fields.length - this.tier_fields.indexOf(curation.tier)
                    //        if (curation.effect in effects) {
                    //            effects[curation.effect]["curations"] += 1
                    //            if (support_score > effects[curation.effect]["support_score"]) {
                    //                effects[curation.effect]["support_score"] = support_score
                    //            }
                    //            if (tier_score > effects[curation.effect]["tier_score"]) {
                    //                effects[curation.effect]["tier_score"] = tier_score
                    //            }
                    //        } else {
                    //            effects[curation.effect] = {
                    //                "support_score": support_score,
                    //                "tier_score": tier_score,
                    //                "curations": 1,
                    //                "effect": curation.effect
                    //            }
                    //        }
                    //    })
                    //    let trustedCuration = {'effect': '', 'support_score': 0, 'tier_score': 0, "curations": 0}
                    //    const scores = ['support_score', 'curations', 'tier_score']
                    //    const properties = [...scores, 'effect']

                    //    for (const effect in effects) {
                    //        for (var i = 0; i < scores.length; i++) {
                    //            const effect_scores = effects[effect]
                    //            if (effect_scores[scores[i]] > trustedCuration[scores[i]]) {
                                    
                    //                properties.map(property => {
                    //                    trustedCuration[property] = effect_scores[property]
                    //                })

                    //                break;
                    //            } else if (effect_scores[scores[i]] < trustedCuration[scores[i]]) {
                    //                break;
                    //            }
                    //        }
                    //    }
                    //    evidence.curator.annotatedEffect = trustedCuration['effect']
                    //    evidence.curator.annotatedTier = this.tier_fields[this.tier_fields.length - trustedCuration['tier_score']]

                    //    this.submitOneEvidence(evidence)
                    //}
                })
            })
        },
        submitCurations() {
            this.diseases.map(disease => {
                disease.evidences.map(evidence => {
                    this.submitOneEvidence(evidence)
                })
            })
            this.$snotify.success("Your curation(s) has been submitted to be reviewed");
        },
        submitOneEvidence(evidence) {
            const annotation = {
                'effect': evidence.curator.annotatedEffect,
                'tier': evidence.curator.annotatedTier,
                'evidence': evidence.id
            }

            // check wether an SIBAnnotation1 instance already exists in the DB
            if (typeof evidence.curator.id === 'undefined') {
                HTTP.post(`/sib_annotations_1/`, annotation)
                    .then((response) => {
                        console.log(`response: ${response}`)
                    })
                    .catch((err) => {
                        log.warn(err);
                        this.$snotify.error("Failed to submit curation");
                    })
            } else {
                HTTP.put(`/sib_annotations_1/${evidence.curator.id}/`, annotation)
                    .then((response) => {
                        console.log(`response: ${response}`)
                    })
                    .catch((err) => {
                        log.warn(err);
                        this.$snotify.error("Failed to submit curation");
                    })
            }
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
