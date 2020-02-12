<template>
    <b-card no-body>
        <b-card-body>
            <b-container
                fluid
                class="evidence"
                v-if="variomes && pubData && !variomes.error"
                style="max-height:20rem;overflow-y:scroll;"
                @mouseup="citable && getSelectionText()"
                @contextmenu="citable && handleRightClick($event)"
            >
                <h5 class="font-weight-bolder" v-html="pubData.title_highlight" />
                <div>{{pubData.date}}</div>
                <p>
                    <b-link v-bind="pubmedURL(`?term=${author}[Author]`)" v-for="(author, index) in pubData.authors" :key="index">
                        {{author + (index < pubData.authors.length-1 ? ', ' : '')}}
                    </b-link>
                </p>
                <b>Abstract</b>
                <p class="text-justify" v-html="pubData.abstract_highlight" />
                <small>
                    PMID:
                    <b-link v-bind="pubmedURL(pubData.id)">{{pubData.id}}</b-link>
                </small>
            </b-container>
            <div
                v-else-if="variomes && (variomes.error || !pubData)"
                class="text-center text-muted font-italic"
            >
                <icon name="exclamation-triangle" scale="3" style="vertical-align: text-bottom; margin-bottom: 5px;" /><br />
                We couldn't load the abstract due to a technical issue
            </div>
            <div v-else class="text-center">
                <b-spinner label="Spinning" variant="primary" /> Loading
            </div>
        </b-card-body>
    </b-card>
</template>

<script>
import {pubmedURL} from "@/utils";

export default {
    name: "VariomesAbstract",
    props: {
        variomes: { required: true },
        citable: { type: Boolean, default: false }
    },
    data() {
        return {
            selection: null
        }
    },
    computed: {
        pubData() {
            return (this.variomes && this.variomes.publications && this.variomes.publications.length > 0 )
                ? this.variomes.publications[0]
                : null;
        }
    },
    methods: {
        pubmedURL,
        getSelectionText() {
            if (window.getSelection) {
                this.selection = window.getSelection().toString();
            } else {
                this.selection = "";
            }
        },
        handleRightClick(event) {
            event.stopPropagation();
            event.preventDefault();
            this.$emit('showmenu', { event, selection: this.selection });
        }
    }
}
</script>

<style scoped>

</style>
