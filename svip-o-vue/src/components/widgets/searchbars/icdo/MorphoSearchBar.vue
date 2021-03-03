<template>
    <v-select
        id="my-select"
        :class="[state === false ? 'invalidated' : '']"
        :options="terms" :value="value" @input="update"
        :multiple="multiple" :taggable="allowCreate" :push-tags="allowCreate"
        :disabled="disabled"
        label="term"
        :filter-by="filterBy"
        @option:created="refreshTerms"
    >
        <template v-slot:option="option">
            <span :class="[option.user_created && 'user_created']">
                {{ option.term && titleCase(option.term.toLowerCase()) }}
            </span>

            <span class="text-muted float-right">
                {{ option.cell_type_code }}
            </span>
        </template>
    </v-select>
</template>

<script>
import { HTTP } from "@/router/http";
import { titleCase } from "@/utils";
import sortBy from 'lodash/sortBy';

export default {
    name: "MorphoSearchBar",
    props: {
        value: {},
        state: {type: Boolean},
        multiple: {type: Boolean, default: false},
        disabled: {type: Boolean, default: false},
        allowCreate: {type: Boolean, default: false},
    },
    data() {
        return {
            terms: [],
            loadingTerms: false
        }
    },
    created() {
        this.refreshTerms();
    },
    methods: {
        titleCase,
        refreshTerms() {
            this.loadingTerms = true;
            HTTP.get('/icdo_morpho?page_size=9999').then(response => {
                this.terms = response.data.results;
            }).finally(() => {
                this.loadingTerms = false;
            });
        },
        update(newValue) {
            this.$emit('input', newValue);
        },
        filterBy(option, label, search) {
            const isearch = search.toLowerCase();
            return (
                (option.term && option.term.toLowerCase().includes(isearch)) ||
                (option.cell_type_code && option.cell_type_code.toLowerCase().includes(isearch))
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
