<template>
    <b-card class="shadow-sm mb-3" align="left" no-body>
        <b-card-body class="p-0">
            <b-table
                v-if="variant"
                :thead-class="theadClass"
                :tbody-class="tbodyClass"
                class="mb-0"
                :items="allVariants"
                :fields="fields"
                show-empty
                empty-text="There seems to be an error"
            >
                <template v-slot:cell(gene)="row">
                    <router-link
                        class="font-weight-bold"
                        :to="{ name: 'gene', params: { gene_id: row.item.gene.id }}"
                    >{{ row.item.gene.symbol }}
                    </router-link>
                </template>
                <template v-slot:cell(name)="data">
                    <b>{{ data.value }}</b>
                </template>
                <template v-slot:cell(hgvs_c)="data">
                    <p class="mb-0">
                        <span class="text-muted">{{ data.value.split(":")[0] }}:</span>
                        {{ data.value.split(":")[1] }}
                    </p>
                </template>
                <template v-slot:cell(disease)>{{ disease_name }}</template>
                <template v-slot:cell(pathogenicity)>{{ pathogenicity }}</template>
                <template v-slot:cell(clinical_significance)>{{ clinical_significance }}</template>

                <template v-if="multiple" v-slot:custom-footer>
                    Add Variant
                </template>
            </b-table>
        </b-card-body>
    </b-card>
</template>

<script>
import fields from "@/data/curation/summary/fields.json";
import {change_from_hgvs, desnakify, var_to_position} from "@/utils";

export default {
    name: "CuratorVariantInformations",
    props: {
        variant: {
            type: Object,
            required: true
        },
        disease_id: {
            type: Number,
            required: true
        },
        multiple: {
            type: Boolean,
            default: false
        },
        theadClass: {
            type: String,
            required: false,
            default: ""
        },
        tbodyClass: {
            type: String,
            required: false,
            default: ""
        }
    },
    data() {
        return {
            fields,
            showCurationTool: false,
            extraVariants: []
        };
    },
    computed: {
        var_position() {
            return var_to_position(this.variant);
        },
        disease_from_var() {
            return this.variant.svip_data.diseases.find(
                element => element.disease_id === this.disease_id
            );
        },
        disease_name() {
            return this.disease_from_var.name;
        },
        pathogenicity() {
            return this.disease_from_var.pathogenic;
        },
        clinical_significance() {
            return this.disease_from_var.clinical_significance;
        },
        allVariants() {
            return [this.variant, ...this.extraVariants]
        }
    }
};
</script>

<style>
</style>
