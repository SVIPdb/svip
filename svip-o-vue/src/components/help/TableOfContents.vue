<template>
  <div class="toc col-md-4 order-md-2 order-sm-0">
    <h3>Table of Contents</h3>
    <ol>
      <li v-for="section in sections" :key="section.name">
        <a :href="`#sec_${ slugify(section.name) }`">{{ section.name }}</a>
      </li>
    </ol>
  </div>
</template>

<script>
import slugify from "slugify";

export default {
	name: "TableOfContents",
	props: {
		sections: { type: Array, required: true }
	},
	methods: {
		slugify
	}
}
</script>

<style scoped>
.toc { position: fixed; right: 0; }
@media(max-width: 600px) {
  .toc { position: relative; }
}
</style>
