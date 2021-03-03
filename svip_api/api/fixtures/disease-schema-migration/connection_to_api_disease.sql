alter table public.api_disease add icd_o_morpho_id int4 null;
alter table public.api_disease add constraint api_disease_morpho_fk foreign key (icd_o_morpho_id) references public.icd_o_morpho(id);

update public.api_disease
set icd_o_morpho_id = icd_o_morpho.id
from icd_o_morpho
where lower(replace(trim(both ' ' from icd_o_morpho.term), ', NOS', '')) = lower(trim(both ' ' from api_disease.name));


alter table public.api_disease
    drop name, drop abbreviation, drop details, drop localization, drop morpho_code, drop snomed_code, drop snomed_name, drop topo_code, drop user_created;