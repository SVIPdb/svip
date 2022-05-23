<template>
    <div>
        <b-spinner
            v-if="loading"
            style="display: block; margin: 0 auto; width: 3rem; height: 3rem"
        />
        <div v-else-if="error">{{ error }}</div>
        <div v-else>
            <div
                v-for="(entry, idx) in lean_history"
                :key="idx"
                style="margin-bottom: 2em"
            >
                <HistoryHeader
                    icon="pen-alt"
                    action="Edited"
                    :actor="entry.changed_by"
                    :date="entry.time"
                />

                <div style="margin-left: 23px; margin-right: 12px">
                    <b-table-simple bordered class="change-table">
                        <b-thead head-variant="light">
                            <b-tr>
                                <b-th style="width: 20%">Field Name</b-th>
                                <b-th style="width: 20%">Old</b-th>
                                <b-th></b-th>
                                <b-th style="width: 60%">New</b-th>
                            </b-tr>
                        </b-thead>

                        <b-tbody>
                            <b-tr
                                v-for="(change, idx) in entry.changes"
                                :key="idx"
                            >
                                <b-td>{{ change.field }}</b-td>
                                <b-td>
                                    <ChangeField :value="change.old" />
                                </b-td>
                                <b-td>&rightarrow;</b-td>
                                <b-td>
                                    <b><ChangeField :value="change.new" /></b>
                                </b-td>
                            </b-tr>
                        </b-tbody>
                    </b-table-simple>
                </div>
            </div>

            <HistoryHeader
                icon="plus-square"
                action="Created"
                :actor="history.created_by"
                :date="history.created_on"
            />
        </div>
    </div>
</template>

<script>
import { HTTP } from "@/router/http";
import { abbreviatedName, simpleDateTime } from "@/utils";
import dayjs from "dayjs";

const HistoryHeader = {
    props: {
        icon: { required: true, type: String },
        action: { required: true, type: String },
        date: { required: true },
        actor: { required: false, type: String },
    },
    render() {
        const m = dayjs(this.date);
        const datetime = m.format("DD.MM.YYYY, h:mm a");

        const parsedActor = this.actor && abbreviatedName(this.actor);

        return (
            <h4 class="history-header">
                <div>
                    <icon name={this.icon} scale="1.1" />
                    <span style="margin-left: 5px;">
                        <b>{this.action}</b> on {datetime}
                        {parsedActor && (
                            <span>
                                {" "}
                                by{" "}
                                <b v-b-tooltip={parsedActor.name}>
                                    {parsedActor.abbrev}
                                </b>
                            </span>
                        )}
                    </span>
                </div>
            </h4>
        );
    },
};

const ChangeField = {
    props: {
        value: { required: true },
    },
    render() {
        let v;
        try {
            v = JSON.parse(this.value);
        } catch (e) {
            v = this.value;
        }

        if (Array.isArray(v)) {
            return v.length > 0 ? (
                <ul class="items">
                    {v.map((x) => (
                        <li>{x || "-"}</li>
                    ))}
                </ul>
            ) : (
                <div class="text-muted font-italic">empty list</div>
            );
        }

        return (
            <div class={v ? null : "text-muted font-italic"}>{v || "n/a"}</div>
        );
    },
};

export default {
    name: "EvidenceHistory",
    components: { ChangeField, HistoryHeader },
    props: {
        entry_id: { type: Number, required: true },
    },
    data() {
        return {
            loading: true,
            error: null,
            history: null,
        };
    },
    created() {
        this.refresh();
    },
    computed: {
        lean_history() {
            return this.history.deltas.filter((d) => d.changes.length > 0);
        },
    },
    methods: {
        simpleDateTime,
        refresh() {
            HTTP.get(`/curation_entries/${this.entry_id}/history`)
                .then((result) => {
                    this.history = result.data;
                    this.loading = false;
                })
                .catch((err) => {
                    this.error = err;
                    throw err;
                });
        },
    },
};
</script>

<style scoped>
.items {
    margin: 0;
    padding: 0 0 0 20px;
}

.history-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    color: #333;
    margin-bottom: 0.5em;
}
</style>
