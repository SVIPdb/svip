<template>
    <div class="card mt-3">
        <!-- <div>{{svip_entries}}</div> -->
        <div class="card-header">
            <div class="card-title">SVIP Information</div>
        </div>

        <div class="card-body top-level">
            <b-table
                v-if="svip_entries"
                :fields="fields"
                :items="svip_entries"
                :sort-by.sync="sortBy"
                :sort-desc="false"
                style="margin-bottom: 0; overflow-x: scroll;"
                show-empty
                ref="table"
            >
                <template v-slot:cell(display)="row">
                    <row-expander :row="row" />
                </template>

                <template v-slot:cell(name)="row">
                    {{ titleCase(row.item.name) }}
                </template>

                <template v-slot:cell(age)="data">
                    <age-distribution
                        :data="data.item.age_distribution"
                    ></age-distribution>
                </template>

                <template v-slot:cell(gender)="data">
                    <gender-plot :data="data.item.gender_balance"></gender-plot>
                </template>

                <template v-slot:cell(pathogenic)="data">
                    <div>
                        <span v-if="data.value">{{ data.value }}</span>
                        <span v-else class="unavailable">unavailable</span>
                    </div>
                </template>

                 <template v-slot:cell(clinical_significance)="data">
                    <evidenceTypesBarPlotVue :data="parseClinEvidencesForPlot(splitCurationEntries(data).pending)"></evidenceTypesBarPlotVue>
                </template>

                <template v-slot:cell(evidence_levels)="data">
                        <score-plot
                        :scores="parseClinEvidencesForPlot(splitCurationEntries(data).pending, filed='tier_level')"
                        :source-name="'svip'"
                    ></score-plot>
                    
                </template>

                <template v-slot:cell(last_modified)="data">
                    <pass :summary="curationSummary(data.item)">
                        <div slot-scope="{ summary }">
                            <span v-if="summary && summary.last_modified">
                                <b
                                    v-b-tooltip.hover="summary.modified_by.name"
                                    >{{ summary.modified_by.abbrev }}</b
                                >
                                on
                                <b
                                    v-b-tooltip.hover="
                                        summary.last_modified.time
                                    "
                                    >{{ summary.last_modified.date }}</b
                                >
                            </span>
                        </div>
                    </pass>
                </template>

                <template v-slot:cell(HEAD_actions)="row">
                    <div
                        style="
                            text-align: right;
                            padding-right: 5px;
                            display: none;
                        "
                    >
                        <b-button
                            size="sm"
                            variant="success"
                            :class="`expander-button ${
                                isAllExpanded ? 'is-expanded' : ''
                            }`"
                            @click.stop="() => setAllExpanded(!isAllExpanded)"
                            >{{ isAllExpanded ? "Collapse All" : "Expand All" }}
                        </b-button>
                    </div>
                </template>

                <!--
                <template v-slot:cell(actions)="row">
                    <div class="details-tray" style="text-align: right;">
                        <b-button v-access="'curators'" class="centered-icons" size="sm"
                            :to="{ name: 'annotate-variant', params: { gene_id: gene, variant_id: variant.id }}"
                        >
                            <icon name="tools" /> Curate
                        </b-button>
                    </div>
                </template>
                -->

                <template v-slot:row-details="row">
                    <div class="row-details">
                        
                        <pass :entries="splitCurationEntries(row)">
                            <b-card
                                no-body
                                slot-scope="{ entries }"
                                class="shadow mb-2"
                            >
                                <b-tabs
                                    v-model="svip_entry_tabs[row.item.name]"
                                    card
                                    :class="`svip-details-tabs selected-tab-${
                                        svip_entry_tabs[row.item.name]
                                    }`"
                                >
                                    <b-tab active>
                                        <template v-slot:title
                                            >Evidence
                                            <b-badge class="text-center">{{
                                                row.item.evidencesNum
                                            }}</b-badge></template
                                        >
                                        <EvidenceTable
                                            :variant="variant"
                                            :row="row"
                                            :diseaseName="row.item.name"
                                            @evidencesNum="displayEvidencesNum"
                                        />
                                        <!--<EvidenceTable :variant="variant" :row="row" :entries="entries.finalized" />-->
                                    </b-tab>

                                    <b-tab
                                        v-if="
                                            groups &&
                                            groups.includes('clinicians')
                                        "
                                    >
                                        <template v-slot:title
                                            >Samples
                                            <b-badge class="text-center">{{
                                                row.item.nb_patients
                                            }}</b-badge></template
                                        >
                                        <SampleTable
                                            :variant="variant"
                                            :row="row"
                                            :groups="groups"
                                        />
                                    </b-tab>

                                    <b-tab
                                        v-if="
                                            groups &&
                                            groups.includes('curators')
                                        "
                                    >
                                        <template v-slot:title
                                            >Curation
                                            <b-badge class="text-center">{{
                                                entries.pending.length
                                            }}</b-badge></template
                                        >
                                        <CurationTable
                                            :variant="variant"
                                            :row="row"
                                            :entries="entries.pending"
                                        />
                                    </b-tab>
                                </b-tabs>
                            </b-card>
                        </pass>
                    </div>
                </template>

                <template v-slot:empty>
                    <NoSVIPInfo />
                </template>
            </b-table>
            <NoSVIPInfo v-else />

            <div
                v-access="'curators'"
                class="paginator-holster mini-inset-tray"
            >
                <b-button
                    v-access="'curators'"
                    class="centered-icons mr-2"
                    size="sm"
                    style="width: 200px"
                    variant="info"
                    :to="{
                        name: 'svipinfo',
                        params: { gene_id: gene.id, variant_id: variant.id },
                    }"
                >
                    Svip Information Summary
                </b-button>

                <b-button
                    v-access="'curators'"
                    class="centered-icons"
                    size="sm"
                    style="width: 100px"
                    variant="info"
                    :to="{
                        name: 'annotate-variant',
                        params: { gene_id: gene, variant_id: variant.id },
                    }"
                >
                    <icon name="pen-alt" /> Curate
                </b-button>
            </div>
        </div>

        <!--
            <div class="card-body top-level">
                <TissueDistribution :tissue_counts="variant.svip_data.tissue_counts" />
            </div>
        -->
    </div>
</template>

<script>
import { mapGetters } from "vuex";
import store from "@/store";
import { abbreviatedName, titleCase } from "@/utils";
import { checkInRole } from "@/directives/access";

import ageDistribution from "@/components/plots/ageDistribution";
import genderPlot from "@/components/plots/genderPlot";
import EvidenceTable from "@/components/genes/variants/svip/EvidenceTable";
import CurationTable from "@/components/genes/variants/svip/CurationTable";
import SampleTable from "@/components/genes/variants/svip/SampleTable";
import dayjs from "dayjs";
import evidenceTypesBarPlotVue from "../../plots/evidenceTypesBarPlot.vue";
import scorePlot from "../../plots/scorePlot.vue";



const NoSVIPInfo = {
    name: "NoSVIPInfo",
    render: function (h) {
        h();

        return (
            <div
                class="text-muted font-italic text-center p-2 d-flex align-items-center justify-content-center"
                style="font-size: 150%;"
            >
                <icon
                    name="question-circle"
                    scale="1.5"
                    style="margin-right: 10px;"
                />
                <div>No SVIP sample information found</div>
            </div>
        );
    },
};

export default {
    name: "SVIPInfo",
    components: {
    SampleTable,
    EvidenceTable,
    CurationTable,
    ageDistribution,
    genderPlot,
    NoSVIPInfo,
    evidenceTypesBarPlotVue,
    scorePlot

}, // TissueDistribution
    props: {
        variant: { type: Object, required: true },
        gene: { type: String, required: true },
    },
    data() {
        return {
            // we're storing the selected tab per disease so that we can manipulate the selection with the per-disease buttons
            // FIXME: (which, incidentally, aren't even being displayed right now...maybe we just remove this?)
            svip_entry_tabs: this.variant.svip_data
                ? this.variant.svip_data.diseases.reduce((acc, x) => {
                    // map each entry in the SVIP table by ID to a selected tab for that entry (e.g., evidence or samples)
                    // by default, it'll be the first tab (evidence)
                    acc[x.name] = 0;
                    return acc;
                }, {})
                : {},
            sortBy: "name",
        };
    },
    methods: {
        parseClinEvidencesForPlot(entries, field='type_of_evidence') {
            let dataMap = new Map();
            for (const entry of entries) {
                if (entry[field]) {
                    if (!dataMap.has(entry[field])) {
                    dataMap.set(entry[field], 1)
                }   else {
                    dataMap.set(entry[field], dataMap.get(entry[field]) + 1)
                }
                } 
            }
            if (field === 'type_of_evidence') {
                return Array.from(dataMap, function (entry) {
                return { name: entry[0], count: entry[1] }
                    });
            } else {
                return Object.fromEntries(dataMap)
            }
            

        },
        displayEvidencesNum(evidencesNum) {
            // update the number of evidences calculated inside the child component
            this.svip_entries
                .filter((entry) => entry.id === evidencesNum.evidence_id)
                .map((row) => (row.evidencesNum = evidencesNum.value));
        },
        packedFilter(filters) {
            return JSON.stringify(filters);
        },
        setAllExpanded(isExpanded) {
            this.variant.svip_data.diseases.forEach((x) => {
                x._showDetails = isExpanded;
            });
        },
        curationCounts(item) {
            return {
                drafts: item.curation_entries.filter(
                    (x) => x.status === "draft"
                ).length,
                saved: item.curation_entries.filter((x) => x.status === "saved")
                    .length,
                submitted: item.curation_entries.filter(
                    (x) => x.status === "submitted"
                ).length,
            };
        },
        curationSummary(item) {
            let most_recent = null;

            if (!item.curation_entries || item.curation_entries.length <= 0) {
                return null;
            } else if (item.curation_entries.length === 1) {
                most_recent = item.curation_entries[0];
            } else {
                most_recent = [...item.curation_entries].sort((a, b) =>
                    dayjs(a.last_modified).diff(dayjs(b.last_modified))
                )[0];
            }

            const modify_date = dayjs(most_recent.last_modified);

            return {
                last_modified: {
                    date: modify_date.format("DD.MM.YYYY"),
                    time: modify_date.format("h:mm a"),
                },
                modified_by: abbreviatedName(most_recent.owner_name),
            };
        },
        splitCurationEntries(row) {
            const annotated_entries = row.item.curation_entries.map((x) => ({
                ...x,
                _showDetails: false,
            }));
            return {
                finalized: annotated_entries.filter(
                    (x) => x.status === "reviewed" || x.status === "unreviewed"
                ),
                pending: annotated_entries.filter(
                    (x) => x.status !== "reviewed"
                ),
            };
        },
        titleCase,
    },
    computed: {
        ...mapGetters({
            user: "currentUser",
        }),
        
        svip_entries() {
            if (
                !this.variant ||
                !this.variant.svip_data ||
                !this.variant.svip_data.diseases
            ) {
                return null;
            }

            const entries = [];
            this.variant.svip_data.diseases.map((disease) => {
                //if (entries.filter(entry => {return entry.name === disease.name}).length === 0) {}

                let diseaseItem = disease;
                diseaseItem.evidencesNum = 0;
                if (disease.name !== "Unspecified") {
                    entries.push(diseaseItem);
                } else if (disease.curation_entries.length > 0) {
                    entries.push(diseaseItem);
                }
            });
            return entries.map((x) => ({
                _showDetails: false,
                ...x,
            }));
        },
        hrefToSUmmary() {
            return (
                "http://localhost:8085/api/v1/variant_summary/?owner=all" +
                this.variant.id
            );
        },

        totalPatients() {
            return this.variant.svip_data.diseases.reduce(
                (acc, x) => acc + x.nb_patients,
                0
            );
        },
        groups() {
            return store.getters.groups;
        },
        isAllExpanded() {
            return this.variant.svip_data.diseases.every((x) => x._showDetails);
        },
        fields() {
            return [
                {
                    key: "display",
                    label: "",
                    sortable: false,
                },
                {
                    key: "name",
                    label: "Disease",
                    sortable: true,
                },
                {
                    key: "nb_patients",
                    label: "# of Samples",
                    formatter: (x) => `${x}/${this.totalPatients}`,
                    sortable: true,
                    class: "text-center",
                },
                {
                    key: "age",
                    label: "Age Distribution",
                    sortable: false,
                    class: "text-center d-none d-lg-table-cell",
                },
                {
                    key: "gender",
                    label: "Gender Balance",
                    sortable: false,
                    class: "text-center d-none d-lg-table-cell",
                },
                {
                    key: "pathogenic",
                    label: "Pathogenicity",
                    sortable: false,
                },
                {
                    key: "clinical_significance",
                    label: "Clinical Significance",
                    sortable: false,
                    class: "d-none d-lg-table-cell",
                },

                                {
                    key: "evidence_levels",
                    label: "Evidence Levels",
                    sortable: false,
                    class: "d-none d-md-table-cell",
                },
                //{
                //    key: "status",
                //    label: "Status",
                //    sortable: false
                //},
                //{
                //    key: "score",
                //    label: "SVIP Confidence",
                //    sortable: true,
                //    class: "text-center"
                //},
                {
                    key: "last_modified",
                    label: "Last Curated",
                    sortable: false,
                    class: [checkInRole("curators") ? "" : "d-none"],
                },
                /*
                {
                    key: "actions",
                    label: "",
                    sortable: false
                }
                 */
            ];
        },
    },
};
</script>

<style scoped>
svg.pathogenicity_level {
    margin-left: 50px;
}

rect.pathogenicity.expert {
    fill: #118644;
}

rect.pathogenicity.automatic {
    fill: #80fe07;
}

.tab-pane.card-body {
    padding: 10px 0 0 0;
}

.paginator-holster {
    padding-left: 15px;
}

.expander-button {
    width: 100px;
    border: solid 1px #eee;
    background: #eee;
}

.expander-button.is-expanded {
    opacity: 0.5;
}
</style>

<style>
/*.svip-details-tabs .card-header {background-color: #ccc;}*/

/*.svip-details-tabs { border: solid 2px #aaa; border-radius: 5px; }*/

.svip-details-tabs.selected-tab-0 .card-header {
    background-color: #8bd4c2;
}

.svip-details-tabs.selected-tab-1 .card-header {
    background-color: #c8bcca;
}

.svip-details-tabs.selected-tab-2 .card-header {
    background-color: #8bd4c2;
}

.svip-details-tabs .card-header a.nav-link.active {
    color: black;
}

.svip-details-tabs .card-header a.nav-link {
    color: #637fb0;
}

.nav-tabs .nav-item {
    margin-right: 3px;
}

.nav-tabs .nav-item .nav-link {
    padding: 5px 20px 8px;
}

.details-tray {
    text-align: right;
}

.details-tray .btn {
    width: 100px;
}

.paginator-holster {
    display: flex;
    padding-left: 15px;
    padding-top: 1em;
    border-top: solid 1px #ddd;
}

.mini-inset-tray {
    justify-content: flex-end;
    padding: 10px;
    background: #eee;
    margin: -3px; /* fixme: remove parent padding so we don't need a negative margin */
    box-shadow: inset 0 5px 5px -5px rgba(0, 0, 0, 0.1);
}
</style>
