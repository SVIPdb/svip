<template>
    <b-card class="shadow-sm mb-3" align="left" no-body>
        <b-card-body class="p-0">
            <b-table
                :thead-class="theadClass"
                :tbody-class="tbodyClass"
                class="mb-0"
                :items="[variant]"
                :fields="fields"
                show-empty
                empty-text="There seems to be an error"
            >
                <template v-slot:cell(gene)="row">
                    <router-link
                        class="font-weight-bold"
                        :to="{ name: 'gene', params: { gene_id: $route.params.gene_id }}"
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
                <template v-slot:cell(disease)>{{ disease }}</template>
                <template v-slot:cell(pathogenicity)>{{ pathogenicity }}</template>
                <template v-slot:cell(clinical_significance)>{{ clinical_significance }}</template>
            </b-table>
        </b-card-body>
    </b-card>
</template>

<script>
import {change_from_hgvs, desnakify, var_to_position} from "@/utils";

export default {
    name: "VariantInformations",
    props: {
        variant: {
            type: Object,
            required: true
        },
        fields: {
            type: Array,
            required: true
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
            showCurationTool: false
        };
    },
    computed: {
        var_position() {
            return var_to_position(this.variant);
        },
        disease() {
            return this.variant.svip_data.diseases.find(
                element => element.id == this.$route.params.disease_id
            ).name;
        },
        pathogenicity() {
            return this.variant.svip_data.diseases.find(
                element => element.id == this.$route.params.disease_id
            ).pathogenic;
        },
        clinical_significance() {
            return this.variant.svip_data.diseases.find(
                element => element.id == this.$route.params.disease_id
            ).clinical_significance;
        }
    }
};
</script>

<style>
</style>
