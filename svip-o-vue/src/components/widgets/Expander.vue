<template>
    <b-link @click="toggle">
        <icon name="chevron-right" :class="`link ${this.value ? 'activated' : ''}`"/>
    </b-link>
</template>

<script>
export default {
    name: "Expander",
    props: {
        value: {type: Boolean}
    },
    methods: {
        toggle() {
            this.$emit('input', !this.value);
        }
    }
}
</script>

<style scoped>
.link {
    transform: rotate(0deg);
    transition: all 100ms linear;
}

.activated {
    transform: rotate(90deg);
    transition: all 100ms linear;
}
</style>
