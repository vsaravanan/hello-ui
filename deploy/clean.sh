
set -exuo pipefail

remote_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$remote_dir/common.sh"

rm /data/logs/hello-ui/* || true

logfile=$(get_caller_script)
start_log_file $logfile

mylog "check out source code from $project_path"
cd "$project_path"

checkout

check_status

kubectl scale deployment hello-ui --replicas=0 || true

sleep 3

kubectl delete svc hello-ui-svc || true

kubectl delete deployment hello-ui || true

kubectl delete rs   -l app=hello-ui || true
kubectl delete pods -l app=hello-ui || true
kubectl delete all  -l app=hello-ui || true

kubectl get deploy,svc | grep -E "hello-ui" || true

check_status


log_time