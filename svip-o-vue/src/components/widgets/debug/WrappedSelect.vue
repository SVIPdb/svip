<template>
    <v-select v-model="selected" push-tags @input="onInput" :options="options"></v-select>
</template>

<script>
export default {
    name: "WrappedSelect",
    props: ['value'],
    data() {
        return {
            selected: this.value,
            options: ["A", "B", "C"]
        }
    },
    watch: {
        value() {
            this.selected = this.value;
        }
    },
    methods: {
        onInput() {
            console.log("Input: ", this.selected);
            this.$emit('input', this.selected);
        }
    }
}
</script>

<style scoped>

</style>
