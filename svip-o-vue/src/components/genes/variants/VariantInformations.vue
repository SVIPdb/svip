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
                empty-text="There seems to be an error">
                <template v-slot:cell(gene)="row">
                    <router-link
                        class="font-weight-bold"
                        :to="{name: 'gene', params: {gene_id: row.item.id}}">
                        {{ row.item.gene.symbol }}
                    </router-link>
                </template>
                <template v-slot:cell(name)="data">
                    <b>{{ data.value }}</b>
                </template>
                <template v-slot:cell(hgvs_c)="data">
                    <p class="mb-0">
                        <span class="text-muted">{{ data.value.split(':')[0] }}:</span>
                        {{ data.value.split(':')[1] }}
                    </p>
                </template>
                <template v-slot:cell(hgvs_p)="data">
                    <p class="mb-0">
                        <span class="text-muted">{{ data.value.split(':')[0] }}:</span>
                        {{ data.value.split(':')[1] }}
                    </p>
                </template>
                <template v-slot:cell(hgvs_g)="data">
                    <p class="mb-0">
                        <span class="text-muted">{{ data.value.split(':')[0] }}:</span>
                        {{ data.value.split(':')[1] }}
                    </p>
                </template>
                <template v-slot:cell(dbsnp_ids)="data">
                    <a
                        v-for="rsid in data.value"
                        :key="rsid"
                        :href="'https://www.ncbi.nlm.nih.gov/snp/' + rsid"
                        target="_blank">
                        {{ $t("rs")}}{{ rsid }}
                        <icon name="external-link-alt"></icon>
                    </a>
                </template>
                <template v-slot:cell(position)="row">
                    <p class="mb-0">
                        <span class="text-muted transcript-id">{{ row.item.reference_name }}:</span>
                        {{ var_position }}
                    </p>
                </template>
                <template slot="frequency">
                    <span v-if="allele_frequency">{{ allele_frequency }}</span>
                    <span v-else class="unavailable">{{ $t("unavailable")}}</span>
                </template>
            </b-table>
        </b-card-body>
    </b-card>
</template>

<script>
import {var_to_position} from '@/utils';
import {round} from 'lodash/math';

export default {
    name: 'VariantInformations',
    props: {
        variant: {
            type: Object,
            required: true,
        },
        fields: {
            type: Array,
            required: true,
        },
        theadClass: {
            type: String,
            required: false,
            default: '',
        },
        tbodyClass: {
            type: String,
            required: false,
            default: '',
        },
    },
    data() {
        return {
            showCurationTool: false,
        };
    },
    computed: {
        allele_frequency() {
            if (this.variant.mv_info) {
                if (this.variant.mv_info.gnomad_genome) {
                    return `gnomAD: ${round(this.variant.mv_info.gnomad_genome.af.af * 100.0, 4)}%`;
                } else if (this.variant.mv_info.exac) {
                    return `ExAC: ${round(this.variant.mv_info.exac.af * 100.0, 4)}%`;
                }
            }

            return null;
        },
        var_position() {
            return var_to_position(this.variant);
        },
    },
};
</script>

<style></style>
