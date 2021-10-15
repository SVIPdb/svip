# Swiss Variant Interpretation Platform (SVIPdb)

## Introduction

The Swiss Variant Interpretation Platform (SVIPdb) is a framework to collect, curate, review, and share variant annotations. It is the software developed as part of the [SPHN](https://sphn.ch/) infrastructure development project [Swiss Variant Interpretation Platform for Oncology](https://svip.ch/) (SVIP). We distinguish between the tool and the service by their acronyms SVIPdb and SVIP, respectively.

## Main components

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

# Prerequisites

You're encouraged to use [Docker](https://www.docker.com/products/docker-desktop) and
[docker-compose](https://docs.docker.com/compose/install/) to run the project; be sure to
have these preinstalled.

You must also have [Git LFS](https://git-lfs.github.com/) installed in order to download
the default database dumps.

# Initial Setup

## Clone the project and its submodules

To clone the project and its submodules, you can run the following:

```bash
git clone git@github.com:SVIPdb/coordinator.git svip
cd svip
git submodule update --init --recursive
```

## Configure your environment

### Make the `seqrepo` database available locally

```bash
cd seqrepo
make
```

### Download the harvester resources

To download the harvester resources you need to have an access token to onkokb as well as for bioontology.

```bash
cd g2p-aggregator/data
make
```

Also add the access tokens to your `.env` file.

```bash
BIOONTOLOGY_API_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
ONCOKB_API_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### Populate the VEP cache

```bash
./dc_harvester.sh build harvester
./dc_harvester.sh run --rm harvester /bin/sh -c 'scripts/populate_vep_cache.sh'
```

## Do initial tasks

To initially start the database server, API, and frontend:

1. Copy the contents of `.env.TEMPLATE` into `.env` and change the fields in it as necessary.
2. Run `docker-compose up -d`, which will launch the database server, API server,
   and static webserver which hosts the frontend.
3. (Optional) If you'd like to load a data dump, execute the following:
   1. `docker-compose exec db /bin/bash`
   2. `cd /backups` and `ls -lt` to review the list of available dumpfiles.
   3. `./restoredump.sh <your_dumpfile> svip_api` to load the dumpfile.

To start the harvester:

1. (Optional) Start a screen/tmux session, since this will likely take a while.
2. Run `docker-compose run --rm harvester /bin/bash`
3. Within the container, edit `entrypoint.sh all` and then execute it to start the harvesting process.

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
