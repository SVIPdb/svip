<template>
    <!--
    /************************ LICENCE ***************************
    *     This file is part of <ViKM Vital-IT Knowledge Management web application>
    *     Copyright (C) <2016> SIB Swiss Institute of Bioinformatics
    *
    *     This program is free software: you can redistribute it and/or modify
    *     it under the terms of the GNU Affero General Public License as
    *     published by the Free Software Foundation, either version 3 of the
    *     License, or (at your option) any later version.
    *
    *     This program is distributed in the hope that it will be useful,
    *     but WITHOUT ANY WARRANTY; without even the implied warranty of
    *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    *     GNU Affero General Public License for more details.
    *
    *     You should have received a copy of the GNU Affero General Public License
    *    along with this program.  If not, see <http://www.gnu.org/licenses/>
    *
    *****************************************************************/
    -->

    <div class='container-fluid'>
        <div class='container'>
            <div class='card'>
                <div class='card-body'>
                    <h5 class="card-title"><b>{{gene.symbol}}:</b> {{phenotypes.length}} variants</h5>
                    <h6 v-if='gene.oncogene'>Oncogene</h6>

                    <dl class="row" style="margin-top: 0.75em;">
                        <dt class="col-2 text-right" style="white-space: nowrap;">Entrez ID</dt>
                        <dd class="col-10"><a :href="`https://www.ncbi.nlm.nih.gov/gene/?term=${gene.entrez_id}%5Buid%5D`" target="_blank">{{gene.entrez_id}}</a></dd>

                        <dt class="col-2 text-right" style="white-space: nowrap;">Ensembl Gene ID</dt>
                        <dd class="col-10"><a :href="`http://www.ensembl.org/Homo_sapiens/Gene/Summary?db=core;g=${gene.ensembl_gene_id}`" target="_blank">{{gene.ensembl_gene_id}}</a></dd>

                        <dt class="col-2 text-right" style="white-space: nowrap;">UniProtKB ID</dt>
                        <dd class="col-10"><a v-if="gene.uniprot_ids" :href="`https://www.uniprot.org/uniprot/${gene.uniprot_ids[0]}`" target="_blank" class="mr-3">{{gene.uniprot_ids[0]}}</a></dd>
                    </dl>
                </div>
            </div>

            <div class='container'>
                <div class='row'>
                    <div class='col-6'>
                        <b-form-group horizontal label="Filter" class="mb-0">
                            <b-input-group>
                                <b-form-input v-model="tableFilter" placeholder="Type to Search"/>
                                <b-input-group-append>
                                    <b-btn :disabled="!tableFilter" @click="tableFilter = ''">Clear</b-btn>
                                </b-input-group-append>
                            </b-input-group>
                        </b-form-group>
                    </div>

                    <div class="col-6 text-right">
                        <form>
                            <b-checkbox v-model="showOnlySVIP">show only SVIP variants</b-checkbox>
                        </form>
                    </div>
                </div>

            </div>

            <div class='container-fluid'>
                <b-table :fields='fields' :items='phenotypes' :sort-by.sync="sortBy" :sort-desc='true'
                         :filter='tableFilter'>
                    <template slot="hgvs_c" slot-scope="data" v-if="data.value">
                        <span class="text-muted">{{data.value.transcript}}:</span>{{data.value.change}}
                    </template>

                    <template slot="hgvs_p" slot-scope="data" v-if="data.value">
                        <span class="text-muted">{{data.value.transcript}}:</span>{{data.value.change}}
                    </template>

                    <template slot="hgvs_g" slot-scope="data" v-if="data.value">
                        <span class="text-muted">{{data.item.reference_name}}:</span>{{data.value}}
                    </template>

                    <template slot="action" slot-scope="data">
                        <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
                        <b-button size="sm" @click.stop="showVariant(data.item.id)">
                            Show Details
                        </b-button>
                    </template>
                </b-table>
            </div>
        </div>

    </div>
</template>

<script>

import {HTTP} from '@/router/http'
import {serverURL} from '@/app_config'
// import geneVariants from '@/components/Variants'
import {mapGetters} from 'vuex'
import store from '@/store'

import {change_from_hgvs, var_to_position} from '../../utils';

export default {
    data() {
        return {
            gene: {
                entrez_id: null,
                symbol: '',
                variants: []
            },
            confirmDeletion: false,
            itemsByPages: 10,
            itemsValue: [5, 10, 50, 100],
            fields: [
                {
                    key: 'name',
                    label: 'Name',
                    sortable: true
                }, {
                    key: 'hgvs_c',
                    label: 'HGVS coding',
                    formatter: (x) => change_from_hgvs(x, true),
                    sortable: true
                }, {
                    key: 'hgvs_p',
                    label: 'HGVS protein',
                    formatter: (x) => change_from_hgvs(x, true),
                    sortable: true
                }, {
                    key: 'hgvs_g',
                    label: 'Position',
                    formatter: (x, k, variant) => var_to_position(variant),
                    sortable: true
                }, {
                    key: 'so_name',
                    label: 'Molecular Consequence',
                    sortable: true
                },
                /*
                {
                    key: 'mock.tier_level',
                    label: 'Tier Level',
                    sortable: true
                },
                {
                    key: 'mock.SVIP_status',
                    label: 'Status',
                    sortable: true
                },
                {
                    key: 'mock.SVIP_confidence_score',
                    label: 'Score',
                    sortable: true
                },
                */
                {
                    key: 'action',
                    label: '',
                    sortable: false
                }
            ],
            sortBy: 'mock.SVIP_confidence_score',
            tableFilter: ''
        }
    },
    computed: {
        ...mapGetters({
            variants: 'variants',
            rawPhenotypes: 'phenotypes',
            geneVariants: 'geneVariants',
            svipVariants: 'svipVariants'
        }),
        showOnlySVIP: {
            get() {
                return store.state.genes.showOnlySVIP;
            },
            set(value) {
                store.dispatch('toggleShowSVIP', {showOnlySVIP: value});
            }
        },
        synonyms() {
            if (this.gene.geneAliases === undefined) return ''
            return this.gene.geneAliases.join(', ')
        },
        phenotypes() {
            let vm = this;

            // use the server's variants, but filter down to only the variants in the mock data
            // return the variants from the server merged with the mock data for that variant under the 'mock' key
            const variants = this.variants.filter(v => {
                return v.gene_symbol === vm.gene.symbol &&
                    (!this.showOnlySVIP || (
                        this.svipVariants.some((x) => x.gene_name === vm.gene.symbol && x.variant_name === v.name)
                    ));
            });

            return variants
                .map(v => {
                    return Object.assign(
                        v,
                        { mock: this.svipVariants.find((x) => x.gene_name === vm.gene.symbol && x.variant_name === v.name) }
                    )
                });

            // _.forEach(this.svipVariants,g => {
            // 	console.log(g);
            // 	let variant = {
            // 		id: g.variant_id,
            // 		name: g.name,
            // 		type: g.so_name,
            // 		sources: g.sources.join("; "),
            // 		cancerTypes: '',
            // 		Drugs: '',
            // 		levelOfEvidence: '',
            // 		nbArticles: '',
            // 		articles: []
            // 	};
            // 	variants.push(variant);
            // });
        }
    },
    // components: {geneVariants: geneVariants},
    methods: {
        setgene(gene) {
            this.gene = Object.assign({}, this.gene, gene)
        },
        showVariant(id) {
            this.$router.push('/gene/' + this.$route.params.gene_id + '/variant/' + id)
        },
        toggleShowOnlySVIP() {
            store.dispatch('toggleShowSVIP', { showOnlySVIP: !this.showOnlySVIP });
        }
    },
    beforeRouteEnter(to, from, next) {
        if (to.params.gene_id !== 'new') {
            HTTP.get('genes/' + to.params.gene_id).then(res => {
                const gene = res.data;
                store.commit('SELECT_GENE', gene)
                next(vm => vm.setgene(gene))
                // store.dispatch('listGeneVariants',{gene: gene.symbol}).then(res => {
                // 	next(vm => vm.setgene(gene));
                // })
            })
        }
    },
    beforeRouteUpdate(to, from, next) {
        if (to.params.gene_id !== 'new') {
            HTTP.get('genes/' + to.params.gene_id).then(res => {
                const gene = res.data;
                store.commit('SELECT_GENE', gene)
                next(vm => vm.setgene(gene))
                // store.dispatch('listGeneVariants',{gene: gene.symbol}).then(res => {
                // 	next(vm => vm.setgene(gene));
                // })
            })
        }
    },
    created() {
        const vm = this;
        store.dispatch('getGenes')
        store.dispatch('getVariants')
        store.dispatch('getPhenotypes')
        store.dispatch('getAssociations')
    }

}
</script>

<style>
.container, .container-fluid {
    margin-top: 20px;
}

</style>
