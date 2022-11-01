<template>
    <b-form-select v-model="selection" class="form-control">
        <option>Associated with diagnosis</option>
        <option>Not associated with diagnosis</option>
        <option>Other</option>
        <option>Conflicting Evidences</option>
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
