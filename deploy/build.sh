#!/bin/bash
# k8master-build-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-build-ui.sh <image>)
# The repo is already synced by the host script before this runs.

set -exuo pipefail

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"

logfile=$(get_caller_script)
start_log_file $logfile

check_status


mylog "check out source code from $project_path"
cd "$project_path"

checkout


mylog "Install dependencies with pnpm"
cd "$project_path"
pnpm install --frozen-lockfile

mylog "Build with pnpm"
cd "$project_path"
pnpm build

mylog "Build image with Buildah"
cd "$project_path"



if [ "${1:-}" = "base" ]; then
    mylog "🚀 buildah building base image ..."
    buildah bud -t "$api_image_base" -f deploy/Dockerfile.base

    mylog " buildah pushing base image to registry"
    buildah push --tls-verify=false "$api_image_base" "$registry_url/${api_image_base}"
    mylog "✅ Base image built and pushed!"
fi

mv "$deploy_path/.current_tag_ui" "$deploy_path/.previous_tag_ui"  || true
mylog "🚀 buildah building latest image ..."
buildah bud -t "$api_image" -f deploy/Dockerfile .

mylog "Record current git commit as the deployment tag"
git rev-parse --short HEAD > "$deploy_path/.current_tag"
cat "$deploy_path/.current_tag"

mylog "buildah push image to registry "
buildah push --tls-verify=false \
    "${api_image}" "$registry_url/${api_image}"

if image_exists "$api_image"; then
    mylog "📤 Rename latest image with timestamp..."
    newname=$(renameWithTimestamp "$api_image")

    buildah tag "$api_image" "$newname"
else
    mylog "no latest image found"
fi

# log_info "Deleting pod for $module"
# kubectl delete pod -l app=$module

# mylog "Apply hello-ui manifest"
# echo kubectl apply -f "$deploy_path/$module.yaml"

# mylog "Roll out latest UI image"
# kubectl set image deployment/$module $module="$api_image"

# mylog "Wait for rollout to finish"
# kubectl rollout status deployment/$module


check_status

mylog "check status of Evicted and Error"
kubectl get all -A | grep -E "Evicted|Error" || true


log_info "build complete on ${HOST}. Image: $api_image"


log_time 