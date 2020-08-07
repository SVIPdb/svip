<template>
    <div>
        <b-card class="shadow-sm mb-3" align="left" no-body>
            <b-card-body class="p-0">
                <h6 class="bg-primary text-light unwrappable-header p-2 m-0">
                    <expander v-model="showAliases" />
                    Variant Summary
                </h6>

                <transition name="slide-fade">
                    <div v-if="showAliases">
                        <b-card-text class="p-2 m-0">
                            <b-textarea class="summary-box" v-model="summary" rows="3" readonly />
                        </b-card-text>

                        <b-card-footer class="d-flex justify-content-end p-2">
                            <b-button variant="success" class="centered-icons" @click="saveSummary"><!-- Ivo : Ouvrir nouvel onglet pour taper commentaire -->
                                Comment Summary
                            </b-button>
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
            showAliases: false,
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
