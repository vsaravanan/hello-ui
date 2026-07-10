#!/bin/bash
# k8master-rollback-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-rollback-ui.sh)

set -euo pipefail

source "$deploy_path/environment.sh"
source "$deploy_path/common.sh"

log_step "Read previous image tag"
PREVIOUS_TAG="$(cat "$deploy_path/.previous_tag_ui")"
echo "$PREVIOUS_TAG"

if [ "$PREVIOUS_TAG" = "none" ]; then
    log_error "No previous image recorded, cannot roll back."
    exit 1
fi

log_step "Roll back hello-ui deployment"
kubectl set image deployment/$module $module="$PREVIOUS_TAG"

log_step "Wait for rollback rollout to finish"
kubectl rollout status deployment/$module

log_info "rollback-ui complete on k8master."
