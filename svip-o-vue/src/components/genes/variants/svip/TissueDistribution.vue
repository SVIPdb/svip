<template>
    <div class="tissue-dist-row">
			<h5 style="margin-bottom: 0.75em;">Tissue Distribution</h5>

			<div ref="thechart" class="disease-holster">
				<div v-for="(bar, idx) in bars" :key="bar.name" class="disease-row">
					<div class="disease-name">{{ bar.name }}</div>
					<svg :id="`disease-chart_${bar.name}`" :ref="`disease-chart_${bar.name}`" class="sig-bar-chart" :viewBox="`0 0 300 ${barHeight}`" preserveAspectRatio="none" :style="`height: ${barHeight}`">
						<g v-for="d in bar.sections" :key="d.k">
							<rect class="bar" :x="d.x" :y="0" :width="d.width" :height="d.height" :fill="d.c"></rect>
						</g>
					</svg>

					<b-tooltip :target="() => getDocument().getElementById(`disease-chart_${bar.name}`)" placement="bottom">
						<div v-for="(disease, idx) in getDiseasesForTissue(bar.name)" :key="disease.name" style="text-align: left;">
							<svg width="10" height="10" class="legend-swatch">
								<rect width="10" height="10" :fill="diseaseColors(disease.name)"></rect>
							</svg>
							<span><b>{{ disease.name }}:</b> {{ disease.count.toLocaleString() }}</span>
						</div>
					</b-tooltip>
				</div>
			</div>
		</div>
</template>

<script>
import * as d3 from "d3";
import {titleCase} from "@/utils";
import * as _ from "lodash";

export default {
	name: "TissueDistribution",
	data() {
		return {
			width: 300,
			barHeight: 25,
			padding: 1
		};
	},
	props: ["tissue_counts"],
	methods: {
		getDocument() { return document; },
		getDiseasesForTissue(tissue_name) {
			return this.tissue_counts.find(x => x.name === tissue_name).diseases;
		}
	},
	computed: {
		diseases() {
			console.log("tissue: ", this.tissue_counts);
			return _.flatten(this.tissue_counts.map(x => x.diseases))
		},
		diseaseColors() {
			const disease_names = this.diseases.map(x => x.name);
			return d3
				.scaleOrdinal(d3.schemeSet3)
				.domain(disease_names);
		},
		bars() {
			const maxWidth = _.max(this.tissue_counts.map(x => x.count));

			return this.tissue_counts.map((curTissue) => {
				const total = curTissue.count;
				const x = d3.scaleLinear()
					.domain([0, 1.0])
					.range([0, (total/maxWidth) * this.width]);

				return {
					name: curTissue.name,
					sections: curTissue.diseases.map((d, i) => {
						const prop = x => x / total;
						const xpos = i > 0 ? d3.sum(this.tissue_counts.slice(0, i), p => x(prop(p.count))) : 0;

						return {
							v: d.count,
							k: d.name,
							x: xpos,
							y: 0,
							c: this.diseaseColors(d.name),
							width: x(prop(d.count)),
							height: this.barHeight
						};
					})
				};
			});
		},
		totalHeight() {
			return this.bars.length * this.barHeight;
		}
	}
};
</script>

<style scoped>
.tissue-dist-row {
	padding: 10px;
	border-bottom: solid 1px #eee;
}

.disease-holster {
	display: inline-block;
}

.disease-holster .disease-row {
	display: flex; flex-direction: row;
	margin-bottom: 0.25em;
}
.disease-holster .disease-row .disease-name {
	min-width: 8ex;
	text-align: right;
	margin-right: 5px;
}
.sig-bar-chart {
	width: 300px;
}

.subsigs {
	font-size: 1.8ex;
	padding: 0 0 0 18px;
	margin: 0;
}
.subsigs li {
	margin: 0;
	padding: 0;
}
</style>
