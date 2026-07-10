#!/bin/bash
# k8master-validate-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-validate-ui.sh)

set -euo pipefail

REMOTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REMOTE_DIR/environment.sh"
source "$REMOTE_DIR/common.sh"


log_step "Check hello-ui pod status"
kubectl get pods -l app=hello-ui

log_step "Wait for hello-ui pod to be Ready"
kubectl wait --for=condition=Ready pod -l app=hello-ui --timeout=60s

log_info "validate-ui complete on k8master."
