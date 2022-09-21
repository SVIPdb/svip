<template>
    <div class="container-fluid">
        <CuratorVariantInformations :variant="variant" :disease_id="disease_id" />
        <VariantSummary :variant="variant" />
        <div>
            <VariantDisease :variant="variant" />
        </div>
    </div>
</template>
<script>
import {mapGetters} from 'vuex';
import CuratorVariantInformations from '@/components/widgets/curation/CuratorVariantInformations';
import store from '@/store';
import VariantSummary from '@/components/widgets/review/VariantSummary';
import VariantDisease from '@/components/widgets/review/VariantDisease';

import ulog from 'ulog';
import BroadcastChannel from 'broadcast-channel';

const log = ulog('Review:AnnotateReview');

export default {
    name: 'AnnotateReview',
    components: {
        VariantSummary,
        VariantDisease,
        CuratorVariantInformations,
    },
    data() {
        return {
            channel: new BroadcastChannel('curation-update'),
            source: 'PMID',
            reference: '',
        };
    },

    computed: {
        ...mapGetters({
            variant: 'variant',
            gene: 'gene',
        }),
        disease_id() {
            return parseInt(this.$route.params.disease_id);
        },
    },

    beforeRouteEnter(to, from, next) {
        const {variant_id} = to.params;
        // ask the store to populate detailed information about this variant
        store.dispatch('getGeneVariant', {variant_id: variant_id}).then(({gene, variant}) => {
            to.meta.title = `SVIP-O: Annotate ${gene.symbol} ${variant.name}`;
            next();
        });
    },
};
</script>

<style>
.variant-card .card-body {
    padding: 0;
}

.variant-header td,
.variant-header th {
    vertical-align: text-bottom;
    padding: 1rem;
}

.custom-style .dropdown-toggle {
    border-radius: 0 !important;
    height: calc(2.15625rem + 2px) !important;
}
</style>
