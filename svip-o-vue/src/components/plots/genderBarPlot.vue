<template>
    <div>
        <div v-if="totalPatients > 0">
            <svg ref="thechart" class="sig-bar-chart">
                <g v-for="d in layout" :key="d.k">
                    <rect
                        class="bar"
                        :x="d.x"
                        :y="d.y"
                        :width="d.width"
                        :height="d.height"
                        :fill="d.c"></rect>
                </g>
            </svg>

            <b-tooltip :target="() => $refs.thechart" placement="top">
                <div v-for="d in this.formattedData" :key="d.label" style="text-align: left">
                    <svg width="10" height="10" class="legend-swatch">
                        <rect width="10" height="10" :fill="d.color"></rect>
                    </svg>
                    <span>
                        <b class="gender-label">{{ d.label }}:</b>
                        {{ d.value.toLocaleString() }}
                        <span v-if="totalPatients > 0">
                            ({{ round((d.value / totalPatients) * 100.0) }}%)
                        </span>
                    </span>
                </div>
            </b-tooltip>
        </div>
        <span v-else class="unavailable">{{ $t("unavailable")}}</span>
    </div>
</template>

<script>
import * as d3 from 'd3';
import round from 'lodash/round';

const genderColors = {
    male: '#0F7FFE',
    female: '#CC66FE',
};

export default {
    data() {
        return {
            width: 45,
            height: 25,
            padding: 1,
        };
    },
    props: ['data'],
    created: function () {
        this.x = d3.scaleLinear();
    },
    methods: {
        round,
    },
    computed: {
        formattedData() {
            return Object.entries(this.data).map(([k, v]) => ({
                label: k,
                value: v,
                color: genderColors[k],
            }));
        },
        totalPatients() {
            return (this.data.male || 0) + (this.data.female || 0);
        },
        layout: function () {
            const total = d3.sum(this.formattedData, d => d.value);
            this.x.domain([0, 1.0]).range([0, this.width]);

            return this.formattedData.map((d, i) => {
                const prop = x => x / total;
                const xpos = i > 0 ? d3.sum(this.formattedData.slice(0, i), p => this.x(prop(p.value))) : 0;

                return {
                    v: d.value,
                    k: d.label,
                    x: xpos,
                    y: 0,
                    c: d.color,
                    width: this.x(prop(d.value)),
                    height: this.height,
                };
            });
        },
    },
};
</script>

<style scoped>
.sig-bar-chart {
    width: 45px;
    height: 28px;
}

.gender-label {
    display: inline-block;
    text-align: right;
    min-width: 7ex;
}
</style>
