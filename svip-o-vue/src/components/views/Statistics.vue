<template>
    <div class="container">
        <div class="row">
            <div class="col-md-10 offset-1">
                <h1 class="section-header">SVIP Statistics</h1>
                <p>SVIP incorporates data both from public databases and expert curation. This page gives an overview
                of how many genes and variants we're tracking, and from where the data originates.</p>
            </div>
        </div>

        <div class="row">
            <div class="col-md-10 offset-1">
                <h2 class="section-header">Variants per Gene</h2>

                <div v-if="genes.data === null">
                    <b-spinner />
                </div>
                <div v-else>
                    <!--
                    <div style="margin-left: 10px;">Showing {{ genes.perPage }} of {{ genes.data.total_genes }} total genes</div>
                    -->

                    <div style="display: flex; justify-content: space-between; align-items: baseline;">
                        <div style="margin-left: 10px;">Showing <b>{{ genes.perPage }}</b> out of <b>{{ genes.data.total_genes }}</b> genes</div>
                        <b-form-group>
                            <b-input-group>
                                <b-form-input v-model="genes.currentFilter" placeholder="Type to Search"/>
                                <b-input-group-append>
                                    <b-btn :disabled="!genes.currentFilter" @click="genes.currentFilter = ''">Clear</b-btn>
                                </b-input-group-append>
                            </b-input-group>
                        </b-form-group>
                    </div>

                    <b-table
                        :fields="genes_variants_fields" :items="genes_variants_rows"
                        :per-page="genes.perPage" :current-page="genes.currentPage"
                        :filter="genes.currentFilter"
                    >
                        <template v-slot:cell(gene)="entry">
                            <b><router-link :to="`/gene/${entry.value.id}`" target="_blank">{{ entry.value.name }}</router-link></b>
                        </template>

                        <template v-slot:head()="data">
                            <SourceIcon v-if="data.column !== 'gene'" :name="data.column"/>
                            {{ data.label }}
                        </template>
                    </b-table>

                    <div>
                        <b-pagination v-if="genes.data.total_genes > genes.perPage" v-model="genes.currentPage"
                            :total-rows="genes.data.total_genes" :per-page="genes.perPage"
                        />
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-10 offset-1">
                <h2 class="section-header">Harvest Runs</h2>

                <div v-if="harvests.data === null">
                    <b-spinner />
                </div>
                <div v-else>
                    <b-table :items="harvests.data" :fields="harvests.fields" :per-page="harvests.perPage" :current-page="harvests.currentPage">
                        <template v-slot:cell(action)="entry">
                            <row-expander :row="entry" />&nbsp;
                        </template>

                        <template v-slot:row-details="entry">
                            <div class="sample-subtable tumor-subtable" style="padding: 0; margin: 0;">
                                <b-table-lite
                                    style="background: none; margin: 0;"
                                    :items="harvestGeneList(
                                        entry.item.stats.genes || entry.item.stats
                                    )"
                                />
                            </div>
                        </template>
                    </b-table>

                    <div style="display: flex;">
                        <b-pagination v-if="harvests.data.length > harvests.perPage" v-model="harvests.currentPage"
                            :total-rows="harvests.data.length" :per-page="harvests.perPage"
                        />
                        <div style="margin-left: 10px;">(showing {{ harvests.perPage }} of {{ harvests.data.length }} total entries)</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import dayjs from "dayjs";
import RelativeTime from 'dayjs/plugin/relativeTime' // load on demand
import {HTTP} from '@/router/http';
import SourceIcon from "@/components/widgets/SourceIcon";
import {combinedDateTime} from "@/utils";
import PagedTable from "@/components/widgets/PagedTable";

dayjs.extend(RelativeTime);

function duration(a, b) {
    if (!b) { b = new Date(); }
    return dayjs(a).to(dayjs(b), true);
}

const harvest_fields = [
    { key: 'action', label: '' },
    { key: 'id', label: 'ID' },
    { key: 'started_on', label: 'Started', formatter: v => combinedDateTime(v) },
    { key: 'ended_on', label: 'Ended', formatter: v => combinedDateTime(v) },
    {
        key: 'duration',
        label: 'Duration',
        formatter: (v, k, r) => duration(r.started_on, r.ended_on)
    },
    { key: 'status', label: 'Status' }
];

export default {
    name: "Statistics",
    components: {PagedTable, SourceIcon},
    data() {
        return {
            genes: {
                data: null,
                perPage: 10,
                currentPage: 1,
                currentFilter: ''
            },
            harvests: {
                data: null,
                fields: harvest_fields,
                perPage: 10,
                currentPage: 1
            }
        }
    },
    created() {
        HTTP.get('/stats/full').then((response) => {
            this.genes.data = response.data.genes;
        });
        HTTP.get('/stats/harvests').then((response) => {
            this.harvests.data = response.data.harvests;
        });
    },
    computed: {
        genes_variants_fields() {
            if (!this.genes.data)
                return null;

            return [
                { key: 'gene', label: 'Gene' },
                ...(Object.values(this.genes.data.sources).map(x => ({
                    key: x.name,
                    label: x.display_name,
                    formatter: (x) => x || 0
                })))
            ]
        },
        genes_variants_rows() {
            if (!this.genes.data)
                return null;

            return Object.entries(this.genes.data.variants_by_source).map(([k, v]) => ({
                gene: { name: k, id: v.gene_id },
                ...(v.sources)
            }));
        }
    },
    methods: {
        harvestGeneList(genes) {
            return Object.entries(genes).map(([k, v]) => ({
                gene: k,
                ...(_.mapValues(v, x => `${x.inserted} / ${x.skipped}`))
            }));
        }
    }
}
</script>

<style scoped>
.geneset {
    padding: 10px;
    background: #eee;
}
.section-header { margin-top: 0.5em; }
</style>
