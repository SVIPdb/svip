// aggregates the number of different effects and tier criteria pro combination disease-type

const aggregateProperty = (type_of_evidence, entry, property) => {
    if (!type_of_evidence[property].hasOwnProperty(entry[property])) {
        type_of_evidence[property][entry[property]] = 1;
    } else {
        type_of_evidence[property][entry[property]] += 1;
    }
};

// helps finding the most frequent effect or tier level for prepopulating the forms

const findMaximum = obj => {
    let sortedItems = Object.keys(obj)
        .map(key => [key, obj[key]])
        .sort((a, b) => {
            return a[1] > b[1] ? 1 : -1;
        });
    return sortedItems[0][0];
};

export const aggregateSubmissionEntries = curationEntries => {
    const submissionEntriesMap = {};

    curationEntries.forEach(entry => {
        let disease =
            entry.disease && entry.disease.name
                ? entry.disease.name
                : "Unspecified";

        if (!submissionEntriesMap.hasOwnProperty(disease)) {
            submissionEntriesMap[disease] = {};
        }
        let type_of_evidence = entry.type_of_evidence;
        if (!submissionEntriesMap[disease].hasOwnProperty(type_of_evidence)) {
            submissionEntriesMap[disease][type_of_evidence] = {
                effect: {},
                tier_level_criteria: {},
                curationEntries: [entry],
            };
        } else {
            submissionEntriesMap[disease][
                type_of_evidence
            ].curationEntries.push(entry);
        }

        aggregateProperty(
            submissionEntriesMap[disease][type_of_evidence],
            entry,
            "effect"
        );
        aggregateProperty(
            submissionEntriesMap[disease][type_of_evidence],
            entry,
            "tier_level_criteria"
        );

        submissionEntriesMap[disease][type_of_evidence].selectedEffect =
            findMaximum(submissionEntriesMap[disease][type_of_evidence].effect);

        submissionEntriesMap[disease][type_of_evidence].selectedTierLevel =
            findMaximum(
                submissionEntriesMap[disease][type_of_evidence]
                    .tier_level_criteria
            );
    });

    return Object.keys(submissionEntriesMap).map(key => {
        return {
            disease: key,
            types: submissionEntriesMap[key],
        };
    });
};
