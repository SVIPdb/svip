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
                                        <b-input v-model="prognosticPredicted" readonly />
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-input readonly />
                                    </b-row>
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="p-2">
                                        <b-form-select v-model="prognosticSelected" class="form-control">
                                            <option>Good outcome</option>
                                            <option>Intermediate</option>
                                            <option>Poor outcome</option>
                                            <option>Unclear</option>
                                            <option>Context-dependent</option>
                                        </b-form-select>
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-form-select class="form-control">
                                            <option>Tier-level</option>
                                        </b-form-select>
                                    </b-row>
                                </b-col>
                                <b-col cols="1" align="center">
                                    <b-row class="justify-content-center">
                                        Review status
                                    </b-row>
                                    <b-row class="justify-content-center">
                                        <!-- Ivo : service to get the others statuses -->
                                        <b-icon v-if="prognosticSelected == prognosticPredicted" style="color:blue;" class="h4 mb-2 m-1" icon="check-square-fill"></b-icon>
                                        <b-icon v-if="prognosticSelected == ''" class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon v-else-if="prognosticSelected != prognosticPredicted" style="color:red;" class="h4 mb-2 m-1" icon="x-square-fill"></b-icon>
                                    </b-row>
                                </b-col>
                                <b-col cols="4">
                                    <b-textarea :disabled="prognosticSelected == prognosticPredicted" class="summary-box" rows="3" placeholder="Comment..." />
                                </b-col>
                            </b-row>
                        </b-card-text>
                    </div>
                </transition>
                <transition name="slide-fade">
                    <div v-if="showPrognostic">
                        <b-card-footer class="m-10">
                            <b-row>
                                <b-col cols="2">Good outcome</b-col>
                                <b-col cols="2">
                                    <a href="#" alt="Link to evidence">Evidence #1</a>
                                </b-col>
                                <b-col cols="2">PMID: 789101</b-col>
                                <b-col cols="6">Public comment from evidence...</b-col>
                            </b-row>
                            <b-row>
                                <b-col cols="2">Good outcome</b-col>
                                <b-col cols="2">
                                    <a href="#" alt="Link to evidence">Evidence #2</a>
                                </b-col>
                                <b-col cols="2">PMID: 789101</b-col>
                                <b-col cols="6">Public comment from evidence...</b-col>
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
                                        <b-input id="diagnosticOutcome" readonly />
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-input id="diagnosticOutcome" readonly />
                                    </b-row>
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="p-2">
                                        <b-form-select class="form-control">
                                            <option>Good outcome</option>
                                            <option>Intermediate</option>
                                            <option>Poor outcome</option>
                                            <option>Unclear</option>
                                            <option>Context-dependent</option>
                                        </b-form-select>
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-form-select class="form-control">
                                            <option>Tier-level</option>
                                        </b-form-select>
                                    </b-row>
                                </b-col>
                                <b-col cols="1" align="center">
                                    <b-row class="justify-content-center">
                                        Review status
                                    </b-row>
                                    <b-row class="justify-content-center">
                                        <b-icon style="color:blue;" class="h4 mb-2 m-1" icon="check-square-fill"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon style="color:red;" class="h4 mb-2 m-1" icon="x-square-fill"></b-icon>
                                    </b-row>
                                </b-col>
                                <b-col cols="4">
                                    <b-textarea
                                        class="summary-box"
                                        rows="3"
                                        placeholder="Comment..."
                                    />
                                </b-col>
                            </b-row>
                        </b-card-text>
                    </div>
                </transition>
                <transition name="slide-fade">
                    <div v-if="showDiagnostic">
                        <b-card-footer class="m-10">
                            <b-row>
                                <b-col cols="2">Good outcome</b-col>
                                <b-col cols="2">
                                    <a href="#" alt="Link to evidence">Evidence #1</a>
                                </b-col>
                                <b-col cols="2">PMID: 789101</b-col>
                                <b-col cols="6">Public comment from evidence...</b-col>
                            </b-row>
                            <b-row>
                                <b-col cols="2">Good outcome</b-col>
                                <b-col cols="2">
                                    <a href="#" alt="Link to evidence">Evidence #2</a>
                                </b-col>
                                <b-col cols="2">PMID: 789101</b-col>
                                <b-col cols="6">Public comment from evidence...</b-col>
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
                                <b-col align-self="stretch" cols="2">
                                    <b-row class="p-2">Drug 1 (1 evidence)</b-row>
                                    <b-row class="p-2">Drug 2 (3 evidences)</b-row>
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="p-2">
                                        <b-input id="predictiveOutcome" readonly />
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-input id="predictiveOutcome" readonly />
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-input id="predictiveOutcome" readonly />
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-input id="predictiveOutcome" readonly />
                                    </b-row>
                                </b-col>
                                <b-col cols="2">
                                    <b-row class="p-2">
                                        <b-form-select class="form-control">
                                            <option>Good outcome</option>
                                            <option>Intermediate</option>
                                            <option>Poor outcome</option>
                                            <option>Unclear</option>
                                            <option>Context-dependent</option>
                                        </b-form-select>
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-form-select class="form-control">
                                            <option>Tier-level</option>
                                        </b-form-select>
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-form-select class="form-control">
                                            <option>Good outcome</option>
                                            <option>Intermediate</option>
                                            <option>Poor outcome</option>
                                            <option>Unclear</option>
                                            <option>Context-dependent</option>
                                        </b-form-select>
                                    </b-row>
                                    <b-row class="p-2">
                                        <b-form-select class="form-control">
                                            <option>Tier-level</option>
                                        </b-form-select>
                                    </b-row>
                                </b-col>
                                <b-col cols="1" align="center">
                                    <b-row class="justify-content-center">
                                        Review status
                                    </b-row>
                                    <b-row class="justify-content-center">
                                        <b-icon style="color:blue;" class="h4 mb-2 m-1" icon="check-square-fill"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon style="color:red;" class="h4 mb-2 m-1" icon="x-square-fill"></b-icon>
                                    </b-row>
                                    <b-row class="justify-content-center">
                                        Review status
                                    </b-row>
                                    <b-row class="justify-content-center">
                                        <b-icon style="color:blue;" class="h4 mb-2 m-1" icon="check-square"></b-icon>
                                        <b-icon class="h4 mb-2 m-1" icon="square"></b-icon>
                                        <b-icon style="color:red;" class="h4 mb-2 m-1" icon="x-square-fill"></b-icon>
                                    </b-row>
                                </b-col>
                                <b-col cols="4">
                                    <b-row class="p-3">
                                        <b-textarea
                                            class="summary-box"
                                            rows="3"
                                            placeholder="Comment..."
                                        />
                                    </b-row>
                                    <b-row class="p-3">
                                        <b-textarea
                                            class="summary-box"
                                            rows="3"
                                            placeholder="Comment..."
                                        />
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
                                    <a href="#" alt="Link to evidence">Evidence #1</a>
                                </b-col>
                                <b-col class="border p-2">PMID: 789101</b-col>
                                <b-col class="border p-2" cols="6">Public comment from evidence...</b-col>
                            </b-row>
                            <b-row align-v="center">
                                <b-col class="border p-2">Good outcome</b-col>
                                <b-col class="border p-2">
                                    <a href="#" alt="Link to evidence">Evidence #1</a>
                                </b-col>
                                <b-col class="border p-2">PMID: 789101</b-col>
                                <b-col class="border p-2" cols="6">Public comment from evidence...</b-col>
                            </b-row>
                            <b-row align-v="center">
                                <b-col class="border p-2">Good outcome</b-col>
                                <b-col class="border p-2">
                                    <a href="#" alt="Link to evidence">Evidence #1</a>
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

            loading: false,
            error: null,
            channel: new BroadcastChannel("curation-update"),
            showDisease: true,
            showPrognostic: false,
            showDiagnostic: false,
            showPredictive: false,
            prognosticPredicted: "Unclear",
            prognosticSelected: ""
        };
    },
    created() {
        this.channel.onmessage = () => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };
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
