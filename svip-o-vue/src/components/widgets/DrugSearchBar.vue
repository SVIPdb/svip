<template>
    <v-select
        id="my-select"
        :class="[state === false ? 'invalidated' : '']"
        :options="drugs" :value="value" @input="update"
        :multiple="multiple" :taggable="allowCreate" :push-tags="allowCreate"
    />
</template>

<script>
import { HTTP } from "@/router/http";
import {titleCase} from "@/utils";

export default {
    name: "DrugSearchBar",
    props: {
        label: {type: String, default: 'common_name' },
        value: {type: Array | Object},
        state: {type: Boolean},
        multiple: {type: Boolean, default: false},
        allowCreate: {type: Boolean, default: false},
    },
    data() {
      return {
          drugs: []
      }
    },
    created() {
        HTTP.get('/drugs').then(response => {
            this.drugs = response.data.map(x => titleCase(x[this.label]));
        });
    },
    methods: {
        update(newValue) {
            console.log("Updating drug selection w/", newValue);
            this.$emit('input', newValue);
        }
    }
}
</script>

<style scoped>
#my-select >>> .dropdown-toggle { padding: 24px; }
.invalidated >>> .dropdown-toggle  {
    border-color: #e74c3c !important;

    /*
    background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='%23dc3545' viewBox='-2 -2 7 7'%3e%3cpath stroke='%23dc3545' d='M0 0l3 3m0-3L0 3'/%3e%3ccircle r='.5'/%3e%3ccircle cx='3' r='.5'/%3e%3ccircle cy='3' r='.5'/%3e%3ccircle cx='3' cy='3' r='.5'/%3e%3c/svg%3E");
    background-repeat: no-repeat;
    background-position: center right calc(1.5em + .375rem);
    background-size: calc(.75em + .375rem) calc(.75em + .375rem);
     */
}
</style>
