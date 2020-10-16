<template>
    <div>
        <b-card class="shadow-sm mb-3" align="left" no-body>
            <b-card-body class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="showDisease" />Disease 1
                </h6>

                <transition name="slide-fade">
                    <div v-if="showDisease">
                        <b-card-text class="p-2 m-0">
                            <b-row align-v="center">
                                <b-col align="center" cols="1">
                                    <expander v-model="showPrognostic" />Prognostic
                                </b-col>
                                <b-col cols="2">
                                    Good outcome (4 evidences)
                                    <br />Intermediate (2 evidences)
                                    <br />Poor outcome (1 evidence)
                                    <br />
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="p-2">
                                        <b-input v-model="prognosticOutcomePredicted" readonly />
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-input v-model="prognosticTrustPredicted" readonly />
                                    </b-row>
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="p-2">
                                        <b-form-select v-model="prognosticOutcomeSelected" class="form-control">
                                            <option>Good outcome</option>
                                            <option>Poor outcome</option>
                                            <option>Intermediate</option>
                                            <option>Unclear</option>
                                            <option>Context-dependent</option>
                                        </b-form-select>
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-form-select v-model="prognosticTrustSelected" class="form-control">
                                            <option>Tier IA: Included in Professional Guidelines</option>
                                            <option>Tier IB: Well-powered studies with consensus from experts in the field</option>
                                            <option>Tier IIC: Multiples small published studies with some consensus</option>
                                            <option>Tier IID: Clinical trial</option>
                                            <option>Tier IID: Pre-clinical study</option>
                                            <option>Tier IID: Population study</option>
                                            <option>Tier IID: Small published study</option>
                                            <option>Tier IID: Case report</option>
                                            <option>Tier III: No convincing published evidence of drugs effect</option>
                                            <option>Tier III: Author statement</option>
                                            <option>Tier IV: Reported evidence supportive of benign/likely benign effect</option>
                                            <option>Other criteria</option>
                                        </b-form-select>
                                    </b-row>
                                </b-col>
                                <b-col cols="1" align="center">
                                    <b-row class="justify-content-center">
                                        Review status
                                    </b-row>
                                    <b-row class="justify-content-center">
                                        <!-- Ivo : service to get the others statuses -->
                                        <b-icon v-if="prognosticOutcomeSelected === prognosticOutcomePredicted && prognosticTrustSelected === prognosticTrustPredicted" style="color:blue;" class="h4 mb-2 m-1" icon="check-square-fill"></b-icon>
                                        <b-icon v-if="prognosticOutcomeSelected === ''" class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon v-else-if="prognosticOutcomeSelected !== prognosticOutcomePredicted || prognosticTrustSelected !== prognosticTrustPredicted" style="color:red;" class="h4 mb-2 m-1" icon="x-square-fill"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                    </b-row>
                                </b-col>
                                <b-col cols="4">
                                    <b-textarea :disabled="prognosticOutcomeSelected === prognosticOutcomePredicted && prognosticTrustSelected === prognosticTrustPredicted" class="summary-box" rows="3" placeholder="Comment..." />
                                </b-col>
                            </b-row>
                        </b-card-text>
                    </div>
                </transition>
                <transition name="slide-fade">
                    <div v-if="showPrognostic">
                        <b-card-footer class="pt-0 pb-0 pl-3 pr-3 fluid">
                            <b-row align-v="center">
                                <b-col class="border p-2">Good outcome</b-col>
                                <b-col class="border p-2">
                                    <b-link v-if="sample_curation_id" :to="{ name: 'view-evidence', params: { action: sample_curation_id } }" alt="Link to evidence">Evidence #1</b-link>
                                    <!-- <router-link :to="`/curation/gene/${data.item.gene_id}/variant/${data.item.variant_id}/evidence/${data.item.evidence_id}`" target="_blank">{{ data.value }}</router-link> -->
                                </b-col>
                                <b-col class="border p-2">PMID: 789101</b-col>
                                <b-col class="border p-2" cols="6">Public comment from evidence...</b-col>
                            </b-row>
                        </b-card-footer>
                    </div>
                </transition>
            </b-card-body>

            <b-card-body class="p-0">
                <transition name="slide-fade">
                    <div v-if="showDisease">
                        <b-card-text class="p-2 m-0">
                            <b-row align-v="center">
                                <b-col align="center" cols="1">
                                    <expander v-model="showDiagnostic" />Diagnostic
                                </b-col>
                                <b-col cols="2">
                                    Associated with diagnosis (1 evidence)
                                    <br />Not associated with diagnosis (1 evidence)
                                    <br />Other (no evidence)
                                    <br />
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="p-2">
                                        <b-input v-model="diagnosticOutcomePredicted" readonly />
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-input v-model="diagnosticTrustPredicted" readonly />
                                    </b-row>
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="p-2">
                                        <b-form-select v-model="diagnosticOutcomeSelected" class="form-control">
                                            <option>Associated with diagnosis</option>
                                            <option>Not associated with diagnosis</option>
                                            <option>Other</option>
                                        </b-form-select>
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-form-select v-model="diagnosticTrustSelected" class="form-control">
                                            <option>Tier IA: Included in Professional Guidelines</option>
                                            <option>Tier IB: Well-powered studies with consensus from experts in the field</option>
                                            <option>Tier IIC: Multiples small published studies with some consensus</option>
                                            <option>Tier IID: Clinical trial</option>
                                            <option>Tier IID: Pre-clinical study</option>
                                            <option>Tier IID: Population study</option>
                                            <option>Tier IID: Small published study</option>
                                            <option>Tier IID: Case report</option>
                                            <option>Tier III: No convincing published evidence of drugs effect</option>
                                            <option>Tier III: Author statement</option>
                                            <option>Tier IV: Reported evidence supportive of benign/likely benign effect</option>
                                            <option>Other criteria</option>
                                        </b-form-select>
                                    </b-row>
                                </b-col>
                                <b-col cols="1" align="center">
                                    <b-row class="justify-content-center">
                                        Review status
                                    </b-row>
                                    <b-row class="justify-content-center">
                                        <!-- Ivo : service to get the others statuses -->
                                        <b-icon v-if="diagnosticOutcomeSelected === diagnosticOutcomePredicted && diagnosticTrustSelected === diagnosticTrustPredicted" style="color:blue;" class="h4 mb-2 m-1" icon="check-square-fill"></b-icon>
                                        <b-icon v-if="diagnosticOutcomeSelected === ''" class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon v-else-if="diagnosticOutcomeSelected !== diagnosticOutcomePredicted || diagnosticTrustSelected !== diagnosticTrustPredicted" style="color:red;" class="h4 mb-2 m-1" icon="x-square-fill"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                    </b-row>
                                </b-col>
                                <b-col cols="4">
                                    <b-textarea :disabled="diagnosticOutcomeSelected === diagnosticOutcomePredicted && diagnosticTrustSelected === diagnosticTrustPredicted" class="summary-box" rows="3" placeholder="Comment..." />
                                </b-col>
                            </b-row>
                        </b-card-text>
                    </div>
                </transition>
                <transition name="slide-fade">
                    <div v-if="showDiagnostic">
                        <b-card-footer class="pt-0 pb-0 pl-3 pr-3 fluid">
                            <b-row align-v="center">
                                <b-col class="border p-2">Good outcome</b-col>
                                <b-col class="border p-2">
                                    <b-link v-if="sample_curation_id" :to="{ name: 'view-evidence', params: { action: sample_curation_id } }" alt="Link to evidence">Evidence #1</b-link>
                                </b-col>
                                <b-col class="border p-2">PMID: 789101</b-col>
                                <b-col class="border p-2" cols="6">Public comment from evidence...</b-col>
                            </b-row>
                            <b-row align-v="center">
                                <b-col class="border p-2">Good outcome</b-col>
                                <b-col class="border p-2">
                                    <b-link v-if="sample_curation_id" :to="{ name: 'view-evidence', params: { action: sample_curation_id } }" alt="Link to evidence">Evidence #1</b-link>
                                </b-col>
                                <b-col class="border p-2">PMID: 789101</b-col>
                                <b-col class="border p-2" cols="6">Public comment from evidence...</b-col>
                            </b-row>
                        </b-card-footer>
                    </div>
                </transition>
            </b-card-body>

            <b-card-body class="p-0">
                <transition name="slide-fade">
                    <div v-if="showDisease">
                        <b-card-text class="p-2 m-0">
                            <b-row align-v="center">
                                <b-col align="center" cols="1">
                                    <expander v-model="showPredictive" />
                                    Predictive /<br />Therapeutic
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="pb-5 pt-5 pl-3">Drug 1 (1 evidence)</b-row>
                                    <b-row class="pb-5 pt-5 pl-3">Drug 2 (3 evidences)</b-row>
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="p-2">
                                        <b-input v-model="predictiveOutcomePredictedDrug1" readonly />
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-input v-model="predictiveTrustPredictedDrug1" readonly />
                                    </b-row>
                                    <b-row class="p-2 pt-4">
                                        <b-input v-model="predictiveOutcomePredictedDrug2" readonly />
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-input v-model="predictiveTrustPredictedDrug2" readonly />
                                    </b-row>
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="p-2">
                                        <b-form-select v-model="predictiveOutcomeSelectedDrug1" class="form-control">
                                            <option>Sensitive (in vitro)</option>
                                            <option>Responsive</option>
                                            <option>Resistant (in vitro)</option>
                                            <option>Reduced sensivity</option>
                                            <option>Not responsive</option>
                                            <option>Adverse response</option>
                                            <option>Other</option>
                                        </b-form-select>
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-form-select v-model="predictiveTrustSelectedDrug1" class="form-control">
                                            <option>Tier IA: Included in Professional Guidelines</option>
                                            <option>Tier IB: Well-powered studies with consensus from experts in the field</option>
                                            <option>Tier IIC: Multiples small published studies with some consensus</option>
                                            <option>Tier IID: Clinical trial</option>
                                            <option>Tier IID: Pre-clinical study</option>
                                            <option>Tier IID: Population study</option>
                                            <option>Tier IID: Small published study</option>
                                            <option>Tier IID: Case report</option>
                                            <option>Tier III: No convincing published evidence of drugs effect</option>
                                            <option>Tier III: Author statement</option>
                                            <option>Tier IV: Reported evidence supportive of benign/likely benign effect</option>
                                            <option>Other criteria</option>
                                        </b-form-select>
                                    </b-row>
                                    <b-row class="p-2 pt-4">
                                        <b-form-select v-model="predictiveOutcomeSelectedDrug2" class="form-control">
                                            <option>Sensitive (in vitro)</option>
                                            <option>Responsive</option>
                                            <option>Resistant (in vitro)</option>
                                            <option>Reduced sensivity</option>
                                            <option>Not responsive</option>
                                            <option>Adverse response</option>
                                            <option>Other</option>
                                        </b-form-select>
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-form-select v-model="predictiveTrustSelectedDrug2" class="form-control">
                                            <option>Tier IA: Included in Professional Guidelines</option>
                                            <option>Tier IB: Well-powered studies with consensus from experts in the field</option>
                                            <option>Tier IIC: Multiples small published studies with some consensus</option>
                                            <option>Tier IID: Clinical trial</option>
                                            <option>Tier IID: Pre-clinical study</option>
                                            <option>Tier IID: Population study</option>
                                            <option>Tier IID: Small published study</option>
                                            <option>Tier IID: Case report</option>
                                            <option>Tier III: No convincing published evidence of drugs effect</option>
                                            <option>Tier III: Author statement</option>
                                            <option>Tier IV: Reported evidence supportive of benign/likely benign effect</option>
                                            <option>Other criteria</option>
                                        </b-form-select>
                                    </b-row>
                                </b-col>
                                <b-col cols="1" align="center">
                                    <b-row class="justify-content-center">
                                        Review status
                                    </b-row>
                                    <b-row class="justify-content-center">
                                        <!-- Ivo : service to get the others statuses -->
                                        <b-icon v-if="predictiveOutcomeSelectedDrug1 === predictiveOutcomePredictedDrug1 && predictiveTrustSelectedDrug1 === predictiveTrustPredictedDrug1" style="color:blue;" class="h4 mb-2 m-1" icon="check-square-fill"></b-icon>
                                        <b-icon v-if="predictiveOutcomeSelectedDrug1 === ''" class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon v-else-if="predictiveOutcomeSelectedDrug1 !== predictiveOutcomePredictedDrug1 || predictiveTrustSelectedDrug1 !== predictiveTrustPredictedDrug1" style="color:red;" class="h4 mb-2 m-1" icon="x-square-fill"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                    </b-row>
                                    <b-row class="pt-5 justify-content-center">
                                        Review status
                                    </b-row>
                                    <b-row class="justify-content-center">
                                        <!-- Ivo : service to get the others statuses -->
                                        <b-icon v-if="predictiveOutcomeSelectedDrug2 === predictiveOutcomePredictedDrug2 && predictiveTrustSelectedDrug2 === predictiveTrustPredictedDrug2" style="color:blue;" class="h4 mb-2 m-1" icon="check-square-fill"></b-icon>
                                        <b-icon v-if="predictiveOutcomeSelectedDrug2 === ''" class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon v-else-if="predictiveOutcomeSelectedDrug2 !== predictiveOutcomePredictedDrug2 || predictiveTrustSelectedDrug2 !== predictiveTrustPredictedDrug2" style="color:red;" class="h4 mb-2 m-1" icon="x-square-fill"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                    </b-row>
                                </b-col>
                                <b-col cols="4">
                                    <b-row class="p-3 pb-4">
                                        <b-textarea :disabled="predictiveOutcomeSelectedDrug1 === predictiveOutcomePredictedDrug1 && predictiveTrustSelectedDrug1 === predictiveTrustPredictedDrug1" class="summary-box" rows="3" placeholder="Comment..." />
                                    </b-row>
                                    <b-row class="p-3">
                                        <b-textarea :disabled="predictiveOutcomeSelectedDrug2 === predictiveOutcomePredictedDrug2 && predictiveTrustSelectedDrug2 === predictiveTrustPredictedDrug2" class="summary-box" rows="3" placeholder="Comment..." />
                                    </b-row>
                                </b-col>
                            </b-row>
                        </b-card-text>
                    </div>
                </transition>
                <transition name="slide-fade">
                    <div v-if="showPredictive">
                        <b-card-footer class="pt-0 pb-0 pl-3 pr-3 fluid">
                            <b-row align-v="center">
                                <b-col class="border p-2">Good outcome</b-col>
                                <b-col class="border p-2">
                                    <b-link v-if="sample_curation_id" :to="{ name: 'view-evidence', params: { action: sample_curation_id } }" alt="Link to evidence">Evidence #1</b-link>
                                </b-col>
                                <b-col class="border p-2">PMID: 789101</b-col>
                                <b-col class="border p-2" cols="6">Public comment from evidence...</b-col>
                            </b-row>
                            <b-row align-v="center">
                                <b-col class="border p-2">Good outcome</b-col>
                                <b-col class="border p-2">
                                    <b-link v-if="sample_curation_id" :to="{ name: 'view-evidence', params: { action: sample_curation_id } }" alt="Link to evidence">Evidence #1</b-link>
                                </b-col>
                                <b-col class="border p-2">PMID: 789101</b-col>
                                <b-col class="border p-2" cols="6">Public comment from evidence...</b-col>
                            </b-row>
                            <b-row align-v="center">
                                <b-col class="border p-2">Good outcome</b-col>
                                <b-col class="border p-2">
                                    <b-link v-if="sample_curation_id" :to="{ name: 'view-evidence', params: { action: sample_curation_id } }" alt="Link to evidence">Evidence #1</b-link>
                                </b-col>
                                <b-col class="border p-2">PMID: 789101</b-col>
                                <b-col class="border p-2" cols="6">Public comment from evidence...</b-col>
                            </b-row>
                        </b-card-footer>
                    </div>
                </transition>
            </b-card-body>
        </b-card>
    </div>
</template>

<script>
/* eslint-disable */
// import fields from "@/data/curation/evidence/fields.js";
import { HTTP } from "@/router/http";
import BroadcastChannel from "broadcast-channel";
import {BIcon, BIconSquare, BIconCheckSquareFill, BIconXSquareFill} from "bootstrap-vue";
import ulog from "ulog";
import RowDetailsHeader from '@/components/genes/variants/sources/shared/RowDetailsHeader';

const log = ulog("VariantDisease");

export default {
    name: "VariantDisease",
    components: {
        BIcon,
        BIconSquare,
        BIconCheckSquareFill,
        BIconXSquareFill,
    },
    props: {
        variant: { type: Object, required: false },
    },
    data() {
        return {
            summary: null,
            history_entry_id: null,

            sample_curation_id: null,

            loading: false,
            error: null,
            channel: new BroadcastChannel("curation-update"),
            
            showDisease: true,
            showPrognostic: false,
            showDiagnostic: false,
            showPredictive: false,

            // Ivo : Fake data... Need a service to get evidences to generate predictive fields and to get other reviews status
            prognosticOutcomePredicted: "Unclear",
            prognosticTrustPredicted: "Tier IA: Included in Professional Guidelines",
            diagnosticOutcomePredicted: "Associated with diagnosis",
            diagnosticTrustPredicted: "Tier IA: Included in Professional Guidelines",
            predictiveOutcomePredictedDrug1: "Responsive",
            predictiveTrustPredictedDrug1: "Tier IID: Case report",
            predictiveOutcomePredictedDrug2: "Other",
            predictiveTrustPredictedDrug2: "Tier III: Author statement",

            prognosticOutcomeSelected: "Unclear",
            prognosticTrustSelected: "Tier IA: Included in Professional Guidelines",
            diagnosticOutcomeSelected: "Associated with diagnosis",
            diagnosticTrustSelected: "Tier IA: Included in Professional Guidelines",
            predictiveOutcomeSelectedDrug1: "Responsive",
            predictiveTrustSelectedDrug1: "Tier IID: Case report",
            predictiveOutcomeSelectedDrug2: "Other",
            predictiveTrustSelectedDrug2: "Tier III: Author statement",

            prognosticComment: ""
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
        HTTP.get(`/curation_entries?variant__gene__symbol=ABL1&variant__name=D276G&page_size=1`).then((response) => {
            this.sample_curation_id = response.data.results[0].id;
        });
    },
    computed: {},
    methods: {},
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
