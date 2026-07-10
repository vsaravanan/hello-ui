#!/bin/bash
# k8master-build-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-build-ui.sh <image>)
# The repo is already synced by the host script before this runs.

set -euo pipefail

START_TIME=$(date +%s)


remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"


log_step "check out source code from $project_path"
cd "$project_path"
echo `pwd`

git reset --hard
git fetch 
git checkout 
git pull 
chmod +x  *.sh deploy/*.sh || true


log_step "Install dependencies with pnpm"
cd "$project_path"
pnpm install --frozen-lockfile

log_step "Build with pnpm"
cd "$project_path"
pnpm build

log_step "Build image with Buildah"
cd "$project_path"



if [ "${1:-}" = "base" ]; then
    log_step "🚀 buildah building base image  $ui_image_base ...
    buildah bud -t $ui_image_base -f deploy/Dockerfile.base "
    buildah bud -t "$ui_image_base" -f deploy/Dockerfile.base

    log_info "buildah push --tls-verify=false $ui_image_base docker://${ui_image_base}"
    buildah push --tls-verify=false "$ui_image_base" "docker://${ui_image_base}"
    log_step "✅ Base image built and pushed!"
fi

mv "$deploy_path/.current_tag_ui" "$deploy_path/.previous_tag_ui"  || true
log_step '🚀 buildah building latest image  $ui_image ...
buildah bud -t "$ui_image" -f deploy/Dockerfile .'
buildah bud -t "$ui_image" -f deploy/Dockerfile .

log_step "Record current git commit as the deployment tag"
git rev-parse --short HEAD > "$deploy_path/.current_tag_ui"
cat "$deploy_path/.current_tag_ui"

log_step "buildah push image to registry ${ui_image}"
buildah push --tls-verify=false \
    "${ui_image}" "docker://${ui_image}"


log_info "kubectl delete pod -l app=$module"
kubectl delete pod -l app=$module

log_info "build-ui complete on ${HOST}. Image: $ui_image"


log_time START_TIME