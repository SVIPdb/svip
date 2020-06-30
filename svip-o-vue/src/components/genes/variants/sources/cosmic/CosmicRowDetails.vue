<template>
    <div class="row">
        <div class="col-3 col-sm-4">
            <!--
      -----------------------------------------------------------------------------------------------------
      --- disease filter
      -----------------------------------------------------------------------------------------------------
      -->
            <b-card>
                <h6 class="card-subtitle mb-2 text-muted">
                    Diseases
                    <i class="float-right" v-if="!currentFilter.phenotype__term">click on a disease to filter the
                        table</i>
                    <span class="float-right badge badge-primary filter-phenotype__term" v-else>
						{{ desnakify(currentFilter.phenotype__term) }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px"
                            @click="currentFilter.phenotype__term = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
                </h6>

                <table class="table table-sm table-hover filtering-table">
                    <thead>
                        <tr>
                            <th>Disease</th>
                            <th># of Samples</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="d in row.item.diseases" :key="d.disease"
                            @click="currentFilter.phenotype__term = d.disease"
                            :class="currentFilter.phenotype__term === d.disease ? 'pointer table-active' : 'pointer'">
                            <td>{{ desnakify(d.disease) }}</td>
                            <td>{{ d.count.toLocaleString() }}</td>
                        </tr>
                    </tbody>
                </table>
            </b-card>

            <!--
            -----------------------------------------------------------------------------------------------------
            --- tissue filter
            -----------------------------------------------------------------------------------------------------
            -->
            <b-card style="margin-top: 1em;">
                <h6 class="card-subtitle mb-2 text-muted">
                    Tissue Types
                    <i class="float-right" v-if="!currentFilter.environmentalcontext__description">click on a tissue
                        type to filter the table</i>
                    <span class="float-right badge badge-primary filter-environmentalcontext__description" v-else>
						{{ desnakify(currentFilter.environmentalcontext__description) }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px"
                            @click="currentFilter.environmentalcontext__description = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
                </h6>
                <table class="table table-sm table-hover filtering-table">
                    <thead>
                        <tr>
                            <th>Tissue Type</th>
                            <th># of Samples</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="d in row.item.contexts" :key="d.context"
                            @click="currentFilter.environmentalcontext__description = d.context"
                            :class="currentFilter.environmentalcontext__description === d.context ? 'pointer table-active' : 'pointer'">
                            <td>{{ desnakify(d.context) }}</td>
                            <td>{{ d.count.toLocaleString() }}</td>
                        </tr>
                    </tbody>
                </table>
            </b-card>
        </div>

        <!--
        =====================================================================================================
        === samples table
        =====================================================================================================
        -->
        <div class="col-9 col-sm-8">
            <b-card>
                <RowDetailsHeader name="Samples" :total-rows="totalRows" v-model="currentFilter"/>

                <b-table
                    :fields="fields" class="table-sm" :api-url="row.item.associations_url"
                    :items="makeAssociationProvider(this.metaUpdated)"
                    :per-page="perPage" :current-page="currentPage" :filter="packedFilter"
                >
                    <template v-slot:cell(disease)="c">
                        <a v-if="c.item.evidence_url" :href="c.item.evidence_url" target="_blank">{{ c.value }}</a>
                        <span v-else>{{ c.value }}</span>
                    </template>
                    <template v-slot:cell(contexts)="c">{{ desnakify(c.value) }}</template>
                    <template v-slot:cell(publications)="c">
                        <template v-for="(p, i) in c.value">
                            <VariomesLitPopover
                                :pubmeta="p" :variant="variant.name" :gene="variant.gene.symbol"
                                :disease="c.item.disease"
                                :key="`${i}_link`"
                            />
                            <span :key="`${i}_comma`" v-if=" i < c.item.publications .length - 1">, </span>
                        </template>
                    </template>
                </b-table>

                <b-pagination v-if="totalRows > perPage" v-model="currentPage" :total-rows="totalRows"
                    :per-page="perPage"/>
            </b-card>
        </div>
    </div>
</template>

<script>
import { desnakify, normalizeItemList, titleCase } from "@/utils";
import { makeAssociationProvider } from "../../item_providers/association_provider";
import RowDetailsHeader from "@/components/genes/variants/sources/shared/RowDetailsHeader";
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";

export default {
    name: "CosmicRowDetails",
    props: {
        row: {type: Object, required: true},
        variant: {type: Object, required: true}
    },
    components: {RowDetailsHeader, VariomesLitPopover},
    data() {
        return {
            currentFilter: {
                phenotype__term: '',
                environmentalcontext__description: '',
                search: ''
            },
            currentPage: 1,
            perPage: 20,
            totalRows: this.row.item.association_count,
            fields: [
                {
                    key: "disease",
                    label: "Disease",
                    sortable: true
                },
                {
                    key: "contexts",
                    label: "Tissue",
                    sortable: true
                },
                {
                    key: "publications",
                    label: "References",
                    sortable: false
                },
            ]
        }
    },
    computed: {
        packedFilter() {
            return JSON.stringify(this.currentFilter);
        }
    },
    methods: {
        metaUpdated({count}) {
            this.totalRows = count;
        },
        makeAssociationProvider,
        normalizeItemList,
        titleCase,
        desnakify
    }
}
</script>

<style scoped>
.badge {
    font-size: 13px;
    margin-left: 5px;
}

.filter-phenotype__term {
    background-color: #598059;
}

.filter-environmentalcontext__description {
    background-color: #596680;
}
</style>
