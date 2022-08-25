const onlyUnique = (value, index, self) => {
	return self.indexOf(value) === index;
};

export const parseVariantsForReview = items => {
	return items.map(item => {
		console.log(items);
		return {
			gene: {id: item.gene.id, symbol: item.gene.symbol},
			variant: {id: item.id, name: item.name},
			hgvs: item.hgvs_c,
			diseases: item.submission_entries.map(entry => entry.disease.name).filter(onlyUnique),
			curators: item.curation_entries.map(entry => entry.owner_name).filter(onlyUnique),
			stage: item.stage,
			deadline: 'No deadline',
			action: 'No action',
			reviews_summary: item.reviews_summary,
			reviewers: item.reviewers,
			review_count: item.review_count,
		};
	});
};
