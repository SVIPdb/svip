<template>
    <div class='container-fluid'>
        <div>
            <p class='text-right'>
                <button class='btn btn-primary btn-sm' @click='newgene()'>new gene</button>
            </p>
        </div>
        <div class="card">
            <div class="card-header">
                <div class="card-title">genes</div>
            </div>
            <table class='table table-hover'>
                <thead>
                    <th st-sort='name'>Name</th>
                    <th st-sort='variants'># variants</th>
                    <th st-sort='date'>Last update</th>
                </thead>
                <tbody>
                    <tr v-for='gene in genes' @click='goTo(gene.gene_id)' class='pointer'>
                        <td>{{gene.name}}</td>
                        <td><b>{{gene.nb_variants}}</b></td>
                        <td>{{gene.timestamp}}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

</template>

<script>

import {HTTP} from '@/router/http'
import {mapGetters} from 'vuex'

export default {
    data() {
        return {
            genes: []
        }
    },
    computed: {
        ...mapGetters({
            user: 'currentUser'
        })
    },
    methods: {
        newgene() {
            this.$router.push('/gene/new/edit')
        },

        goTo(id) {
            this.$router.push('/gene/' + id)
        }

    },
    mounted() {
        HTTP.get('/gene').then(res => {
            this.genes = res.data
        })
    }
}

</script>
