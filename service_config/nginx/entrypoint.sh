#!/usr/bin/env bash

sh -c "/reloader.sh &"
exec "$@"