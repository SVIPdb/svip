<template>
    <b-form-select v-model="selection" class="form-control">
        <option>Sensitive (in vitro)</option>
        <option>Responsive</option>
        <option>Resistant (in vitro)</option>
        <option>Reduced sensitivity</option>
        <option>Not responsive</option>
        <option>Adverse response</option>
        <option>Other</option>
    </b-form-select>
</template>

<script>
export default {
    name: "SelectPredictiveTherapeuticOutcome",
    props: ["value"],
    computed: {
        selection: {
            get() {
                return this.value;
            },
            set(value) {
                this.$emit("input", value);
            },
        },
    },
};
</script>

<style scoped></style>
