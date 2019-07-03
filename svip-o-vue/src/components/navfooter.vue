<template>
	<!-- footer -->
	<footer class="footer">
		<div class="container-fluid">
			<div class="row" style="width: 100%;">
				<div class="col-lg-3 col-sm-12 text-center version-info">
						<div class="align-bottom">
							<a :href="serverURL" target="_blank">SVIPdb</a> v{{appVersion}} ({{releaseName}})

							<div class="feedback">
								Questions or Comments:<br />
								<a href="mailto:feedback@svip.ch">feedback@svip.ch</a>
							</div>
						</div>
				</div>

				<div class="col-lg-9 col-sm-12">
					<div class="container-fluid attributions">
						<div class="row align-items-center">
							<div class="col-lg-4 col-sm-12 text-center">
								<a href="https://www.ethz.ch" target="_blank">
									<img src="../assets/logos/eth_logo_small.png" alt="ETH" class="footer_logo"/>
								</a>
							</div>
							<div class="col-lg-4 col-sm-12 text-center">
								<a href="https://www.sib.swiss/" target="_blank">
									<img src="../assets/logos/sib_logo_medium_titled.png" alt="SIB" class="footer_logo"/>
								</a>
							</div>
							<div class="col-lg-4 col-sm-12 text-center">
								<a href="https://www.hes-so.ch/" target="_blank">
									<img src="../assets/logos/logo-hes-so-noir-433.png" alt="HES-SO" class="footer_logo"/>
								</a>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</footer>
</template>

<script>
import {serverURL, appVersion, releaseName} from "../app_config";

export default {
	name: "navFooter",
	data() {
		return {
			serverURL, appVersion, releaseName
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
