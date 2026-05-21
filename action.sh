#!/bin/bash
act -j authn-jwt \
  -P self-hosted=ubuntu:latest \
  --container-architecture linux/amd64 \
  -s CONJUR_URL=https://latamlab.secretsmgr.cyberark.cloud/api \
  -s CONJUR_SERVICE_ID=github
