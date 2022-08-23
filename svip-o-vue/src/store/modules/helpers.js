const onlyUnique = (value, index, self) => {
	return self.indexOf(value) === index;
};

export const parseVariantsForReview = items => {
	return items.map(item => {
		return {
			gene: {id: item.gene.id, symbol: item.gene.symbol},
			variant: {id: item.id, name: item.name},
			hgvs: item.hgvs_c,
			diseases: item.submission_entries.map(entry => entry.disease.name).filter(onlyUnique),
			curators: item.curation_entries.map(entry => entry.owner_name).filter(onlyUnique),
			stage: item.stage,
			status: 'No status',
			deadline: 'No deadline',
			action: 'No action',
		};
	});
};
