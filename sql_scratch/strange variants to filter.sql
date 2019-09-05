select * from api_variant where hgvs_c is null;

select
       payload->'cosmic'->'Mutation CDS' as "Mutation CDS",
       variant_name,
       refseq, isoform,
       hgvs_c, hgvs_p, hgvs_g,
       * from api_association
inner join api_variantinsource av on api_association.variant_in_source_id = av.id
inner join api_variant a on av.variant_id = a.id
where a.id=938;

select substr(hgvs_c, position(':' in hgvs_c) + 1) from api_variant;

select
       ag.symbol, source,
       refseq, isoform,
       payload->'cosmic'->'Mutation CDS' as "Mutation CDS",
       substr(hgvs_c, position(':' in hgvs_c) + 1),
       variant_name,
       hgvs_c, hgvs_p, hgvs_g
from api_association
inner join api_variantinsource av on api_association.variant_in_source_id = av.id
inner join api_variant a on av.variant_id = a.id
inner join api_gene ag on a.gene_id = ag.id
where payload->'cosmic'->>'Mutation CDS' != substr(hgvs_c, position(':' in hgvs_c) + 1);

select array_agg(distinct src.name), ag.symbol, refseq, isoform from api_variant
inner join api_variantinsource vis on api_variant.id = vis.variant_id
inner join api_source src on vis.source_id = src.id
inner join api_gene ag on api_variant.gene_id = ag.id
where isoform='ENST00000288602'
group by ag.symbol, refseq, isoform;
