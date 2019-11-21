<template>
    <div class="container">
        <div class="col-12">
            <h1>Debug Page</h1>
            <p>Try out your in-development components or other functionality on this page.</p>

            <b-card no-body>
                <b-tabs card>
                    <b-tab title="Search Bars">
                        <div class="page-section">
                            <h4>Variant Search Bar</h4>
                            <ul>
                                <li v-for="(a, idx) in selected_variants" :key="idx">{{ a }}</li>
                            </ul>
                            <SearchBar multiple variants-only v-model="selected_variants" />

                            <h3>Bind to Bar Test</h3>
                            <b-button @click="populateSearchBar">Populate Bar</b-button>&nbsp;
                            <b-button type="button" @click="clearBar">Clear Bar</b-button>
                        </div>

                        <div class="page-section">
                            <h4>Drug Search Bar</h4>
                            <ul>
                                <li v-for="(a, idx) in selected_drugs" :key="idx">{{ a.medicine_name }}</li>
                            </ul>
                            <DrugSearchBar v-model="selected_drugs" />
                        </div>

                        <div class="page-section">
                            <h4>Bare Vue-Select</h4>

                            <div>{{ JSON.stringify(bare_value) }}</div>

                            <v-select v-model="bare_value" :options="['A', 'B', 'C']" />

                            <b-button @click="bare_value = 'C'">populate bare w/C</b-button>
                        </div>

                        <div class="page-section">
                            <h4>Wrapped Vue-Select</h4>

                            <div>{{ JSON.stringify(wrapped_value) }}</div>

                            <WrappedSelect v-model="wrapped_value" />
                            <b-button @click="wrapped_value = 'C'">populate wrapped w/C</b-button>
                        </div>
                    </b-tab>

                    <b-tab title="Variant Info">
                        <div class="page-section">
                            <h4>Variant Information Header w/Mutable Body</h4>
                            <CuratorVariantInformations :variant="loaded_variant" :disease_id="177" multiple />
                        </div>
                    </b-tab>

                    <b-tab title="Generic Tables">
                        <div class="page-section">
                            <h4>Generic Paged Table</h4>

                            <PagedTable :apiUrl="`/curation_entries`" :fields="curation_fields">
                                <template v-slot:cell(created_on)="data">
                                    {{ simpleDateTime(data.value).date }}
                                </template>
                            </PagedTable>
                        </div>
                    </b-tab>
                </b-tabs>
            </b-card>
        </div>
    </div>
</template>

<script>
import SearchBar from "@/components/widgets/SearchBar";
import DrugSearchBar from "@/components/widgets/DrugSearchBar";
import CuratorVariantInformations from "@/components/curation/widgets/CuratorVariantInformations";
import {HTTP} from '@/router/http';
import PagedTable from "@/components/widgets/PagedTable";
import curation_fields from "@/data/curation/evidence/fields.json";
import WrappedSelect from "@/components/widgets/debug/WrappedSelect";
import {simpleDateTime} from "@/utils";

export default {
    name: "Debug",
    components: {WrappedSelect, PagedTable, CuratorVariantInformations, SearchBar, DrugSearchBar},
    data() {
        return {
            curation_fields,
            selected_variants: [],
            selected_drugs: [],
            loaded_variant: null,

            bare_value: 'C',
            wrapped_value: 'B'
        }
    },
    created() {
        // load an example variant and feed it into variant-informations
        HTTP.get(`/variants/119`).then(response => {
            console.log("Loaded variant: ", response.data);
            this.loaded_variant = response.data;
        });
    },
    methods: {
        simpleDateTime,
        populateSearchBar() {
            const item = { "id": 8, "g_id": 1, "type": "v", "label": "EGFR L858R (c.2573T>G)", "sources": [ "civic", "cosmic", "oncokb" ] };
            this.selected_variants = [item];
        },
        clearBar() {
            this.selected_variants = [];
        }
    }
}
</script>

<style scoped>
.page-section {
    margin-bottom: 2em;
}
</style>
