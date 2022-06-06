<template functional>
    <span class="unavailable">{{ $t("unavailable")}}</span>
</template>

<script>
export default {
    name: "UnavailableCol",
    props: {
        row: {type: Object, required: true}
    }
}
</script>

<style scoped>

</style>
