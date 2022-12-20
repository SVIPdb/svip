<template>
    <!-- footer -->
    <footer class="footer">
        <div class="container-fluid">
            <div class="row" style="width: 100%">
                <div class="col-lg-3 col-sm-12 text-center version-info">
                    <div class="align-bottom">
                        <a :href="serverURL" target="_blank">{{ $t("SVIPdb")}}</a>
                        {{ appVersion }} ({{ releaseName }})
                        <div class="feedback">
                            <anchor-router-link
                                :to="{name: 'about', hash: '#disclaimer'}"
                                :scrollOptions="{
                                    container: 'body',
                                    duration: 700,
                                    easing: 'ease',
                                }">
                                {{ $t("Disclaimer &amp; License")}}
                            </anchor-router-link>
                        </div>
                        <div class="feedback">
                            {{ $t("Questions or Comments:")}}
                            <br />
                            <a href="mailto:feedback@svip.ch">{{ $t("feedback@svip.ch")}}</a>
                        </div>
                    </div>
                </div>

                <div class="col-lg-9 col-sm-12" v-if="windowWidth > 1000">
                    <div class="container-fluid attributions">
                        <div class="row align-items-center">
                            <div class="col-lg-4 col-sm-12 text-center">
                                <a href="https://www.ethz.ch" target="_blank">
                                    <img
                                        src="../../assets/logos/eth_logo_small.png"
                                        alt="ETH"
                                        class="footer_logo" />
                                </a>
                            </div>
                            <div class="col-lg-4 col-sm-12 text-center">
                                <a href="https://www.sib.swiss/" target="_blank">
                                    <img
                                        src="../../assets/logos/sib_logo_medium_titled.png"
                                        alt="SIB"
                                        class="footer_logo" />
                                </a>
                            </div>
                            <div class="col-lg-4 col-sm-12 text-center">
                                <a href="https://www.hes-so.ch/" target="_blank">
                                    <img
                                        src="../../assets/logos/logo-hes-so-noir-433.png"
                                        alt="HES-SO"
                                        class="footer_logo" />
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
import {appVersion, releaseName, serverURL} from '../../app_config';
import AnchorRouterLink from 'vue-anchor-router-link';

export default {
    name: 'navFooter',
    components: {
        AnchorRouterLink,
    },
    data() {
        return {
            serverURL,
            appVersion,
            releaseName,
            windowWidth: window.innerWidth,
        };
    },

    computed: {
        year() {
            return new Date().getFullYear();
        },
    },
    mounted() {
        this.$nextTick(() => {
            window.addEventListener('resize', this.onResize);
        });
    },

    methods: {
        onResize() {
            this.windowWidth = window.innerWidth;
        },
    },
    beforeDestroy() {
        window.removeEventListener('resize', this.onResize);
    },
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
