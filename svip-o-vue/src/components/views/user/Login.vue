<template>
    <div class="trunk">
        <h1>Log In to SVIP</h1>
        <p>Enter your credentials below to log in to your SVIP account.</p>
        <div class="text-muted font-italic" style="text-align: center;">
            If you don't have credentials, or the appropriate credentials<br />
            for the resource you're trying to access, you can always go home:
            <div style="margin-top: 0.5em;"><router-link to="/">SVIP homepage</router-link></div>
        </div>

        <transition name="fade">
            <div v-if="error_msg && error_msg.non_field_errors" class="errors">
                <h3>Error{{ error_msg.non_field_errors.length !== 1 ? 's' : ''}}:</h3>
                <div v-if="error_msg.non_field_errors && error_msg.non_field_errors.length === 1">{{
                    error_msg.non_field_errors[0] }}
                </div>
                <ul v-else>
                    <li v-for="(err, idx) in error_msg.non_field_errors" :key="idx">{{ err }}</li>
                </ul>
            </div>
            <div v-else-if="error_msg" class="errors">
                <h3>Server Error:</h3>
                <div>{{ error_msg }}</div>
            </div>
        </transition>

        <b-form @submit="onSubmit">
            <b-form-group label="Username">
                <b-form-input v-model="username"></b-form-input>
            </b-form-group>

            <b-form-group label="Password">
                <b-form-input v-model="password" type="password"></b-form-input>
            </b-form-group>

            <b-form-group>
                <b-button type="submit" variant="primary" class="float-right">Log In</b-button>
            </b-form-group>
        </b-form>
    </div>
</template>

<script>
import store from '@/store';

export default {
    name: "Login",
    data() {
        return {
            username: '',
            password: '',
            error_msg: this.default_error_msg && {non_field_errors: [this.default_error_msg]}
        }
    },
    props: {
        default_error_msg: {type: String},
        nextRoute: {type: String}
    },
    methods: {
        onSubmit(evt) {
            evt.preventDefault();
            this.error_msg = null;

            store.dispatch("login", {username: this.username, password: this.password}).then(() => {
                // we presume success if we reached this point
                this.$snotify.success(`Logged in as ${this.username}`);

                if (this.nextRoute) {
                    this.$router.push(this.nextRoute);
                } else {
                    this.$router.push("/");
                }
            }).catch((err) => {
                if (!err.response || !err.response.hasOwnProperty('data')) {
                    // if it's a low-level error, e.g. the server's gone, there won't be any payload
                    this.error_msg = err.message;
                } else {
                    this.error_msg = err.response.data;
                }

                return true;
            });
        }
    }
}
</script>

<style scoped>
.errors {
    margin-bottom: 1em;
    color: #a33;
}

/* causes the errors to animate whenever a login is attempted */
.fade-enter-active, .fade-leave-active {
    transition: opacity .5s;
}

.fade-enter, .fade-leave-to {
    opacity: 0;
}
</style>
