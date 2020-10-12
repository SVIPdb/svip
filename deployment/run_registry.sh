#!/usr/bin/env bash

docker run -d -p 15000:5000 --restart=always --name registry registry:2
