#!/bin/bash
# environment.sh (frontend / hello-ui)
# Sourced by every host-side script in this deploy/ folder.
# This file lives inside the hello-ui repo, so it's identical on the
# host and on k8master once git pull has synced them.

git_url="https://github.com/vsaravanan/hello-ui.git"
module=hello-ui
service=hello-ui-svc
project_path=/data/fe/hello-ui
deploy_path=/data/fe/hello-ui/deploy
ui_image_base="k8master:5000/hello-ui-base:latest"
ui_image="k8master:5000/hello-ui:latest"

HOST="k8master"
