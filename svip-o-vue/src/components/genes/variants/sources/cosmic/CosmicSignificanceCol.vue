<template functional>
    <span>
        {{ $t("FATHMM Prediction:")}}
        {{
            {{ $t("props.row.item.extras.fathmm_prediction")}}
                {{ $t("? props.row.item.extras.fathmm_prediction.toLowerCase()")}}
                {{ $t(": 'n/a'")}}
        }}
        {{
            {{ $t("props.row.item.extras.fathmm_score &&")}}
            {{ $t("` (score: ${parseFloat(props.row.item.extras.fathmm_score).toLocaleString()})`")}}
        }}
    </span>
</template>

<script>
import {titleCase} from '@/utils';

export default {
    name: 'CosmicSignificanceCol',
    props: {
        row: {type: Object, required: true},
    },
    methods: {
        titleCase,
    },
};
</script>

<style scoped></style>
