<template>
	<!-- footer -->
	<footer class="footer">
		<div class="container-fluid">
			<div class="row" style="width: 100%;">
				<div class="col-md-3 col-sm-12 text-center version-info border-right">
						<div class="align-bottom">
							<a href="https://svip-dev.nexus.ethz.ch/api/v1/" target="_blank">SVIPdb</a> v{{appVersion}} ({{releaseName}})<br />
							Questions or Comments:<br />
							<a href="mailto:feedback@svip.ch">feedback@svip.ch</a>
						</div>
				</div>
				<div class="col-md-3 col-sm-12 text-center">
					<a href="https://www.ethz.ch" target="_blank">
						<img src="../assets/eth_logo_small.png" alt="ETH" class="footer_logo"/>
					</a>
				</div>
				<div class="col-md-3 col-sm-12 text-center">
					<a href="https://www.sib.swiss/" target="_blank">
						<img src="../assets/SIB_logo_20ans.png" alt="SIB Logo 20ans" class="footer_logo"/>
					</a>
				</div>
				<div class="col-md-3 col-sm-12 text-center">
					<a href="https://www.hes-so.ch/" target="_blank">
						<img src="../assets/logo-hes-so-noir-433.png" alt="HES-SO" class="footer_logo"/>
					</a>
				</div>
			</div>
		</div>
	</footer>
</template>

<script>
import {appVersion, releaseName} from "../app_config";

export default {
	name: "navHeader",
	data() {
		return {
			appVersion, releaseName
		}
	},
	computed: {
		year() {
			return new Date().getFullYear();
		}
	}
};
</script>

<style>
img.footer_logo {
	max-height: 100px;
	width: auto;
}

footer {
	position: absolute;
	width: 100%;
	bottom: 0;
	background-color: #f5f5f5;
}
</style>
