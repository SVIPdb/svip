<template>
    <b-card-text>
        <b-table :fields="fields" :items="row.item.curation_entries" show-empty small>
            <template v-slot:cell(display)="row">
                <expander v-access="'curators'" :row="row"/>
            </template>
            <template v-slot:cell(references)="data">
                <VariomesLitPopover
                    :pubmeta="{ pmid: trimPrefix(data.value, 'PMID:') }"
                    :variant="variant.name"
                    :gene="variant.gene.symbol"
                    :disease="row.item.name"
                />
            </template>
            <template v-slot:row-details="row">
                <b-card v-access="'curators'" no-body class="border-0">
                    <b-container fluid>
                        <b-row class="p-3 bg-light">
                            <b-col>
                                <b>Complementary information</b>
                                <br/>
                                {{ row.item.summary }}
                                <br/>
                                <br/>
                                <b>Personal comment (Only for curators)</b>
                                <br/>
                                {{ row.item.comment == null ? '-' : row.item.comment }}
                            </b-col>
                        </b-row>
                    </b-container>
                </b-card>
            </template>
            <template v-slot:empty="scope">
                <div class="empty-table-msg">- no evidence items -</div>
            </template>
        </b-table>
    </b-card-text>
</template>

<script>
import VariomesLitPopover from "@/components/widgets/VariomesLitPopover";
import {trimPrefix} from "@/utils";
import {checkInRole} from "@/directives/access";

export default {
    name: "EvidenceTable",
    components: {VariomesLitPopover},
    props: {
        variant: {required: true, type: Object},
        row: {required: true, type: Object}
    },
    data() {
        return {
            fields: [
                {key: "display", label: "", sortable: false},
                {key: "type_of_evidence", label: "Evidence Type", sortable: true},
                {key: "effect", label: "Effect", sortable: true},
                {key: "drug", label: "Drug", sortable: true},
                {key: "tier_level_criteria", label: "Tier Criteria", sortable: true},
                {key: "tier_level", label: "Tier Level", sortable: true},
                {key: "mutation_origin", label: "Mutation Origin", sortable: true},
                {key: "summary", label: "Complementary Information", sortable: false},
                {key: "support", label: "Support", sortable: true},
                {key: "references", label: "References", sortable: false},
                {
                    key: "curator",
                    label: "Curator",
                    sortable: false,
                    thStyle: {display: this.checkInRole("curators") ? "" : "none"}
                },
                {
                    key: "date",
                    label: "Date",
                    sortable: true,
                    thStyle: {display: this.checkInRole("curators") ? "" : "none"}
                }
            ]
        };
    },
    methods: {
        trimPrefix,
        checkInRole
    }
};
</script>

<style scoped>
</style>
