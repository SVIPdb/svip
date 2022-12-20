<template>
    <b-form-select v-model="selection" class="form-control">
        <option>{{ $t("FDA/EMA/Swissmedic approved therapy")}}</option>
        <option>{{ $t("Therapy included in Professional Guidelines such as NCCN or CAP")}}</option>
        <option>{{ $t("Well-powered studies with consensus from experts in the field")}}</option>
        <option>{{ $t("FDA/EMA/Swissmedic approved therapy for a different tumor type")}}</option>
        <option>{{ $t("Small published studies with some consensus")}}</option>
        <option>{{ $t("Population study")}}</option>
        <option>{{ $t("Clinical trial")}}</option>
        <option>{{ $t("Pre-clinical trial")}}</option>
        <option>{{ $t("Case reports")}}</option>
        <option>{{ $t("No convincing published evidence of drugs effect")}}</option>
        <option>{{ $t("Reported evidence supportive of benign/likely benign effect")}}</option>
        <option>{{ $t("Other criteria")}}</option>
        <option>{{ $t("Not applicable")}}</option>
    </b-form-select>
</template>

<script>
export default {
    name: 'SelectTherapeuticTier',
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
