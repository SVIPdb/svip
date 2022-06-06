<template>
    <div>
        <div class="card mt-3 top-level">
            <div class="card-header">
                <div class="card-title">
                    {{ $t("SOCIBP Samples")}}
                    <div class="float-right align-middle">
                        <a :href="`https://socibp.nexus.ethz.ch/cbioportal`" target="_blank">
                            <icon name="external-link-alt"/>
                        </a>
                    </div>
                </div>
            </div>

            <div v-if="items && items.length > 0" class="card-body top-level">
                <b-table :fields="fields" :items="items" :sort-by.sync="sortBy" :sort-desc="false">
                    <template v-slot:cell(studyName)="row">
                        <a :href="row.item.authed_link" v-b-tooltip="row.item.study.name">{{ row.item.studyName }}</a>
                    </template>
                    <template v-slot:cell(num_patients_samples)="row">
                        {{ row.item.num_patients }} / {{ row.item.num_samples }}
                    </template>
                </b-table>
            </div>
            <div v-else class="card-body text-muted errorbox">
                {{ $t("SOCIBP is currently unavailable, please try again later.")}}
            </div>
        </div>
    </div>
</template>

<script>
import ulog from 'ulog';
import { HTTP } from "@/router/http";

const log = ulog('SOCIBP');

export default {
    name: "SOCIBP",
    data() {
        return {
            sortBy: "",
            items: [],
            fields: [
                {
                    key: "studyName",
                    label: "Study",
                    sortable: true
                },
                {
                    key: "num_patients_samples",
                    label: "Samples/Patients",
                    sortable: true
                }
            ]
        };
    },
    mounted() {
        // noinspection JSCheckFunctionSignatures
        HTTP.get(`/socibp/stats/${this.protein}/${this.change}`, {handled: true}).then((response) => {
            this.items = response.data.mutations.map(x => ({
                studyName: x.study.shortName,
                study: x.study,
                num_patients: x.num_patients,
                num_samples: x.num_samples,
                authed_link: x.authed_link
            }));
            this.$emit('updated');
        }).catch((err) => {
            log.warn(err);
            
            // just don't display the thing if we encounter an error
            this.items = [];
        })
    },
    props: {
        protein: {type: String, required: true},
        change: {type: String, required: true}
    }
};
</script>

<style scoped>
.errorbox {
    text-align: center;
    padding: 15px;
    font-style: italic;
}
</style>
