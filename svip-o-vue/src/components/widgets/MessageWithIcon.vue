<template>
    <div :class="['alert', variant]">
        <div class="d-flex align-items-center text-left">
            <div class="mr-4" style="font-size: 32px;">
                <slot name="icon"><icon name="question-circle" /></slot>
            </div>
            <div>
                <slot></slot>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: "MessageWithIcon",
    props: {
        variant: { type: String, default: "alert-warning" }
    }
}
</script>

<style scoped>

</style>
