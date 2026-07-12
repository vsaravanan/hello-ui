#!/bin/bash
# k8master-rollback-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-rollback-ui.sh)

set -euo pipefail

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"

mylog "Read previous image tag"
PREVIOUS_TAG="$(cat "$deploy_path/.previous_tag_ui")"
echo "$PREVIOUS_TAG"

if [ "$PREVIOUS_TAG" = "none" ]; then
    log_error "No previous image recorded, cannot roll back."
    exit 1
fi

mylog "Roll back hello-ui deployment"
kubectl set image deployment/$module $module="$PREVIOUS_TAG"

mylog "Wait for rollback rollout to finish"
kubectl rollout status deployment/$module

log_info "rollback-ui complete on k8master."
