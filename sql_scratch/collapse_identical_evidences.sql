-- mimic how the front-end retrieves evidence for a given variant-in-source
-- collapse entries with mostly the same columns, but different evidence and source links, into a single entry
-- includes the collapsed entries w/their relevant information in
select
  min(aa.id) as id,
  aa.variant_in_source_id,
  ap.term as disease,
  case when count(distinct aa.id) = 1 then min(aa.source_link) else null end as evidence_url,
  aa.evidence_type,
  aa.evidence_direction,
  aa.clinical_significance,
  aa.drug_labels,
  string_agg(distinct ae.description, '; ') as contexts,
  string_agg(distinct aa.evidence_level, ',') as evidence_levels,
  array_agg(distinct pubs_tbl) as publications,
  jsonb_agg(distinct jsonb_build_object(
    'id', aa.id,
    'evidence_url', aa.source_link,
    'evidence_level', aa.evidence_level,
    'publications', (
      select array_agg(pubs) from api_evidence, unnest(api_evidence.publications) as pubs
      where api_evidence.association_id=aa.id)
  )) as children,
  count(distinct aa.id) as collapsed_count
from api_association aa
inner join api_phenotype ap on aa.id = ap.association_id
inner join api_environmentalcontext ae on aa.id = ae.association_id
inner join api_evidence aev on aa.id = aev.association_id, unnest(aev.publications) pubs_tbl
group by
  aa.variant_in_source_id,
  ap.term,
  aa.evidence_type,
  aa.evidence_direction,
  aa.clinical_significance,
  aa.drug_labels;

create or replace view api_collapsed_associations as
  select
    min(aa.id) as id,
    aa.variant_in_source_id,
    ap.term as disease,
    case when count(distinct aa.id) = 1 then min(aa.source_link) else null end as evidence_url,
    aa.evidence_type,
    aa.evidence_direction,
    aa.clinical_significance,
    aa.drug_labels,
    string_agg(distinct ae.description, '; ') as contexts,
    string_agg(distinct aa.evidence_level, ',') as evidence_levels,
    array_agg(distinct pubs_tbl) as publications,
    jsonb_agg(distinct jsonb_build_object(
      'id', aa.id,
      'evidence_url', aa.source_link,
      'evidence_level', aa.evidence_level,
      'publications', (
        select array_agg(pubs) from api_evidence, unnest(api_evidence.publications) as pubs
        where api_evidence.association_id=aa.id)
    )) as children,
    count(distinct aa.id) as collapsed_count
  from api_association aa
  inner join api_phenotype ap on aa.id = ap.association_id
  inner join api_environmentalcontext ae on aa.id = ae.association_id
  inner join api_evidence aev on aa.id = aev.association_id, unnest(aev.publications) pubs_tbl
  group by
    aa.variant_in_source_id,
    ap.term,
    aa.evidence_type,
    aa.evidence_direction,
    aa.clinical_significance,
    aa.drug_labels;

select collapsed_count, count(distinct collapsed_count) from api_collapsed_associations group by collapsed_count;

-- check if we have any associations with more than one phenotype (we generally don't)
select aa.id, count(distinct ap.id) as phenotypes from api_association aa
inner join api_phenotype ap on aa.id = ap.association_id
group by aa.id;

select aa.id, count(distinct ap.id) as contexts
from api_association aa
inner join api_environmentalcontext ap on aa.id = ap.association_id
group by aa.id;

select * from api_environmentalcontext
inner join api_association aa on api_environmentalcontext.association_id = aa.id
where association_id=570;