<template>
    <div class="row">
        <div class="col-xl-3 col-4">
            <b-card>
                <h6 class="card-subtitle mb-2 text-muted">
                    Diseases
                    <i class="float-right" v-if="!currentFilter.disease">click on a disease to filter the evidences
                        table</i>
                    <span class="float-right badge badge-primary" v-if="currentFilter.disease" style="font-size: 13px">
						{{ titleCase(currentFilter.disease) }}
						<button type="button" class="close small ml-3" aria-label="Close" style="font-size: 14px"
                            @click="currentFilter.disease = ''">
								<span aria-hidden="true">&times;</span>
						</button>
					</span>
                </h6>
                <table class="table table-sm table-hover filtering-table">
                    <thead>
                        <tr>
                            <th>Disease</th>
                            <th># of Occcurences</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="d in row.item.diseases_collapsed" :key="d.disease"
                            @click="currentFilter.disease = d.disease"
                            :class="currentFilter.disease === d.disease ? 'pointer table-active' : 'pointer'">
                            <td>{{ titleCase(d.disease) }}</td>
                            <td>{{ d.count.toLocaleString() }}</td>
                        </tr>
                    </tbody>
                </table>
            </b-card>
        </div>

        <!-- FIXME: add filtering on categorical columns w/a dropdown -->

        <div class="col-xl-9 col-8">
            <b-card>
                <RowDetailsHeader name="Evidences" :total-rows="totalRows" v-model="currentFilter"/>

                <b-table
                    :fields="fields" class="table-sm filter-table" :api-url="apiUrl"
                    :items="association_provider"
                    :per-page="perPage" :current-page="currentPage" :filter="packedFilter"
                >
                    <template v-slot:cell(disease)="c">
                        <a v-if="c.item.evidence_url" :href="c.item.evidence_url" target="_blank">{{ c.value }}</a>
                        <span v-else>{{ c.value }}</span>
                    </template>
                    <template v-slot:cell(drug)="c">{{ normalizeItemList(c.value) }}</template>
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

                    <template v-slot:cell(actions)="row">
                        <div v-if="row.item.collapsed_count > 1" class="details-tray" style="text-align: right;">
                            <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
                            <b-button size="sm" small
                                @click.stop="row.item._animatedDetails = !row.item._animatedDetails">
                                {{ row.item._animatedDetails ? "Hide" : "Show" }} {{ row.item.collapsed_count }} Item(s)
                            </b-button>
                        </div>
                    </template>

                    <template v-slot:row-details="row">
                        <transition-expand>
                            <div v-if="row.item._animatedDetails">
                                <div class="sample-subtable tumor-subtable">
                                    <b-table class="sample-subtable-table" sort-by="url" :fields="evidenceChildFields"
                                        :items="row.item.children">
                                        <template v-slot:cell(url)="c">
                                            <a :href="c.value">EID {{ c.value.split("/")[11] }}</a>
                                        </template>

                                        <template v-slot:cell(publications)="c">
                                            <template v-for="(p, i) in c.value.map(parsePublicationURL)">
                                                <VariomesLitPopover
                                                    :pubmeta="p" :variant="variant.name" :gene="variant.gene.symbol"
                                                    :disease="row.item.disease"
                                                    :key="`${i}_link`"
                                                />
                                                <span :key="`${i}_comma`"
                                                    v-if=" i < c.item.publications .length - 1">, </span>
                                            </template>
                                        </template>
                                    </b-table>
                                </div>
                            </div>
                        </transition-expand>
                    </template>
                </b-table>

                <b-pagination v-if="totalRows > perPage" v-model="currentPage" :total-rows="totalRows"
                    :per-page="perPage"/>
            </b-card>
        </div>
    </div>
</template>

<script>
import { normalizeItemList, parsePublicationURL, titleCase } from "@/utils";
import RowDetailsHeader from "@/components/genes/variants/sources/shared/RowDetailsHeader";
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";
import { makeCollapsedAssociationProvider } from "@/components/genes/variants/item_providers/collapsed_association_provider";
import TransitionExpand from "@/components/widgets/TransitionExpand";
import { makeAssociationProvider } from "@/components/genes/variants/item_providers/association_provider";

// if true, aggregate evidences with mostly the same values under a single entry
const isCollapsed = true;

export default {
    name: "CivicRowDetails",
    components: {TransitionExpand, RowDetailsHeader, VariomesLitPopover},
    props: {
        row: {type: Object, required: true},
        variant: {type: Object, required: true}
    },
    data() {
        return {
            currentFilter: {
                disease: '',
                search: ''
            },
            testExpand: false,
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
                    key: "evidence_type",
                    label: "Evidence Type",
                    sortable: true
                },
                {
                    key: "evidence_direction",
                    label: "Direction",
                    sortable: true
                },
                {
                    key: "clinical_significance",
                    label: "Clinical Significance",
                    sortable: true
                },
                {
                    key: isCollapsed ? "evidence_levels" : "evidence_level",
                    label: "Evidence Level(s)",
                    sortable: true
                },
                {
                    key: "drug_labels",
                    label: "Drug",
                    sortable: true
                },
                {
                    key: "publications",
                    label: "References",
                    sortable: false
                },
                {
                    key: "actions",
                    label: "",
                    sortable: false
                }
            ],
            evidenceChildFields: [
                {key: "url", label: "Source", sortable: true},
                {key: "evidence_level", label: "Evidence Level", sortable: true},
                {key: "publications", label: "Reference(s)", sortable: true},
            ]
        }
    },
    computed: {
        packedFilter() {
            return JSON.stringify(this.currentFilter);
        },
        apiUrl() {
            return isCollapsed ? this.row.item.collapsed_associations_url : this.row.item.associations_url;
        },
        association_provider() {
            if (isCollapsed) {
                return makeCollapsedAssociationProvider(this.metaUpdated);
            }
            return makeAssociationProvider(this.metaUpdated);
        }
    },
    methods: {
        metaUpdated({count}) {
            this.totalRows = count;
        },
        normalizeItemList,
        titleCase,
        parsePublicationURL
    }
}
</script>

<style scoped>
.details-tray button {
    min-width: 120px;
}

.sample-subtable-table {
    background: none !important;
}
</style>
