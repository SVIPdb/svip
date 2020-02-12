<template>
    <div class="container">
        <div class="row">
            <div class="col-md-9 offset-1 mt-1">
                <h1>Releases</h1>
                <p>The current SVIP release is <b>v0.3.0</b>. The full changelog with each version is listed below.</p>

                <div v-for="(release, code) in releases" class="release">
                    <h3>v{{ code }} - {{ release.name }}</h3>
                    <p>{{ release.summary }}</p>

                    <div class="release-body">
                        <div v-if="release.changes">
                            <h4><expander v-model="release.significant">Significant Changes</expander></h4>

                            <b-collapse :visible="release.significant">
                                <ul class="changelog">
                                    <li v-for="entry in release.changes">{{ entry }}</li>
                                </ul>
                            </b-collapse>
                        </div>

                        <div v-if="release.changelog">
                            <h4><expander v-model="release.full">Full Changelist</expander></h4>

                            <b-collapse :visible="release.full">
                                <ul class="changelog">
                                    <li v-for="commit in release.changelog">
                                        <b v-b-tooltip="`${commit.author.name} on ${commit.author.date}`">
                                            {{ relativeDate(commit.author.date) }}:
                                        </b>
                                        {{ commit.subject }}
                                    </li>
                                </ul>
                            </b-collapse>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import v020_commits from '@/data/releases/v020_commits.js';
import v030_commits from '@/data/releases/v030_commits.js';
import dayjs from "dayjs";
import RelativeTime from 'dayjs/plugin/relativeTime' // load on demand
dayjs.extend(RelativeTime);

export default {
    name: "Releases",
    data() {
        return {
            releases: {
                "0.3.0": {
                    name: 'Alpha Centauri',
                    summary: 'Released on 10.02.2020, this release includes a work-in-progress curation interface as well as many small tweaks and bugfixes.',
                    changes: [
                        'Adds curation dashboard, showing pending curation tasks and completed entries.',
                        'Adds the ability to create curation entries for variants',
                        'Integrates with the text mining API to show variant and/or disease-specific literature results during curation',
                    ],
                    significant: true, full: false, changelog: v030_commits
                },
                "0.2.0": {
                    name: 'Alpha Bump',
                    summary: 'Released on 18.07.2019, this release includes an initial mockup of the clinical interface plus many small fixes.',
                    changes: [
                        'Includes a mockup of the SVIP clinical interface.',
                        'Samples table is shown under each disease if the user is a clinician.',
                        'Subtables for tumor-specific and sequencing-specific information per sample.',
                        'Includes preview of evidence/curation table, currently always shown.',
                    ],
                    significant: true, full: false, changelog: v020_commits
                },
                "0.1.0": {
                    name: 'Alpha Asterisk',
                    summary: 'This is the first SVIP release, published on 07.02.2019.',
                    changes: [
                        'First release of the interface to SVIP partners',
                        'Aggregated results from CIViC, OncoKB, and COSMIC',
                        'Pathogenicity and population stats from MyVariant.info.',
                        'SVIP panel with simulated data',
                        'Supports searching for genes and variants',
                        'Simple mock login system that differentiates between clinicians, curators, and anonymous users',
                    ],
                    significant: true, full: false
                },
            }
        }
    },
    methods: {
        relativeDate(x) {
            return dayjs(x).fromNow();
        }
    }
}
</script>

<style scoped>
.release { margin-top: 2em; }
.release-body { margin-left: 20px; }
.changelog li { margin-bottom: 0.2em; }
</style>
