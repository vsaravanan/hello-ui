#!/bin/bash
# k8master-build-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-build-ui.sh <image>)
# The repo is already synced by the host script before this runs.

set -euo pipefail



REMOTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REMOTE_DIR/environment.sh"
source "$REMOTE_DIR/common.sh"

log_step "Install dependencies with pnpm"
cd /data/fe/hello-ui
pnpm install --frozen-lockfile

log_step "Build with pnpm"
cd /data/fe/hello-ui
pnpm build

log_step "Build image with Buildah"
cd /data/fe/hello-ui
buildah bud -t "$UI_IMAGE" -f deploy/Dockerfile .

log_step "Record current git commit as the deployment tag"
git rev-parse --short HEAD > /data/fe/hello-ui/deploy/.current_tag_ui
cat /data/fe/hello-ui/deploy/.current_tag_ui

log_step "Push image to registry"
buildah push --tls-verify=false \
    "${UI_IMAGE}" "docker://${UI_IMAGE}"

log_info "build-ui complete on k8master. Image: $UI_IMAGE"
