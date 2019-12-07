<template>
    <div class="sidebar">
        <div class="sidebar-backdrop" @click="closeSidebarPanel" v-if="isPanelOpen"></div>
        <transition name="slide">
            <div v-if="isPanelOpen" class="sidebar-panel">
                <slot></slot>
            </div>
        </transition>
    </div>
</template>
<script>
import store from '@/store';

export default {
    name: "Sidebar",
    methods: {
        closeSidebarPanel() {
            store.commit("TOGGLE_NAV");
        }
    },
    computed: {
        isPanelOpen() {
            return store.state.site.isNavOpen;
        }
    }
};
</script>
<style>
.slide-enter-active,
.slide-leave-active {
    transition: transform 0.3s ease;
}

.slide-enter,
.slide-leave-to {
    transform: translateX(100%);
    transition: all 100ms ease-in 0s;
}

.sidebar-backdrop {
    background-color: rgba(19, 15, 64, 0.2);
    width: 100vw;
    height: 100vh;
    position: fixed;
    top: 0;
    right: 0;
    cursor: pointer;
    transition: background-color;
}

.sidebar-panel {
    overflow-y: auto;
    background-color: white;
    position: fixed;
    right: 0;
    top: 0;
    bottom: 0;
    height: 100vh;
    z-index: 999;
    padding: 6.3rem 20px 2rem 20px;
    width: 400px;
    border-left: solid 1px #ccc;
}
</style>
