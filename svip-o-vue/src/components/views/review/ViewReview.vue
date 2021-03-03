<template>
    <div class="container-fluid">
        <b-card v-for="(review, index) in reviews" :key="index" class="shadow-sm mb-3" no-body>
            <b-card-header class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="review[0].review_status" />
                    {{ index }}
                    <transition name="slide-fade">
                        <span v-if="!review[0].review_status">
                             - (
                            <span v-for="(analysis, index) in review" :key="index" align="bottom">
                                {{ analysis.type_of_evidence }}:
                                <b-icon v-if="review[index].sib_annotation_outcome === review[index].reviewer_annotation_outcome && review[index].sib_annotation_trust === review[index].reviewer_annotation_trust" style="color:blue; background-color: white; border-radius: 5px;" class="h5 m-0 ml-1 mr-1" icon="check"></b-icon>
                                <b-icon v-else-if="review[index].sib_annotation_outcome !== review[index].reviewer_annotation_outcome || review[index].sib_annotation_trust !== review[index].reviewer_annotation_trust" style="color:red; background-color: white; border-radius: 5px;" class="h5 m-0 ml-1 mr-1" icon="x"></b-icon>
                            </span>)
                        </span>
                    </transition>
                </h6>
            </b-card-header>
            
            <transition name="slide-fade">
                <b-card-text v-if="review[0].review_status" class="mb-n3">
                    <b-table :fields="fields" :items="Object.values(review)" thead-class="text-uppercase" :bordered="true">

                        <template v-slot:cell(type_of_evidence)="data">
                            <span>{{ data.item.type_of_evidence }}</span>
                        </template>

                        <template v-slot:cell(sib_annotation)="data">
                            <div class="pb-2">
                                <span>{{ data.item.sib_annotation_outcome }}</span>
                            </div>
                            <div class="pt-2">
                                <span>{{ data.item.sib_annotation_trust }}</span>
                            </div>
                        </template>

                        <template v-slot:cell(reviewer_annotation)="data">
                            <div class="pb-2">
                                <span v-if="data.item.reviewer_annotation_outcome === data.item.sib_annotation_outcome">{{ data.item.reviewer_annotation_outcome }}</span>
                                <span v-if="data.item.reviewer_annotation_outcome !== data.item.sib_annotation_outcome" style="font-weight: bold; color: red;">{{ data.item.reviewer_annotation_outcome }}</span>
                            </div>
                            <div class="pt-2">
                                <span v-if="data.item.reviewer_annotation_trust === data.item.sib_annotation_trust">{{ data.item.reviewer_annotation_trust }}</span>
                                <span v-if="data.item.reviewer_annotation_trust !== data.item.sib_annotation_trust" style="font-weight: bold; color: red;">{{ data.item.reviewer_annotation_trust }}</span>
                            </div>
                        </template>

                        <template v-slot:cell(review_status)="data">
                            <div align="center">
                                <b-icon v-if="data.item.sib_annotation_outcome === data.item.reviewer_annotation_outcome && data.item.sib_annotation_trust === data.item.reviewer_annotation_trust" style="color:blue;" class="h3 mb-2 m-1" icon="check"></b-icon>
                                <b-icon v-else-if="data.item.sib_annotation_outcome !== data.item.reviewer_annotation_outcome || data.item.sib_annotation_trust !== data.item.reviewer_annotation_trust" style="color:red;" class="h3 mb-2 m-1" icon="x"></b-icon>
                            </div>
                        </template>

                        <template v-slot:cell(comment)="data">
                            <span>{{ data.item.comment }}</span>
                        </template>

                    </b-table>
                </b-card-text>
            </transition>
        </b-card>

        <modify-review v-for="(disease, index) in diseases" :key="index" :label="index" :disease="disease" />

    </div>
</template>

<script>
/* eslint-disable */
import { HTTP } from "@/router/http";
import { var_to_position } from "@/utils";
import { BIcon, BIconQuestion, BIconCheck, BIconX } from "bootstrap-vue";
import ModifyReview from "@/components/widgets/review/ModifyReview";
import ulog from "ulog";

const log = ulog("ViewReview");

export default {
    name: "ViewReview",
    components: {
        BIcon,
        BIconQuestion,
        BIconCheck,
        BIconX,
        ModifyReview,
    },
    props: {
        review: {type: Object, required: false}
    },
    data() {
        return {
            fields: [
                {
                    key: "type_of_evidence",
                    label: "Type of evidence",
                    thStyle: "width: 10%;"
                },
                {
                    key: "sib_annotation",
                    label: "SIB annotation",
                    thStyle: "width: 25%;"
                },
                {
                    key: "reviewer_annotation",
                    label: "Reviewer annotation",
                    thStyle: "width: 25%;"
                },
                {
                    key: "review_status",
                    label: "Review status",
                    thStyle: "width: 5%;"
                },
                {
                    key: "comment",
                    label: "Comment",
                    thStyle: "width: 35%;"
                },
            ],
            reviews: {
                "Sylvie Müller": [
                    {
                        review_status: false, // Ivo : is it really that bad to put it here? PS: this field can be in every object, I only work with the first one...
                        type_of_evidence: "Prognostic",
                        sib_annotation_outcome: "Intermediate",
                        sib_annotation_trust: "Tier IID: Population study",
                        reviewer_annotation_outcome: "Poor outcome",
                        reviewer_annotation_trust: "Tier IID: Population study",
                        comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", 
                    },
                    {
                        type_of_evidence: "Diagnostic",
                        sib_annotation_outcome: "Associated with diagnosis",
                        sib_annotation_trust: "Tier IA: Included in Professional Guidelines",
                        reviewer_annotation_outcome: "Associated with diagnosis",
                        reviewer_annotation_trust: "Tier IID: Population study",
                        comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                    },
                    {
                        type_of_evidence: "Predictive / Therapeutic - Bafilomycin",
                        sib_annotation_outcome: "Resistant (in vitro)",
                        sib_annotation_trust: "Tier IID: Pre-clinical study",
                        reviewer_annotation_outcome: "Resistant (in vitro)",
                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                        comment: "",
                    },
                    {
                        type_of_evidence: "Predictive / Therapeutic - Sorafenib",
                        sib_annotation_outcome: "Sensitive (in vitro)",
                        sib_annotation_trust: "Tier IID: Pre-clinical study",
                        reviewer_annotation_outcome: "Sensitive (in vitro)",
                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                        comment: "",
                    },
                ],
                "David Roch": [
                    {
                        review_status: false,
                        type_of_evidence: "Prognostic",
                        sib_annotation_outcome: "Intermediate",
                        sib_annotation_trust: "Tier IID: Population study",
                        reviewer_annotation_outcome: "Poor outcome",
                        reviewer_annotation_trust: "Tier IID: Population study",
                        comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
                    },
                    {
                        type_of_evidence: "Diagnostic",
                        sib_annotation_outcome: "Associated with diagnosis",
                        sib_annotation_trust: "Tier IA: Included in Professional Guidelines",
                        reviewer_annotation_outcome: "Associated with diagnosis",
                        reviewer_annotation_trust: "Tier IA: Included in Professional Guidelines",
                        comment: "",
                    },
                    {
                        type_of_evidence: "Predictive / Therapeutic - Bafilomycin",
                        sib_annotation_outcome: "Resistant (in vitro)",
                        sib_annotation_trust: "Tier IID: Pre-clinical study",
                        reviewer_annotation_outcome: "Resistant (in vitro)",
                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                        comment: "",
                    },
                    {
                        type_of_evidence: "Predictive / Therapeutic - Sorafenib",
                        sib_annotation_outcome: "Sensitive (in vitro)",
                        sib_annotation_trust: "Tier IID: Pre-clinical study",
                        reviewer_annotation_outcome: "Sensitive (in vitro)",
                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                        comment: "",
                    },
                ],
                "Edmond Latifi": [
                    {
                        review_status: false,
                        type_of_evidence: "Prognostic",
                        sib_annotation_outcome: "Intermediate",
                        sib_annotation_trust: "Tier IID: Population study",
                        reviewer_annotation_outcome: "Poor outcome",
                        reviewer_annotation_trust: "Tier IID: Population study",
                        comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
                    },
                    {
                        type_of_evidence: "Diagnostic",
                        sib_annotation_outcome: "Associated with diagnosis",
                        sib_annotation_trust: "Tier IA: Included in Professional Guidelines",
                        reviewer_annotation_outcome: "Associated with diagnosis",
                        reviewer_annotation_trust: "Tier IA: Included in Professional Guidelines",
                        comment: "",
                    },
                    {
                        type_of_evidence: "Predictive / Therapeutic - Bafilomycin",
                        sib_annotation_outcome: "Resistant (in vitro)",
                        sib_annotation_trust: "Tier IID: Pre-clinical study",
                        reviewer_annotation_outcome: "Resistant (in vitro)",
                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                        comment: ""
                    },
                    {
                        type_of_evidence: "Predictive / Therapeutic - Sorafenib",
                        sib_annotation_outcome: "Sensitive (in vitro)",
                        sib_annotation_trust: "Tier IID: Pre-clinical study",
                        reviewer_annotation_outcome: "Sensitive (in vitro)",
                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                        comment: ""
                    },
                ]
            },

            diseases: {
                "Aggressive fibromatosis": {
                    "Prognostic": [
                        {
                            outcome: [
                                { label: "Good outcome", nb_evidence: 0 },
                                { label: "Intermediate", nb_evidence: 2 },
                                { label: "Poor outcome", nb_evidence: 1 },
                            ],
                            sib_annotation_outcome: "Intermediate",
                            sib_annotation_trust: "Tier IID: Population study",
                            reviewer_annotation_outcome: "Intermediate",
                            reviewer_annotation_trust: "Tier IID: Population study",
                            review_other_status: [
                                { status: 2, review_id: 1, reviewer: "Sylvie Müller" },
                                { status: 2, review_id: 2, reviewer: "David Roch" },
                            ],
                            comment: "",
                            evidence: [
                                { reject: false, outcome: "Intermediate", evidence_link: "282", pmid_link: "23960186", evidence_comment: "The study involved 115 patients diagnosed with aggressive fibromatosis, who underwent surgical resection of the tumors. CTNNB1 exon 3 mutations were detected in 75% of the tumors, including T41A in 46%. At a median follow-up of 31 months, 5-year recurrence-free survival was slightly, although not statistically significantly, worse for patients with CTNNB1 mutated tumors than for those with wild-type tumors (58% vs. 74%, respectively). The specific CTNNB1 codon mutation (A41T or S45F) did not correlate with the risk for recurrence." },
                                { reject: false, outcome: "Intermediate", evidence_link: "281", pmid_link: "22744289", evidence_comment: "In 47 patients diagnosed with desmoid-type fibromatosis, CTNNB1 exon 3 mutation were identified in 39 cases (83 %), predominantly T41A (77 %). There was no correlation between any specific CTNNB1 mutation and clinical outcome." },
                                { reject: false, outcome: "Poor outcome", evidence_link: "284", pmid_link: "20197769", evidence_comment: "Tumors from 101 patients, diagnosed with extra-abdominal fibromatosis, were studied. 87% of the tumors exhibited CTNNB1 exon 3 mutations, including T41A in 39.5% of the cases. The patient underwent surgery, followed in most cases by radiotherapy. During a median 62 month follow-up period, 51 patients relapsed, 1 with a wild-type CTNNB1 tumor and 50 with  mutated CTNNB1. The 5-year recurrence-free survival was significantly shorter in all mutated CTNNB1 tumors, including T41A, compared with wild-type tumors, but this poor outcome could not be related to a specific genotype, as there was no significant difference between T41A, S45F, or S45P mutants." },
                            ],
                            show_review_status: false
                        },    
                    ],
                    "Diagnostic": [
                        {
                            outcome: [
                                { label: "Associated with diagnosis", nb_evidence: 1 },
                                { label: "Not associated with diagnosis", nb_evidence: 0 },
                                { label: "Other", nb_evidence: 0 },
                            ],
                            sib_annotation_outcome: "Associated with diagnosis",
                            sib_annotation_trust: "Tier IA: Included in Professional Guidelines",
                            reviewer_annotation_outcome: "Associated with diagnosis",
                            reviewer_annotation_trust: "Tier IA: Included in Professional Guidelines",
                            review_other_status: [
                                { status: 2, review_id: 3, reviewer: "Sylvie Müller" },
                                { status: 0, review_id: 4, reviewer: "David Roch" },
                            ],
                            comment: "",
                            evidence: [
                                { reject: false, outcome: "Associated with diagnosis", evidence_link: "280", pmid_link: "28961825", evidence_comment: 'Approximately 85%–90% of desmoid-type fibromatosis (DF) harbors mutations in the CTNNB1 gene (predominantly T41A in roughly 50% of the cases), leading to nuclear accumulation of CTNNB1-encoded protein. CTNNB1 mutations and APC mutations appear to be mutually exclusive in DF, thus, detection of a somatic CTNNB1 mutation may help to exclude a syndromal condition. Vice versa, CTNNB1 wild-type status in DF should raise suspicion for familial adenomatous polyposis (FAP), with more extensive diagnostic clinical work-up (e.g. colonoscopy). Mutation analysis of CTNNB1 has been proposed as a specific diagnostic tool for establishing DF diagnosis, particularly in challenging or diagnostically ambiguous cases (recommendation issued  by the European Consensus Initiative between Sarcoma PAtients EuroNet (SPAEN) and European Organization for Research and Treatment of Cancer (EORTC)/Soft Tissue and Bone Sarcoma Group (STBSG)).' },
                            ],
                            show_review_status: false
                        },
                    ],
                    "Predictive / Therapeutic": [
                        {
                            outcome: [
                                { label: "Bafilomycin", nb_evidence: 1 }
                            ],
                            sib_annotation_outcome: "Resistant (in vitro)",
                            sib_annotation_trust: "Tier IID: Pre-clinical study",
                            reviewer_annotation_outcome: "Resistant (in vitro)",
                            reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                            review_other_status: [
                                { status: 1, review_id: 5, reviewer: "Sylvie Müller" },
                                { status: 1, review_id: 6, reviewer: "David Roch" },
                            ],
                            comment: "",
                            evidence: [
                                { reject: false, outcome: "Resistant (in vitro)", evidence_link: "283", pmid_link: "30980399", evidence_comment: "Treatment of T41A-mutated primary desmoid tumor cells with bafilomycin did not have any effect." },
                            ],
                            show_review_status: false
                        },
                        {
                            outcome: [
                                { label: "Sorafenib", nb_evidence: 1 }
                            ],
                            sib_annotation_outcome: "Sensitive (in vitro)",
                            sib_annotation_trust: "Tier IID: Pre-clinical study",
                            reviewer_annotation_outcome: "Sensitive (in vitro)",
                            reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                            review_other_status: [
                                { status: 0, review_id: 5, reviewer: "Sylvie Müller" },
                                { status: 1, review_id: 6, reviewer: "David Roch" },
                            ],
                            comment: "",
                            evidence: [
                                { reject: false, outcome: "Sensitive (in vitro)", evidence_link: "285", pmid_link: "30980399", evidence_comment: "In primary cell cultures, T41A-mutated desmoid cells were sensitive - in terms of cell viability (apoptosis), invasion and migration - to sorafenib." },
                            ],
                            show_review_status: false
                        }
                    ]
                }
            }
        }
    },
    created() {
        /* Ivo : Adapt this to the review?
        this.refresh();

        // deal with updates from people editing curation entries, which could change pathogenicity/clinical sig.
        this.channel.onmessage = () => {
            this.refresh();
        };*/
    },
    methods: {
        /* Ivo : Adapt this to the review?
        refresh() {
            HTTP.get(this.variantInfoUrl).then(response => {
                const { disease, pathogenic, clinical_significance } = response.data;
                this.disease_name = disease && disease.name;
                this.pathogenicity = pathogenic;
                this.clinical_significance = clinical_significance;
            });

        }*/
    },
    computed: {}
};
</script>

<style>
.table td {
    vertical-align: middle;
}

/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
    transition: all 0.5s ease;
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
<style>
.ajax-loader-bar {
    display: none !important;
}
</style>
