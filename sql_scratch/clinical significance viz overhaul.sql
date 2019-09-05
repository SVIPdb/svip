select source, evidence_type, count(*) from api_association group by source, evidence_type;

select source, clinical_significance, count(*) from api_association
where source='civic'
group by source, clinical_significance;