<template functional>
    <span>
        FATHMM Prediction:
        {{
            props.row.item.extras.fathmm_prediction
                ? props.row.item.extras.fathmm_prediction.toLowerCase()
                : "n/a"
        }}
        {{
            props.row.item.extras.fathmm_score &&
            ` (score: ${parseFloat(
                props.row.item.extras.fathmm_score
            ).toLocaleString()})`
        }}
    </span>
</template>

<script>
import { titleCase } from "@/utils";

export default {
    name: "CosmicSignificanceCol",
    props: {
        row: { type: Object, required: true },
    },
    methods: {
        titleCase,
    },
};
</script>

<style scoped></style>
