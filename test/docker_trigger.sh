#!/bin/bash

TRIGGER_URL="https://registry.hub.docker.com/u/nullcake/graylog-alpine/trigger"

# Trigger all tags/branchs for this automated build.
curl -H "Content-Type: application/json" --data '{"build": true}' -X POST ${TRIGGER_URL}/${DOCKER_TRIGGER_TOKEN}/ >/dev/null 2>&1

