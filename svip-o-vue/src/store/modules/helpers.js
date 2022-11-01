const onlyUnique = (value, index, self) => {
    return self.indexOf(value) === index;
};

// none = 'none'
// loaded = 'loaded'
// ongoing_curation = 'ongoing_curation'
// annotated = 'annotated'
// ongoing_review = 'ongoing_review'
// unapproved = 'unapproved'
// reannotated = 'reannotated'
// on_hold = 'on_hold'
// approved = 'approved'
// fully_approved = 'fully_approved'

export const parseVariantsForReview = items => {
    return items.map(item => {
        return {
            gene: {id: item.gene.id, symbol: item.gene.symbol},
            variant: {id: item.id, name: item.name},
            hgvs: item.hgvs_c,
            diseases: item.submission_entries
                .map(entry => {
                    return entry.disease && entry.disease.name ? entry.disease.name : 'Unspecified';
                })
                .filter(onlyUnique),
            curators: item.curation_entries.map(entry => entry.owner_name).filter(onlyUnique),
            stage: item.stage,
            deadline: 'No deadline',
            action: 'No action',
            reviews_summary: item.reviews_summary,
            reviewers: item.reviewers,
            review_count: item.review_count,
            variant_status: getVariantStatus(item),
            draft_summary: item.draft_summary,
            review_cycle: item.review_cycle,
        };
    });
};

const ifReviewIsDraft = () => {};

const getVariantStatus = variant => {
    if (variant.review_cycle < 2) {
        if (variant.review_count === 0) {
            return 'New';
        } else if (
            variant.review_count !== 3 ||
            (variant.review_count <= 3 && variant.draft_summary && variant.draft_summary.includes(true))
        ) {
            return 'In process';
        } else if (variant.review_count === 3 && variant.reviews_summary.reduce((a, b) => a + b, 0) === 3) {
            return 'Approved';
        } else if (variant.stage === 'unapproved') {
            return 'On-hold';
        }
        return 'None';
    } else {
        return 'Second review';
    }
};
