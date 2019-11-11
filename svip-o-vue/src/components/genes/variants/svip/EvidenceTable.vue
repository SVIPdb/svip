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
                <b-card v-access="'curators'" no-body class="border-0 p-3 bg-light">
                    <div style="margin-bottom: 1em;">
                        <b>Complementary information</b><br/>
                        {{ row.item.summary || '-' }}
                    </div>
                    <div>
                        <b>Personal comment (Only for curators)</b><br/>
                        {{ row.item.comment || '-' }}
                    </div>
                </b-card>
            </template>

            <template v-slot:cell(created_on)="data">
            {{ new Date(data.value).toLocaleString() }}
            </template>

            <template v-slot:empty="scope">
                <div class="empty-table-msg">no evidence items</div>
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
                    key: "owner_name",
                    label: "Curator",
                    sortable: false,
                    thStyle: {display: this.checkInRole("curators") ? "" : "none"}
                },
                {
                    key: "created_on",
                    label: "Date",
                    sortable: true,
                    thStyle: {display: this.checkInRole("curators") ? "" : "none"}
                }
            ].map(x => {
                if (!x.formatter) { x.formatter = (v) => v || '-'; }
                return x;
            })
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
