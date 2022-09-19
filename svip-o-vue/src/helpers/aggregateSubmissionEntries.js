// aggregates the number of different effects and tier criteria pro combination disease-type

const aggregateProperty = (type_of_evidence, entry, property) => {
    if (!type_of_evidence[property].hasOwnProperty(entry[property])) {
        type_of_evidence[property][entry[property]] = 1;
    } else {
        type_of_evidence[property][entry[property]] += 1;
    }
};

// select curationEntry properties
const selectCurationEntryProperties = entry => {
    return {
        pmid: entry.references.split(':')[1],
        effect: entry.effect,
        tier_level_criteria: entry.tier_level_criteria,
        support: entry.support,
        id: entry.id,
        comment: entry.comment,
    };
};

// helps to find the most frequent effect or tier level for pre-populating the forms

const findMaximum = obj => {
    let sortedItems = Object.keys(obj)
        .map(key => [key, obj[key]])
        .sort((a, b) => {
            return a[1] > b[1] ? -1 : 1;
        });
    return sortedItems[0][0];
};

export const aggregateSubmissionEntries = curationEntries => {
    const submissionEntriesMap = {};

    curationEntries.forEach(entry => {
        let disease = entry.disease && entry.disease.name ? entry.disease.name : 'Unspecified';

        if (!submissionEntriesMap.hasOwnProperty(disease)) {
            submissionEntriesMap[disease] = {};
        }
        let type_of_evidence =
            entry.drugs.length > 0 ? `${entry.type_of_evidence} - ${entry.drugs[0]}` : entry.type_of_evidence;

        if (!submissionEntriesMap[disease].hasOwnProperty(type_of_evidence)) {
            submissionEntriesMap[disease][type_of_evidence] = {
                diseaseId: entry.disease ? entry.disease.id : null,
                drug: entry.drugs.length > 0 ? entry.drugs[0] : null,
                effect: {},
                tier_level_criteria: {},
                curationEntries: [selectCurationEntryProperties(entry)],
            };
        } else {
            submissionEntriesMap[disease][type_of_evidence].curationEntries.push(
                selectCurationEntryProperties(entry)
            );
        }

        aggregateProperty(submissionEntriesMap[disease][type_of_evidence], entry, 'effect');
        aggregateProperty(submissionEntriesMap[disease][type_of_evidence], entry, 'tier_level_criteria');

        submissionEntriesMap[disease][type_of_evidence].selectedEffect = findMaximum(
            submissionEntriesMap[disease][type_of_evidence].effect
        );

        submissionEntriesMap[disease][type_of_evidence].selectedTierLevel = findMaximum(
            submissionEntriesMap[disease][type_of_evidence].tier_level_criteria
        );
    });

    return Object.keys(submissionEntriesMap).map(key => {
        return {
            disease: key,
            types: submissionEntriesMap[key],
        };
    });
};

export const prepareForSubmission = (submissionEntries, variant, user) => {
    let result = [];
    submissionEntries.forEach(entry => {
        for (const [type, typeInfo] of Object.entries(entry.types)) {
            result.push({
                variant_id: variant.id,
                owner_id: user.user_id,
                disease_name: entry.disease,
                disease_id: typeInfo.diseaseId,
                drug: typeInfo.drug,
                type_of_evidence: type.includes('Predictive / Therapeutic') ? type.split(' - ')[0] : type,
                effect: typeInfo.selectedEffect,
                tier: typeInfo.selectedTierLevel,
                curation_entries: typeInfo.curationEntries.map(i => i.id),
            });
        }
    });

    return result;
};
