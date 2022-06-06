<template>
    <div class="container">
        <div class="row">
            <div class="col-md-9 offset-1 mt-1">
                <h1>{{ $t("Releases")}}</h1>
                <p>{{ $t("The current SVIP release is")}} <b>{{ appVersion }} ({{ releaseName }})</b>{{ $t(". The full changelog with each version is listed below.")}}</p>

                <div v-for="(release, code) in releases" class="release" :key="code">
                    <h3>{{ $t("v")}}{{ code }} - {{ release.name }}</h3>
                    <p>{{ release.summary }}</p>

                    <div class="release-body">
                        <div v-if="release.changes">
                            <h4><expander v-model="release.significant">{{ $t("Significant Changes")}}</expander></h4>

                            <b-collapse :visible="release.significant">
                                <ul class="changelog">
                                    <li v-for="(entry, idx) in release.changes" :key="idx">{{ entry }}</li>
                                </ul>
                            </b-collapse>
                        </div>

                        <div v-if="release.changelog">
                            <h4><expander v-model="release.full">{{ $t("Full Changelist (")}}{{ release.changelog.length }} {{ $t("commits)")}}</expander></h4>

                            <b-collapse :visible="release.full">
                                <ul class="changelog">
                                    <li v-for="commit in release.changelog" :key="commit.commit">
                                        <b v-b-tooltip="`${commit.author.name} on ${commit.author.date} [${commit.abbreviated_commit}]`">
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
import {appVersion, releaseName} from '@/app_config'
import v020_commits from '@/data/releases/v020_commits.js';
import v030_commits from '@/data/releases/v030_commits.js';
import v090_commits from '@/data/releases/v090_commits.js';
import v100_commits from '@/data/releases/v100_commits.js';
import v130_commits from '@/data/releases/v130_commits.js';
import dayjs from "dayjs";
import RelativeTime from 'dayjs/plugin/relativeTime' // load on demand
dayjs.extend(RelativeTime);

export default {
    name: "Releases",
    data() {
        return {
            appVersion,
            releaseName,
            releases: {
                "1.3.0": {
                    name: 'Init Expo',
                    summary: 'Released on 17.12.2021, this includes the reviewer interface and a submit variant feature.',
                    changes: [
                        'Finalized review interface',
                        'Introduced feature to submit additional variants',
                        'Lots of bugfixes and other improvements'
                    ],
                    significant: true, full: false, changelog: v130_commits
                },
                "1.0.0": {
                    name: 'Beta Aleph',
                    summary: 'Released on 20.10.2020, this is the first feature-complete public release.',
                    changes: [
                        'Finalized curation interface',
                        'Added 273 SVIP-curated entries for selected variants in TP53, CTNNB1, NRAS',
                        'Lots of bugfixes and other improvements'
                    ],
                    significant: true, full: false, changelog: v100_commits
                },
                "0.9.0": {
                    name: 'Alpha Zett',
                    summary: 'Released on 01.06.2020, this release includes a lot of small polishes in anticipation of the public release.',
                    changes: [
                        'Merges project page with main site.',
                        'Fixes many small issues, removes debugging code in anticipation of the public release.',
                        '[Backend]: includes all dependencies in the deployment scripts.',
                        '[Backend]: fixes lots of frontend build issues.',
                        '[Backend]: adds load-balancing between multiple SVIP instances.',
                    ],
                    significant: true, full: false, changelog: v090_commits
                },
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
