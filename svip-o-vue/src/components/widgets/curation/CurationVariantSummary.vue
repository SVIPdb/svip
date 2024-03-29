<template>
    <div>
        <b-card class="shadow-sm mb-3" align="left" no-body>
            <b-card-body class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    {{ $t("Variant Summary")}}
                    <b class="draft-header" v-bind:style="{display: this.draftDisplay}">{{ $t("[ DRAFT ]")}}</b>
                    <div v-if="date !== null" class="update">
                        {{ $t("Last update:")}}
                        <b class="date">
                            {{new Intl.DateTimeFormat('en-GB', { dateStyle: 'long', timeStyle: 'short' }).format(date)}}
                        </b>
                    </div>
                </h6>

                <b-card-text class="p-2 m-0">
                    <b-textarea
                        id="variant-summary"
                        class="summary-box"
                        v-on:input="changeSummary($event)"
                        rows="3"
                        :value="summaryModel"
                        v-bind:style="{
                            backgroundColor: this.summaryTextBackground,
                            height: textboxHeight,
                        }"
                        @input="summaryDraftBoolean" />
                </b-card-text>

                <b-card-footer class="d-flex justify-content-end p-2">
                    <b-button
                        class="mr-2 centered-icons"
                        variant="info"
                        v-b-tooltip="'History'"
                        @click="showHistory">
                        <icon name="history" label="History" />
                        History
                    </b-button>
                    <b-button
                        variant="warning"
                        class="mr-2 centered-icons"
                        :disabled="!showSummaryDraft"
                        @click="saveSummaryDraft">
                        {{ $t("Finish later")}}
                    </b-button>
                    <b-button
                        variant="danger"
                        class="mr-2 centered-icons"
                        :disabled="!showSummaryDraft"
                        @click="deleteSummaryDraft">
                        {{ $t("Delete this draft")}}
                    </b-button>
                    <b-button variant="success" class="centered-icons" @click="saveSummary">
                        {{ $t("Save Summary")}}
                    </b-button>
                </b-card-footer>
            </b-card-body>
        </b-card>

        <b-modal ref="history-modal" hide-footer static lazy scrollable size="lg" :title="`Summary History`">
            <div>
                <VariantInSVIPHistory v-if="history_entry_id" :entry_id="history_entry_id" />
                <div v-else>{{ $t("Error: no summary history available")}}</div>
            </div>
        </b-modal>
    </div>
</template>

<script>
// import fields from "@/data/curation/evidence/fields.js";
import {HTTP} from '@/router/http';
import BroadcastChannel from 'broadcast-channel';
import VariantInSVIPHistory from '@/components/widgets/curation/VariantInSVIPHistory';
import ulog from 'ulog';
import {mapGetters} from 'vuex';

const log = ulog('CurationVariantSummary');

export default {
    name: 'CurationVariantSummary',
    components: {VariantInSVIPHistory},
    props: {
        variant: {type: Object, required: false},
    },
    data() {
        return {
            summary: this.variant.svip_data && this.variant.svip_data.summary, // permanent summary (not draft)
            summaryDraft: null,
            showSummaryDraft: false,
            serverSummaryDraft: null, // defines whether a draft exists in the DB for this user and variant (if so: PATCH request instead of POST)

            date: null,
            changeDate: false,

            textboxHeight: '2rem',
            history_entry_id: null,
            loading: false,
            error: null,
            channel: new BroadcastChannel('curation-update'),
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
        if (this.variant.svip_data.calculate_summary_date) {
            this.date = new Date(this.variant.svip_data.calculate_summary_date);
        }
    },
    computed: {
        summaryModel() {
            // What is shown in the summary box
            return this.showSummaryDraft ? this.summaryDraft : this.summary;
        },
        ...mapGetters({
            user: 'currentUser',
        }),
        draftDisplay() {
            return this.showSummaryDraft ? 'inline-block' : 'none';
        },
        summaryTextBackground() {
            return this.showSummaryDraft ? 'rgb(248, 236, 210)' : 'white';
        },
    },
    methods: {
        convertRemToPixels(rem) {
            return rem * parseFloat(getComputedStyle(document.documentElement).fontSize);
        },
        summaryDraftBoolean() {
            //const regExp = /[a-zA-Z]/g;
            //if (regExp.test(this.summaryDraft) && this.summaryDraft !== this.summary) {
            if (this.summaryDraft != null && this.summaryDraft !== this.summary) {
                this.showSummaryDraft = true;
            } else {
                this.showSummaryDraft = false;
            }
        },
        getSummaryDraft() {
            // get already existing summary draft for this variant and user (if exists)
            HTTP.get(`/summary_draft/?variant=${this.variant.id}&owner=${this.user.user_id}`).then(
                response => {
                    const results = response.data.results;
                    if (results.length > 0) {
                        this.serverSummaryDraft = results[0];
                        this.summaryDraft = results[0].content;
                    }
                    this.summaryDraftBoolean();

                    const totalHeight = document.getElementById('variant-summary').scrollHeight;
                    const maxHeight = this.convertRemToPixels(14);
                    if (totalHeight > maxHeight) {
                        this.textboxHeight = maxHeight + 'px';
                    } else {
                        this.textboxHeight = totalHeight + 'px';
                    }
                }
            );
        },
        changeSummary(event) {
            this.summaryDraft = event;
        },
        saveSummaryDraft() {
            // Prepare a JSON containing parameters for SummaryDraft model
            const summaryDraftJSON = {
                content: this.summaryDraft,
                owner: this.user.user_id,
                variant: this.variant.id,
            };

            if (this.serverSummaryDraft === null) {
                // summaryDraft doesn't already exist (for this user and variant): post new
                HTTP.post(`/summary_draft/`, summaryDraftJSON)
                    .then(() => {
                        this.getSummaryDraft();
                        this.$snotify.success('Your draft has been posted');
                    })
                    .catch(err => {
                        log.warn(err);
                        this.$snotify.error('Failed to post new summary draft');
                    });
            } else {
                // summaryDraft already exists: modify it
                HTTP.patch(`/summary_draft/${this.serverSummaryDraft.id}`, {
                    content: this.summaryDraft,
                })
                    .then(() => {
                        this.getSummaryDraft();
                        this.$snotify.success('Your draft has been updated');
                    })
                    .catch(err => {
                        log.warn(err);
                        this.$snotify.error('Failed to update summary draft');
                    });
            }
        },
        deleteSummaryDraft() {
            // send a delete request only if SummaryDraft instance exists in the server
            if (this.serverSummaryDraft !== null) {
                HTTP.delete(`/summary_draft/${this.serverSummaryDraft.id}/`)
                    .then(() => {
                        this.serverSummaryDraft = null;
                        this.summaryDraft = null;
                        this.showSummaryDraft = false;
                        this.$snotify.success('Your draft has been deleted');
                    })
                    .catch(err => {
                        log.warn(err);
                        this.$snotify.error('Failed to delete your draft');
                    });
            } else {
                this.summaryDraft = null;
                this.showSummaryDraft = false;
                this.$snotify.success('Your draft has been deleted');
            }
        },
        saveSummary() {
            let params = {summary: this.summaryModel};

            if (this.date) {
                // following code block relies on VueConfirmDialog (imported in main.js and App.vue)
                this.$confirm({
                    message: `Change the modification date of this summary ?\n\n
                        If so, the current date will be replace the existing one.`,
                    button: {
                        no: 'Ignore',
                        yes: 'Update',
                    },

                    callback: confirm => {
                        if (confirm) {
                            this.changeDate = true;
                            params['summary_date'] = new Date().toJSON();
                        } else {
                            this.changeDate = false;
                        }
                        this.sendSummaryRequest(params);
                    },
                });
            } else {
                // no date for summary yet, so don't offer to ignore the date change
                this.changeDate = true;
                params['summary_date'] = new Date().toJSON();
                this.sendSummaryRequest(params);
            }
        },
        sendSummaryRequest(params) {
            //check if a summary draft exists in the DB to delete it
            if (!this.serverSummaryDraft) {
                // No summary draft in the DB
                if (!this.variant.svip_data) {
                    params['variant'] = this.variant.url;
                    return HTTP.post('/variants_in_svip', params)
                        .then(response => {
                            this.variant.svip_data = response.data;
                            this.$snotify.success('Summary updated! (SVIP variant created, too.)');
                            this.summary = response.data.summary;
                            this.summaryUpdateCallback();
                        })
                        .catch(err => {
                            log.warn(err);
                            this.$snotify.error('Failed to update summary');
                        });
                } else {
                    HTTP.patch(`/variants_in_svip/${this.variant.svip_data.id}/`, params)
                        .then(response => {
                            this.$snotify.success('Summary updated!');
                            this.summary = response.data.summary;
                            this.summaryUpdateCallback();
                        })
                        .catch(err => {
                            log.warn(err);
                            this.$snotify.error('Failed to update summary');
                        });
                }
            } else {
                // Update summary and delete draft in the same request
                // Provide var_id only if VariantInSVIP already existing (if not provided, the viewset will simply create it)
                if (this.variant.svip_data) {
                    params['var_id'] = this.variant.svip_data.id;
                }
                params['summary_draft_id'] = this.serverSummaryDraft.id;

                HTTP.post(`/update_variant_summary`, params)
                    .then(() => {
                        this.serverSummaryDraft = null;
                        this.$snotify.success('Summary updated!');
                        this.summary = this.summaryModel;
                        this.summaryUpdateCallback();
                    })
                    .catch(err => {
                        log.warn(err);
                        this.$snotify.error('Failed to update summary');
                    });
            }
        },
        summaryUpdateCallback() {
            this.summaryDraft = null;
            this.showSummaryDraft = false;
            if (this.changeDate) {
                this.date = new Date();
            }
        },
        showHistory() {
            this.$refs['history-modal'].show();
            this.history_entry_id = this.variant.svip_data.id;
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

.draft-header {
    margin-left: 1rem;
    color: rgb(248, 236, 210);
}

.update {
    right: 1rem;
    position: absolute;
    display: inline-block;
}

.date {
    margin-left: 0.5rem;
}
</style>
