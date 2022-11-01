<template>
    <div class="container">
        <div class="highlight-clean">
            <div class="container">
                <div class="intro section text-center">
                    <img
                        src="../../assets/logos/SVIP_Logo_Text_cmyk_Large.png"
                        class="img-fluid"
                        width="483"
                        height="137"
                        alt="SVIP Logo" />
                </div>

                <div class="section row justify-content-md-center">
                    <div class="col-xs-12 col-md-8 col-lg-8">
                        <SearchBar />
                    </div>
                </div>

                <div v-if="loadingStats === 'error'" class="section stats row justify-content-md-center">
                    <div class="text-center text-muted font-italic">
                        <icon
                            name="exclamation-triangle"
                            scale="3"
                            class="blinking"
                            style="vertical-align: text-bottom; margin-bottom: 5px; color: #e7c28b" />
                        <br />
                        The SVIP API is not available.
                        <br />
                        Please check your connection and then
                        <a href="mailto:feedback@svip.ch">contact us</a>
                        .
                    </div>
                </div>
                <div v-else class="section stats row justify-content-md-center">
                    <div class="col">
                        <h3>
                            <b-spinner v-if="loadingStats === true" />
                            <span v-else>
                                {{ nbGenes.toLocaleString() }} Gene{{ nbGenes !== 1 ? 's' : '' }}
                            </span>
                        </h3>
                        <span class="text-muted">{{ nbGenesSVIP }} with SVIP data</span>
                    </div>
                    <div class="col">
                        <h3>
                            <b-spinner v-if="loadingStats === true" />
                            <span v-else>
                                {{ nbVariants.toLocaleString() }} Variant{{ nbVariants !== 1 ? 's' : '' }}
                            </span>
                        </h3>
                        <div class="text-muted">{{ nbVariantsSVIP }} with SVIP data</div>
                        <div class="text-muted">{{ nbSvipCurations }} curation entries</div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div
                    class="col-12 justify-content-center"
                    style="text-align: center; font-style: italic; color: #999; margin-top: 60px">
                    <a
                        href="https://www.sphn.ch/en/projects/infrastructure-development-projects.html"
                        target="_blank">
                        <img
                            src="../../assets/logos/sphn_logo_middle.png"
                            width="170"
                            alt="SPHN: Swiss Personalized Health Network" />
                    </a>
                    <div style="padding-top: 2em">an SPHN Infrastructure Development project</div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import {mapGetters} from 'vuex';
import store from '@/store';
import SearchBar from '../widgets/searchbars/SearchBar';

export default {
    name: 'home',
    components: {SearchBar},
    data() {
        return {
            gene: {},
        };
    },
    computed: {
        ...mapGetters({
            loadingStats: 'loadingStats',
            genes: 'genes',
            nbGenes: 'nbGenes',
            nbGenesSVIP: 'nbGenesSVIP',
            nbVariants: 'nbVariants',
            nbVariantsSVIP: 'nbVariantsSVIP',
            nbSvipCurations: 'nbSvipCurations',
        }),
    },
    created() {
        store.dispatch('getSiteStats');
    },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.section {
    margin-top: 60px;
}

.intro {
    margin-top: 120px;
}

.stats {
    text-align: center;
}

.d-center {
    display: flex;
    align-items: center;
}

.selected img {
    width: auto;
    max-height: 23px;
    margin-right: 0.5rem;
}
</style>
