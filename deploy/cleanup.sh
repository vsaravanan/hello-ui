#!/bin/bash
# k8master-cleanup-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-cleanup-ui.sh)

set -exuo pipefail

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"


log_step "Remove leftover $module validation check pod"
kubectl delete pod curl-ui-check --ignore-not-found

log_info "cleanup-ui complete on k8master."
