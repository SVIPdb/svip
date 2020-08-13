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

const log = ulog('VariantSummary');

export default {
    name: "VariantSummary",
    components: {
        
    },
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
            showSummary: true,
            isEditMode: false,
            summaryComment: "",
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
        saveSummaryComment() {
            this.isEditMode = false;
            this.$snotify.success("Your comment has been saved");
        },
        deleteSummaryComment() {
            this.summaryComment = "";
            this.isEditMode = false;
            this.$snotify.success("Your comment has been deleted");
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
