<template>
    <div>
        <b-spinner v-if="loading" />
        <div v-else-if="error">{{ error }}</div>
        <div v-else-if="history.deltas && history.deltas.length > 0">
            <div v-for="(entry, idx) in history.deltas">
                <b-table-simple bordered>
                    <caption>Change on {{ new Date(entry.time).toLocaleString() }}</caption>
                    <b-thead head-variant="light">
                        <b-tr>
                            <b-th style="width: 20%;">Field Name</b-th>
                            <b-th style="width: 20%;">Old</b-th>
                            <b-th></b-th>
                            <b-th style="width: 60%;">New</b-th>
                        </b-tr>
                    </b-thead>

                    <b-tbody>
                        <b-tr v-for="change in entry.changes">
                            <b-td>{{ change.field }}</b-td>
                            <b-td>{{ change.old || '-' }}</b-td>
                            <b-td>&rightarrow;</b-td>
                            <b-td><b>{{ change.new || '-' }}</b></b-td>
                        </b-tr>
                    </b-tbody>
                </b-table-simple>
            </div>
        </div>
        <div v-else style="text-align: center;">
            <i>No recorded history yet.</i>
        </div>
    </div>
</template>

<script>
import {HTTP} from '@/router/http';

export default {
    name: "EvidenceHistory",
    props: {
        entry_id: { type: Number, required: true }
    },
    data() {
        return {
            loading: true,
            error: null,
            history: null
        };
    },
    created() {
        this.refresh();
    },
    methods: {
        refresh() {
            HTTP.get(`/curation_entries/${this.entry_id}/history`)
                .then((result) => {
                    this.history = result.data;
                    this.loading = false;
                })
                .catch((err) => {
                    this.error = err;
                    throw err;
                })
        }
    }
}
</script>

<style scoped>

</style>
