<template>
    <div>
        <hr />

        <div v-if="!isLoading && comments">
            <div v-for="comment in comments">
                <b>{{comment.owner_name}}:</b> {{ comment.text }}
                <hr />
            </div>
        </div>
        <b-spinner v-else />

        <div style="position: absolute; left: 0; right: 0; bottom: 0; padding: 20px;">
            <b-textarea ref="commentbox" v-model="comment_text" style="width: 100%;" />
            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 0.5em;">
                <span class="text-muted">commenting as <b>{{ username }}</b></span>
                <b-button variant="info" size="sm" @click="addComment">Add Comment</b-button>
            </div>
        </div>
    </div>
</template>

<script>
import {HTTP} from '@/router/http';
import {mapGetters} from "vuex";

export default {
    name: "CommentList",
    props: {
        variant_id: { type: Number, required: true }
    },
    data() {
        return {
            isLoading: true,
            comments: [],
            comment_text: ''
        }
    },
    created() {
        this.refresh()
    },
    mounted() {
        // focus the editbox, too?
        this.$refs.commentbox.focus();
    },
    computed: {
        ...mapGetters({
            username: "username"
        }),
    },
    methods: {
        refresh() {
            this.isLoading = true;
            HTTP.get(`/comments?variant=${this.variant_id}`)
                .then((response) => {
                    this.isLoading = false;
                    this.comments = response.data.results;
                });
        },
        addComment() {
            HTTP.post(`/comments`, {
                variant: this.variant_id,
                text: this.comment_text
            }).then((response) => {
                this.refresh();
            });
        }
    }
}
</script>

<style scoped>

</style>
