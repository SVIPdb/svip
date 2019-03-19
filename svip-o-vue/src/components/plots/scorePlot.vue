<template>
	<div>
		<svg ref="thechart" class="bar-chart" :style="`width: ${width}px; height: ${height + 14}px`">
			<g v-for="(d, i) in layout" :key="i">
				<rect class="bar" :x="d.x" :y="d.y" :width="d.width" :height="d.height" :fill="d.c"></rect>
				<rect v-if="d.v === 0" class="zero-value" :x="d.x + 3" :y="3" :width="d.width - 6" height="18" rx="2" ry="2"></rect>
				<text :x="d.x + (boxWidth/2.0)" :y="height + 14"
							text-anchor="middle" font-size="11" class="rating-label">
					{{ d.k }}
				</text>
			</g>

			<line class="basis" x1="0" :x2="width" :y1="height + 2" :y2="height + 2"></line>
		</svg>

		<b-tooltip :target="() => $refs.thechart" placement="left">
			<div v-for="d in layout" :key="d.k" style="text-align: left;">
				<svg width="10" height="10" class="legend-swatch">
					<rect width="10" height="10" :fill="d.c"></rect>
				</svg>
				<span class="inline-label">{{ d.k }}:</span> {{ d.v }}
			</div>
		</b-tooltip>
	</div>
</template>

<script>
import * as d3 from "d3";
import * as _ from 'lodash';

const source_levels = {
	// from https://civicdb.org/help/evidence/evidence-levels
	'civic': [
		{level: 'A', c: '#5cb05e'},
		{level: 'B', c: '#50aee3'},
		{level: 'C', c: '#646eaf'},
		{level: 'D', c: '#e89544'},
		{level: 'E', c: '#d1555c'}
	],
	// from https://oncokb.org/levels
	'oncokb': [
		{level: '1',  c: '#5cb05e'}, // used to be #48873c, but livened it up a bit w/CIViC's level 'A'
		{level: '2A', c: '#30578c'},
		{level: '2B', c: '#7597b5'},
		{level: '3A', c: '#6e3a77'},
		{level: '3B', c: '#9e7da5'},
		{level: '4',  c: '#2e2e2c'},
		{level: 'R1', c: '#be382a'},
		{level: 'R2', c: '#d78579'}
	]
}

export default {
	data() {
		const boxWidth = 25;
		return {
			boxWidth,
			width: boxWidth * source_levels[this.sourceName].length,
			height: 25,
			padding: 1
		};
	},
	props: ["scores", "sourceName"],
	created: function () {
		this.x = d3.scaleLinear();
		return (this.y = d3.scaleLinear());
	},
	methods: {},
	mounted: function () {
	},
	computed: {
		aggregatedData() {
			// for some reason, data() isn't updated if we change the sort order, so 'width' ends up being out-of-date with
			// the row to which we're bound; we manually set it here to compensate.
			this.width =  25 * source_levels[this.sourceName].length;

			// first, construct an object with all levels for the source, merging in the actual scores where available
			return source_levels[this.sourceName].map((x) => ({
				k: x.level, v: this.scores[x.level] || 0, c: x.c
			}));

			/*
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
			*/
		},
		layout: function () {
			this.x
				.domain([0, this.aggregatedData.length])
				.range([0, this.width]);
			this.y
				.domain([0, d3.max(this.aggregatedData, (d) => d.v)])
				.range([0, this.height]);

			// if either of the scales have 0-length domains, the value will always be the mean of the range
			// we need to bump the domain up a bit if its bounds are equal to provide resolution
			if (this.y.domain()[0] === this.y.domain()[1]) {
				this.y.domain([0,1]);
			}

			return this.aggregatedData.map(
				(function (_this) {
					return function (d, i) {
						return {
							v: d.v,
							k: d.k,
							x: _this.x(i),
							y: _this.y.range()[1] - _this.y(d.v),
							c: d.c,
							width: Math.max(1, _this.x(1) - _this.x(0) - _this.padding),
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
.inline-label {
	display: inline-block;
	text-align: right;
	min-width: 3ex;
}

.bar-chart .zero-value {
	stroke: #aaa;
	stroke-dasharray: 2px;
	stroke-width: 0.5px;
	fill: transparent;
}

.bar-chart .rating-label {
	font-size: 11px;
	/*font-family: "Heiti SC", sans-serif;*/
	text-align: center;
	fill: #777;
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
