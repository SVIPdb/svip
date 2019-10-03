<template>
  <b-card class="shadow-sm mb-3" align="left" no-body>
    <b-card-body class="p-0">
      <b-table
        class="mb-0"
        thead-class="bg-primary text-light"
        :items="items"
        :fields="fields"
        show-empty
        empty-text="There seems to be an error"
      ></b-table>
    </b-card-body>
  </b-card>
</template>

<script>
import fields from "@/components/curation/data/evidence/fields.json";

export default {
  name: "EvidenceCard",
  props: {
    items: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      fields
    };
  },
  computed: {}
};
</script>

<style>
</style>
