<template>
    <v-select
        id="my-select"
        :class="[state === false ? 'invalidated' : '']"
        :options="diseases" :value="value" @input="update"
        :multiple="multiple" :taggable="allowCreate" :push-tags="allowCreate"
        :disabled="disabled"
        label="name"
        :filter-by="filterBy"
        @option:created="refreshDiseases"
    >
        <template v-slot:option="option">
            <span :class="[option.user_created && 'user_created']">
                {{ option.name || option.label }}
            </span>

            <span class="text-muted float-right">
                {{ option.localization && titleCase(option.localization.toLowerCase()) }}
            </span>
        </template>
    </v-select>
</template>

<script>
import { HTTP } from "@/router/http";
import { titleCase } from "@/utils";
import sortBy from 'lodash/sortBy';

export default {
    name: "DiseaseSearchBar",
    props: {
        value: {},
        state: {type: Boolean},
        multiple: {type: Boolean, default: false},
        disabled: {type: Boolean, default: false},
        allowCreate: {type: Boolean, default: false},
    },
    data() {
        return {
            diseases: []
        }
    },
    created() {
        this.refreshDiseases();
    },
    methods: {
        titleCase,
        refreshDiseases() {
            HTTP.get('/diseases?page_size=9999').then(response => {
                this.diseases = sortBy(response.data.results, x => !x.user_created);
            });
        },
        update(newValue) {
            this.$emit('input', newValue);
        },
        filterBy(option, label, search) {
            const isearch = search.toLowerCase();
            return (
                (option.name && option.name.toLowerCase().includes(isearch)) ||
                (option.localization && option.localization.toLowerCase().includes(isearch))
            );
        }
    }
}
</script>

<style scoped>
#my-select >>> .vs__dropdown-toggle { padding: 24px; }
.invalidated >>> .vs__dropdown-toggle  {
    border-color: #e74c3c !important;
}
.user_created { font-style: italic; }
</style>
