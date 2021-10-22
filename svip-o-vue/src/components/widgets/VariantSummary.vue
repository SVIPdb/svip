<template>
    <div>
        <b-card class="shadow-sm mb-3" no-body>
            <b-card-body class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="showSummary" />
                    Variant Summary
                    <div v-if="date !== null" class="update">Last update: 
                        <b class="date">
                            {{new Intl.DateTimeFormat('en-GB', { dateStyle: 'long', timeStyle: 'short' }).format(date)}}
                        </b>
                    </div>
                </h6>

                <transition name="slide-fade">
                    <div v-if="showSummary">
                        <b-card-text class="p-2 m-0">
                            <b-textarea class="summary-box" v-model="summary" rows="3" readonly />
                        </b-card-text>
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
            showSummary: true,
            isEditMode: false,
            summaryComment: "",
            serverSummaryComment: null,
            date: null
        };
    },
    mounted() {},
    created() {
        this.channel.onmessage = () => {
            if (this.$refs.paged_table) {
                this.$refs.paged_table.refresh();
            }
        };
        if(this.isOpen){
            this.showSummary = true;
        }

        if (this.variant.svip_data.calculate_summary_date) {
            this.date = new Date(this.variant.svip_data.calculate_summary_date)
        }
    },
    computed: {
        ...mapGetters({
            user: "currentUser"
        })
    },
    methods: {}
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

.update {
    right: 1rem;
    position: absolute;
    display: inline-block
}

.date {
    margin-left: 0.5rem;
}
</style>
