<template>
    <b-form-select v-model="selection" class="form-control">

        <option>{{ $t("Tier IA: FDA/EMA/Swissmedic approved therapy")}}</option>
        <option>{{ $t("Tier IA: Therapy included in Professional Guidelines such as NCCN or CAP")}}</option>
        <option>{{ $t("Tier IB: Well-powered studies with consensus from experts in the field")}}</option>
        <option>{{ $t("Tier IIC: FDA/EMA/Swissmedic approved therapy for a different tumor type")}}</option>
        <option>{{ $t("Tier IIC: Small published studies with some consensus")}}</option>
        <option>{{ $t("Tier IID: Population study")}}</option>
        <option>{{ $t("Tier IID: Clinical trial")}}</option>
        <option>{{ $t("Tier IID: Pre-clinical trial")}}</option>
        <option>{{ $t("Tier IID: Case reports")}}</option>
        <option>{{ $t("Tier III: No convincing published evidence of drugs effect")}}</option>
        <option>{{ $t("Tier IV: Reported evidence supportive of benign/likely benign effect")}}</option>
        <option>{{ $t("Other criteria")}}</option>
    </b-form-select>
</template>

<script>
export default {
    name: "SelectTherapeuticTier",
    props: ['value'],
    computed: {
        selection: {
            get() {
                return this.value
            },
            set(value) {
                this.$emit('input', value)
            },
        }
    }
}
</script>

<style scoped>

</style>
