<template>
    <b-form-select v-model="selection" class="form-control">
        <option>Good outcome</option>
        <option>Poor outcome</option>
        <option>Intermediate</option>
        <option>Not associated with prognosis</option>
        <option>Conflicting Evidences</option>
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
