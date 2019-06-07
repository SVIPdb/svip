#!/bin/bash

createdb svip_api
pg_restore -d svip_api /backups/svip_api_debug_2019-05-24.dump
