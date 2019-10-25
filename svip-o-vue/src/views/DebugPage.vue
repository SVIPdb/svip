<template>
    <div class="container">
        <div class="col-10 offset-1">
            <h1>Debug Page</h1>
            <p>Try out your in-development components or other functionality on this page.</p>

            <div class="page-section">
                <h4>Variant Search Bar</h4>
                <ul>
                    <li v-for="a in selected_variants">{{ a }}</li>
                </ul>
                <SearchBar multiple variants-only v-model="selected_variants" />
            </div>

            <div class="page-section">
                <h4>Drug Search Bar</h4>
                <ul>
                    <li v-for="a in selected_drugs">{{ a.medicine_name }}</li>
                </ul>
                <DrugSearchBar v-model="selected_drugs" />
            </div>
        </div>
    </div>
</template>

<script>
import SearchBar from "@/components/widgets/SearchBar";
import DrugSearchBar from "@/components/widgets/DrugSearchBar";

export default {
    name: "Debug",
    components: {SearchBar, DrugSearchBar},
    data() {
        return {
            selected_variants: [],
            selected_drugs: []
        }
    }
}
</script>

<style scoped>
.page-section {
    margin-bottom: 2em;
}
</style>
