<template>
    <v-select v-model="selected" @change="onChanged" push-tags @input="onInput" :options="options"></v-select>
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
        },
        onChanged() {
            const value = this.selected;
            console.log("Changed: ", value);
            this.selected = value;
        }
    }
}
</script>

<style scoped>

</style>
