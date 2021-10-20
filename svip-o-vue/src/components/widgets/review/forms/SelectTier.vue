<template>
    <b-form-select v-model="selection" class="form-control">

        <option>Tier IA: Included in Professional Guidelines</option>
        <option>
            Tier IB: Well-powered studies with consensus from experts in the field
        </option>
        <option>Tier IIC: Multiples small published studies with some consensus
        </option>
        <option>Tier IID: Clinical trial</option>
        <option>Tier IID: Pre-clinical trial</option>
        <option>Tier IID: Population study</option>
        <option>Tier IID: Small published study</option>
        <option>Tier IID: Case reports</option>
        <option>Tier III: No convincing published evidence of drugs effect</option>
        <option>Tier III: Author statement</option>
        <option>
            Tier IV: Reported evidence supportive of benign/likely benign effect
        </option>
        <option>Other criteria</option>

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
