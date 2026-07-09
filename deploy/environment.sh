#!/bin/bash
# environment.sh (frontend / hello-ui)
# Sourced by every host-side script in this deploy/ folder.
# This file lives inside the hello-ui repo, so it's identical on the
# host and on k8master once git pull has synced them.

FRONTEND_GIT_URL="https://github.com/vsaravanan/hello-ui.git"
FRONTEND_DIR="/data/fe/hello-ui"
UI_IMAGE="k8master:5000/hello-ui:latest"

HOST="k8master"
