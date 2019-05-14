<template>
  <!-- <div class="col-sm-auto"> -->
  <div class="card mt-3">
    <div class="card-header">
      <div class="card-title">Curation details</div>
    </div>
    <div class="card-body">
      <b-table :items="curationDataFiltered">
        <template slot="actions" slot-scope="row">
          <!-- We use @click.stop here to prevent a 'row-clicked' event from also happening -->
          <!-- <b-button size="sm" @click.stop="row.toggleDetails">
          {{ row.detailsShowing ? "Hide" : "Show" }} Details
        </b-button> -->
        </template>
      <!-- <template slot="name" slot-scope="row">
      {{ row.item.name }}
    </template> -->
    </b-table>
    </div>
  </div>
<!-- </div> -->
</template>

<script>
// import {normalizeItemList, titleCase, desnakify} from "@/utils";
// import {makeAssociationProvider} from "../../item_providers/association_provider";
// import PubmedPopover from "@/components/widgets/PubmedPopover";
// import RowDetailsHeader from "@/components/genes/sources/shared/RowDetailsHeader";

export default {
  name: "svipShowCuration",
  props: {
    // row: {type: Object, required: true}
    curationData: Array,
    disease_type: String
  },
  // components: {RowDetailsHeader, PubmedPopover},
  data() {
    return {

      // fields: [
      //   {
      //     key: "",
      //     label: "",
      //     sortable: true
      //   },
      //   {
      //     key: "",
      //     label: "",
      //     sortable: true
      //   },
      //   {
      //     key: "",
      //     label: "",
      //     sortable: true
      //   }
      // ]
    }
  },
  computed: {
    curationDataFiltered: function () {
      // return this.disease_type.substring(1, 4)
      let myDiseaseType = this.disease_type
      this.curationData = _.filter(this.curationData, function(x){
        return x.disease == myDiseaseType;
      })
      return this.curationData;
    }
  },
  methods: {
  }
}
</script>

<style scoped>
</style>
