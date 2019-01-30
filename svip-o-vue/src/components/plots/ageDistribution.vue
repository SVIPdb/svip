<template>
    <div>
        <svg ref="thechart" class="age-bar-chart">
            <rect
                class="bar"
                v-for="(d,i) in layout"
                :x="d.x"
                :y="d.y"
                :width="d.width"
                :height="d.height"
                :fill="d.c"
            >
            </rect>

            <line class="basis" x1="0" x2="100%" y1="27" y2="27"></line>
        </svg>

        <b-tooltip :target="() => $refs.thechart" placement="top">
            <div v-for="(d) in this.aggregatedData" style="text-align: left;">
                <svg width="10" height="10" class="legend-swatch"><rect width="10" height="10" :fill="d.c"></rect></svg>
                <span><b>{{d.k}}:</b> {{d.v}}</span>
            </div>
        </b-tooltip>
    </div>
</template>

<script>

import Vue from 'vue'
import * as d3 from 'd3'

export default {
    name: 'age_distribution',
    data() {
        return {
            width: 100,
            height: 25,
            color: '#C00',
            padding: 1
        }
    },
    props: ['data'],
    created: function () {
        this.x = d3.scaleLinear()
        return this.y = d3.scaleLinear()
    },
    methods: {},
    mounted: function () {

    },
    computed: {
        aggregatedData() {
            const data = [
                {k: '<40', v: this.data['<40'], c: '#0575E6'},
                {k: '41-60', v: this.data['41-60'], c: 'rgb(38,92,194)'},
                {k: '61-80', v: this.data['61-80'], c: 'rgb(25,62,158)'},
                {k: '>80', v: this.data['>80'], c: '#021b79'}
            ]
            return data
        },
        layout: function () {
            this.x.domain([0, this.aggregatedData.length]).range([0, this.width])
            this.y.domain([
                0, d3.max(this.aggregatedData, function (d) {
                    return d.v
                })
            ]).range([0, this.height])
            return this.aggregatedData.map((function (_this) {
                return function (d, i) {
                    return {
                        v: d.v,
                        k: d.k,
                        x: _this.x(i),
                        y: _this.y.range()[1] - _this.y(d.v),
                        c: d.c,
                        width: Math.max(1, _this.x(1) - _this.x(0) - _this.padding),
                        height: _this.y(d.v)
                    }
                }
            })(this))
        },
        tooltip() {
            let html = "<dl class = 'row' style='margin: 0'>"
            _.forEach(this.aggregatedData, d => {
                html += "<dt class='col-6'  style='text-align: right; padding-right: 2px;'>" + d.k + ":</dt><dd class='col-6' style='text-align: left; padding-left: 2px;'>" + d.v + '</dd>'
            })
            html += '</dl>'
            return html
        }
    }
}

</script>

<style>
.age-bar-chart {
    width: 100px;
    height: 28px;
}

.age-bar-chart line {
    shape-rendering: crispEdges;
    stroke: #aaa;
}

#tooltip {
    position: absolute;
    text-align: center;
    width: 120px;
    height: 28px;
    padding: 2px;
    font: 12px sans-serif;
    color: #FFF;
    background-color: #000;
    border: 0px;
    border-radius: 8px;
    pointer-events: none;
}
</style>
