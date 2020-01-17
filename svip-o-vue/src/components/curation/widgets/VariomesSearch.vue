<template>
    <b-card-body style="padding: 0;">
        <b-row class="textmining-paginator">
            <b-col>
                <expander v-model="isSearchParamsVisible" />&nbsp;
                <b>Results:</b>&nbsp;
                <span v-if="loadingVariomes">
                    <b-spinner small /> loading...
                </span>
                <span v-else>{{ totalRows && totalRows.toLocaleString() }}</span>
            </b-col>
            <b-col class="my-1">
                <b-form-group label="Per page" label-cols-sm="6" label-cols-md="4" label-cols-lg="3" label-align-sm="right" label-size="sm" label-for="perPageSelect" class="mb-0">
                    <b-form-select v-model="perPage" id="perPageSelect" size="sm" :options="pageOptions"/>
                </b-form-group>
            </b-col>

            <b-col class="my-1 pager-search">
                <b-pagination v-model="currentPage" :total-rows="totalRows" :per-page="perPage" align="fill" size="sm" class="my-0"/>
                <b-button size="sm" variant="info" :disabled="loadingVariomes" @click="query"><icon name="search" /> Query</b-button>
            </b-col>
        </b-row>

        <b-collapse class="search-params" :visible="isSearchParamsVisible">
            <b>Disease:</b>&nbsp;
            <v-select style="min-width: 400px; background: white;" v-model="disease" placeholder="select a disease to query"
                :options="diseases" label="name" :clearable="true"
            />
        </b-collapse>

        <div style="margin-top: 10px;">
            <div v-if="variomesError" class="text-center text-muted font-italic">
                <icon name="exclamation-triangle" scale="3" style="vertical-align: text-bottom; margin-bottom: 5px;" /><br />
                {{ variomesError.message }}<br />
                ({{ variomesError.reason }})
            </div>
            <b-table v-else show-empty :busy="variomes.length === 0" :items="variomes.publications" thead-class="unwrappable-header" :sort-by="sortBy" :sort-desc="sortDesc" :fields="fieldsTextMining" :current-page="currentPage" :per-page="perPage" small>
                <template v-slot:table-busy>
                    <div class="text-center text-danger my-2">
                        <b-spinner class="align-middle" small style="margin-right: 5px;" />
                        <strong>Loading...</strong>
                    </div>
                </template>
                <template v-slot:cell(id)="row">
                    <VariomesLitPopover
                        :pubmeta="{ pmid: row.item.id }"
                        :variant="variomes.query.variant"
                        :gene="variomes.query.gene"
                        :disease="variomes.query.disease"
                        deferred
                    />
                </template>
                <template v-slot:cell(title_highlight)="data">
                    <span v-html="data.value"></span>
                </template>
                <template v-slot:cell(action)="row">
                    <b-button
                        variant="success"
                        size="sm"
                        @click="addEvidenceFromList(row.item.id)"
                        target="_blank"
                    >
                        <icon name="plus" />
                    </b-button>
                </template>
                <template v-slot:cell(authors)="data">{{ data.value.join(", ") }}</template>
                <template v-slot:cell(publication_type)="data">{{ data.value.join(", ") }}</template>
                <template v-slot:cell(score)="data">
                    <b class="dotted-line" :ref="data.item.id">{{ data.value.toFixed(2) }}</b>
                    <b-tooltip :target="() => $refs[data.item.id]">
                        <ul class="p-0 m-0">
                            <li class="d-flex justify-content-between align-items-center gene">
                                {{variomes.query.genes_variants[0].gene}}
                                <span class="text-white pl-1">{{data.item.details.query_details.query_gene_count.all}}</span>
                            </li>
                            <li class="d-flex justify-content-between align-items-center variant">
                                {{variomes.query.genes_variants[0].variant}}
                                <span class="text-white pl-1">{{data.item.details.query_details.query_variant_count.all}}</span>
                            </li>
                            <li class="d-flex justify-content-between align-items-center disease">
                                {{variomes.query.disease}}
                                <span class="text-white pl-1">{{data.item.details.query_details.query_disease_count.all}}</span>
                            </li>
                        </ul>
                    </b-tooltip>
                </template>
            </b-table>
        </div>
    </b-card-body>
</template>

<script>
import { mapGetters } from "vuex";
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";
import fieldsTextMining from "@/data/curation/text_mining/fields.json";
import store from "@/store";
import { desnakify } from "@/utils";
import { HTTP } from "@/router/http";

export default {
    name: "VariomesSearch",
    components: {
        VariomesLitPopover
    },
    props: {
        variant: { type: Object, required: true },
        gene: { type: Object, required: true },
    },
    data() {
        return {
            fieldsTextMining,
            source: "PMID",
            reference: null,
            variomes: [],
            loadingVariomes: true,
            variomesError: null,
            totalRows: 0,
            sortBy: "score",
            sortDesc: true,
            currentPage: 1,
            perPage: 10,
            pageOptions: [10, 20, 30],

            isSearchParamsVisible: false,
            disease: null,
            diseases: []
        };
    },
    computed: {
        disease_id() {
            return parseInt(this.$route.params.disease_id);
        }
    },
    // components: {geneVariants: geneVariants},
    methods: {
        desnakify,
        addEvidenceFromList(id) {
            this.$emit('add-evidence-from-list', id);
        },
        query() {
            console.log("Disease: ", this.disease);
            this.loadingVariomes = true;
            this.variomesError = null;
            HTTP.get(`variomes_search`, {
                params: {
                    genvars: `${this.variant.gene.symbol} (${this.variant.name})`,
                    disease: this.disease.name
                }
            })
                .then(response => {
                    this.variomes = response.data;
                    this.totalRows = this.variomes.publications.length;
                })
                .catch(err => {
                    this.variomesError = {
                        message: "Couldn't retrieve publication info, try again later.",
                        reason: err
                    };
                })
                .finally(() => { this.loadingVariomes = false; });
        }
    },
    async created() {
        const { disease_id } = this.$route.params;

        // first, get all the diseases
        this.diseases = await HTTP.get(`/diseases?page_size=9999`).then(response => response.data.results);
        // preselect the one we found
        this.disease = this.diseases.find(x => x.id == disease_id);

        // then, query variomes based on that data
        this.query();
    }
};
</script>

<style scoped>
.textmining-paginator {
    border-bottom: solid 1px #ddd; padding-bottom: 10px; display: flex; align-items: baseline;
}

.search-params {
    padding: 10px;
    border-bottom: solid 1px #ddd; display: flex; align-items: baseline;
    background: #eee;
}

.pager-search {
    display: flex;
    flex-direction: row;
    align-items: center;
}
.pager-search .pagination {
    flex: 1 0;
    margin-right: 5px;
}
</style>
