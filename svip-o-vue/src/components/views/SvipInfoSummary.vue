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
                @click=""
            >
                Show only my entries
            </b-form-checkbox>
        </div>
        <div class="mycontainer">
        <object :data="summaryBlob" class="summaryContent" type="text/html"></object>
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
            console.log('function getSummaryAsBlob')
            try {
                const response = await HTTP.get(`/variant_summary/${this.variant_id}`, {
                    params: {
                        // change this to format
                        format,
                        onlyOwned: this.show_only_my_entries 
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
        console.log('mounted')
        this.variant_id = this.$route.params.variant_id
        this.summaryBlob = await this.getSummaryAsBlob()
        console.log(this.summaryBlob)
       
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
   
    /* margin: 90px 0px 0px 0px; */
    padding: 0px;
    width: 100%;
    height: calc(100%);
}
.mycontainer object {
    width: 100%;
    height: calc(100% - 218px);
}

.summaryConntent {
    width: 100%;
}
</style>
