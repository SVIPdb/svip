<template>
    <div class="mt-1 text-left">
        <b-button pill class="mr-1 mb-1" variant="primary" size="sm"
            v-for="x in annotationUsed" :key="x.id"
            :class="[x.etype === 'Excluded' && 'ref-excluded']"
            v-b-tooltip="`${x.etype}`"
            :to="`/curation/entry/${x.id}`"
            target="_blank"
        >
            Entry #{{ x.id }}
        </b-button>
    </div>
</template>

<script>
export default {
    name: "EntriesInUse",
    props: { annotationUsed: { required: true }}
}
</script>

<style scoped>
.ref-excluded { background-color: #b32323; border: solid 1px #9f3737; }
</style>
