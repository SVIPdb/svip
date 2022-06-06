<template>
    <div>
        <div class="form-container">
            <button
                class="button2"
                type="submit"
                name="if_pdf"
                value="pdf"
                role="button"
            >
                <a
                    class="link"
                    target="_blank"
                    :href="`http://localhost:8085/api/v1/variant_summary/${variant_id}?if_pdf=pdf`"
                    >Download as PDF</a
                >
            </button>
            <b-form-checkbox
                size="lg"
                class="ml-4"
                id="checkbox-1"
                v-model="owner"
                name="checkbox-1"
                value="own"
                unchecked-value="all"
            >
                Show my entries
            </b-form-checkbox>
        </div>
        <div v-html="owner === 'own' ? ownTemplate : template"></div>
    </div>
</template>
<script>
import { mapGetters } from "vuex";
import { HTTP } from "@/router/http";
export default {
    name: "SvipInfoSummary",
    data() {
        return {
            template: null,
            ownTemplate: null,
            variant_id: "",
            owner: "all",
            loaded: false,
            url: `/variant_summary/${this.$route.params.variant_id}`,
        };
    },
    computed: {
        ...mapGetters({
            user: "currentUser",
        }),
    },
    methods: {},
    mounted() {
        const regex = /id="djDebug"/;
        console.log(this);
        this.variant_id = this.$route.params.variant_id;
        HTTP.get(`/variant_summary/${this.$route.params.variant_id}`).then(
            (response) => {
                this.template = response.data.replace(
                    regex,
                    "style='display: none'"
                );
            }
        );
        HTTP.get(
            `/variant_summary/${this.$route.params.variant_id}?owner=own&user=${this.user.user_id}`
        ).then((response) => {
            console.log(response.data);
            this.ownTemplate = response.data.replace(
                regex,
                "style='display: none'"
            );
        });
    },
};
</script>
<style scoped>
.form-container {
    display: flex;
    width: 70%;
    flex-direction: row;
    margin: 50px 0;
}

button {
    margin-right: 10px;
    background-color: darkcyan;
    border: none;
    color: white;
    padding: 10px;
    text-align: center;
    text-decoration: none;
    display: inline-block;
    font-size: 16px;
    margin: 4px 2px;
    cursor: pointer;
    width: 150px;
}

.link {
    color: aliceblue;
    text-decoration: none;
}

.form-container {
    display: flex;
    width: 70%;
    flex-direction: row;
    margin: auto;
    align-items: center;
}
.bg-primary {
    background-color: rgb(45, 62, 79);
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
