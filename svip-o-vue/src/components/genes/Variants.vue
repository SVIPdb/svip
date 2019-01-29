<template>
    <div class="card card-default">
        <div class="card-header">
            <div class="card-title">
                List of variants....
            </div>
        </div>
        <div class='card-body'>
            <p class='text-center'><i>something interesting here...</i></p>
        </div>
    </div>
</template>

<script>

import Vue from 'vue'
import {serverURL} from '@/app_config'
import {mapGetters} from 'vuex'
import variantTable from '@/components/genes/VariantTable'

export default {
    data() {
        return {}
    },
    computed: {
        ...mapGetters({
            user: 'currentUser'
        })
    },
    components: {
        filesTable
    },
    filters: {},
    props: ['gene'],
    created() {
        const gene_id = this.$route.params.gene_id;
    },
    methods: {}
}

</script>

<style>

</style>
