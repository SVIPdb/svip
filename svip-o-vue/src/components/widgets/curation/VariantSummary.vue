<template>
    <div>
        <b-card class="shadow-sm mb-3" align="left" no-body>
            <b-card-body class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    Variant Summary
                </h6>

                <b-card-text class="p-2 m-0">
                    <b-textarea class="summary-box" v-on:input="changeSummary($event)" rows="3" :value=summary />
                </b-card-text>

                <b-card-footer class="d-flex justify-content-end p-2">
                    <b-button
                        class="mr-2 centered-icons"
                        variant="info"
                        v-b-tooltip="'History'"
                        @click="showHistory"
                    >
                        <icon name="history" label="History" /> History
                    </b-button>
                    <!--<b-button variant="success" class="centered-icons" @click="saveAsADraft">-->
                    <b-button variant="warning" class="mr-2 centered-icons" :disabled=!showSummaryDraft>
                        Save as a draft
                    </b-button>
                    <b-button variant="danger" class="mr-2 centered-icons" :disabled=!showSummaryDraft>
                        Delete this draft
                    </b-button>
                    <b-button variant="success" class="centered-icons" @click="saveSummary">
                        Save Summary
                    </b-button>
                </b-card-footer>
            </b-card-body>
        </b-card>

        <b-modal ref="history-modal"
            hide-footer static lazy scrollable size="lg"
            :title="`Summary History`"
        >
            <div>
                <VariantInSVIPHistory v-if="history_entry_id" :entry_id="history_entry_id" />
                <div v-else>Error: no summary history available</div>
            </div>
        </b-modal>
    </div>
</template>

<script>
// import fields from "@/data/curation/evidence/fields.js";
import { HTTP } from "@/router/http";
import BroadcastChannel from "broadcast-channel";
import VariantInSVIPHistory from "@/components/widgets/curation/VariantInSVIPHistory";
import ulog from 'ulog';

const log = ulog('VariantSummary');

export default {
    name: "VariantSummary",
    components: { VariantInSVIPHistory },
    props: {
        variant: { type: Object, required: false }
    },
    data() {
        return {
            summary: this.variant.svip_data && this.variant.svip_data.summary,
            history_entry_id: null,

            loading: false,
            error: null,
            channel: new BroadcastChannel("curation-update"),
            summaryDraft: '',
            summaryInput: '' 
        };
    },
    mounted() {
        this.getSummaryDraft();
    },
    created() {
        this.channel.onmessage = () => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };
    },
    computed: {
        showSummaryDraft() {
            const regExp = /[a-zA-Z]/g;
            if (regExp.test(this.summaryInput) && this.summaryInput !== this.summary) {
                return true
            } else {
                return false
            }
        },
        summaryModel() {
            return this.showSummaryDraft ? this.summary : this.summaryDraft
        }
    },
    methods: {
        getSummaryDraft() {
            // get already existing summary comment for this variant and user (if exists)
            HTTP.get(`/summary_drafts/?variant=${this.variant.id}&owner=${this.user.user_id}`).then((response) => {
                const results = response.data.results

                if (results.length > 0) {
                    this.summaryDraft = results[0]
                    //this.summaryDraft = results[0].content
                }
            });
        },
        changeSummary(event) {
            console.log(event)
            this.summaryInput = event
        },
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
        },
        showHistory() {
            this.$refs["history-modal"].show();
            this.history_entry_id = this.variant.svip_data.id;
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
