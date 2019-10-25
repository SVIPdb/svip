<template>
    <div class="col-sm-auto" v-if="items && items.length > 0">
        <div class="card mt-3 top-level">
            <div class="card-header">
                <div class="card-title">SOCIBP Samples</div>
            </div>

            <div class="card-body top-level">
                <b-table :fields="fields" :items="items" :sort-by.sync="sortBy" :sort-desc="false">
                    <template v-slot:cell(studyName)="row">
                        <a :href="row.item.authed_link" v-b-tooltip="row.item.study.name">{{ row.item.studyName }}</a>
                    </template>
                    <template v-slot:cell(num_patients_samples)="row">
                        {{ row.item.num_patients }} / {{ row.item.num_samples }}
                    </template>
                </b-table>
            </div>
        </div>
    </div>
</template>

<script>
import {HTTP} from "@/router/http";

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
                    label: "# of Samples/Patients",
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
            }))
        }).catch((err) => {
            // just don't display the thing if we encounter an error
            console.warn("Encountered error when querying SOCIBP, hiding widget. Error: ", err);
            this.items = [];
        })
    },
    props: {
        protein: {type: String, required: true},
        change: {type: String, required: true}
    }
};
</script>

<style scoped></style>
