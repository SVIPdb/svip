<template>
	<div>
		<svg ref="thechart" class="sig-bar-chart">
			<g v-for="d in layout" :key="d.k">
				<rect class="bar" :x="d.x" :y="d.y" :width="d.width" :height="d.height" :fill="d.c"></rect>
			</g>
		</svg>

		<b-tooltip :target="() => $refs.thechart" placement="top">
			<div v-for="d in this.formattedData" :key="d.name" style="text-align: left;">
				<svg width="10" height="10" class="legend-swatch">
					<rect width="10" height="10" :fill="d.color"></rect>
				</svg>
				<span><b>{{ d.name }}:</b> {{ d.count.toLocaleString() }}</span>
			</div>
		</b-tooltip>
	</div>
</template>

<script>
import * as d3 from "d3";
import {titleCase} from "@/utils";
import * as _ from "lodash";

const colorMap = d3
	.scaleOrdinal(d3.schemeSet3)
	.domain(
		[
			"(unknown)",
			"Pathogenic",
			"Likely Pathogenic",
			"Uncertain Significance",
			"Likely Benign",
			"Better Outcome",
			"N/A",
			"Negative",
			"Positive",
			"Reduced Sensitivity",
			"Sensitivity/Response",
			"resistant",
			"sensitive"
		].map(x => x.toLowerCase())
	);

export default {
	data() {
		return {
			width: 300,
			height: 25,
			color: "#C00",
			padding: 1
		};
	},
	props: ["data"],
	created: function () {
		this.x = d3.scaleLinear();
	},
	methods: {},
	computed: {
		formattedData: function () {
			return _.sortBy(this.data, x => -x.count).map((d) => {
				let name;

				if (d.name === "NA") {
					name = "N/A";
				} else if (d.name === "null") {
					name = "(unknown)";
				} else {
					name = titleCase(d.name);
				}

				return {
					name: name,
					count: d.count,
					color: colorMap(name.toLowerCase())
				};
			});
		},
		layout: function () {
			const total = d3.sum(this.formattedData, d => d.count);
			this.x.domain([0, 1.0]).range([0, this.width]);

			return this.formattedData.map((d, i) => {
				const prop = x => x / total;
				const xpos =
					i > 0
						? d3.sum(this.formattedData.slice(0, i), p =>
							this.x(prop(p.count))
						)
						: 0;

				return {
					v: d.count,
					k: d.name,
					x: xpos,
					y: 0,
					c: d.color,
					width: this.x(prop(d.count)),
					height: this.height
				};
			});
		}
	}
};
</script>

<style>
.sig-bar-chart {
	width: 300px;
	height: 28px;
}

#sigtooltip {
	position: absolute;
	text-align: left;
	min-width: 150px;
	padding: 10px;
	font: 12px sans-serif;
	color: #fff;
	background-color: rgba(0, 0, 0, 0.8);
	border: 0;
	border-radius: 8px;
	pointer-events: none;
}

.tooltip-inner {
	max-width: 100% !important;
}
</style>
