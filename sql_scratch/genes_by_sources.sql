select AG.symbol, AV.name, count(*) from svip_curationentry CE
inner join api_disease AD on AD.id = CE.disease_id
inner join api_variant AV on AV.id = CE.variant_id
inner join api_gene AG on AG.id = AV.gene_id
where CE.status='unreviewed'
group by AG.symbol, AV.name;

select count(*) from svip_curationentry CE where CE.status='unreviewed';

select * from (
  select
    symbol,
    sum(compiled.civic_counts) as civic_counts,
    sum(compiled.oncokb_counts) as oncokb_counts,
    sum(compiled.clinvar_counts) as clinvar_counts,
    sum(compiled.cosmic_counts) as cosmic_counts
  from (
    select
      symbol,
      (select cnt where name='civic') as civic_counts,
      (select cnt where name='oncokb') as oncokb_counts,
      (select cnt where name='clinvar') as clinvar_counts,
      (select cnt where name='cosmic') as cosmic_counts
    from (
      select AG.symbol, AVS.name, count(*) as cnt from api_variantinsource VIS
      inner join api_variant AV on VIS.variant_id = AV.id
      inner join api_gene AG on AV.gene_id = AG.id
      inner join api_source AVS on VIS.source_id = AVS.id
      group by AG.symbol, AVS.name
    ) as var_counts
  ) as compiled
  group by symbol
) as Z
order by civic_counts + oncokb_counts + clinvar_counts + cosmic_counts;
