<!--

Based on:
  https://bl.ocks.org/shimizu/f90651541575f348a129444003a73467

Links:
  Props: https://vuejs.org/v2/guide/components.html#Passing-Data-with-Props
  Methods: https://vuejs.org/v2/guide/events.html#Method-Event-Handlers

-->

<template>
	<div>
		<svg width="50" ref="thechart" height="30"></svg>

		<b-tooltip :target="() => $refs.thechart" placement="top">
			<div v-for="d in this.formattedData" style="text-align: left;">
				<svg width="10" height="10" class="legend-swatch">
					<rect width="10" height="10" :fill="d.color"></rect>
				</svg>
				<span
				><b>{{ d.label }}:</b> {{ d.value }}</span
				>
			</div>
		</b-tooltip>
	</div>
</template>

<script>
import Vue from "vue";
import * as d3 from "d3";

export default {
	mounted: function () {
		const svg = d3.select(this.$el).select("svg");
		const width = +svg.attr("width");
		const height = +svg.attr("height");

		const margin = {top: 0, left: 0, bottom: 0, right: 0};

		const chartWidth = width - (margin.left + margin.right);
		const chartHeight = height - (margin.top + margin.bottom);

		this.chartLayer = svg
			.append("g")
			.attr("transform", `translate(${margin.left}, ${margin.top})`);

		this.arc = d3
			.arc()
			.outerRadius(chartHeight / 2)
			.innerRadius(chartHeight / 4);
		// .padAngle(0.03)
		// .cornerRadius(0)

		this.pieG = this.chartLayer
			.append("g")
			.attr(
				"transform",
				`translate(${chartWidth / 2}, ${chartHeight / 2})`
			);

		this.drawChart(this.formattedData);
	},
	props: ["data"],
	computed: {
		formattedData() {
			let data = [];
			_.forEach(this.data, (v, k) => {
				data.push({
					label: k,
					value: v,
					color: k === "male" ? "#0F7FFE" : "#CC66FE"
				});
			});
			return data;
		},
		tooltip() {
			let html = "<dl class = 'row' style='margin: 0'>";
			_.forEach(this.data, (v, k) => {
				html +=
					"<dt class='col-6'  style='text-align: right; padding-right: 2px;'>" +
					k +
					":</dt><dd class='col-6' style='text-align: left; padding-left: 2px;'>" +
					v +
					"</dd>";
			});
			html += "</dl>";
			return html;
		}
	},
	watch: {
		data: function (newData) {
			this.drawChart(this.formattedData);
		}
	},
	methods: {
		drawChart: function (data) {
			const arcs = d3
				.pie()
				.sort(null)
				.value(function (d) {
					return d.value;
				})(data);

			const block = this.pieG.selectAll(".arc").data(arcs);

			block.select("path").attr("d", this.arc);

			const newBlock = block
				.enter()
				.append("g")
				.classed("arc", true);

			newBlock
				.append("path")
				.attr("d", this.arc)
				.attr("id", function (d, i) {
					return "arc-" + i;
				})
				.attr("stroke", "none")
				.attr("fill", d => {
					return d.data.label === "male" ? "#0F7FFE" : "#CC66FE";
				})
				.attr("title", d => d.label + ": " + d.value);
		}
	}
};
</script>
<style>
#tooltip {
	position: absolute;
	text-align: center;
	width: 120px;
	height: 28px;
	padding: 2px;
	font: 12px sans-serif;
	color: #fff;
	background-color: #000;
	border: 0px;
	border-radius: 8px;
	pointer-events: none;
}
</style>
