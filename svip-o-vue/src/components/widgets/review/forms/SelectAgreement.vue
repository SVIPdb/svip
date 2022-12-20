<template>
    <b-form-select v-model="selection" class="form-control">
        <option>{{ $t("I agree.")}}</option>
        <option>{{ $t("I don't agree.")}}</option>
    </b-form-select>
</template>

<script>
export default {
    name: 'SelectAgreement',
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
