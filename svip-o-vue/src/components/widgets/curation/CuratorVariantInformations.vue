<template>
    <b-card class="shadow-sm mb-3" align="left" no-body>
        <b-card-body class="p-0">
            <b-table
                v-if="variant"
                class="mb-0"
                :items="allVariants"
                :fields="visibleFields"
                show-empty
                empty-text="There seems to be an error"
            >
                <template v-slot:cell(gene)="row">
                    <router-link
                        class="font-weight-bold"
                        :to="{ name: 'gene', params: { gene_id: row.item.gene.id }}"
                        target="_blank"
                    >{{ row.item.gene.symbol }}
                    </router-link>
                </template>
                <template v-slot:cell(name)="data">
                    <router-link
                        class="font-weight-bold"
                        :to="{ name: 'variant', params: { gene_id: data.item.gene.id, variant_id: data.item.id }}"
                        target="_blank"
                    >{{ data.value }}</router-link>
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
                <template v-slot:cell(additional_var)>
                    {{ additionalVariants.join(", ") }}
                </template>

                <template v-if="multiple" v-slot:custom-footer>
                </template>
            </b-table>
            <div v-else class="m-2">
                <b-spinner small />
            </div>
        </b-card-body>
    </b-card>
</template>

<script>
import { HTTP } from "@/router/http";
import fields from "@/data/curation/summary/fields.json";
import { var_to_position } from "@/utils";

export default {
    name: "CuratorVariantInformations",
    props: {
        variant: {
            required: true
        },
        disease_id: {
            type: Number,
            required: false
        },
        multiple: {
            type: Boolean,
            default: false
        }
    },
    data() {
        return {
            additionalVariants: [],
            fields,
            showCurationTool: false,
            extraVariants: [],
            disease_name: null,
            pathogenicity: null,
            clinical_significance: null,
            channel: new BroadcastChannel("curation-update")
        };
    },
    created() {
        this.refresh();
        // deal with updates from people editing curation entries, which could change pathogenicity/clinical sig.
        this.channel.onmessage = () => {
            this.refresh();
        };
        console.log("flag")
        this.getRows()
        //console.log(this.apiUrl())
    },
    methods: {
        refresh() {
            HTTP.get(this.variantInfoUrl).then(response => {
                const { disease, pathogenic, clinical_significance } = response.data;
                //this.additional_var
                this.disease_name = disease && disease.name;
                this.pathogenicity = pathogenic;
                this.clinical_significance = clinical_significance;
            });

        },
        apiUrl() {
            const params = [
                this.variant && `variant_ref=${this.variant.id}`,
                // this.disease_id && `disease=${this.disease_id}`,
                this.filterCurator && `owner=${this.userID}`,
                // FIXME: these two are mutually exclusive
                this.onlySubmitted && `status=submitted`,
                this.notSubmitted && `status_ne=submitted`
            ].filter(x => x);

            return `/curation_entries${params ? "?" + params.join("&") : ""}`;
        },
        getRows() {
            HTTP.get(this.apiUrl()).then(res => {
                const additionalVariants = []
                res.data.results.map(curation => {
                    curation.extra_variants.map(extra_var => {
                        if (!additionalVariants.includes(extra_var.description)) {
                            additionalVariants.push(extra_var.description)
                        }
                    })
                })
                console.log(additionalVariants)
                this.additionalVariants = additionalVariants;
            }).catch(err => {
                this.loading = { error: err };
            });
        }
    },
    computed: {
        visibleFields() {
            //const additional_var = {
            //    "key": "addition_var",
            //    "label": "Additional variants",
            //    "sortable": false
            //}
            //fields.splice(2, 0, additional_var);
            fields.push({
                "key": "additional_var",
                "label": "Additional variants",
                "sortable": false
            })
            return (!this.disease_id)
                ? fields.filter(x => x.key !== 'disease')
                : fields;
        },
        variantInfoUrl() {
            if (!this.variant) {
                return null;
            }

            return `/variants/${this.variant.id}/curation_summary${ this.disease_id ? `?disease_id=${this.disease_id}` : ''}`;
        },
        var_position() {
            if (!this.variant) { return null; }
            return var_to_position(this.variant);
        },
        allVariants() {
            return [this.variant, ...this.extraVariants]
        }
    }
};
</script>

<style>
</style>
