<template>
    <div>
        <b-card class="shadow-sm mb-3" align="left" no-body>
            <b-card-body class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="showAliases" />
                    Disease 1
                </h6>

                <transition name="slide-fade">
                    <div v-if="showAliases">
                        <b-card-text class="p-2 m-0">
                            <b-container class="bv-example-row">
                                <b-row align-v="center">
                                    <b-col cols="2">Prognostic</b-col>
                                    <b-col cols="3">
                                        Good outcome (4 evidences)<br>
                                        Intermediate (2 evidences)<br>
                                        Poor outcome (1 evidence)<br>
                                    </b-col>
                                    <b-col cols="2">
                                        <p><b-input id="prognosticOutcome" readonly /></p>
                                        <b-input id="prognosticOutcome" readonly />
                                    </b-col>
                                    <b-col cols="2">
                                        <p><b-form-select class="form-control" id="exampleFormControlSelect1">
                                            <option>Good outcome</option>
                                            <option>Intermediate</option>
                                            <option>Poor outcome</option>
                                            <option>Unclear</option>
                                            <option>Context-dependent</option>
                                        </b-form-select></p>
                                        <b-form-select class="form-control" id="exampleFormControlSelect1">
                                            <option>Good outcome</option>
                                            <option>Intermediate</option>
                                            <option>Poor outcome</option>
                                            <option>Unclear</option>
                                            <option>Context-dependent</option>
                                        </b-form-select>
                                    </b-col>
                                    <b-col cols="1">
                                        Review status<br>
                                        <b-icon class="h5 mb-2" icon="check-square"></b-icon>
                                        <b-icon class="h5 mb-2" icon="square"></b-icon>
                                        <b-icon class="h5 mb-2" icon="x-square"></b-icon>
                                    </b-col>
                                    <b-col cols="2">
                                        <b-textarea class="summary-box" rows="3" placeholder="Comment..." />
                                    </b-col>
                                </b-row>
                            </b-container>
                        </b-card-text>
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
import { BIcon, BIconSquare, BIconCheckSquare, BIconXSquare } from 'bootstrap-vue'
import ulog from 'ulog';

const log = ulog('VariantDisease');

export default {
    name: "VariantDisease",
    components: {
        BIcon,
        BIconSquare,
        BIconCheckSquare,
        BIconXSquare
    },
    props: {
        variant: { type: Object, required: false }
    },
    data() {
        return {
            summary: null,
            history_entry_id: null,

            loading: false,
            error: null,
            channel: new BroadcastChannel("curation-update"),
            showAliases: true,
        };
    },
    created() {
        this.channel.onmessage = () => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };
    },
    computed: {

    },
    methods: {
        saveSummary() {
            if (!this.variant.svip_data) {
                return HTTP.post('/variants_in_svip', { variant: this.variant.url, summary: this.summary })
                    .then((response) => {
                        this.variant.svip_data = response.data;
                        this.summary = response.data.summary;
                        this.$snotify.success("Summary updated! (SVIP variant created, too.)");
                    })
                    .catch((err) => {
                        log.warn(err);
                        this.$snotify.error("Failed to update summary");
                    })
            }

            HTTP.patch(`/variants_in_svip/${this.variant.svip_data.id}/`, { summary: this.summary })
                .then((response) => {
                    this.summary = response.data.summary;
                    this.$snotify.success("Summary updated!");
                })
                .catch((err) => {
                    log.warn(err);
                    this.$snotify.error("Failed to update summary");
                })
        }
    }
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
