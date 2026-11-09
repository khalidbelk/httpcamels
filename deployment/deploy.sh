#!/bin/bash

set -e

docker build --build-arg CACHEBUST=$(date +%s) -t httpcamels .
docker rm -f httpcamels 2>/dev/null
docker run --restart unless-stopped -d --name httpcamels --runtime=solo5 -p 3001:8080 httpcamels
docker image prune -f