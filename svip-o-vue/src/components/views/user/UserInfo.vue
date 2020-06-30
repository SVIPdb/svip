<template>
    <div class="trunk">
        <div v-if="user">
            <h3>Information for "{{ user.username }}"</h3>

            <div class="user-info">
                <dl>
                    <dt>Username</dt>
                    <dd>{{ user.username }}</dd>

                    <dt>User ID</dt>
                    <dd>{{ user.user_id }}</dd>

                    <dt>Groups</dt>
                    <dd>
                        <span v-for="(group, idx) in user.groups" :key="group"><span v-if="idx !== 0">, </span>{{ group }}</span>
                    </dd>

                    <dt>Login Expires In</dt>
                    <dd>{{ remaining(currentTime) }}</dd>
                </dl>
            </div>
        </div>

        <div v-else class="not-logged-in">
            You must be logged in to view your user information.
            <hr style="width: 75%"/>
            <router-link to="login">log in</router-link>
        </div>
    </div>
</template>

<script>
import { mapGetters } from "vuex";
import { millisecondsToStr } from "@/utils";
import store from '@/store';
import ulog from 'ulog';

const log = ulog('Store:UserInfo');

export default {
    name: "UserInfo",
    data() {
        return {
            currentTime: Date.now()
        };
    },
    computed: {
        ...mapGetters({
            user: "currentUser"
        })
    },
    methods: {
        remaining(curTime) {
            const diff = (store.getters.jwtExp * 1000) - curTime;
            return (diff >= 0) ? millisecondsToStr(diff) : "expired!";
        }
    },
    created() {
        store.dispatch("checkCredentials").then((result) => {
            log.trace("Logged in?: ", result);
        });

        setInterval(() => {
            this.currentTime = Date.now();
        }, 1000)
    }
}
</script>

<style scoped>
.trunk { width: 600px; }

.user-info {
    margin-top: 1em;
    border: solid 1px #ccc;
    border-radius: 5px;
    padding: 20px;
}

dl {
    display: flex;
    flex-wrap: wrap;
    margin: 0;
}

dt {
    width: 25%;
    text-align: right;
}

dt::after { content: ': '; }

dd {
    padding-left: 10px;
    width: 75%;
}

.not-logged-in {
    color: #777;
    font-size: 20px; text-align: center; font-style: oblique;
}
</style>
