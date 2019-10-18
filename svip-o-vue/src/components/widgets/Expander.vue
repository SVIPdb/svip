<template>
  <b-link @click="row.toggleDetails">
<!--    <icon :name="row.detailsShowing ? 'chevron-down' : 'chevron-right'"></icon>-->
    <icon name="chevron-right" :class="`link ${row.detailsShowing ? 'activated' : ''}`" />
  </b-link>
</template>

<script>
export default {
  name: "Expander",
  props: {
    row: {type: Object, required: true}
  }
}
</script>

<style scoped>
.link {
  transform: rotate(0deg);
  transition: all 100ms linear;
}
.activated {
  transform: rotate(90deg);
  transition: all 100ms linear;
}
</style>
