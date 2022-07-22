<template>
    <div id="app">
        <vue-snotify></vue-snotify>
        <nav-header></nav-header>
        <vue-confirm-dialog></vue-confirm-dialog>

        <!-- content -->
        <router-view style="margin: 90px auto 200px auto" />
        
        <nav-footer v-if="!isHelp" ></nav-footer>
    </div>
</template>

<script>

import navHeader from "@/components/structure/navheader";
import navFooter from "@/components/structure/navfooter";
import "@/components/widgets/StyledLabels";
import ProgressManager from "@/support/progress";

export let np_manager = null;

export default {
    components: { navHeader, navFooter },
    name: "App",
    computed: {
        year() {
            return new Date().getFullYear();
        },
        isHelp() {
        return this.$route.name === 'help'
  }
    },
    mounted() {
        
        if (!np_manager) {
            np_manager = ProgressManager({ parent: ".ajax-loader-bar" });
        }
    },
    watch: {
        $route: {
            handler: (to) => {
                // page title logic:
                // if 'to' is not falsey, check if its 'title' attribute is a function; if it is, invoke it
                // if 'title' is not a function, but isn't falsey, just use the 'title' attribute as-is
                // if 'to' or to.title's resolved value is falsey, default to the string 'SVIP-O'
                if (!to || !to.meta || !to.meta.title) {
                    document.title = "SVIP-O";
                    return;
                }

                document.title =
                    (to.meta.title instanceof Function && to.meta.title(to)) ||
                    to.meta.title;
            },
            immediate: true,
        },
    },
};
</script>

<style>
.pointer {
    cursor: pointer;
}

.ban {
    cursor: not-allowed;
}

.uppercase {
    text-transform: uppercase;
}

.has-error {
    color: #dc3545;
}

.has-error input {
    border: 1px solid #dc3545 !important;
}

.has-error input:focus {
    border: 1px solid #dc3545;
    box-shadow: 0 0 0 0.15rem #f8e6e0 !important;
}

.has-error small {
    float: left;
    margin-top: 5px;
    font-style: italic;
    font-size: 11px;
}

.has-error small {
    float: left;
    margin-top: 5px;
    font-style: italic;
    font-size: 11px;
}
</style>
