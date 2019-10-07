<template>
  <b-card class="shadow-sm mb-3" align="left" no-body>
    <b-card-header
      class="p-1"
      :header-bg-variant="cardHeaderBg"
      :header-text-variant="cardTitleVariant"
      :class="title == 'ON REQUEST' ? customClass : ''"
    >
      <div class="d-flex justify-content-between">
        <div class="p-2 font-weight-bold">
          {{title}}
          <b-button class="ml-3" size="sm" variant="primary" @click="setCustomFilter(curator)">
            My curations
            <b-badge
              pill
              class="bg-white text-dark"
            >{{items.filter(element => element.curator == this.curator && element.curated == 'Ongoing').length}}</b-badge>
          </b-button>
          <b-button class="ml-3" size="sm" variant="primary" @click="setCustomFilter('all')">
            All curations
            <b-badge pill class="bg-white text-dark">{{items.length}}</b-badge>
          </b-button>
          <b-button-group v-if="cardFilterOption" class="ml-3" size="sm">
            <b-button variant="danger" @click="setStatusFilter('Not assigned')">Not assigned</b-button>
            <b-button variant="warning" @click="setStatusFilter('Ongoing')">Ongoing</b-button>
            <b-button variant="success" @click="setStatusFilter('Complete')">Complete</b-button>
            <b-button variant="info" @click="setStatusFilter('all')">All</b-button>
          </b-button-group>
        </div>
        <div>
          <b-input-group size="sm" class="p-1">
            <b-form-input v-model="filter" placeholder="Type to Search"></b-form-input>
            <b-input-group-append>
              <b-button :variant="settings.buttonBg" size="sm" @click="filter = ''">Clear</b-button>
            </b-input-group-append>
          </b-input-group>
        </div>
      </div>
    </b-card-header>
    <b-card-body class="p-0">
      <b-table
        small
        class="mb-0"
        :items="filteredItems"
        :fields="fields"
        hover
        :filter="filter"
        :sort-by.sync="sortBy"
        :sort-desc="true"
        show-empty
      >
        <template v-slot:cell(gene_name)="data">
          <p class="font-weight-bold mb-0">{{data.value}}</p>
        </template>
        <template v-slot:cell(hgvs)="data">
          <p class="mb-0">{{data.value}}</p>
        </template>
        <template v-slot:cell(deadline)="row">
          <p
            v-if="row.item.curated != 'Complete'"
            :class="setFlagClass(row.item.days_left)+' m-0 p-0'"
          >
            <span class="font-weight-bold">{{ setLetter(row.item.days_left) }}</span>
            ({{row.item.days_left}} days)
          </p>
        </template>
        <template v-slot:cell(curated)="data">
          <b-badge :variant="setBadgeClass(data.value)">{{data.value}}</b-badge>
        </template>
        <template v-slot:cell(reviewed)="data">
          <icon
            v-for="(reviewer, index) in data.value"
            v-bind:key="index"
            v-b-popover.hover.top="reviewer.label"
            :name="reviewer.value ? 'check' : 'times'"
            :class="reviewer.value ? 'text-success mr-1' : 'text-danger mr-1'"
          ></icon>
        </template>
        <template v-slot:cell(action)="row">
          <b-form-checkbox
            :disabled="row.item.curated == 'Complete' || row.item.curator != curator && row.item.curator != null"
            :checked="row.item.curator == curator ? true : false"
          >
            <icon class="text-primary" name="eye" />
          </b-form-checkbox>
        </template>
        <template v-slot:cell(single_action)>
          <icon class="mr-1" name="eye" />
        </template>
      </b-table>
    </b-card-body>
  </b-card>
</template>

<script>
/**
 * @group Curation
 * This Notification card allows to display a card which contains a table filled with samples waiting to be curated or reviewed
 */
export default {
  name: "NotificationCard",
  props: {
    // The items of the table
    items: {
      type: Array,
      required: true,
      // The default value is an empty array: `[]`
      default: []
    },
    // The fields of the table
    fields: {
      type: Array,
      required: true,
      // The default value is an empty array: `[]`
      default: []
    },
    // The title of the card
    title: {
      type: String,
      required: true,
      // The default value is: `DEFAULT_TITLE`
      default: "DEFAULT_TITLE"
    },
    // The default column used to sort (Desc) the table
    sortBy: {
      type: String,
      required: false,
      // The default valie is: `id`
      default: "id"
    },
    cardHeaderBg: {
      type: String,
      required: false,
      default: "light"
    },
    cardTitleVariant: {
      type: String,
      required: false,
      default: "primary"
    },
    cardFilterOption: {
      type: Boolean,
      required: false,
      default: false
    }
  },
  data() {
    return {
      customClass: "customClass",
      curator: "Curator2", //FIXME MANUALLY SETTING THE CURATOR
      // Custom settings for the visual
      settings: {
        buttonBg: "primary"
      },
      // Needed parameters for the table
      filter: null,
      myFilter: "all",
      statusFilter: "all",
      // Days left limits
      daysLeft: {
        min: 2,
        max: 14
      },
      curationStatus: {
        "Not assigned": "danger",
        Ongoing: "warning",
        Complete: "success"
      }
    };
  },
  methods: {
    /**
     * @vuese
     * Used to set up the correct flag class depending on the days left
     * @arg `Number` Days left
     */
    setFlagClass(days_left) {
      if (days_left <= this.daysLeft.min) {
        return "text-danger";
      } else if (days_left <= this.daysLeft.max) {
        return "text-warning";
      } else {
        return "text-success";
      }
    },
    /**
     * @vuese
     * Used to set up the correct flag class depending on the days left
     * @arg `Number` Days left
     */
    setLetter(days_left) {
      if (days_left <= this.daysLeft.min) {
        return "H";
      } else if (days_left <= this.daysLeft.max) {
        return "M";
      } else {
        return "L";
      }
    },
    /**
     * @vuese
     * Used to set up the correct badge depending on the status
     * @arg `String` Curation status
     */
    setBadgeClass(status) {
      return this.curationStatus[status];
    },
    setCustomFilter(filter) {
      this.myFilter = filter;
    },
    setStatusFilter(filter) {
      this.statusFilter = filter;
    }
  },
  computed: {
    filteredItems() {
      let items = this.items;
      if (this.statusFilter != "all") {
        items = items.filter(element => element.curated == this.statusFilter);
      }
      if (this.myFilter != "all") {
        return items.filter(
          element =>
            (element.curator == this.curator && element.curated == "Ongoing") ||
            !element.curated
        );
      } else {
        return items;
      }
    }
  }
};
</script>

<style>
.customClass {
  background-color: "#c40000 !important";
}
</style>
