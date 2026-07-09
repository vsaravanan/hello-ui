#!/bin/bash
# k8master-rollback-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-rollback-ui.sh)

set -exuo pipefail

REMOTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REMOTE_DIR/environment.sh"
source "$REMOTE_DIR/common.sh"

log_step "Read previous image tag"
PREVIOUS_TAG="$(cat /data/fe/hello-ui/deploy/.previous_tag_ui)"
echo "$PREVIOUS_TAG"

if [ "$PREVIOUS_TAG" = "none" ]; then
    log_error "No previous image recorded, cannot roll back."
    exit 1
fi

log_step "Roll back hello-ui deployment"
kubectl set image deployment/hello-ui hello-ui="$PREVIOUS_TAG"

log_step "Wait for rollback rollout to finish"
kubectl rollout status deployment/hello-ui

log_info "rollback-ui complete on k8master."
