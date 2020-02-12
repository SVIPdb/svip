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
import navHeader from "@/components/structure/navheader";
import navFooter from "@/components/structure/navfooter";
import '@/components/widgets/StyledLabels'; // adds components 'optional', 'coordinates'

export default {
    components: {navHeader, navFooter},
    name: "App",
    computed: {
        year() {
            return new Date().getFullYear();
        }
    },
    watch: {
        '$route': {
            handler: (to, from) => {
                document.title = (to.meta.title instanceof Function && to.meta.title(to)) || to.meta.title || 'SVIP-O'
            },
            immediate: true
        }
    }
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
