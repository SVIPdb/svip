# Releases

This directory holds commit logs for each minor and/or major SVIP release. These commit logs are used to render
the changelogs on the `Releases` page in the SVIP UI.

## Creating a New Release

Before you begin, ensure that you are in `svip-o-vue` and that the working directory is clean (i.e., everything
is commited).

Then, run the following:

`npm version {major|minor}`

This will do the following:

-   bump the version number in `package.json`,
-   create a new commit containing just the new version number, and
-   add a new tag in the repo that corresponds to the version.

## Populating the Releases Page

To create the commit log, run the following:

`../scripts/gitlog_json.sh <LAST_VERSION>~ > src/data/releases/v100_commits.js`

Where `LAST_VERSION` is either the commit hash or tag of the last commit in the previous version.

Now, you'll have to add an entry to the list in `src/components/views/Releases.vue`. First, we'll import the new
commit log that we created in the last step:

`import v100_commits from '@/data/releases/v100_commits.js';`

Second, we'll need to add an entry to the `relreases` key in `data()`; it'll look something like this:

```
"1.0.0": {
    name: 'Beta Aleph',
    summary: 'Released on 10.20.2020, this is the first feature-complete public release.',
    changes: [
        'Finalized curation interface',
        'Added 273 SVIP-curated entries for selected variants in TP53, CTNNB1, NRAS',
        'Lots of bugfixes and other improvements'
    ],
    significant: true, full: false, changelog: v100_commits
},
```

Where `changelog` refers to the commit log we imported before.

The `name` field is composed of two words. The first is "Alpha", "Beta", etc. and identfies the release stage, and is
based on the major version field. The second is an alphabetic sequence of otherwise arbitrary words, with each subsequent
minor version number getting a new second term. For example, v0.1.0 is "Alpha Asterisk", v0.2.0 is be "Alpha Bump", etc.

The `summary` contains a one-sentence summary of this release and typically includes the release date. Try to summarize
the major changes introduced in this release in your own words in the `changes` array.

The `significant` and `full` keys are used by the collapsers on the page; their values here will be whether they're
expanded or collapsed by default.
