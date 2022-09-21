<template>
    <div>
        <svg ref="thechart" class="bar-chart" :style="`width: ${width}px; height: ${height + 14}px`">
            <g v-for="(d, i) in layout" :key="i">
                <rect class="bar" :x="d.x" :y="d.y" :width="d.width" :height="d.height" :fill="d.c"></rect>
                <rect
                    v-if="d.v === 0"
                    class="zero-value"
                    :x="d.x + 3"
                    :y="3"
                    :width="d.width - 6"
                    height="10"
                    rx="2"
                    ry="2" />
                <text
                    :x="d.x + boxWidth / 2.0"
                    :y="height + 14"
                    text-anchor="middle"
                    font-size="9"
                    class="rating-label">
                    {{ d.k.replace('Tier', '') }}
                </text>
            </g>

            <line class="basis" x1="0" :x2="width" :y1="height + 2" :y2="height + 2"></line>
        </svg>

        <b-tooltip :target="() => $refs.thechart" placement="left">
            <div v-for="d in layout" :key="d.k" style="text-align: left">
                <svg width="10" height="10" class="legend-swatch">
                    <rect width="10" height="10" :fill="d.c"></rect>
                </svg>
                <span class="inline-label">{{ d.k }}:</span>
                {{ d.v }}
            </div>
        </b-tooltip>
    </div>
</template>

<script>
import * as d3 from 'd3';

const source_levels = {
    // from https://civicdb.org/help/evidence/evidence-levels
    civic: [
        {level: 'A', c: '#5cb05e', range_key: '#007AFF'},
        {level: 'B', c: '#50aee3'},
        {level: 'C', c: '#646eaf'},
        {level: 'D', c: '#e89544'},
        {level: 'E', c: '#d1555c', range_key: '#cfcfcf'},
    ],
    // from https://oncokb.org/levels
    oncokb: [
        {level: '1', c: '#5cb05e', range_key: '#007AFF'}, // used to be #48873c, but livened it up a bit w/CIViC's level 'A'
        {level: '2A', c: '#30578c'},
        {level: '2B', c: '#7597b5'},
        {level: '3A', c: '#6e3a77'},
        {level: '3B', c: '#9e7da5'},
        {level: '4', c: '#444441', range_key: '#cfcfcf'},
        {level: 'R1', c: '#be382a', range_key: '#df8c7f'},
        {level: 'R2', c: '#d78579', range_key: '#88281e'},
    ],
    svip: [
        {level: 'Tier IA', c: '#5cb05e', range_key: '#007AFF'},
        {level: 'Tier IB', c: '#30578c', range_key: '#0d5832'},
        {level: 'Tier IIC', c: '#7597b5', range_key: '#cfcfcf'},
        {level: 'Tier IID', c: '#6e3a77', range_key: '#b0930b'},
        {level: 'Tier III', c: '#444441', range_key: '#df8c7f'},
        {level: 'Tier IV', c: '#7597b5', range_key: '#88281e'},
    ],
};

// constructs a linear color scale using any level with a 'range_key' value as an anchor in the interpolation
const color_scales = Object.entries(source_levels).reduce((acc, [name, levels]) => {
    const key_levels = levels.map((x, idx) => ({...x, idx})).filter(x => x.hasOwnProperty('range_key'));

    acc[name] = d3
        .scaleLinear()
        .domain(key_levels.map(x => x.idx))
        .range(key_levels.map(x => x.range_key));
    return acc;
}, {});

export default {
    data() {
        const boxWidth = 22;
        return {
            boxWidth,
            width: boxWidth * source_levels[this.sourceName].length,
            height: 15,
            padding: 1,
        };
    },
    props: ['scores', 'sourceName'],
    created: function () {
        this.x = d3.scaleLinear();
        return (this.y = d3.scaleLinear());
    },
    methods: {},
    mounted: function () {},
    watch: {
        sourceName: function (val) {
            // for some reason, data() isn't updated if we change the sort order, so 'width' ends up being out-of-date with
            // the row to which we're bound; we manually set it here to compensate.
            this.width = 25 * source_levels[val].length;
        },
    },
    computed: {
        aggregatedData() {
            const colorScale = color_scales[this.sourceName];

            // first, construct an object with all levels for the source, merging in the actual scores where available
            // return it in the {k, v, c} format that the viz code expects
            return source_levels[this.sourceName].map((x, idx) => ({
                k: x.level,
                v: this.scores[x.level] || 0,
                c: colorScale(idx),
            }));
        },
        layout: function () {
            this.x.domain([0, this.aggregatedData.length]).range([0, this.width]);
            this.y.domain([0, d3.max(this.aggregatedData, d => d.v)]).range([0, this.height]);

            // if either of the scales have 0-length domains, the value will always be the mean of the range
            // we need to bump the domain up a bit if its bounds are equal to provide resolution
            if (this.y.domain()[0] === this.y.domain()[1]) {
                this.y.domain([0, 1]);
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
                            height: _this.y(d.v),
                        };
                    };
                })(this)
            );
        },
    },
};
</script>

<style>
.inline-label {
    display: inline-block;
    text-align: right;
    font-weight: bold;
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
