<template>
    <b-form-select v-model="selection" class="form-control">
        <option>{{ $t("Included in Professional Guidelines")}}</option>
        <option>{{ $t("Well-powered studies with consensus from experts in the field")}}</option>
        <option>{{ $t("Multiples small published studies with some consensus")}}</option>
        <option>{{ $t("Clinical trial")}}</option>
        <option>{{ $t("Pre-clinical trial")}}</option>
        <option>{{ $t("Population study")}}</option>
        <option>{{ $t("Small published study")}}</option>
        <option>{{ $t("Small published studies with some consensus")}}</option>
        <option>{{ $t("Case reports")}}</option>
        <option>{{ $t("No convincing published evidence of drugs effect")}}</option>
        <option>{{ $t("Author statement")}}</option>
        <option>{{ $t("Reported evidence supportive of benign/likely benign effect")}}</option>
        <option>{{ $t("Other criteria")}}</option>
        <option>{{ $t("Not applicable")}}</option>
    </b-form-select>
</template>

<script>
export default {
    name: 'SelectTier',
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
