<template>
    <div class="toc col-md-3 order-md-2 order-sm-0">
        <h3>{{ $t("Table of Contents")}}</h3>
        <b-list-group v-b-scrollspy="90">
            <b-list-group-item v-for="section in sections" :key="section.name"
                :href="`#sec_${ slugifySans(section.name) }`">
                {{ section.name }}
            </b-list-group-item>
        </b-list-group>
    </div>
</template>

<script>
import { slugifySans } from "@/utils";

export default {
    name: "TableOfContents",
    props: {
        sections: {type: Array, required: true}
    },
    methods: {
        slugifySans
    }
}
</script>

<style scoped>
.toc { position: fixed; right: 130px; }

@media (max-width: 600px) {
    .toc { position: relative; }
}
</style>
