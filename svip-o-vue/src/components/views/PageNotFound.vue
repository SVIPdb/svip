<template>
    <!-- FIXME: replace this with a redirect to a real 404 page (i.e., one handled by nginx that returns a 404, not a 200) -->
    <div class="not-found">
        <h1>404</h1>

        <p>The page you requested wasn't found.</p>

        <router-link to="/">Return to SVIP-O homepage</router-link>
    </div>
</template>

<script>
export default {
    name: 'PageNotFound',
};
</script>

<style scoped>
.not-found {
    padding-top: 3em;
    text-align: center;
    font-style: italic;
    color: #777;
    font-size: large;
}

.not-found h1 {
    color: black;
    font-size: 72px;
}
</style>
