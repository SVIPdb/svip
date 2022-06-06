<template>
    <b-form-select v-model="selection" class="form-control">

        <option>{{ $t("Tier IA: Included in Professional Guidelines")}}</option>
        <option>
            {{ $t("Tier IB: Well-powered studies with consensus from experts in the field")}}
        </option>
        <option>{{ $t("Tier IIC: Multiples small published studies with some consensus")}}
        </option>
        <option>{{ $t("Tier IID: Clinical trial")}}</option>
        <option>{{ $t("Tier IID: Pre-clinical trial")}}</option>
        <option>{{ $t("Tier IID: Population study")}}</option>
        <option>{{ $t("Tier IID: Small published study")}}</option>
        <option>{{ $t("Tier IID: Case reports")}}</option>
        <option>{{ $t("Tier III: No convincing published evidence of drugs effect")}}</option>
        <option>{{ $t("Tier III: Author statement")}}</option>
        <option>
            {{ $t("Tier IV: Reported evidence supportive of benign/likely benign effect")}}
        </option>
        <option>{{ $t("Other criteria")}}</option>

    </b-form-select>
</template>

<script>
export default {
    name: "SelectTier",
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
