<template>
    <div class="container-fluid">
        <!-- Ivo : To change? -->
        <CuratorVariantInformations :variant="variant" :disease_id="disease_id"/>

        <!-- Ivo : Change name to "VariantSummaryReview"? -->
        <ModifyVariantSummary :variant="variant" :comments="summary.comments"/>

        <div v-for="(disease) in diseases" :key="disease">
            <modify-review :disease="disease"/>
            <!--<modify-review :index="index" :label="index" :disease="disease"/>-->
        </div>
    </div>
</template>

<script>
/* eslint-disable */
import {HTTP} from "@/router/http";
import {var_to_position} from "@/utils";
import {BIcon, BIconQuestion, BIconCheck, BIconX} from "bootstrap-vue";
import ModifyReview from "@/components/widgets/review/ModifyReview";
import ulog from "ulog";
import {mapGetters} from "vuex";
import CuratorVariantInformations from "@/components/widgets/curation/CuratorVariantInformations";
import ModifyVariantSummary from "@/components/widgets/review/ModifyVariantSummary";
import store from "@/store";

const log = ulog("ViewReview");

export default {
    name: "ViewReview",
    components: {
        BIcon,
        BIconQuestion,
        BIconCheck,
        BIconX,
        ModifyReview,
        CuratorVariantInformations,
        ModifyVariantSummary
    },
    props: {
        review: {type: Object, required: false}
    },
    data() {
        return {
            //diseases:
            diseases: [
                //{
                    {
                        "disease": "Ag",
                        //"disease": "Aggressive fibromatosis",
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
                                note: null,
                                items: [
                                    {
                                        outcome: [
                                            {label: "Good outcome", nb_evidence: 0},
                                            {label: "Intermediate", nb_evidence: 2},
                                            {label: "Poor outcome", nb_evidence: 1},
                                        ],
                                        sib_annotation_outcome: "Intermediate",
                                        sib_annotation_trust: "Tier IID: Population study",
                                        reviews: [
                                            {
                                                reviewer: "John Doe",
                                                reviewer_mail: "test@test.com",
                                                reviewer_annotation_outcome: "Poor outcome",
                                                reviewer_annotation_trust: "Tier IID: Population study",
                                                comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                                            },
                                            {
                                                reviewer: "Jean Doe",
                                                reviewer_mail: "test@test.com",
                                                reviewer_annotation_outcome: "Intermediate",
                                                reviewer_annotation_trust: "Tier IID: Population study",
                                                comment: null
                                            },
                                            {
                                                reviewer: "Johnny Doe",
                                                reviewer_mail: "test@test.com",
                                                reviewer_annotation_outcome: "Intermediate",
                                                reviewer_annotation_trust: "Tier IID: Population study",
                                                comment: null
                                            },
                                        ],
                                        evidence: [
                                            {
                                                reject: false,
                                                outcome: "Intermediate",
                                                evidence_link: "282",
                                                pmid_link: "23960186",
                                                evidence_comment: "The study involved 115 patients diagnosed with aggressive fibromatosis, who underwent surgical resection of the tumors. CTNNB1 exon 3 mutations were detected in 75% of the tumors, including T41A in 46%. At a median follow-up of 31 months, 5-year recurrence-free survival was slightly, although not statistically significantly, worse for patients with CTNNB1 mutated tumors than for those with wild-type tumors (58% vs. 74%, respectively). The specific CTNNB1 codon mutation (A41T or S45F) did not correlate with the risk for recurrence."
                                            },
                                            {
                                                reject: false,
                                                outcome: "Intermediate",
                                                evidence_link: "281",
                                                pmid_link: "22744289",
                                                evidence_comment: "In 47 patients diagnosed with desmoid-type fibromatosis, CTNNB1 exon 3 mutation were identified in 39 cases (83 %), predominantly T41A (77 %). There was no correlation between any specific CTNNB1 mutation and clinical outcome."
                                            },
                                            {
                                                reject: false,
                                                outcome: "Poor outcome",
                                                evidence_link: "284",
                                                pmid_link: "20197769",
                                                evidence_comment: "Tumors from 101 patients, diagnosed with extra-abdominal fibromatosis, were studied. 87% of the tumors exhibited CTNNB1 exon 3 mutations, including T41A in 39.5% of the cases. The patient underwent surgery, followed in most cases by radiotherapy. During a median 62 month follow-up period, 51 patients relapsed, 1 with a wild-type CTNNB1 tumor and 50 with  mutated CTNNB1. The 5-year recurrence-free survival was significantly shorter in all mutated CTNNB1 tumors, including T41A, compared with wild-type tumors, but this poor outcome could not be related to a specific genotype, as there was no significant difference between T41A, S45F, or S45P mutants."
                                            },
                                        ],
                                        show_review_status: false,
                                        note: null
                                    },
                                ]
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
                        ],
                        "Prognostic": [
                            {
                                outcome: [
                                    {label: "Good outcome", nb_evidence: 0},
                                    {label: "Intermediate", nb_evidence: 2},
                                    {label: "Poor outcome", nb_evidence: 1},
                                ],
                                sib_annotation_outcome: "Intermediate",
                                sib_annotation_trust: "Tier IID: Population study",
                                reviews: [
                                    {
                                        reviewer: "John Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Poor outcome",
                                        reviewer_annotation_trust: "Tier IID: Population study",
                                        comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                                    },
                                    {
                                        reviewer: "Jean Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Intermediate",
                                        reviewer_annotation_trust: "Tier IID: Population study",
                                        comment: null
                                    },
                                    {
                                        reviewer: "Johnny Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Intermediate",
                                        reviewer_annotation_trust: "Tier IID: Population study",
                                        comment: null
                                    },
                                ],
                                evidence: [
                                    {
                                        reject: false,
                                        outcome: "Intermediate",
                                        evidence_link: "282",
                                        pmid_link: "23960186",
                                        evidence_comment: "The study involved 115 patients diagnosed with aggressive fibromatosis, who underwent surgical resection of the tumors. CTNNB1 exon 3 mutations were detected in 75% of the tumors, including T41A in 46%. At a median follow-up of 31 months, 5-year recurrence-free survival was slightly, although not statistically significantly, worse for patients with CTNNB1 mutated tumors than for those with wild-type tumors (58% vs. 74%, respectively). The specific CTNNB1 codon mutation (A41T or S45F) did not correlate with the risk for recurrence."
                                    },
                                    {
                                        reject: false,
                                        outcome: "Intermediate",
                                        evidence_link: "281",
                                        pmid_link: "22744289",
                                        evidence_comment: "In 47 patients diagnosed with desmoid-type fibromatosis, CTNNB1 exon 3 mutation were identified in 39 cases (83 %), predominantly T41A (77 %). There was no correlation between any specific CTNNB1 mutation and clinical outcome."
                                    },
                                    {
                                        reject: false,
                                        outcome: "Poor outcome",
                                        evidence_link: "284",
                                        pmid_link: "20197769",
                                        evidence_comment: "Tumors from 101 patients, diagnosed with extra-abdominal fibromatosis, were studied. 87% of the tumors exhibited CTNNB1 exon 3 mutations, including T41A in 39.5% of the cases. The patient underwent surgery, followed in most cases by radiotherapy. During a median 62 month follow-up period, 51 patients relapsed, 1 with a wild-type CTNNB1 tumor and 50 with  mutated CTNNB1. The 5-year recurrence-free survival was significantly shorter in all mutated CTNNB1 tumors, including T41A, compared with wild-type tumors, but this poor outcome could not be related to a specific genotype, as there was no significant difference between T41A, S45F, or S45P mutants."
                                    },
                                ],
                                show_review_status: false,
                                note: null
                            },
                        ],
                        "Diagnostic": [
                            {
                                outcome: [
                                    {label: "Associated with diagnosis", nb_evidence: 1},
                                    {label: "Not associated with diagnosis", nb_evidence: 0},
                                    {label: "Other", nb_evidence: 0},
                                ],
                                sib_annotation_outcome: "Associated with diagnosis",
                                sib_annotation_trust: "Tier IA: Included in Professional Guidelines",
                                reviews: [
                                    {
                                        reviewer: "John Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Associated with diagnosis",
                                        reviewer_annotation_trust: "Tier IA: Included in Professional Guidelines",
                                        comment: null,
                                    },
                                    {
                                        reviewer: "Jean Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Associated with diagnosis",
                                        reviewer_annotation_trust: "Tier IA: Included in Professional Guidelines",
                                        comment: null
                                    },
                                    {
                                        reviewer: "Johnny Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Associated with diagnosis",
                                        reviewer_annotation_trust: "Tier IA: Included in Professional Guidelines",
                                        comment: null
                                    }
                                ],
                                evidence: [
                                    {
                                        reject: false,
                                        outcome: "Associated with diagnosis",
                                        evidence_link: "280",
                                        pmid_link: "28961825",
                                        evidence_comment: 'Approximately 85%–90% of desmoid-type fibromatosis (DF) harbors mutations in the CTNNB1 gene (predominantly T41A in roughly 50% of the cases), leading to nuclear accumulation of CTNNB1-encoded protein. CTNNB1 mutations and APC mutations appear to be mutually exclusive in DF, thus, detection of a somatic CTNNB1 mutation may help to exclude a syndromal condition. Vice versa, CTNNB1 wild-type status in DF should raise suspicion for familial adenomatous polyposis (FAP), with more extensive diagnostic clinical work-up (e.g. colonoscopy). Mutation analysis of CTNNB1 has been proposed as a specific diagnostic tool for establishing DF diagnosis, particularly in challenging or diagnostically ambiguous cases (recommendation issued  by the European Consensus Initiative between Sarcoma PAtients EuroNet (SPAEN) and European Organization for Research and Treatment of Cancer (EORTC)/Soft Tissue and Bone Sarcoma Group (STBSG)).'
                                    },
                                ],
                                show_review_status: false,
                                note: null
                            },
                        ],
                        "Predictive / Therapeutic": [
                            {
                                outcome: [
                                    {label: "Bafilomycin", nb_evidence: 1}
                                ],
                                sib_annotation_outcome: "Resistant (in vitro)",
                                sib_annotation_trust: "Tier IID: Pre-clinical study",
                                reviews: [
                                    {
                                        reviewer: "John Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Resistant (in vitro)",
                                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                                        comment: null,
                                    },
                                    {
                                        reviewer: "Jean Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Resistant (in vitro)",
                                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                                        comment: null
                                    },
                                    {
                                        reviewer: "Johnny Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Resistant (in vitro)",
                                        reviewer_annotation_trust: "Tier IA: Included in Professional Guidelines",
                                        comment: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
                                    }
                                ],
                                evidence: [
                                    {
                                        reject: false,
                                        outcome: "Resistant (in vitro)",
                                        evidence_link: "283",
                                        pmid_link: "30980399",
                                        evidence_comment: "Treatment of T41A-mutated primary desmoid tumor cells with bafilomycin did not have any effect."
                                    },
                                ],
                                show_review_status: false,
                                note: null
                            },
                            {
                                outcome: [
                                    {label: "Sorafenib", nb_evidence: 1}
                                ],
                                sib_annotation_outcome: "Sensitive (in vitro)",
                                sib_annotation_trust: "Tier IID: Pre-clinical study",
                                reviews: [
                                    {
                                        reviewer: "John Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Sensitive (in vitro)",
                                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                                        comment: null,
                                    },
                                    {
                                        reviewer: "Jean Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Sensitive (in vitro)",
                                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                                        comment: null
                                    },
                                    {
                                        reviewer: "Johnny Doe",
                                        reviewer_mail: "test@test.com",
                                        reviewer_annotation_outcome: "Sensitive (in vitro)",
                                        reviewer_annotation_trust: "Tier IID: Pre-clinical study",
                                        comment: null
                                    }
                                ],
                                evidence: [
                                    {
                                        reject: false,
                                        outcome: "Sensitive (in vitro)",
                                        evidence_link: "285",
                                        pmid_link: "30980399",
                                        evidence_comment: "In primary cell cultures, T41A-mutated desmoid cells were sensitive - in terms of cell viability (apoptosis), invasion and migration - to sorafenib."
                                    },
                                ],
                                show_review_status: false,
                                note: null
                            }
                        ]
                    }
                //},
            ],
            summary: {
                content: "",
                comments: []
            }
        }
    },
    mounted() {
        HTTP.get(`/summary_comments/?variant=${this.variant.id}`).then((response) => {
            const results = response.data.results
            console.log(results)
            this.summary.comments = results;
        });
    },
    computed: {
        ...mapGetters({
            variant: "variant",
            gene: "gene"
        }),
        disease_id() {
            return parseInt(this.$route.params.disease_id);
        },
        annotationUsed() {
            if (!this.source || !this.reference) {
                return null;
            }

            const thisRef = `${this.source.trim()}:${this.reference.trim()}`;
            return this.used_references[thisRef];
        }
    },
    methods: {
        //
    },
    beforeRouteEnter(to, from, next) {
        const {variant_id} = to.params;

        // ask the store to populate detailed information about this variant
        store.dispatch("getGeneVariant", {variant_id: variant_id}).then(({gene, variant}) => {
            to.meta.title = `SVIP-O: Annotate ${gene.symbol} ${variant.name}`;
            next();
        });
    }
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
    /* .slide-fade-leave-active below version 2.1.8 */
{
    opacity: 0;
    max-height: 0;
}
</style>
<style>
.ajax-loader-bar {
    display: none !important;
}
</style>
