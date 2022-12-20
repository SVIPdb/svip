<template>
    <b-form-select v-model="selection" class="form-control">
        <option>{{ $t("Good outcome")}}</option>
        <option>{{ $t("Poor outcome")}}</option>
        <option>{{ $t("Intermediate")}}</option>
        <option>{{ $t("Not associated with prognosis")}}</option>
        <option>{{ $t("Conflicting Evidences")}}</option>
    </b-form-select>
</template>

<script>
export default {
    name: 'SelectPrognosticOutcome',
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
