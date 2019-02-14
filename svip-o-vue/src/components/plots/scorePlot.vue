<template>
	<div>
		<svg ref="thechart" class="bar-chart">
			<g v-for="(d, i) in layout" :key="i">
				<rect class="bar" :key="d.k" :x="d.x" :y="d.y" :width="d.width" :height="d.height" :fill="d.c"></rect>
				<rect v-if="d.v === 0" class="zero-value" :x="d.x + 3" :y="3" :width="d.width - 6" height="18" rx="2" ry="2"></rect>
			</g>

			<line class="basis" x1="0" x2="100%" y1="27" y2="27"></line>
		</svg>

		<b-tooltip :target="() => $refs.thechart" placement="left">
			<div v-for="d in layout" :key="d.k" style="text-align: left;">
				<svg width="10" height="10" class="legend-swatch">
					<rect width="10" height="10" :fill="d.c"></rect>
				</svg>
				<b>score {{ d.k }}:</b> {{ d.v }}
			</div>
		</b-tooltip>
	</div>
</template>

<script>
import * as d3 from "d3";

export default {
	data() {
		return {
			width: 100,
			height: 25,
			color: "#C00",
			padding: 1
		};
	},
	props: ["data"],
	created: function () {
		this.x = d3.scaleLinear();
		return (this.y = d3.scaleLinear());
	},
	methods: {},
	mounted: function () {
	},
	computed: {
		aggregatedData() {
			let temp = _.reduce(
				this.data,
				function (result, value, key) {
					(result[value] || (result[value] = [])).push(key);
					return result;
				},
				{}
			);
			let data = {
				1: {k: 1, v: 0, c: "#AAFFA9"},
				2: {k: 2, v: 0, c: "rgb(166,252,182)"},
				3: {k: 3, v: 0, c: "rgb(137,252,189)"},
				4: {k: 4, v: 0, c: "#11FFBD"}
			};
			_.forEach(temp, (v, i) => {
				if (data[i] !== undefined) data[i].v = v.length;
			});
			return Object.values(data);
		},
		layout: function () {
			this.x
				.domain([0, this.aggregatedData.length])
				.range([0, this.width]);
			this.y
				.domain([
					0,
					d3.max(this.aggregatedData, function (d) {
						return d.v;
					})
				])
				.range([0, this.height]);
			return this.aggregatedData.map(
				(function (_this) {
					return function (d, i) {
						return {
							v: d.v,
							k: d.k,
							x: _this.x(i),
							y: _this.y.range()[1] - _this.y(d.v),
							c: d.c,
							width: Math.max(
								1,
								_this.x(1) - _this.x(0) - _this.padding
							),
							height: _this.y(d.v)
						};
					};
				})(this)
			);
		}
	}
};
</script>

<style>
.bar-chart {
	width: 100px;
	height: 28px;
}

.bar-chart .zero-value {
	stroke: #aaa;
	stroke-dasharray: 2px;
	stroke-width: 0.5px;
	fill: transparent;
}

.bar-chart .rating-label {
	font-size: 12px;
	font-family: "Heiti SC", sans-serif;
	text-align: center;
}

.bar-chart line {
	shape-rendering: crispEdges;
	stroke: #aaa;
}

#tooltip {
	position: absolute;
	text-align: center;
	min-width: 80px;
	padding: 5px;
	font: 12px sans-serif;
	color: #fff;
	background-color: #000;
	border: 0px;
	border-radius: 8px;
	pointer-events: none;
}
</style>
