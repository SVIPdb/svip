<template>
    <v-select :label="'medicine_name'" :options="drugs" :value="value" @input="update" multiple />
</template>

<script>
import { HTTP } from "@/router/http";

export default {
    name: "DrugSearchBar",
    props: {
        label: {type: String, defualt: 'medicine_name' },
        value: {type: Array}
    },
    data() {
      return {
          drugs: []
      }
    },
    created() {
        HTTP.get('/drugs').then(response => {
            console.log(response.data);
            this.drugs = response.data;
        });
    },
    methods: {
        update(newValue) { this.$emit('input', newValue); }
    }
}
</script>

<style scoped>

</style>
