<template>
    <div>
        <svg ref="thechart" class="sig-bar-chart" viewBox="0 0 300 25" preserveAspectRatio="none">
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

                <ul class="subsigs" v-if="d.subsigs">
                    <li v-for="s in d.subsigs" :key="s.name">{{ s.count }} {{s.name}}</li>
                </ul>
            </div>
        </b-tooltip>
    </div>
</template>

<script>
import * as d3 from "d3";
import {titleCase} from "@/utils";
import * as _ from "lodash";

const evidence_types = [
    "Predictive",
    "Diagnostic",
    "Prognostic",
    "Predisposing",
    "Functional"
];

const colorMap = d3
    .scaleOrdinal(d3.schemeSet3)
    .domain(evidence_types);

export default {
    data() {
        return {
            width: 300,
            height: 25,
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
            /*
            const fakeData = [
                { name: "Predictive", count: Math.round(Math.random()*20) },
                { name: "Diagnostic", count: Math.round(Math.random()*20) },
                { name: "Prognostic", count: Math.round(Math.random()*20) },
                {
                    name: "Predisposing", count: Math.round(Math.random()*20),
                    subsigs: [
                        { name: "Likely Pathogenic", count: Math.round(Math.random()*20) },
                        { name: "Oncogenic, Gain-of-function", count: Math.round(Math.random()*20) },
                        { name: "Oncogenic, Inconclusive", count: Math.round(Math.random()*20) },
                        { name: "Oncogenic, Likely Gain-of-function", count: Math.round(Math.random()*20) },
                        { name: "Oncogenic, Loss-of-function", count: Math.round(Math.random()*20) },
                        { name: "Positive", count: Math.round(Math.random()*20) }

                    ]
                },
                {
                    name: "Functional", count: Math.round(Math.random()*20),
                    subsigs: [
                        { name: "Gain of Function", count: Math.round(Math.random()*20) },
                        { name: "Loss of Function", count: Math.round(Math.random()*20) },
                        { name: "Neomorphic", count: Math.round(Math.random()*20) }
                    ]
                },
            ];
             */

            return _.sortBy(this.data, x => evidence_types.indexOf(x.name)).map((d) => {
                return {
                    name: d.name,
                    count: d.count,
                    subsigs: d.subsigs,
                    color: colorMap(d.name)
                };
            });
        },
        layout: function () {
            const total = d3.sum(this.formattedData, d => d.count);
            this.x.domain([0, 1.0]).range([0, this.width]);

            return this.formattedData.map((d, i) => {
                const prop = x => x / total;
                const xpos = i > 0 ? d3.sum(this.formattedData.slice(0, i), p => this.x(prop(p.count))) : 0;

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

<style scoped>
.sig-bar-chart {
    width: 100%;
    max-width: 300px;
    height: 25px;
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
