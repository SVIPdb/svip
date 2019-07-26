<template>
  <b-card class="shadow-sm mb-3" align="left" no-body>
    <b-card-header
      class="p-1"
      :header-bg-variant="settings.cardHeaderBg"
      :header-text-variant="settings.cardTitleVariant"
    >
      <div class="d-flex justify-content-between">
        <div class="p-2 font-weight-bold">
          {{title}}
          <b-badge pill class="bg-white text-dark">{{items.length}}</b-badge>
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
        :items="items"
        :fields="fields"
        hover
        :filter="filter"
        :sort-by.sync="sortBy"
        :sort-desc="true"
        show-empty
      >
        <template slot="flag" slot-scope="row">
          <icon name="flag" :class="setFlagClass(row.item.days_left)"></icon>
        </template>
        <template slot="gene_name" slot-scope="data">
          <p class="font-weight-bold mb-0">{{data.value}}</p>
        </template>
        <template slot="hgvs" slot-scope="data">
          <p class="text-monospace mb-0">{{data.value}}</p>
        </template>
        <template
          slot="deadline"
          slot-scope="row"
        >{{row.item.deadline}} ({{row.item.days_left}} days)</template>
        <template slot="curated" slot-scope="data">
          <b-badge :variant="setBadgeClass(data.value)">{{data.value}}</b-badge>
        </template>
        <template slot="reviewed" slot-scope="data">
          <b-img
            v-for="(reviewer, index) in data.value"
            v-bind:key="index"
            v-b-tooltip.hover
            :title="reviewer.label"
            blank
            :blank-color="reviewer.value ? '#28a745' : '#ff5555'"
            class="mr-1"
            width="12"
            height="12"
          ></b-img>
        </template>
        <template slot="action">
          <icon class="mr-1" name="eye" />
          <icon class="mr-1" name="edit" />
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
    }
  },
  data() {
    return {
      // Custom settings for the visual
      settings: {
        cardHeaderBg: "light",
        cardTitleVariant: "primary",
        buttonBg: "primary"
      },
      // Needed parameters for the table
      filter: null,
      // Days left limits
      daysLeft: {
        min: 2,
        max: 14
      },
      curationStatus: {
        No: "danger",
        "On going": "info",
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
     * Used to set up the correct badge depending on the status
     * @arg `String` Curation status
     */
    setBadgeClass(status) {
      return this.curationStatus[status];
    }
  }
};
</script>

<style>
</style>
