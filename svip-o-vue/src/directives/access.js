import {Bus} from "@/bus";
import store from "@/store";

// Initialize the annoying-background directive.
export default {
	bind: function (el, binding) {
		const refreshPermissions = () => {
			let pass = false;

			if (binding.value === 'active') {
				// just check if they have valid login data at all
				pass = store.getters.jwtData;
			}
			else if (store.getters.groups) {
				pass = store.getters.groups.includes(binding.value);
			}

			el.style.display = pass ? "" : "none";
		};

		// bind to update this control whenever the user's permissions change (e.g. when logging in or out)
		Bus.$on("user.updated", () => {
			refreshPermissions(el, binding);
		});

		// ...and fire off one refresh just to get us up-to-date
		refreshPermissions(el, binding);
	}
};
