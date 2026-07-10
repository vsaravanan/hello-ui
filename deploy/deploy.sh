#!/bin/bash
# k8master-deploy-ui.sh
# Runs entirely on k8master (invoked via: bash k8master-deploy-ui.sh <image>)

set -euo pipefail

START_TIME=$(date +%s)


remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"



# log_step "Save current image as previous tag (for rollback)"
# kubectl get deployment hello-ui -o jsonpath='{.spec.template.spec.containers[0].image}' > /data/fe/hello-ui/deploy/.previous_tag_ui 2>/dev/null || echo "none" > /data/fe/hello-ui/deploy/.previous_tag_ui
# cat /data/fe/hello-ui/deploy/.previous_tag_ui

kubectl delete deployment $module --ignore-not-found
kubectl delete svc $service --ignore-not-found
kubectl delete pod -l app=$module

log_step "Apply hello-ui manifest 
        kubectl apply -f $deploy_path/hello-ui.yaml"
kubectl apply -f "$deploy_path/hello-ui.yaml"

log_step "Roll out latest UI image
        kubectl set image deployment/$module $module=$ui_image"
kubectl set image deployment/$module $module="$ui_image"

log_step "Wait for rollout to finish
        kubectl rollout status deployment/$module"
kubectl rollout status deployment/$module


log_info "deploy-ui complete on k8master."

log_time START_TIME