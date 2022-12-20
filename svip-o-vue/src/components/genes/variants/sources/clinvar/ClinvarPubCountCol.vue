<template>
    <span>{{ totalSubmissions.toLocaleString() }} {{ $t("submission")}}{{ totalSubmissions !== 1 ? 's' : '' }}</span>
</template>

<script>
export default {
    name: 'ClinvarPubCountCol',
    props: {
        row: {type: Object, required: true},
    },
    computed: {
        totalSubmissions() {
            return this.row.item.diseases.reduce((acc, x) => acc + x.count, 0);
        },
    },
};
</script>

<style scoped></style>
