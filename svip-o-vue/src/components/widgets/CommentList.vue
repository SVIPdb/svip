<template>
    <div>
        <div v-if="!isLoading && comments">
            <div v-for="comment in comments" :key="comment.id">
                <b>{{comment.owner_name}}:</b> {{ comment.text }}
                <hr />
            </div>
        </div>
        <div v-else-if="error" class="text-center text-muted font-italic">
            <icon name="exclamation-triangle" scale="3" style="vertical-align: text-bottom; margin-bottom: 5px;" />
            <div>We couldn't load the comments due to a technical issue</div>
        </div>
        <b-spinner v-else />

        <div class="comment-box">
            <b-textarea ref="commentbox" v-model="comment_text" style="width: 100%; margin-bottom: 1em;" />
            <v-select style="width: 100%;" :options="tagtypes" multiple taggable push-tags />
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
            error: null,
            comments: [],
            comment_text: '',
            tagtypes: []
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
        loadTags() {
            HTTP.get('/tagtypes').then((response) => {
                this.tagtypes = response.data.results;
            });
        },
        refresh() {
            this.isLoading = true;
            HTTP.get(`/comments?variant=${this.variant_id}`)
                .then((response) => {
                    this.isLoading = false;
                    this.comments = response.data.results;
                }).error((response) => {
                    this.isLoading = false;
                    if (response.data && response.data.detail) {
                        this.error = response.data.detail;
                    }
                });
        },
        createTag(value) {
            console.log("Creating tag: ", value);
        },
        addComment() {
            HTTP.post(`/comments`, {
                variant: this.variant_id,
                text: this.comment_text
            }).then((response) => {
                this.comment_text = '';
                this.refresh();
            }).error((response) => {
                this.isLoading = false;

                if (response.data && response.data.detail) {
                    this.$snotify.error(response.data.detail);
                }
                else {
                    this.$snotify.error("An error occurred while posting your comment");
                }
            });
        }
    }
}
</script>

<style scoped>
.comment-box {
    position: absolute;
    left: 0; right: 0; bottom: 0;
    padding: 20px;
}
</style>
