#!/bin/bash
# k8master-cleanup-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-cleanup-ui.sh)

set -exuo pipefail

REMOTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REMOTE_DIR/common.sh"

log_step "Remove leftover hello-ui validation check pod"
kubectl delete pod curl-ui-check --ignore-not-found

log_info "cleanup-ui complete on k8master."
