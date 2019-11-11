<template>
    <div>
        <b-spinner v-if="loading" />
        <div v-else-if="error">{{ error }}</div>
        <div v-else>
            <div v-for="(entry, idx) in lean_history">
                <b-table-simple bordered :key="idx">
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
                            <b-td>
                                <ChangeField :value="change.old" />
                            </b-td>
                            <b-td>&rightarrow;</b-td>
                            <b-td>
                                <b><ChangeField :value="change.new" /></b>
                            </b-td>
                        </b-tr>
                    </b-tbody>
                </b-table-simple>
            </div>

            <div>
                <b>Created on:</b> {{ history.created_on ? new Date(history.created_on).toLocaleString() : 'unknown' }}
            </div>
        </div>
    </div>
</template>

<script>
import {HTTP} from '@/router/http';

const ChangeField = {
    props: {
        value: { required: true }
    },
    render(h) {
        let v;
        try {
            v = JSON.parse(this.value);
        }
        catch(e) {
            v = this.value;
        }

        if (Array.isArray(v)) {
            return h('ul', {class: 'items'}, v.map(x => {
                return h('li', null, x || '-')
            }))
        }

        return h('div', null, v || '-')
    }
};

export default {
    name: "EvidenceHistory",
    components: {ChangeField},
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
    computed: {
        lean_history() {
            return this.history.deltas.filter(d => d.changes.length > 0)
        }
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
.items {
    margin: 0;
    padding: 0 0 0 20px;
}
</style>
