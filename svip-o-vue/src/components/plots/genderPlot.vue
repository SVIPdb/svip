<template>
    <div>
        <svg ref="thechart" class="sig-bar-chart">
            <rect class="bar" v-for="(d, i) in layout" :key="i" :x="d.x" :y="d.y" :width="d.width" :height="d.height"
                :fill="d.c"></rect>

            <line class="basis" x1="0" x2="100%" y1="27" y2="27"></line>
        </svg>

        <b-tooltip :target="() => $refs.thechart" placement="top">
            <div v-for="d in this.formattedData" :key="d.k" style="text-align: left;">
                <svg width="10" height="10" class="legend-swatch">
                    <rect width="10" height="10" :fill="d.c"></rect>
                </svg>
                <span>
                    <b class="gender-label">{{ d.k }}:</b> {{ d.v.toLocaleString() }}
                    <span v-if="totalPatients > 0">({{ round(d.v/totalPatients * 100.0) }}%)</span>
                </span>
            </div>
        </b-tooltip>
    </div>
</template>

<script>
import * as d3 from "d3";
import round from 'lodash/round';

const genderColors = {
    'male': '#0F7FFE',
    'female': '#CC66FE'
};

export default {
    data() {
        return {
            width: 45,
            height: 25,
            padding: 1
        };
    },
    props: ["data"],
    created: function () {
        this.x = d3.scaleLinear();
        this.y = d3.scaleLinear();
    },
    methods: {
        round
    },
    computed: {
        formattedData() {
            return Object
                .entries(this.data)
                .map(([k, v]) => ({k, v, c: genderColors[k]}));
        },
        totalPatients() {
            return this.data.male + this.data.female;
        },
        layout: function () {
            this.x
                .domain([0, this.formattedData.length])
                .range([0, this.width]);

            this.y
                .domain([0, d3.max(this.formattedData, d => d.v)])
                .range([0, this.height]);

            return this.formattedData.map(
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

<style scoped>
.sig-bar-chart {
    width: 45px;
    height: 28px;
}

.sig-bar-chart line {
    shape-rendering: crispEdges;
    stroke: #aaa;
}

.gender-label {
    display: inline-block;
    text-align: right;
    min-width: 7ex;
}
</style>
