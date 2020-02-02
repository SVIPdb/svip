<template>
    <div class="container">
        <div class="row">
            <div class="col-md-10 offset-1">
                <h1>SVIP Statistics</h1>
                <p>SVIP incorporates data both from public databases and expert curation. This page gives an overview
                of how many genes and variants we're tracking, and from where the data originates.</p>
            </div>
        </div>

        <div class="row">
            <div class="col-md-10 offset-1">
                <h2>Variants per Gene</h2>

                <table class="table" style="width: 100%;">
                    <thead>
                        <tr>
                            <td>Gene</td>
                            <td v-for="source in genes.sources">
                                <SourceIcon :name="source.name"/>
                                {{ source.display_name }}
                            </td>
                        </tr>
                    </thead>

                    <tbody>
                        <tr v-for="(entry, gene) in genes.variants_by_source">
                            <td>
                                <b><router-link :to="`/gene/${entry.gene_id}`" target="_blank">{{ gene }}</router-link></b>
                            </td>
                            <td v-for="source in genes.sources">
                               {{ entry.sources[source.name] || 0 }}
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="row">
            <div class="col-md-10 offset-1">
                <h2>Harvest Runs</h2>

                <b-table :items="harvests" :fields="harvest_fields">
                    <template v-slot:cell(id)="entry">
                        <row-expander :row="entry" />&nbsp;
                        {{ entry.id }}
                    </template>

                    <template v-slot:row-details="entry">
                        <div class="sample-subtable tumor-subtable" style="padding: 0; margin: 0;">
                            <b-table-lite
                                style="background: none; margin: 0;"
                                :items="harvestGeneList(entry.item.stats.genes)"
                            />
                        </div>
                    </template>
                </b-table>
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

dayjs.extend(RelativeTime);

function duration(a, b) {
    if (!b) { b = new Date(); }
    return dayjs(a).to(dayjs(b), true);
}

const harvest_fields = [
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
    components: {SourceIcon},
    data() {
        return {
            genes: [],
            harvests: [],
            harvest_expanded: {},
            harvest_sortBy: 'id',
            harvest_fields
        }
    },
    created() {
        HTTP.get('/stats/full').then((response) => {
            this.genes = response.data.genes;
        });
        HTTP.get('/stats/harvests').then((response) => {
            this.harvests = response.data.harvests;
        });
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
</style>
