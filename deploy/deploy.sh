#!/bin/bash
# k8master-deploy-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-deploy-ui.sh <image>)

set -euo pipefail


REMOTE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REMOTE_DIR/environment.sh"
source "$REMOTE_DIR/common.sh"



log_step "Save current image as previous tag (for rollback)"
kubectl get deployment hello-ui -o jsonpath='{.spec.template.spec.containers[0].image}' > /data/fe/hello-ui/deploy/.previous_tag_ui 2>/dev/null || echo "none" > /data/fe/hello-ui/deploy/.previous_tag_ui
cat /data/fe/hello-ui/deploy/.previous_tag_ui

kubectl delete deployment hello-ui --ignore-not-found
kubectl delete svc hello-ui-svc --ignore-not-found
kubectl delete pod -l app=hello-ui

log_step "Apply hello-ui manifest"
kubectl apply -f /data/fe/hello-ui/deploy/hello-ui.yaml

log_step "Roll out latest UI image"
kubectl set image deployment/hello-ui hello-ui="$UI_IMAGE"

log_step "Wait for rollout to finish"
kubectl rollout status deployment/hello-ui


log_info "deploy-ui complete on k8master."
