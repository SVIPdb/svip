<template>
    <div>
        <b-card class="shadow-sm mb-3" align="left" no-body>
            <b-card-body class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    Variant Summary
                    <b class='draft-header' v-bind:style="{display: this.draftDisplay}">[ DRAFT ]</b>
                </h6>

                <b-card-text class="p-2 m-0">
                    <b-textarea 
                        class="summary-box" 
                        v-on:input="changeSummary($event)" 
                        rows="3" 
                        :value=summaryModel
                        v-bind:style="{backgroundColor: this.summaryTextBackground}"
                    />
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
                    <b-button variant="warning" class="mr-2 centered-icons" :disabled=!showSummaryDraft @click="saveSummaryDraft">
                        Finish later
                    </b-button>
                    <b-button variant="danger" class="mr-2 centered-icons" :disabled=!showSummaryDraft @click="deleteSummaryDraft">
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
import {mapGetters} from "vuex";

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
            summaryDraft: '',
            serverSummaryDraft: null, // defines whether a draft exists in the DB for this user and variant (if so: PATCH request instead of POST)

            history_entry_id: null,
            loading: false,
            error: null,
            channel: new BroadcastChannel("curation-update"),
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
            if (regExp.test(this.summaryDraft) && this.summaryDraft !== this.summary) {
                return true
            } else {
                return false
            }
        },
        summaryModel() {
            return this.showSummaryDraft ? this.summaryDraft : this.summary
        },
        ...mapGetters({
            user: "currentUser"
        }),
        draftDisplay() {
            return this.showSummaryDraft ? 'inline-block' : 'none'
        },
        summaryTextBackground() {
            return this.showSummaryDraft ? 'rgb(248, 236, 210)' : 'white'
        }
    },
    methods: {
        getSummaryDraft() {
            // get already existing summary comment for this variant and user (if exists)
            HTTP.get(`/summary_draft/?variant=${this.variant.id}&owner=${this.user.user_id}`).then((response) => {
                const results = response.data.results
                if (results.length > 0) {
                    this.serverSummaryDraft = results[0]
                    this.summaryDraft = results[0].content
                    //this.summaryDraft = results[0].content
                }
            });
        },
        changeSummary(event) {
            this.summaryDraft = event
        },
        saveSummaryDraft() {
            // Prepare a JSON containing parameters for SummaryDraft model
            const summaryDraftJSON = {
                content: this.summaryDraft,
                owner: this.user.user_id,
                variant: this.variant.id
            }


            if (this.serverSummaryDraft === null) {
                // summaryDraft doesn't already exist (for this user and variant): post new
                HTTP.post(`/summary_draft/`, summaryDraftJSON)
                    .then(() => {
                        this.getSummaryDraft();
                        this.isEditMode = false;
                        this.$snotify.success("Your draft has been posted");
                    })
                    .catch((err) => {
                        log.warn(err);
                        this.$snotify.error("Failed to post new summary draft");
                    })
            } else {
                // summaryDraft already exists: modify it
                HTTP.patch(`/summary_draft/${this.serverSummaryDraft.id}`, {content: this.summaryDraft})
                    .then(() => {
                        this.getSummaryDraft();
                        this.isEditMode = false;
                        this.$snotify.success("Your draft has been updated");
                    })
                    .catch((err) => {
                        log.warn(err);
                        this.$snotify.error("Failed to update summary draft");
                    })
            }
        },
        deleteSummaryDraft() {
            // send a delete request only if SummaryComment instance exists in the server
            if (this.serverSummaryDraft !== null) {
                HTTP.delete(`/summary_draft/${this.serverSummaryDraft.id}/`)
                    .then(() => {
                        this.serverSummaryDraft = null
                        this.summaryDraft = "";
                        this.$snotify.success("Your draft has been deleted");
                    })
                    .catch((err) => {
                        log.warn(err);
                        this.$snotify.error("Failed to delete your draft");
                    })
            } else {
                this.summaryComment = "";
                this.isEditMode = false;
                this.$snotify.success("Your draft has been deleted");
            }
        },
        saveSummary() {
            if (!this.variant.svip_data) {
                return HTTP.post('/variants_in_svip', { variant: this.variant.url, summary: this.summaryModel })
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
            HTTP.patch(`/variants_in_svip/${this.variant.svip_data.id}/`, { summary: this.summaryModel })
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

.draft-header {
    margin-left: 3rem;
    color: rgb(248, 236, 210);
}
</style>
