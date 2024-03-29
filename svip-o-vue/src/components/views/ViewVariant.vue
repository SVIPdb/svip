<template>
    <div>
        <div class="container-fluid">
            <div class="card variant-card">
                <div class="card-body top-level">
                    <table class="table variant-header">
                        <tr>
                            <th></th>
                            <th>{{ $t("Gene Name")}}</th>
                            <th>{{ $t("Variant")}}</th>

                            <th>{{ $t("HGVS.c")}}</th>
                            <th class="d-none d-sm-table-cell">{{ $t("HGVS.p")}}</th>
                            <th class="d-none d-sm-table-cell">{{ $t("HGVS.g")}}</th>

                            <th :class="hiddenCols">{{ $t("dbSNP")}}</th>
                            <!-- <th>Molecular consequence</th> -->
                            <th :class="hiddenCols">{{ $t("Position")}}</th>
                            <th :class="hiddenCols">{{ $t("Allele Frequency")}}</th>
                            <th>{{ $t("Status")}}</th>
                            <th>{{ $t("SVIP Confidence")}}</th>
                            <th></th>
                            <!--- for actions -->
                        </tr>

                        <tr>
                            <td>
                                <expander v-model="showAliases" />
                            </td>
                            <td>
                                <b>
                                    <router-link :to="'/gene/' + gene_id">
                                        {{ variant.gene.symbol }}
                                    </router-link>
                                </b>
                            </td>
                            <td>
                                <b>{{ variant.name }}</b>
                            </td>

                            <coordinates :val="hgvs_c_pos" />
                            <coordinates class="d-none d-sm-table-cell" :val="hgvs_p_pos" />
                            <coordinates class="d-none d-sm-table-cell" :val="hgvs_g_pos" />

                            <optional :class="hiddenCols" :val="variant.dbsnp_ids">
                                <a
                                    v-for="rsid in variant.dbsnp_ids"
                                    :key="rsid"
                                    :href="'https://www.ncbi.nlm.nih.gov/snp/' + rsid"
                                    target="_blank">
                                    rs{{ rsid }}
                                    <icon name="external-link-alt"></icon>
                                </a>
                            </optional>

                            <!-- <td>{{ desnakify(variant.so_name) }}</td> -->

                            <optional :class="hiddenCols" :val="var_position">
                                <span class="text-muted transcript-id">{{ variant.reference_name }}:</span>
                                &#x200b;{{ var_position }}
                            </optional>

                            <td :class="hiddenCols">
                                <span v-if="allele_frequency">{{ allele_frequency }}</span>
                                <span v-else class="unavailable">{{ $t("unavailable")}}</span>
                            </td>

                            <td>{{ this.variant.public_stage }}</td>
                            <td>
                                <icon
                                    v-for="score in [1, 2, 3]"
                                    :key="score"
                                    :name="variant.confidence < score ? 'regular/star' : 'star'"
                                    style="margin-right: 5px" />
                            </td>

                            <td>
                                <div class="details-tray" style="text-align: right">
                                    <!--
                                    <b-button
                                        size="sm"
                                        @click.stop="() => { showAliases = !showAliases; }"
                                    >{{ showAliases ? "Hide" : "Show" }} Aliases</b-button>
                                    -->

                                    <b-button
                                        class="discuss-btn"
                                        v-access="'curators'"
                                        v-if="commentsEnabled"
                                        @click="toggleNav">
                                        <!--
                                        <div class="icon-composer">
                                            <icon name="comment" scale="1.4" />
                                            <span class="overlay">{{ commentCount }}</span>
                                        </div> {{ $t("Discuss")}}
                                        -->
                                        <icon name="comment" scale="1.4" />
                                        Discuss
                                    </b-button>
                                </div>
                            </td>
                        </tr>

                        <transition name="slide-fade">
                            <tr v-if="showAliases" class="details-row">
                                <td></td>
                                <td colspan="9">
                                    <div class="aliases-list">
                                        <div v-for="x in variant.gene.aliases" :key="x">
                                            {{ x }}
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </transition>
                    </table>
                </div>
            </div>

            <GeneSummary :gene="gene" class="variant-summary" />
            <VariantSummary :variant="variant" class="variant-summary" />
            <variant-svip :variant="variant" :gene="gene_id"></variant-svip>
            <variant-public-databases :variant="variant"></variant-public-databases>
            <b-row v-access="'curators'">
                <b-col>
                    <b-card class="shadow-sm mt-3" align="left" no-body>
                        <b-card-body class="p-0 text-center">
                            <b-row no-gutters>
                                <b-col v-for="(item, index) in linkItems" :key="index">
                                    <b-button
                                        squared
                                        block
                                        variant="outline-secondary"
                                        :href="getLink(item)"
                                        target="_blank">
                                        {{ item }}
                                        <icon name="external-link-alt"></icon>
                                    </b-button>
                                </b-col>
                            </b-row>
                        </b-card-body>
                    </b-card>
                </b-col>
            </b-row>
        </div>

        <VariantExternalInfo :variant="variant" :mvInfo="variant.mv_info" :extras="all_extras" />

        <!-- invisible things are down here -->
        <Sidebar v-access="'curators'" v-if="commentsEnabled">
            <h4 style="border-bottom: solid 1px #ccc; padding-bottom: 15px">
                {{ $t("Comments on")}} {{ variant.description }}
            </h4>
            <CommentList :variant_id="variant.id" @commented="getCommentCount" />
        </Sidebar>
    </div>
</template>

<script>
// import geneVariants from '@/components/Variants'
import round from 'lodash/round';
import {mapGetters} from 'vuex';
import variantPublicDatabases from '@/components/genes/variants/PublicDatabases';
import variantSvip from '@/components/genes/variants/SVIPInfo';
import store from '@/store';
import GeneSummary from '@/components/widgets/GeneSummary';
import VariantSummary from '@/components/widgets/VariantSummary';

import {change_from_hgvs, desnakify, var_to_position} from '@/utils';
import VariantExternalInfo from '@/components/genes/variants/external/VariantExternalInfo';
import Sidebar from '@/components/structure/sidebar/Sidebar';
import CommentList from '@/components/widgets/CommentList';
import {commentsEnabled} from '@/app_config';
import {HTTP} from '@/router/http';

export default {
    name: 'ViewVariant',
    components: {
        CommentList,
        Sidebar,
        VariantExternalInfo,
        variantPublicDatabases,
        variantSvip,
        GeneSummary,
        VariantSummary,
    },
    data() {
        return {
            showAliases: false,
            linkItems: ['Uniprot', 'MCG Biomarkers', 'Varsome', 'DoCM', 'Mycancergenome'],
            commentCount: null,
            commentsEnabled,
            hiddenCols: 'd-none d-lg-table-cell',
        };
    },
    created() {
        this.getCommentCount();
    },
    watch: {
        $route: () => {
            this.getCommentCount();
        },
    },
    computed: {
        ...mapGetters({
            variant: 'variant',
            gene: 'gene',
            user: 'currentUser',
        }),
        synonyms() {
            if (this.gene.geneAliases === undefined) return '';
            return this.gene.geneAliases.join(', ');
        },
        gene_id() {
            let test = this.variant.gene.url.match(/genes\/(\d+)/);
            if (test) return test[1];
            return '';
        },
        hgvs_c_pos() {
            return change_from_hgvs(this.variant.hgvs_c, true);
        },
        hgvs_p_pos() {
            return change_from_hgvs(this.variant.hgvs_p, true);
        },
        hgvs_g_pos() {
            return change_from_hgvs(this.variant.hgvs_g, true);
        },
        var_position() {
            return var_to_position(this.variant);
        },
        hg19_id() {
            return var_to_position(this.variant, true);
        },
        all_extras() {
            return this.variant.variantinsource_set.reduce((acc, x) => {
                return Object.assign({}, acc, x['extras']);
            }, {});
        },
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
    },
    methods: {
        getLink(source) {
            switch (source) {
            case 'Uniprot':
                return `https://www.uniprot.org/uniprotkb?query=${this.variant.name}`;
            case 'Mycancergenome':
                return `https://www.mycancergenome.org/content/search/?query=${this.variant.name}`;
            case 'Varsome':
                return `https://varsome.com/search-results/${this.variant.name}`;
            case 'DoCM':
                return `http://www.docm.info`;
            case 'MCG Biomarkers':
                return 'https://www.cancergenomeinterpreter.org/biomarkers';
            }
        },
        desnakify,
        toggleNav() {
            store.commit('TOGGLE_NAV');
        },
        getCommentCount() {
            this.commentCount = null;

            if (!this.user || !this.user.groups.includes('curators')) {
                return;
            }

            return HTTP.get(`/comments?variant=${this.$route.params.variant_id}&page_size=9999`).then(
                response => {
                    this.commentCount = response.data.count;
                }
            );
        },
    },
    beforeRouteEnter(to, from, next) {
        const {variant_id} = to.params;

        // ask the store to populate detailed information about this variant
        store.dispatch('getGeneVariant', {variant_id: variant_id}).then(({gene, variant}) => {
            to.meta.title = `SVIP-O: ${gene.symbol} ${variant.name}`;
            next();
        });
    },
};
</script>

<style scoped>
.variant-card .card-body {
    padding: 0;
}

.variant-header {
    margin-bottom: 0;
}

.variant-header td,
.variant-header th {
    vertical-align: text-bottom;
    padding: 1rem;
}

.variant-summary {
    margin-top: 1rem;
}

.aliases-list {
    font-style: italic;
}

.details-row {
    background: #eee;
    box-shadow: inset;
}

/* Enter and leave animations can use different */
/* durations and timing functions.              */
.slide-fade-enter-active {
    transition: all 0.5s ease;
}

.slide-fade-leave-active {
    transition: all 0.3s ease;
}

.slide-fade-enter-to,
.slide-fade-leave {
    max-height: 120px;
}

.slide-fade-enter, .slide-fade-leave-to
    /* .slide-fade-leave-active below version 2.1.8 */ {
    opacity: 0;
    max-height: 0;
}

.icon-composer {
    display: inline-block;
    position: relative;
    bottom: 1px;
}

.icon-composer .overlay {
    position: absolute;
    color: #839596;
    left: 6px;
    top: 4px;
    font-size: 13px;
    font-weight: bold;
    text-align: center;
}
</style>
