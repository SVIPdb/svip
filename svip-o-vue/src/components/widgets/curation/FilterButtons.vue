<template>
    <b-button-group :size="size">
        <b-button class="filter-btn" v-for="item in items"
            :variant="item.variant || (value === (item.value === undefined? item.label: item.value) && selectedVariant) || defaultVariant || 'primary'"
            @click="update(item.value === undefined? item.label: item.value)" :key="item.label"
        >
            {{ item.label }}
            <transition name="fade">
                <icon class="caret" scale="1.5" v-if="value === (item.value === undefined? item.label: item.value)" name="caret-up" />
            </transition>
        </b-button>
    </b-button-group>
</template>

<script>
export default {
    name: "FilterButtons",
    props: {
        size: { type: String, default: 'sm' },
        items: { required: true, type: Array },
        value: { required: true },
        defaultVariant: { type: String, required: false },
        selectedVariant: { type: String, required: false }
    },
    methods: {
        update(v) {
            this.$emit('input', v);
        }
    }
}
</script>

<style scoped>
.filter-btn {
    position: relative;
}
.filter-btn .caret {
    position: absolute;
    top: 100%;
    left: 50%;
    transform: translate(-50%,-50%);
}

.fade-enter-active, .fade-leave-active {
    transition: all 0.3s;
}
.fade-enter, .fade-leave-to {
    margin-top: 5px;
    opacity: 0;
}
</style>
