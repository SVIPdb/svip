<template>
    <div>
        <div class="card mt-3 top-level">
            <div class="card-header">
                <div class="card-title">Polymorphisms</div>
            </div>

            <div class="card-body top-level">
                <b-table :fields="fields" :items="items" :sort-by.sync="sortBy" :sort-desc="false">
                    <template v-slot:cell(actions)="row">
                        <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
                        <b-button size="sm" @click.stop="row.toggleDetails">
                            {{ row.detailsShowing ? "Hide" : "Show" }} Details
                        </b-button>
                    </template>
                    <template v-slot:cell(name)="row">
                        {{ row.item.name }}
                    </template>
                </b-table>
            </div>
        </div>
    </div>
</template>

<script>
import round from 'lodash/round';

/*
// NOTE: will be used if we report ethnicity-specific stats
const exac_pops = {
	afr: "African/African American",
	amr: "Latino",
	eas: "East Asian",
	fin: "Finnish",
	nfe: "Non-Finnish European",
	sas: "South Asian",
	oth: "Other"
};
*/

const sources = [
    {
        name: "ExAC",
        key: "exac",
        freq_path: x => x.af,
        count_path: x => x.ac.ac,
        total_path: x => x.an.an_adj
    },
    {
        name: "gnomAD",
        key: "gnomad_genome",
        freq_path: x => x.af.af,
        count_path: x => x.ac.ac,
        total_path: x => x.an.an
    }
];

export default {
    name: "PopulationStats",
    data() {
        return {
            sortBy: "",
            items: sources.map(source => ({
                source: source.name,
                frequency: this.mvInfo[source.key]
                    ? source.freq_path(this.mvInfo[source.key]).toExponential()
                    : "None",
                count: this.mvInfo[source.key]
                    ? source.count_path(this.mvInfo[source.key])
                    : null,
                total: this.mvInfo[source.key]
                    ? source.total_path(this.mvInfo[source.key])
                    : null,
                consequence: "N/A"
            })),
            fields: [
                {
                    key: "source",
                    label: "Source",
                    sortable: true
                },
                {
                    key: "count",
                    formatter: (x, i, v) =>
                        x !== null && v !== null
                            ? `${x.toLocaleString()} / ${v.total.toLocaleString()}`
                            : "-",
                    label: "# Observed",
                    sortable: true
                },
                {
                    key: "frequency",
                    label: "Percent",
                    formatter: x => x && !isNaN(x) ? `${round(x * 100.0, 4)}%` : '-',
                    sortable: true
                }
            ]
        };
    },
    props: ["mvInfo"]
};
</script>

<style scoped></style>
