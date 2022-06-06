<template>
    <b-form-select v-model="selection" class="form-control">
        <option>{{ $t("Sensitive (in vitro)")}}</option>
        <option>{{ $t("Responsive")}}</option>
        <option>{{ $t("Resistant (in vitro)")}}</option>
        <option>{{ $t("Reduced sensivity")}}</option>
        <option>{{ $t("Not responsive")}}</option>
        <option>{{ $t("Adverse response")}}</option>
        <option>{{ $t("Other")}}</option>
    </b-form-select>
</template>

<script>
export default {
    name: "SelectPredictiveTherapeuticOutcome",
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
