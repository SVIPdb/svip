<template>
    <b-form-select v-model="selection" class="form-control">
        <option>{{ $t("Associated with diagnosis")}}</option>
        <option>{{ $t("Not associated with diagnosis")}}</option>
        <option>{{ $t("Other")}}</option>
        <option>{{ $t("Conflicting Evidences")}}</option>
    </b-form-select>
</template>

<script>
export default {
    name: 'SelectDiagnosticOutcome',
    props: ['value'],
    computed: {
        selection: {
            get() {
                return this.value;
            },
            set(value) {
                this.$emit('input', value);
            },
        },
    },
};
</script>

<style scoped></style>
