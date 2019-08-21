<template>
	<div class="container">
		<div class="row">
			<div class="col-md-9">
				<h1>Glossary</h1>
				<p>The following list describes terms found in SVIP.</p>
			</div>
		</div>

		<div class="highlight-clean row">
			<TableOfContents :sections="help_sections" />

			<div class="col-md-8 order-1">
				<div class="section" v-for="section in help_sections" :key="section.name">
					<h3>{{ section.name }}</h3>
					<a class="target-label" :name="`sec_${slugify(section.name)}`"> </a>

					<div class="terms">
						<div class="entry" v-for="entry in section.content" :key="entry.Field">
							<div class="term"><b>{{ entry.Field }}:</b></div>
							<div class="definition">
								<span v-if="entry['Complete description']">{{ entry['Complete description'] }}</span>
								<span v-else><i>missing description!</i></span>

								<div class="example" v-if="entry['Example']">
									<b>Example:</b>
									<div v-if="typeof entry['Example'] == 'object' && entry['Example'].img">
										<img :src="require(`./resources/${entry['Example'].img}`)"  alt="Example"/>
									</div>
									<span class="example-text" v-else>{{ entry['Example'] }}</span>
								</div>

								<div class="references" v-if="entry.Reference && entry.Reference.length === 1">
									<b>Reference:</b>&nbsp;
									<span>
											<a :href="entry.Reference[0]" v-if="entry.Reference[0].startsWith('http')">{{ entry.Reference[0] }}</a>
											<span v-else>{{ entry.Reference[0] }}</span>
									</span>
								</div>
								<div class="references" v-else-if="entry.Reference">
									<b>References:</b>
									<ul>
										<li v-for="(ref, idx) in entry.Reference" :key="idx">
											<a :href="ref" v-if="ref.startsWith('http')">{{ ref }}</a>
											<span v-else>{{ ref }}</span>
										</li>
									</ul>
								</div>
							</div>
						</div>
					</div>
				</div>

			</div>
		</div>
	</div>
</template>

<script>
import slugify from "slugify";
import TableOfContents from "@/components/help/TableOfContents";

const help_sections = [
	{
		name: 'Variant Information',
		content: require('./json/variant_info')
	},
	{
		name: 'SVIP: Overview',
		content: require('./json/svip_info')
	},
	{
		name: 'SVIP: Samples',
		content: require('./json/svip_samples')
	},
	{
		name: 'SVIP: Curation',
		content: require('./json/svip_curation')
	},
	{
		name: 'Public Databases',
		content: require('./json/public_info')
	},
];

export default {
	name: "Help",
	components: {TableOfContents},
	data() {
		return {
			help_sections
		};
	},
	methods: {
		slugify
	}
}
</script>

<style scoped>
.section { margin-bottom: 1em; position: relative; }
.section .target-label { position: absolute; top: -85px; }

.terms { margin-left: 20px; }
.terms .entry { margin-bottom: 1em; }
.terms .term { font-weight: bold; font-size: larger; }
.terms .definition { margin-left: 10px; }

.terms .example {
	margin-top: 0.5em;
}
.terms .example .example-text {
  font-style: oblique; margin-left: 3px;
}

.terms .definition .references {
	margin-top: 0.5em;
}
</style>
