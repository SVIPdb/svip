<template>
    <div class="mycontainer">
        <b-container v-if="!loaded" fluid class="container">
            <b-spinner type="grow" />
            <b-spinner type="grow" />
            <b-spinner type="grow" />
        </b-container>
        <object
            type="text/html"
            :data="documentation_url"
            @load="loaded = true"
            @progress="loaded = false"
        />
    </div>
</template>

<script>
// import TableOfContents from "@/components/help/TableOfContents";
// import { slugifySans } from "@/utils";

// const help_sections = [
//     {
//         name: 'Variant Information',
//         content: require('@/components/help/json/variant_info')
//     },
//     {
//         name: 'SVIP: Overview',
//         content: require('@/components/help/json/svip_info')
//     },
//     {
//         name: 'SVIP: Samples',
//         content: require('@/components/help/json/svip_samples')
//     },
//     {
//         name: 'SVIP: Curation',
//         content: require('@/components/help/json/svip_curation')
//     },
//     {
//         name: 'Public Databases',
//         content: require('@/components/help/json/public_info')
//     },
// ];

export default {
    name: "Help",
    // components: {TableOfContents},
    data() {
        return {
            loaded: false,
            documentation_url: `${process.env.VUE_APP_DOCUMENTATION_URL}`,
        };
    },
    // methods: {
    //     slugifySans,
    //     formatNewlines(text) {
    //         return text.split("\n").join("<br />");
    //     }
    // }
};
</script>

<style scoped>
.container {
    text-align: center;
    margin: 20px;
}
.section {
    margin-bottom: 3em;
}

.section .sec-header {
    position: relative;
    margin-top: -90px;
    padding-top: 90px;
}

.terms {
    margin-left: 20px;
}

.terms .entry {
    margin-bottom: 1em;
}

.terms .term {
    font-weight: bold;
    font-size: larger;
}

.terms .definition {
    margin-left: 10px;
}

.terms .missing-desc {
    font-style: italic;
    color: #777;
}

.terms .example {
    margin-top: 0.5em;
}

.terms .example .example-text {
    font-style: oblique;
    margin-left: 3px;
}

.terms .definition .references {
    margin-top: 0.5em;
}

.mycontainer {
    position: absolute;
    top: -12px;
    /* margin: 90px 0px 0px 0px; */
    padding: 0px;
    width: 100%;
    height: calc(100%);
}
.mycontainer object {
    width: 100%;
    height: calc(100% - 218px);
}
</style>
