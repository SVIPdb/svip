<template>
    <div class="comment-harness">
        <div class="comments">
            <div v-if="!isLoading && comments && comments.length > 0">
                <div class="comment" v-for="comment in comments" :key="comment.id">
                    <div class="body">
                        <pass :bits="abbreviatedName(comment.owner_name)">
                            <b slot-scope="{ bits }" v-b-tooltip.hover="bits.name">{{ bits.abbrev }}: </b>
                        </pass>
                        {{ comment.text }}
                    </div>
                    <div class="metaframe">
                        <div v-if="comment.tags">
                            <b-badge small :style="`background-color: ${colorizeTag(c)};`" v-for="c in comment.tags" :key="c">{{ c }}</b-badge>
                        </div>
                        <div class="datetime">
                            {{ formatCommentDatetime(comment.created_on) }}
                        </div>
                    </div>
                    <button v-if="ownsComment(comment.owner_name)" class="delete" @click="removeComment(comment.id)" aria-label="Remove comment">
                        <icon name="times" />
                    </button>

                    <hr />
                </div>
            </div>
            <div v-else-if="error" class="text-center text-muted font-italic">
                <icon name="exclamation-triangle" scale="3" style="vertical-align: text-bottom; margin-bottom: 5px;" />
                <div>{{ $t("We couldn't load the comments due to a technical issue")}}</div>
            </div>
            <div v-else-if="comments.length === 0">
                <h5 class="text-center font-italic" style="color: #777;">{{ $t("~ no comments yet ~")}}</h5>
            </div>
            <div v-else style="margin: 0 auto; text-align: center;">
                <b-spinner />
            </div>
        </div>

        <div class="comment-box">
            <v-select v-model="comment_tags" style="width: 100%;" :options="tagtypes" placeholder="select or enter new tags" multiple taggable push-tags>
                <template v-slot:option="option">
                    <div class="option-w-color">
                        <!--
                        <div class="color-block" :style="`background-color: ${colorizeTag(option.label)};`">&nbsp;</div>
                        <div>{{ option.label }}</div>
                        -->
                        <b-badge small :style="`background-color: ${colorizeTag(option.label)};`">{{ option.label }}</b-badge>
                    </div>
                </template>

                <template v-slot:selected-option-container="{ option, disabled, multiple, deselect }">
                    <b-badge :style="`background-color: ${colorizeTag(option.label)};`" :disabled="disabled">
                        {{ option.label }}
                        <button v-if="multiple" :disabled="disabled" @click="deselect(option)" type="button" class="close" aria-label="Remove option">
                            <span style="margin-left: 3px;" aria-hidden="true">&times;</span>
                        </button>
                    </b-badge>
                </template>
            </v-select>

            <b-textarea ref="commentbox" v-model="comment_text" style="width: 100%; margin: 0.5em 0;" />
            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 0.5em;">
                <span class="text-muted">{{ $t("commenting as")}} <b>{{ username }}</b></span>
                <b-button variant="info" size="sm" @click="addComment" :disabled="!comment_text">{{ $t("Add Comment")}}</b-button>
            </div>
        </div>
    </div>
</template>

<script>
import { HTTP } from '@/router/http';
import { mapGetters } from "vuex";
import { abbreviatedName, colorizeTag } from "@/utils";
import dayjs from "dayjs";
import ulog from 'ulog';

const log = ulog('CommentList');

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
            tagtypes: [],

            // new comment fields
            comment_text: '',
            comment_tags: [],
            console
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
            HTTP.get('/comments/tagtypes').then((response) => {
                this.tagtypes = response.data;
            });
        },
        refresh() {
            this.isLoading = true;
            this.loadTags();

            HTTP.get(`/comments?variant=${this.variant_id}&page_size=9999`)
                .then((response) => {
                    this.isLoading = false;
                    this.comments = response.data.results;
                }).catch((response) => {
                    this.isLoading = false;
                    if (response.data && response.data.detail) {
                        this.error = response.data.detail;
                    }
                });
        },
        createTag(value) {
            log.debug("Creating tag: ", value);
        },
        addComment() {
            HTTP.post(`/comments`, {
                variant: this.variant_id,
                text: this.comment_text,
                tags: this.comment_tags
            }).then((response) => {
                this.comment_text = '';
                this.comment_tags = [];
                this.$emit("commented", response);
                this.refresh();
            }).catch((response) => {
                this.isLoading = false;

                if (response.data && response.data.detail) {
                    this.$snotify.error(response.data.detail);
                }
                else {
                    this.$snotify.error("An error occurred while posting your comment");
                }
            });
        },
        removeComment(id) {
            if (confirm('Are you sure you wish to delete this comment?')) {
                HTTP.delete(`/comments/${id}`).then(() => {
                    this.refresh();
                }).catch((response) => {
                    this.isLoading = false;

                    if (response.data && response.data.detail) {
                        this.$snotify.error(response.data.detail);
                    }
                    else {
                        this.$snotify.error(`An error occurred while deleting comment ${id}`);
                    }
                })
            }
        },
        formatCommentDatetime(x) {
            return dayjs(x).format("h:mm a, DD.MM.YYYY")
        },
        ownsComment(commenter_name) {
            return this.username && commenter_name === this.username
        },
        colorizeTag,
        abbreviatedName
    }
}
</script>

<style scoped>
.comment-harness {
    position: absolute;
    left: 0; top: 77px; right: 0; bottom: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
}

.comments {
    flex: 1 0;
    padding: 20px;
    overflow-y: auto;
    background: linear-gradient(to top, rgba(128, 128, 128, 0.25) 0%, rgba(0,0,0,0) 20px);
}

.comment { position: relative; }
.comment .delete {
    position: absolute; right: 0; top: 0; padding: 0;
    display: flex; justify-content: center; align-items: center;
    width: 20px; height: 20px; text-align: center; vertical-align: center;
    border-radius: 5px; background-color: #bababa; color: black;
}
.comment .body {
    width: 90%; text-align: justify;
    margin-bottom: 2px;
}
.comment .metaframe {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
}
.comment .datetime {
    text-align: right;
    color: #777;
    font-size: smaller;
    white-space: nowrap;
}

.comment-box {
    border-top: solid 1px #ccc;
    padding: 20px;
    flex: 0 1;
}
.comment-box .badge {
    display: flex; align-items: center;
    justify-content: space-between;
    margin: 3px; padding: 0 6px;
}

.option-w-color {
    display: flex;
    align-items: center;
}
.option-w-color .color-block {
    width: 1em; height: 1em; border-radius: 5px;
    margin-right: 5px;
}
</style>
