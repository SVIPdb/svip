<template>
    <div class="card mt-3">
        <!-- <div>{{items}}</div> -->
        <div class="card-header">
            <div class="card-title">Publicly Available Information</div>
        </div>

        <div class="card-body top-level">
            <b-table
                :fields="fields"
                :items="items"
                :sort-by.sync="sortBy"
                :sort-desc="false"
            >
                <template v-slot:cell(actions)="row">
                    <!--
                    <div class="details-tray" style="text-align: right;">
                        <b-button
                            size="sm"
                            @click.stop="row.toggleDetails"
                        >{{ row.detailsShowing ? "Hide" : "Show" }} Details
                        </b-button>
                    </div>
                    -->
                    <row-expander :row="row" />
                </template>

                <template v-slot:cell(source)="row">
                    <div style="display: flex; align-items: center">
                        <SourceIcon
                            :name="row.item.source.name"
                            :size="20"
                            :margin-right="8"
                            :no-tip="true"
                        />
                        <a :href="row.item.variant_url" target="_blank">{{
                            row.item.source.display_name
                        }}</a>
                    </div>
                </template>

                <template v-slot:cell(diseases)="data">
                    <component
                        v-if="rowHasPart(data, 'diseases')"
                        :is="data.item.colum_parts.diseases"
                        :row="data"
                    />
                    <span v-else
                        >{{ Object.keys(data.item.diseases).length }} disease{{
                            Object.keys(data.item.diseases).length !== 1
                                ? "s"
                                : ""
                        }}</span
                    >
                </template>

                <template v-slot:cell(association_count)="data">
                    <component
                        v-if="rowHasPart(data, 'publication_count')"
                        :is="data.item.colum_parts.publication_count"
                        :row="data"
                    />
                    <span v-else
                        >{{ data.value.toLocaleString() }} evidence{{
                            data.value !== 1 ? "s" : ""
                        }}</span
                    >
                </template>

                <template v-slot:cell(clinical)="data">
                    <!-- <div>{{data.item.evidence_types}}</div> -->
                    <component
                        v-if="rowHasPart(data, 'clinical')"
                        :is="data.item.colum_parts.clinical"
                        :row="data"
                    />
                    
                    <evidenceTypesBarPlot
                        v-else
                        :data="data.item.evidence_types"
                    />
                </template>

                <template v-slot:cell(scores)="data">

                    <component
                        v-if="rowHasPart(data, 'scores')"
                        :is="data.item.colum_parts.scores"
                        :row="data"
                    />
                    <score-plot
                        v-else
                        :scores="data.item.scores"
                        :source-name="data.item.source.name"
                    ></score-plot>
                </template>

                <template v-slot:row-details="row">
                    <div class="row-details">
                        <component
                            v-if="row.item.details_part"
                            :is="row.item.details_part"
                            :row="row"
                            :variant="variant"
                        />
                        <div v-else>No row details control provided!</div>
                    </div>
                </template>
            </b-table>

            <div v-if="sourcesNotFound.length > 0" class="var-not-found">
                No data available for this variant in
                {{ sourcesNotFound.map((x) => x.display_name).join(", ") }}
            </div>
        </div>

    </div>
    
</template>

<script>
import store from "@/store";
import scorePlot from "@/components/plots/scorePlot";
// import significanceBarPlot from "@/components/plots/significanceBarPlot";
import evidenceTypesBarPlot from "@/components/plots/evidenceTypesBarPlot";
import { normalizeItemList } from "../../../utils";
import CosmicRowDetails from "./sources/cosmic/CosmicRowDetails";
import CosmicPubCountCol from "@/components/genes/variants/sources/cosmic/CosmicPubCountCol";
import UnavailableCol from "@/components/genes/variants/sources/shared/UnavailableCol";
import OncoKBRowDetails from "./sources/oncokb/OncoKBRowDetails";
import SourceIcon from "@/components/widgets/SourceIcon";
import CivicRowDetails from "@/components/genes/variants/sources/civic/CivicRowDetails";
import ClinvarRowDetails from "@/components/genes/variants/sources/clinvar/ClinvarRowDetails";
import SignificanceBarPlot from "@/components/genes/variants/sources/clinvar/SignificanceBarPlot";
import ClinvarPubCountCol from "@/components/genes/variants/sources/clinvar/ClinvarPubCountCol";

const overrides = {
    civic: {
        details_part: CivicRowDetails,
    },
    cosmic: {
        colum_parts: {
            clinical: UnavailableCol,
            publication_count: CosmicPubCountCol,
            scores: UnavailableCol,
        },
        details_part: CosmicRowDetails,
    },
    oncokb: {
        details_part: OncoKBRowDetails,
    },
    clinvar: {
        details_part: ClinvarRowDetails,
        colum_parts: {
            clinical: SignificanceBarPlot,
            publication_count: ClinvarPubCountCol,
            scores: UnavailableCol,
        },
    },
};

export default {
    name: "VariantPublicDatabases",
    components: { SourceIcon, scorePlot, evidenceTypesBarPlot },
    props: { variant: { type: Object, required: true } },
    data() {
        return {
            sortBy: "source",
            fields: [
                {
                    key: "actions",
                    label: "",
                    sortable: false,
                },
                {
                    key: "source",
                    label: "Source",
                    sortable: true,
                },
                {
                    key: "diseases",
                    label: "Diseases",
                    sortable: true,
                },
                {
                    key: "association_count",
                    label: "Database Evidences",
                    sortable: true,
                },
                {
                    key: "clinical",
                    label: "Clinical Significance / Interpretation",
                    sortable: false,
                    class: "d-none d-md-table-cell",
                },
                {
                    key: "scores",
                    label: "Evidence Levels",
                    sortable: false,
                    class: "d-none d-lg-table-cell",
                },
            ],
        };
    },
    computed: {
        items() {
            return this.variant.variantinsource_set.map((vis) => {
                return {
                    ...vis,
                    _showDetails: false,
                    filter: "",
                    colum_parts: overrides.hasOwnProperty(vis.source.name)
                        ? overrides[vis.source.name].colum_parts
                        : null,
                    details_part: overrides.hasOwnProperty(vis.source.name)
                        ? overrides[vis.source.name].details_part
                        : null,
                };
            });
        },
        sourcesNotFound() {
            // we're sure sources exists because we populated it from the store
            return store.state.genes.sources.filter(
                (x) =>
                    x.num_variants > 0 && // remove sources that have no variants across the board
                    !x.no_associations && // remove sources that shouldn't appear to have variants
                    !this.variant.variantinsource_set.find(
                        (y) => x.name === y.source.name
                    )
            );
        },
    },
    methods: {
        rowHasPart(row, part) {
            return row.item.colum_parts && row.item.colum_parts[part];
        },
        normalizeItemList,
    },
    created() {
        store.dispatch("getSources");
    },
};
</script>

<style scoped>
.var-not-found {
    background: #f5f5f5;
    -webkit-border-radius: 5px;
    -moz-border-radius: 5px;
    border-radius: 5px;
    padding: 10px;
    padding-left: 15px;
    font-style: italic;
    color: #999;
}

.details-tray button {
    width: 100px;
}
</style>
