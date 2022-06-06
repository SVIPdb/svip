<template functional>
    <span>{{ props.row.value.toLocaleString() }} {{ $t("sample")}}{{ props.row.value !== 1 ? "s" : "" }}</span>
</template>

<script>
export default {
    name: "CosmicPubCountCol",
    props: {
        row: {type: Object, required: true}
    }
}
</script>

<style scoped>

</style>
