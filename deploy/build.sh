#!/bin/bash
# k8master-build-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-build-ui.sh <image>)
# The repo is already synced by the host script before this runs.

set -euo pipefail

START_TIME=$(date +%s)


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


if [ "${1:-}" = "base" ]; then
    log_step "🚀 Building base image..."
    buildah bud -t "$UI_IMAGE_BASE" -f deploy/Dockerfile.base
    buildah push --tls-verify=false "$UI_IMAGE_BASE" "docker://${UI_IMAGE_BASE}"
    log_step "✅ Base image built and pushed!"
fi

mv /data/fe/hello-ui/deploy/.current_tag_ui /data/fe/hello-ui/deploy/.previous_tag_ui
buildah bud -t "$UI_IMAGE" -f deploy/Dockerfile .

log_step "Record current git commit as the deployment tag"
git rev-parse --short HEAD > /data/fe/hello-ui/deploy/.current_tag_ui
cat /data/fe/hello-ui/deploy/.current_tag_ui

log_step "Push image to registry"
buildah push --tls-verify=false \
    "${UI_IMAGE}" "docker://${UI_IMAGE}"

log_info "build-ui complete on k8master. Image: $UI_IMAGE"

kubectl delete pod -l app=hello-ui

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))


log_time START_TIME