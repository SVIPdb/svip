import {abbreviatedName} from '@/utils';

export default [
    {
        key: 'gene',
        label: 'Gene',
        sortable: true,
    },
    {
        key: 'variant',
        label: 'Variant',
        sortable: true,
    },
    {
        key: 'hgvs',
        label: 'HGVS.c',
        sortable: false,
    },
    {
        key: 'diseases',
        label: 'Disease(s)',
        sortable: true,
    },
    {
        key: 'status',
        label: 'Reviews',
        sortable: true,
    },

    {
        key: 'variant_status',
        label: 'Status',
        sortable: true,
    },

    {
        key: 'curators',
        label: 'Curator(s)',
        sortable: true,
        filterByFormatted: x => x.map(z => abbreviatedName(z.name).abbrev).join(', '),
    },
    {
        key: 'action',
        label: 'Action',
        sortable: false,
    },
];
