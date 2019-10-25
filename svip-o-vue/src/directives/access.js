import {Bus} from "@/bus";
import store from "@/store";

/**
 * Checks if the logged-in user belongs to the given role.
 * @param role the role to check, or 'active' to check for any valid login
 * @returns {boolean} true if they have the given role, false otherwise
 */
export function checkInRole(role) {
    if (role === 'active') {
        // just check if they have valid login data at all
        return !!store.getters.jwtData;
    } else {
        return store.getters.groups && store.getters.groups.includes(role);
    }
}

export default {
    bind: function (el, binding) {
        const refreshPermissions = () => {
            el.style.display = checkInRole(binding.value) ? "" : "none";
        };

        // bind to update this control whenever the user's permissions change (e.g. when logging in or out)
        Bus.$on("user.updated", () => {
            refreshPermissions(el, binding);
        });

        // ...and fire off one refresh just to get us up-to-date
        refreshPermissions(el, binding);
    }
};
