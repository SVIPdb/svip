<template>
    <div>
        <div class="form-container">
            <b-button variant="info" 
            target="_blank" 
            @click="downloadSummaryAsPdf">
                Download as PDF
            </b-button>
            <b-form-checkbox
                size="lg"
                class="ml-4"
                v-model="show_only_my_entries"
                @change="updateSummary"
            >
                Show only my entries
            </b-form-checkbox>
        </div>


        <div class="mycontainer">
            <div class="border1">
        <object :data="summaryBlob" type="text/html"></object>
        </div>
        </div>
    </div>
</template>
<script>
import { mapGetters } from "vuex";
import { HTTP } from "@/router/http";
export default {
    name: "SvipInfoSummary",
    data() {
        return {
            summaryBlob: null,
            variant_id: null,
            show_only_my_entries: false,
            loaded: false,
        };
    },
    computed: {
        ...mapGetters({
            user: "currentUser",
        }),
    },
    methods: {
        async getSummaryAsBlob(format='html') {
            try {
                const response = await HTTP.get(`/variant_summary/${this.variant_id}`, {
                    params: {
                        // change this to format
                        format: format,
                        onlyOwned: this.show_only_my_entries,
                        user: this.user.user_id
                    },
                    headers: { 
                        'Content-Type': format === 'pdf' ? 'application/pdf' : 'text/html' 
                    },
                    responseType: 'blob',
                })
                const contentType = await response.headers['content-type']
                const data = await response.data
                return window.URL.createObjectURL(new Blob([data], { type: contentType }))
        
                 
            } catch(err) {
                console.error(err)
            }
        },  async updateSummary() {
            this.summaryBlob = await this.getSummaryAsBlob('html')
        },

          async downloadSummaryAsPdf() {
            const pdf = await this.getSummaryAsBlob('pdf')
            const anchor = document.createElement('a');
            anchor.href = pdf
            anchor.target = '_blank'
            anchor.click();
        }
    },
    async mounted() {
        this.variant_id = this.$route.params.variant_id
        this.summaryBlob = await this.getSummaryAsBlob()
    }
  
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

.form-container {
    display: flex;
    width: 70%;
    flex-direction: row;
    margin: auto;
    align-items: center;
}
.mycontainer {
    margin: 60px auto; 
    width: 80%;
    height: auto;
}

.border1 {
    border: 1px gray dotted;
    padding: 20px;
    display: flex;
    height: auto;
}
.mycontainer object {
    margin: 0px auto; 
    border: 1px gray dotted;
    width: 100%;
    height: max-content;
    min-height: 800px;
}



</style>
