<template>
    <div>
        <div v-if="diseases.length > 0">

            <div v-for="(review, idx) in diseases" :key="idx">
                <b-card class="shadow-sm mb-3" align="left" no-body>
                    <h6
                        class="bg-primary text-light unwrappable-header p-2 m-0"
                    >
                        <expander v-model="expander_array[idx].disease" />
                        {{ review.disease }}
                    </h6>
                    <div
                        v-for="(evidence, index) in review.evidences"
                        :key="index"
                    >
                        <b-card-body class="p-0">
                            <transition name="slide-fade">
                                <div v-if="expander_array[idx].disease">
                                    <b-card-text class="p-2 m-0">
                                        <b-row align-v="center" align-h="left">
                                            <b-col
                                                align="left"
                                                cols="3"
                                                class="ml-4"
                                            >
                                                <expander
                                                    v-model="
                                                        expander_array[idx]
                                                            .evidences[index]
                                                    "
                                                />
                                                {{ evidence.fullType }}
                                            </b-col>
                                            <b-col cols="2" align="center">
                                                <p
                                                    class="mb-2"
                                                    v-for="(
                                                        effect, i
                                                    ) in evidence.effectOfVariant"
                                                    :key="i"
                                                >
                                                    {{ effect.label }}:
                                                    {{
                                                        effect.count
                                                            ? effect.count
                                                            : "no"
                                                    }}
                                                    evidence(s)
                                                </p>
                                            </b-col>
                                            <b-col cols="6" align="center">
                                                <div v-if="evidence.curator">
                                                    <b-row
                                                        class="p-1 d-flex justify-content-end flex-row no-wrap"
                                                    >
                                                    {{evidence}}
                                                    <br/>
                                                     <br/>
                                                    {{evidence.curator}}
                                                        <select-prognostic-outcome
                                                            v-if="
                                                                evidence.typeOfEvidence ===
                                                                'Prognostic'
                                                            "
                                                            v-model="
                                                                evidence.curator
                                                                    .annotatedEffect
                                                            "
                                                            :disabled="
                                                                not_submitted ||
                                                                already_reviewed
                                                            "
                                                            class="m-1 d-inline w-25"
                                                        ></select-prognostic-outcome>
                                                        <select-diagnostic-outcome
                                                            v-if="
                                                                evidence.typeOfEvidence ===
                                                                'Diagnostic'
                                                            "
                                                            v-model="
                                                                evidence.curator
                                                                    .annotatedEffect
                                                            "
                                                            :disabled="
                                                                not_submitted ||
                                                                already_reviewed
                                                            "
                                                            class="m-1 d-inline w-25"
                                                        ></select-diagnostic-outcome>
                                                        <select-predictive-therapeutic-outcome
                                                            v-if="
                                                                evidence.typeOfEvidence ===
                                                                'Predictive / Therapeutic'
                                                            "
                                                            v-model="
                                                                evidence.curator
                                                                    .annotatedEffect
                                                            "
                                                            :disabled="
                                                                not_submitted ||
                                                                already_reviewed
                                                            "
                                                            class="m-1 d-inline w-25"
                                                        ></select-predictive-therapeutic-outcome>
                                                        <select-various-outcome
                                                            v-if="
                                                                ![
                                                                    'Prognostic',
                                                                    'Diagnostic',
                                                                    'Predictive / Therapeutic',
                                                                ].includes(
                                                                    evidence.typeOfEvidence
                                                                )
                                                            "
                                                            v-model="
                                                                evidence.curator
                                                                    .annotatedEffect
                                                            "
                                                            :evidenceType="
                                                                evidence.typeOfEvidence
                                                            "
                                                            fieldType="effect"
                                                            :disabled="
                                                                not_submitted ||
                                                                already_reviewed
                                                            "
                                                            class="m-1 d-inline w-25"
                                                        >
                                                        </select-various-outcome>

                                                        <select-tier
                                                            v-if="
                                                                [
                                                                    'Prognostic',
                                                                    'Diagnostic',
                                                                ].includes(
                                                                    evidence.typeOfEvidence
                                                                )
                                                            "
                                                            v-model="
                                                                evidence.curator
                                                                    .annotatedTier
                                                            "
                                                            :disabled="
                                                                not_submitted ||
                                                                already_reviewed
                                                            "
                                                            class="m-1 d-inline w-50"
                                                        />
                                                        <select-therapeutic-tier
                                                            v-if="
                                                                [
                                                                    'Predictive / Therapeutic',
                                                                ].includes(
                                                                    evidence.typeOfEvidence
                                                                )
                                                            "
                                                            v-model="
                                                                evidence.curator
                                                                    .annotatedTier
                                                            "
                                                            :disabled="
                                                                not_submitted ||
                                                                already_reviewed
                                                            "
                                                            class="m-1 d-inline w-50"
                                                        />
                                                        <select-various-outcome
                                                            v-if="
                                                                ![
                                                                    'Prognostic',
                                                                    'Diagnostic',
                                                                    'Predictive / Therapeutic',
                                                                ].includes(
                                                                    evidence.typeOfEvidence
                                                                )
                                                            "
                                                            v-model="
                                                                evidence.curator
                                                                    .annotatedTier
                                                            "
                                                            :evidenceType="
                                                                evidence.typeOfEvidence
                                                            "
                                                            fieldType="tier"
                                                            :disabled="
                                                                not_submitted ||
                                                                already_reviewed
                                                            "
                                                            class="m-1 d-inline w-50"
                                                        />
                                                    </b-row>
                                                </div>
                                            </b-col>
                                        </b-row>
                                    </b-card-text>
                                    <transition name="slide-fade">
                                        <div
                                            v-if="
                                                expander_array[idx].evidences[
                                                    index
                                                ]
                                            "
                                        >
                                            <b-card-footer
                                                class="pt-0 pb-0 pl-3 pr-3 fluid"
                                            >
                                                <b-row
                                                    align-v="center"
                                                    v-for="(
                                                        curation, i
                                                    ) in evidence.curations"
                                                    :key="i"
                                                >
                                                    <b-col class="border p-2"
                                                        >PMID:
                                                        <b-link
                                                            target="_blank"
                                                            active
                                                            :href="`https://pubmed.ncbi.nlm.nih.gov/${curation.pmid}`"
                                                        >
                                                            {{ curation.pmid }}
                                                        </b-link>
                                                    </b-col>
                                                    <b-col class="border p-2">{{
                                                        curation.effect
                                                    }}</b-col>
                                                    <b-col class="border p-2">{{
                                                        curation.tier
                                                    }}</b-col>
                                                    <b-col class="border p-2">
                                                        Support:
                                                        {{ curation.support }}
                                                    </b-col>
                                                    <b-col class="border p-2">
                                                        <b-link
                                                            :to="{
                                                                name: 'view-evidence',
                                                                params: {
                                                                    action: curation.id,
                                                                },
                                                            }"
                                                            target="_blank"
                                                            alt="Link to evidence"
                                                            >Curation entry #{{
                                                                curation.id
                                                            }}
                                                        </b-link>
                                                    </b-col>

                                                    <b-col
                                                        class="border p-2"
                                                        cols="6"
                                                        >{{
                                                            curation.comment
                                                        }}</b-col
                                                    >
                                                </b-row>
                                            </b-card-footer>
                                        </div>
                                    </transition>
                                </div>
                            </transition>
                        </b-card-body>
                        <hr v-if="expander_array[idx].disease" />
                    </div>
                </b-card>
            </div>
            <b-button
                class="float-right"
                @click="submitCurations(true)"
                :disabled="not_submitted || already_reviewed"
            >
                Confirm annotation
            </b-button>
        </div>
        <b-navbar-text
            v-if="not_submitted"
            class="fixed-bottom submitted-bar"
            align="center"
        >
            THE CURATIONS FOR THIS VARIANT HAVE NOT BEEN SUBMITTED TO BE
            ANNOTATED YET.
        </b-navbar-text>
        <b-navbar-text
            v-if="already_reviewed"
            class="fixed-bottom submitted-bar"
            align="center"
        >
            THE FIRST ROUND OF ANNOTATION HAS ALREADY BEEN CONFIRMED AND THE
            VARIANT HAS ALREADY RECEIVED REVIEW(S).
        </b-navbar-text>
    </div>
</template>

<script>
/* eslint-disable */
// import fields from "@/data/curation/evidence/fields.js";
import { HTTP } from "@/router/http";
import BroadcastChannel from "broadcast-channel";
import {
    BIcon,
    BIconSquare,
    BIconCheckSquareFill,
    BIconXSquareFill,
} from "bootstrap-vue";
import ulog from "ulog";
import SelectPrognosticOutcome from "@/components/widgets/review/forms/SelectPrognosticOutcome";
import SelectDiagnosticOutcome from "@/components/widgets/review/forms/SelectDiagnosticOutcome";
import SelectPredictiveTherapeuticOutcome from "@/components/widgets/review/forms/SelectPredictiveTherapeuticOutcome";
import SelectVariousOutcome from "@/components/widgets/review/forms/SelectVariousOutcome";
import SelectTier from "@/components/widgets/review/forms/SelectTier";
import SelectTherapeuticTier from "@/components/widgets/review/forms/SelectTherapeuticTier";
import { mapGetters } from "vuex";

const log = ulog("SelectEffect");

export default {
    name: "SelectEffect",
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
        variant: { type: Object, required: false },
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
            support_fields: ["Strong", "Moderate", "Low"],
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
                "Other criteria",
            ],
            all_fields: {
                "Predictive / Therapeutic": {
                    effect: [
                        "Sensitive (in vitro)",
                        "Responsive",
                        "Resistant (in vitro)",
                        "Reduced sensitivity",
                        "Not responsive",
                        "Adverse response",
                        "Other",
                    ],
                    tier_criteria: [
                        "FDA/EMA/Swissmedic approved therapy (Tier IA)",
                        "Therapy included in Professional Guidelines such as NCCN or CAP (Tier IA)",
                        "Well-powered studies with consensus from experts in the field (Tier IB)",
                        "FDA/EMA/Swissmedic approved therapy for a different tumor type (Tier IIC)",
                        "Small published studies with some consensus (Tier IIC)",
                        "Population study (Tier IID)",
                        "Clinical trial (Tier IID)",
                        "Pre-clinical trial (Tier IID)",
                        "Case reports (Tier IID)",
                        "No convincing published evidence of drugs effect (Tier III)",
                        "Reported evidence supportive of benign/likely benign effect (Tier IV)",
                        "Other criteria",
                    ],
                },
                Prognostic: {
                    effect: [
                        "Good outcome",
                        "Poor outcome",
                        "Intermediate",
                        "Not associated with prognosis",
                    ],
                    tier_criteria: [
                        "Included in Professional Guidelines (Tier IA)",
                        "Well-powered studies with consensus from experts in the field (Tier IB)",
                        "Small published studies with some consensus (Tier IIC)",
                        "Population study (Tier IID)",
                        "Clinical trial (Tier IID)",
                        "Pre-clinical trial (Tier IID)",
                        "Case reports (Tier IID)",
                        "No convincing published evidence of drugs effect (Tier III)",
                        "Reported evidence supportive of benign/likely benign effect (Tier IV)",
                        "Other criteria",
                    ],
                },
                Diagnostic: {
                    effect: [
                        "Associated with diagnosis",
                        "Not associated with diagnosis",
                        "Other",
                    ],
                    tier_criteria: [
                        "Included in Professional Guidelines (Tier IA)",
                        "Well-powered studies with consensus from experts in the field (Tier IB)",
                        "Small published studies with some consensus (Tier IIC)",
                        "Population study (Tier IID)",
                        "Clinical trial (Tier IID)",
                        "Pre-clinical trial (Tier IID)",
                        "Case reports (Tier IID)",
                        "No convincing published evidence of drugs effect (Tier III)",
                        "Reported evidence supportive of benign/likely benign effect (Tier IV)",
                        "Other criteria",
                    ],
                },
                "Variant identification": {
                    effect: ["Unknown"],
                    tier_criteria: ["None"],
                },
                Function: {
                    effect: [
                        "Gain of function",
                        "Loss of function",
                        "Neomorphic",
                        "Unaltered function",
                        "Dominant negative",
                    ],
                    tier_criteria: [
                        "Well-established in vivo study",
                        "Well-established in vitro study",
                        "Prediction",
                        "Author statement",
                        "Other criteria",
                    ],
                },
                "Subcellular location": {
                    effect: [
                        "Loss of physiological location",
                        "Decreased physiological location",
                        "Increased physiological location",
                        "New location",
                        "Unaltered location",
                        "Other",
                    ],
                    tier_criteria: [
                        "Well-established in vivo study",
                        "Well-established in vitro study",
                        "Prediction",
                        "Author statement",
                        "Other criteria",
                    ],
                },
                Interaction: {
                    effect: [
                        "Loss of interaction with known partner(s)",
                        "Decreased interaction with known partner(s)",
                        "Increased interaction with known partner(s)",
                        "New interaction partner(s)",
                        "Other",
                    ],
                    tier_criteria: [
                        "Well-established in vivo study",
                        "Well-established in vitro study",
                        "Prediction",
                        "Author statement",
                        "Other criteria",
                    ],
                },
                Expression: {
                    effect: [
                        "Loss of expression",
                        "Decreased expression",
                        "Increased expression",
                        "Misexpression",
                        "Other",
                    ],
                    tier_criteria: [
                        "Well-established in vivo study",
                        "Well-established in vitro study",
                        "Author statement",
                        "Other criteria",
                    ],
                },
                "Response to drug": {
                    effect: [
                        "Loss of drug response",
                        "Decreased drug response",
                        "Increased drug response",
                        "Newly acquired drug response",
                        "Other",
                    ],
                    tier_criteria: [
                        "Well-established in vivo study",
                        "Well-established in vitro study",
                        "Prediction",
                        "Author statement",
                        "Other criteria",
                    ],
                },
            },
            already_reviewed: false,
            not_submitted: false,
            expander_array: [],
        };
    },
    mounted() {},
    created() {
        // Watch if use is going to leave the page
        window.addEventListener("beforeunload", this.beforeWindowUnload);

        // Check that this page is appropriate regarding current review stage of variant
        if (
            ["none", "loaded", "ongoing_curation"].includes(this.variant.stage)
        ) {
            this.not_submitted = true;
        } else if (
            [
                "1_review",
                "2_reviews",
                "conflicting_reviews",
                "to_review_again",
                "on_hold",
                "fully_reviewed",
            ].includes(this.variant.stage)
        ) {
            this.already_reviewed = true;
        }

        this.channel.onmessage = () => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };
        this.prognosticOutcomeSelected = this.prognosticOutcomePredicted;

        // TODO: this pulls a vaguely relevant curation entry, but it'll obviously be replaced later with a real reference
        HTTP.get(
            `/curation_entries?variant__gene__symbol=NRAS&page_size=1`
        ).then((response) => {
            this.sample_curation_id = response.data.results[0].id;
        });
        this.getReviewData();
    },
    computed: {
        ...mapGetters({
            user: "currentUser",
        }),
    },
    methods: {
        beforeWindowUnload(e) {
            // Cancel the event
            e.preventDefault();
            // Chrome requires returnValue to be set
            e.returnValue = "";
        },
        getReviewData() {
            const params = {
                reviewer: this.user.user_id,
                var_id: this.variant.id,
                only_clinical: false,
            };
            HTTP.post(`/review_data`, params)
                .then((response) => {
                    this.diseases = response.data.review_data;
                    this.prefillAnnotations(this.diseases);
                })
                .catch((err) => {
                    log.warn(err);
                    //this.$snotify.error("Failed to fetch data");
                });
        },
        prefillAnnotations(diseases) {
            diseases.map((disease) => {
                let evidences_expanders = [];
                disease.evidences.map((evidence) => {
                    // Check whether SIBAnnotation1 objects already exist in the database
                    if (typeof evidence.curator === "undefined") {
                        if (
                            [
                                "Prognostic",
                                "Diagnostic",
                                "Predictive / Therapeutic",
                            ].includes(evidence.typeOfEvidence)
                        ) {
                            this.annotateClinicalEvidence(evidence);
                        } else {
                            this.annotateNonClinicalEvidence(evidence);
                        }
                    }
                    evidences_expanders.push(false);
                });

                this.expander_array.push({
                    disease: true,
                    evidences: evidences_expanders,
                });
            });

            this.submitCurations(false);
        },
        annotateClinicalEvidence(evidence) {
            let effects = {};
            evidence.curations.map((curation) => {
                let support_score =
                    this.support_fields.length -
                    this.support_fields.indexOf(curation.support);
                let tier_score =
                    this.tier_fields.length -
                    this.tier_fields.indexOf(curation.tier);
                if (curation.effect in effects) {
                    effects[curation.effect]["curations"] += 1;
                    if (
                        support_score >
                        effects[curation.effect]["support_score"]
                    ) {
                        effects[curation.effect]["support_score"] =
                            support_score;
                    }
                    if (tier_score > effects[curation.effect]["tier_score"]) {
                        effects[curation.effect]["tier_score"] = tier_score;
                    }
                } else {
                    effects[curation.effect] = {
                        support_score: support_score,
                        tier_score: tier_score,
                        curations: 1,
                        effect: curation.effect,
                    };
                }
            });

            // trustedCuration is the currently most trusted association of effect & tier calculated from tier_level and number of such curations
            let trustedCuration = {
                effect: "",
                support_score: 0,
                tier_score: 0,
                curations: 0,
            };

            // score categories ranked by priority
            const scores = ["support_score", "curations", "tier_score"];
            const properties = [...scores, "effect"];

            for (const effect in effects) {
                for (var i = 0; i < scores.length; i++) {
                    // iterate to next score field only if current score values are equal (so score field with lower priority will settle which effect to keep)
                    // otherwise break and iterate to next effect
                    const effect_scores = effects[effect];
                    if (effect_scores[scores[i]] > trustedCuration[scores[i]]) {
                        properties.map((property) => {
                            trustedCuration[property] = effect_scores[property];
                        });
                        break;
                    } else if (
                        effect_scores[scores[i]] < trustedCuration[scores[i]]
                    ) {
                        break;
                    }
                }
            }
            evidence.curator = {};
            evidence.curator.annotatedEffect = trustedCuration["effect"];
            evidence.curator.annotatedTier =
                this.tier_fields[
                    this.tier_fields.length - trustedCuration["tier_score"]
                ];
        },
        annotateNonClinicalEvidence(evidence) {
            let effects = {};
            evidence.curations.map((curation) => {
                // tiers listed first are the most trustable ones (so we attribute a higher score)
                let tier_score =
                    this.all_fields[evidence.typeOfEvidence]["tier_criteria"]
                        .length -
                    this.all_fields[evidence.typeOfEvidence][
                        "tier_criteria"
                    ].indexOf(curation.tier);
                if (curation.effect in effects) {
                    // keep record of number of times the effect is listed
                    effects[curation.effect]["curations"] += 1;
                    // replace tier_score only if higher than the one already registered for this effect
                    if (tier_score > effects[curation.effect]["tier_score"]) {
                        effects[curation.effect]["tier_score"] = tier_score;
                    }
                } else {
                    effects[curation.effect] = {
                        curations: 1,
                        tier_score: tier_score,
                        effect: curation.effect,
                    };
                }
            });

            // trustedCuration is the currently most trusted association of effect & tier calculated from tier_level and number of such curations
            let trustedCuration = { effect: "", tier_score: 0, curations: 0 };

            // score categories ranked by priority (count is more important than tier)
            const scores = ["curations", "tier_score"];
            const properties = [...scores, "effect"];

            for (const effect in effects) {
                for (var i = 0; i < scores.length; i++) {
                    // iterate to next score field only if current score values are equal (so score field with lower priority will settle which effect to keep)
                    // otherwise break and iterate to next effect
                    const effect_scores = effects[effect];
                    if (effect_scores[scores[i]] > trustedCuration[scores[i]]) {
                        properties.map((property) => {
                            trustedCuration[property] = effect_scores[property];
                        });
                        break;
                    } else if (
                        effect_scores[scores[i]] < trustedCuration[scores[i]]
                    ) {
                        break;
                    }
                }
            }
            evidence.curator = {};
            evidence.curator.annotatedEffect = trustedCuration["effect"];
            evidence.curator.annotatedTier =
                this.all_fields[evidence.typeOfEvidence]["tier_criteria"][
                    this.all_fields[evidence.typeOfEvidence]["tier_criteria"]
                        .length - trustedCuration["tier_score"]
                ];
        },
        submitCurations(notify) {
            let evidences_data = [];

            this.diseases.map((disease) => {
                disease.evidences.map((evidence) => {
                    let evidence_obj = {
                        effect: evidence.curator.annotatedEffect,
                        tier: evidence.curator.annotatedTier,
                        evidence: evidence.id,
                    };

                    if (typeof evidence.curator.id !== "undefined") {
                        evidence_obj["id"] = evidence.curator.id;
                    }

                    evidences_data.push(evidence_obj);
                });
            });

            console.log(evidences_data);

            HTTP.post(`/sib_annotations_1`, evidences_data)
                .then((response) => {
                    console.log(`response: ${response.data}`);
                    if (notify) {
                        this.$snotify.success(
                            "Your curation(s) have been submitted to be reviewed"
                        );
                    }
                })
                .catch((err) => {
                    log.warn(err);
                    this.$snotify.error("Failed to submit curation");
                });
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

.submitted-bar {
    background-color: rgb(194, 45, 0);
    color: white;
    font-weight: bold;
    text-align: center;
    padding: 0.4rem;
}
</style>
