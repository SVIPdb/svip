#!/usr/bin/env bash

TARGET_DB=${1:-svip_api}

pg_dump -U postgres -F c -d ${TARGET_DB} > ${TARGET_DB}_$( date +"%Y-%m-%d" ).dump
