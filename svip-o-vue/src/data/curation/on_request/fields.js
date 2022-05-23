import { abbreviatedName } from "@/utils";

export default [
    {
        key: "gene_name",
        label: "Gene",
        sortable: true,
    },
    {
        key: "variant",
        label: "Variant",
        sortable: true,
    },
    {
        key: "hgvs",
        label: "HGVS.c",
        sortable: false,
    },
    {
        key: "disease",
        label: "Disease(s)",
        sortable: true,
    },
    {
        key: "status",
        label: "Status",
        sortable: true,
    },
    {
        key: "deadline",
        label: "Deadline (days left)",
        sortable: true,
    },
    {
        key: "requester",
        label: "Requester",
        sortable: true,
    },
    {
        key: "curator",
        label: "Curator(s)",
        sortable: true,
        filterByFormatted: (x) =>
            x.map((z) => abbreviatedName(z.name).abbrev).join(", "),
    },
    {
        key: "action",
        label: "Action",
        sortable: false,
    },
];
