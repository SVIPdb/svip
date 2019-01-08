/* eslint-disable */
<template>
	<!-- footer -->
	<b-navbar type="light" variant="light" toggleable="md" :sticky='true'>
	<div class = 'container-fluid'>
		<div class = 'row' style = 'width: 100%'>
			<div class = 'col-4 text-center'><img src="../assets/SIB_logo_20ans.png" alt="SIB Logo 20ans" class = 'footer_logo'></div>
			<div class = 'col-4 text-center'><img src="../assets/eth_logo.png" alt="ETH"  class = 'footer_logo'></div>
			<div class = 'col-4 text-center'><img src="../assets/logo-hes-so-noir-433.png" alt="HES-SO"  class = 'footer_logo'></div>
		</div>
	</div>
	</b-navbar>	
</template>

<script>

import Vue from 'vue'

export default {
name: 'navHeader',
computed:{
year () {
	return new Date().getFullYear();
}
}
	
}

</script>


<style>
img.footer_logo{
	max-height: 100px;
	width: auto;
}
</style>
/* eslint-disable */