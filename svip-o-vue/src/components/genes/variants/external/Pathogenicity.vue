<template>
    <div>
        <div class="card mt-3 top-level">
            <div class="card-header">
                <div class="card-title">Algorithmic Impact Prediction</div>
            </div>

            <div class="card-body top-level">
                <b-table :fields="fields" :items="items" :sort-by.sync="sortBy" :sort-desc="false">
                    <template v-slot:cell(actions)="row">
                        <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
                        <b-button size="sm" @click.stop="row.toggleDetails">
                            {{ row.detailsShowing ? 'Hide' : 'Show' }} Details
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
import {desnakify} from '@/utils';
import round from 'lodash/round';

function deref_path(target, path) {
    return path.split('.').reduce((acc, x) => (acc ? acc[x] : null), target);
}

const sources = [
    {name: 'SIFT', path: 'cadd.sift', score: 'val', impact: 'cat'},
    {name: 'Polyphen', path: 'cadd.polyphen', score: 'val', impact: 'cat'},
    // {name: "FATHMM", path: "dbnsfp.fathmm", score: 'score', impact: 'pred'},
    {
        name: 'FATHMM',
        path: 'extras',
        score: 'fathmm_score',
        impact: 'fathmm_prediction',
    },
];

export default {
    name: 'Pathogenicity',
    data() {
        return {
            sortBy: '',
            items: sources
                .filter(source => {
                    const q = deref_path(this, source.path);
                    return q && !isNaN(q[source.score]);
                })
                .map(source => {
                    const extracted = deref_path(this, source.path);
                    return {
                        source: source.name,
                        score: round(parseFloat(extracted[source.score]), 3),
                        impact: desnakify(extracted[source.impact], true),
                    };
                }),
            fields: [
                {
                    key: 'source',
                    label: 'Source',
                    sortable: true,
                },
                {
                    key: 'score',
                    label: 'Score',
                    sortable: true,
                },
                {
                    key: 'impact',
                    label: 'Impact',
                    sortable: true,
                },
            ],
        };
    },
    props: ['cadd', 'dbnsfp', 'extras'],
};
</script>

<style scoped></style>
