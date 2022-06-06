<template>
    <div>
        <b-card class="shadow-sm mb-3" no-body>
            <b-card-body class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="showSummary"/>
                    {{ $t("Variant Summary")}}
                </h6>

                <transition name="slide-fade">
                    <div v-if="showSummary">
                        <b-card-text class="p-2 m-0">
                            <b-textarea class="summary-box" v-model="summary" rows="3"/>
                        </b-card-text>

                        <b-card-footer class="p-2 m-0">
                            <b-row align-v="center">
                                <b-col cols="10">
                                    <div v-for="(comment,index) in comments" :key="index">
                                        <b-alert :show="comment.content !== null" variant="light">
                                            <b>{{ comment.reviewer }}</b>: <p>{{ comment.content }}</p>
                                        </b-alert>
                                    </div>

                                </b-col>
                                <b-col cols="2" align-self="start">
                                    <b-button variant="success" block class="centered-icons">
                                        {{ $t("Save modifications")}}
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
// import { HTTP } from "@/router/http";
import BroadcastChannel from "broadcast-channel";
// import ulog from 'ulog';

// const log = ulog('VariantSummary');

export default {
    name: "ModifyVariantSummary",
    components: {},
    props: {
        variant: {type: Object, required: false},
        comments: {type: Array, required: true}
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
        if (this.isOpen) {
            this.showSummary = true;
        }
    },
    computed: {},
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
