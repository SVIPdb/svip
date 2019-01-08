/* eslint-disable */
<template>
	<div id="app">
		<vue-snotify></vue-snotify>
		<nav-header></nav-header>

		<!-- content -->
	  <router-view style="margin: 90px auto 200px auto"/>

	  <nav-footer></nav-footer>
	</div>
</template>


<script>

import navHeader from '@/components/navheader'
import navFooter from '@/components/navfooter'

export default {
  components: { navHeader, navFooter },
  name: 'App',
	computed:{
		year () {
			return new Date().getFullYear();
		}
	}
}
</script>


<style>

.pointer{
	cursor:pointer;
}
.ban{
	cursor:not-allowed;
}

.uppercase{
	text-transform:uppercase;
}

.has-error{
	color:#dc3545;
}
.has-error input{
	border:1px solid #dc3545 !important;
}
.has-error input:focus{
	border:1px solid #dc3545;
	box-shadow:0 0 0 0.15rem #F8E6E0 !important;
}
.has-error select{
	border:1px solid #dc3545 !important;
}
.has-error select:focus{
	border:1px solid #dc3545;
	box-shadow:0 0 0 0.15rem #F8E6E0 !important;
}



.has-error small{
	float:left;
	margin-top:5px;
	font-style:italic;
	font-size:11px;
}


</style>
