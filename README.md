# SVIP

## Main components:

This top-level project coordinates three sub-projects that compose SVIP:
1. **[g2p-aggregator](https://gitlab.ethz.ch/svip/g2p-aggregator):** contains the pipeline (in `g2p-aggregator/harvester`) that populates the variant database,
2. **[svip_api](https://gitlab.ethz.ch/svip/svip_api):** the Django/[DRF](https://www.django-rest-framework.org/) API server that serves data from the database to the front-end,
3. **[svip-o-vue](https://gitlab.ethz.ch/svip/svip-o-vue):** the [Vue.js](https://vuejs.org/)-based web front-end.

`docker-compose.yml` is the main configuration file for launching the set of containers
that compose the complete SVIP system. It includes definitions for a few other essential
services, such as the Postgres database and local copy of the Universal Transcript Archive
(UTA). These are built from Docker Hub images and thus don't have any local data
in this repo.

The top-level git project includes the three sub-projects as git submodules. Typically,
we commit to the coordinating project when we want to declare that all the sub-projects
are compatible with each other at that point in their respective commit histories. We'll
also add tags to the coordinating repo (and probably the sub-repos as well) when we
perform official releases.

# Notes and other components:

There are currently three environments in which the project can run:
- **local**, in which the API server runs on port 8085, the front-end runs on 8080,
and the database server is accessible for debugging on port 30432.
- **dev**, which typically is deployed to the svip-dev server.
- **external**, which typically is deployed to svip-test.

All the environments require that docker and docker-compose are installed.

The `deployment` folder contains (work-in-progress) scripts that facilitate deployment
and synchronization across the three environments.

The `db_config` folder contains initialization scripts for the postgres database;
on first execution, it loads a sample database containing some faked SVIP data and
entries from public databases (CIViC, OncoKB, etc.).

Other random folders:
- `sql_scratch` contains scratch SQL scripts used for ad-hoc analyses.
- `notebooks` contains some Jupyter notebooks for ad-hoc analyses.
- `assets` contains artwork and other static assets used in the front-end and promotional.
- `svip_db_backups` stores snapshots of the database, retrieved from svip-dev.
- `kibana` contains configuration info for g2p-aggregator's original front-end.
(It's essentially an artifact of the g2p-aggregator project and isn't used by SVIP.)
- `outputs` contains a few dumps of information retrieved from some of the sources
for reference purposes.
