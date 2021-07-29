<template>
    <div>
        <b-card class="shadow-sm mb-3" no-body>
            <b-card-body class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="showSummary" />
                    Variant Summary
                </h6>

                <transition name="slide-fade">
                    <div v-if="showSummary">
                        <b-card-text class="p-2 m-0">
                            <b-textarea class="summary-box" v-model="summary" rows="3" readonly />
                        </b-card-text>

                        <b-card-footer class="p-2 m-0">
                            <b-row align-v="center">
                                <b-col v-if="isEditMode || summaryComment !== ''" md="auto" class="font-weight-bold">Your comment :</b-col>
                                <b-col v-if="!isEditMode && summaryComment !== ''" class="text-justify">
                                    {{ summaryComment }}
                                </b-col>
                                <b-col v-if="isEditMode">
                                    <b-textarea v-model="summaryComment" class="summary-box" rows="3" />
                                </b-col>
                                <b-col v-if="!isEditMode">
                                    <b-button v-if="summaryComment === ''" @click="isEditMode = true" variant="success" class="float-right centered-icons">
                                        Comment summary
                                    </b-button>
                                    <b-button v-if="summaryComment !== ''" @click="isEditMode = true" variant="success" class="float-right centered-icons">
                                        Modify comment
                                    </b-button>
                                </b-col>
                                <b-col v-if="isEditMode" md="auto">
                                    <b-button @click="saveSummaryComment" :disabled="summaryComment === ''" variant="success" class="centered-icons">
                                        Save comment
                                    </b-button>
                                    <b-button @click="deleteSummaryComment" variant="danger" class="centered-icons mt-2">
                                        Delete comment
                                    </b-button>
                                </b-col>
                            </b-row>
                        </b-card-footer>
                    </div>
                </transition>
            </b-card-body>
        </b-card>
    </div>
</template>

<script>
// import fields from "@/data/curation/evidence/fields.js";
import { HTTP } from "@/router/http";
import BroadcastChannel from "broadcast-channel";
import ulog from 'ulog';
import {mapGetters} from "vuex";

const log = ulog('VariantSummary');

export default {
    name: "VariantSummary",
    components: {

    },
    props: {
        variant: { type: Object, required: false },
        isOpen: { type: Boolean, required: false, default: false }
    },
    data() {
        return {
            summary: this.variant.svip_data && this.variant.svip_data.summary,
            history_entry_id: null,
            loading: false,
            error: null,
            channel: new BroadcastChannel("curation-update"),
            showSummary: false,
            isEditMode: false,
            summaryComment: "",
            serverSummaryComment: null,
        };
    },
    mounted() {
        this.getSummaryComment();
    },
    created() {
        this.channel.onmessage = () => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };
        if(this.isOpen){
            this.showSummary = true;
        }
    },
    computed: {
        ...mapGetters({
            user: "currentUser"
        })
    },
    methods: {
        getSummaryComment() {
            // get already existing summary comment for this variant and user (if exists)
            HTTP.get(`/summary_comments/?variant=${this.variant.id}&owner=${this.user.user_id}`).then((response) => {
                const results = response.data.results

                if (results.length > 0) {
                    this.serverSummaryComment = results[0]
                    this.summaryComment = results[0].content
                } else {
                    this.serverSummaryComment = null
                }
            });
        },
        saveSummaryComment() {
            // Prepare a JSON containing parameters for SummaryComment model
            const summaryCommentJSON = {
                content: this.summaryComment,
                owner: this.user.user_id,
                variant: this.variant.id
            }


            if (this.serverSummaryComment === null) {
                // summaryComment doesn't already exist (for this user and variant): post new
                HTTP.post(`/summary_comments/`, summaryCommentJSON)
                    .then((response) => {
                        this.getSummaryComment();
                        this.isEditMode = false;
                        this.$snotify.success("Your comment has been posted");
                    })
                    .catch((err) => {
                        log.warn(err);
                        this.$snotify.error("Failed to post new summary comment");
                    })
            } else {
                // summaryComment already exists: modify it
                HTTP.patch(`/summary_comments/${this.serverSummaryComment.id}`, {content: this.summaryComment})
                    .then((response) => {
                        this.getSummaryComment();
                        this.isEditMode = false;
                        this.$snotify.success("Your comment has been updated");
                    })
                    .catch((err) => {
                        log.warn(err);
                        this.$snotify.error("Failed to update summary comment");
                    })
            }
        },
        deleteSummaryComment() {
            // send a delete request only if SummaryComment instance exists in the server
            if (this.serverSummaryComment !== null) {
                HTTP.delete(`/summary_comments/${this.serverSummaryComment.id}/`)
                    .then((response) => {
                        this.serverSummaryComment = null
                        this.summaryComment = "";
                        this.isEditMode = false;
                        this.$snotify.success("Your comment has been deleted");
                    })
                    .catch((err) => {
                        log.warn(err);
                        this.$snotify.error("Failed to update summary");
                    })
            } else {
                this.summaryComment = "";
                this.isEditMode = false;
                this.$snotify.success("Your comment has been deleted");
            }
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
