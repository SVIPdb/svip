<template>
<svg class="bar-chart">
	<rect
    class="bar"
    v-for="(d,i) in layout"
    :x="d.x"
    :y="d.y"
    :width="d.width"
    :height="d.height"
    :fill="d.c"
	@mouseover='mouseover(d)'
	@mouseout='mouseout(d)'
  >
</rect>
</svg>
</template>

<script>

import Vue from 'vue'
import * as d3 from "d3";

export default{
	data () {
		return {
			width: 100,
        	height: 25,
			color: '#C00',
			padding: 1
		}
	},
	props: ['data'],
    created: function() {
      this.x = d3.scaleLinear();
      return this.y = d3.scaleLinear();
    },
	methods: {
		mouseover (d) {
			let div = d3.select('#tooltip');
			if (div.empty()){
				 div = d3.select("body").append("div")	
			    .attr("id","tooltip")				
			    .style("opacity", 0);
			}
			div.transition()		
                .duration(200)		
                .style("opacity", .9);		
            div	.html("<b>score "+d.k+":</b> "+d.v)	
                .style("left", (event.clientX) + "px")		
                .style("top", (event.clientY - 28) + "px");				
		},
		mouseout () {
			let div = d3.select('#tooltip');
			if (div.empty()){
				 div = d3.select("body").append("div")	
			    .attr("id","tooltip")				
			    .style("opacity", 0);
			}
			div.transition()		
                .duration(200)		
                .style("opacity", 0);		
			
		}
	},
    mounted: function() {

    },
    computed: {
		aggregatedData () {
			let temp = _.reduce(this.data, function(result, value, key) {
				(result[value] || (result[value] = [])).push(key);
				return result;
			}, {});
			let data = {
				1: {k:1, v:0,c: '#AAFFA9'},
				2: {k:2, v:0, c: 'rgb(166,252,182)'},
				3: {k:3, v:0, c: 'rgb(137,252,189)'},
				4: {k:4, v:0, c: '#11FFBD'},
			};
			_.forEach(temp,(v,i) => {
				if (data[i] !== undefined) data[i].v = v.length
			})
			return Object.values(data);
		},
      layout: function() {
        this.x.domain([0, this.aggregatedData.length]).range([0, this.width]);
        this.y.domain([
          0, d3.max(this.aggregatedData, function(d) {
            return d.v;
          })
        ]).range([0, this.height]);
        return this.aggregatedData.map((function(_this) {
          return function(d, i) {
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
        })(this));
      }
    }
}

</script>

<style>
.bar-chart{
	width: 100px;
	height: 25px;
}
#tooltip {	
    position: absolute;			
    text-align: center;			
    width: 120px;					
    height: 28px;					
    padding: 2px;				
    font: 12px sans-serif;		
    background: lightsteelblue;	
    border: 0px;		
    border-radius: 8px;			
    pointer-events: none;			
}
</style>