<template>
    <div class="row">
        <div class="col-xl-3 col-4 d-none d-xl-block">
            <b-card>
                <h6 class="card-subtitle mb-2 text-muted">
                    {{ $t("Diseases")}}
                    <i class="float-right" v-if="!currentFilter.phenotype__term">
                        {{ $t("click on a disease to filter the table")}}
                    </i>
                    <span
                        class="float-right badge badge-primary filter-phenotype__term"
                        v-if="currentFilter.phenotype__term"
                        style="font-size: 13px">
                        {{ titleCase(currentFilter.phenotype__term) }}
                        <button
                            type="button"
                            class="close small ml-3"
                            aria-label="Close"
                            style="font-size: 14px"
                            @click="currentFilter.phenotype__term = ''">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </span>
                </h6>
                <table class="table table-sm table-hover filtering-table">
                    <thead>
                        <tr>
                            <th>{{ $t("Disease")}}</th>
                            <th>{{ $t("# of Submissions")}}</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr
                            v-for="d in row.item.diseases"
                            :key="d.disease"
                            @click="currentFilter.phenotype__term = d.disease"
                            :class="
                                currentFilter.phenotype__term === d.disease
                                    ? 'pointer table-active'
                                    : 'pointer'
                            ">
                            <td>{{ titleCase(d.disease) }}</td>
                            <td>{{ d.count.toLocaleString() }}</td>
                        </tr>
                    </tbody>
                </table>
            </b-card>
        </div>

        <!-- FIXME: add filtering on categorical columns w/a dropdown -->

        <div class="col-xl-9 col-8 col-sm-12">
            <b-card>
                <RowDetailsHeader name="Diseases" :total-rows="totalRows" v-model="currentFilter" />

                <b-table
                    :fields="fields"
                    class="table-sm filter-table"
                    :api-url="row.item.associations_url"
                    :items="assocation_provider"
                    :per-page="perPage"
                    :current-page="currentPage"
                    :filter="packedFilter">
                    <template v-slot:cell(disease)="c">
                        <a v-if="c.item.evidence_url" :href="c.item.evidence_url" target="_blank">
                            {{ c.value }}
                        </a>
                        <span v-else>{{ c.value }}</span>
                    </template>
                    <template v-slot:cell(drug)="c">{{ normalizeItemList(c.value) }}</template>
                    <template v-slot:cell(publications)="c">
                        <template v-for="(p, i) in c.value">
                            <VariomesLitPopover
                                :pubmeta="p"
                                :variant="variant.name"
                                :gene="variant.gene.symbol"
                                :disease="c.item.disease"
                                :key="`${i}_link`" />
                            <span :key="`${i}_comma`" v-if="i < c.item.publications.length - 1">,</span>
                        </template>
                    </template>
                </b-table>

                <b-pagination
                    v-if="totalRows > perPage"
                    v-model="currentPage"
                    :total-rows="totalRows"
                    :per-page="perPage" />
            </b-card>
        </div>
    </div>
</template>

<script>
import {normalizeItemList, titleCase} from '@/utils';
import {makeAssociationProvider} from '@/components/genes/variants/item_providers/association_provider';
import RowDetailsHeader from '@/components/genes/variants/sources/shared/RowDetailsHeader';
import VariomesLitPopover from '@/components/widgets/VariomesLitPopover';

export default {
    name: 'ClinvarRowDetails',
    components: {RowDetailsHeader, VariomesLitPopover},
    props: {
        row: {type: Object, required: true},
        variant: {type: Object, required: true},
    },
    data() {
        return {
            currentFilter: {
                phenotype__term: '',
                search: '',
            },
            currentPage: 1,
            perPage: 20,
            totalRows: this.row.item.association_count,
            fields: [
                {
                    key: 'disease',
                    label: 'Disease',
                    sortable: true,
                },
                // {
                // 	key: "evidence_type",
                // 	label: "Evidence Type",
                // 	sortable: true
                // },
                {
                    key: 'clinical_significance',
                    label: 'Interpretation',
                    sortable: true,
                },
                {
                    key: 'evidence_level',
                    label: 'Assertion Criteria',
                    sortable: true,
                },
                {
                    key: 'extras.num_submissions',
                    label: '# of Submissions',
                    sortable: true,
                },
                // {
                // 	key: "publications",
                // 	label: "References",
                // 	sortable: false
                // },
            ],
        };
    },
    computed: {
        packedFilter() {
            return JSON.stringify(this.currentFilter);
        },
        assocation_provider() {
            return makeAssociationProvider(this.metaUpdated, {
                'disease': 'phenotype__term',
                'contexts': 'environmentalcontext__description',
                'extras.num_submissions': 'extras__num_submissions',
            });
        },
    },
    methods: {
        metaUpdated({count}) {
            this.totalRows = count;
        },
        makeAssociationProvider,
        normalizeItemList,
        titleCase,
    },
};
</script>

<style scoped></style>
