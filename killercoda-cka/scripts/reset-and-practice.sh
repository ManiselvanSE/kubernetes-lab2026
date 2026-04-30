#!/bin/bash
# =============================================================================
# CKA EXAM PRACTICE - RESET & PRACTICE AGAIN
# =============================================================================
# Run this when you want to PRACTICE AGAIN with a fresh environment.
# This script:
#   1. Removes what YOU created during practice (HPAs, services, policies, etc.)
#   2. Restores prerequisites that may have been modified
#   3. Re-runs the setup to ensure a clean state
#   4. Prints your practice tasks clearly
#
# Run: ./scripts/reset-and-practice.sh
# Or:  bash scripts/reset-and-practice.sh
# =============================================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "================================================================================
  CKA PRACTICE - RESET AND PRACTICE AGAIN
================================================================================
"
echo "[1/3] Removing resources YOU created during practice..."
echo ""

# Q1 - Remove HPA (keep ns and deploy)
kubectl delete hpa apache-server -n auto-scale 2>/dev/null || true

# Q2 - Remove service (keep ns and deploy)
kubectl delete svc front-end-svc -n spline-reticulator 2>/dev/null || true

# Q3 - Restore deployment without sidecar
kubectl delete deployment synergy-leverager 2>/dev/null || true
kubectl apply -f - <<'YAML' 2>/dev/null || true
apiVersion: apps/v1
kind: Deployment
metadata:
  name: synergy-leverager
  labels:
    app: synergy-leverager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: synergy-leverager
  template:
    metadata:
      labels:
        app: synergy-leverager
    spec:
      containers:
      - name: synergy-leverager
        image: alpine:latest
        command: ["/bin/sh", "-c", "while true; do echo logging >> /var/log/synergy-leverager.log; sleep 1; done"]
        volumeMounts:
        - name: data
          mountPath: /var/log
      volumes:
      - name: data
        emptyDir: {}
YAML

# Q4 - Remove high-priority if created, remove from deployment
kubectl delete priorityclass high-priority 2>/dev/null || true
kubectl patch deployment busybox-logger -n priority --type=json -p='[{"op":"remove","path":"/spec/template/spec/priorityClassName"}]' 2>/dev/null || true

# Q5 - Remove StorageClass local-path
kubectl delete sc local-path 2>/dev/null || true

# Q6 - Remove ArgoCD resources (keep ns and CRDs)
kubectl delete -f ~/argo-helm.yaml 2>/dev/null || true
rm -f ~/argo-helm.yaml 2>/dev/null || true

# Q7 - Remove PVC and MariaDB deployment
kubectl delete deployment mariadb -n mariadb 2>/dev/null || true
kubectl delete pvc mariadb -n mariadb 2>/dev/null || true

# Q8 - Remove Gateway and HTTPRoute
kubectl delete gateway web-gateway -n webapp 2>/dev/null || true
kubectl delete httproute web-route -n webapp 2>/dev/null || true

# Q10 - Restore wordpress (delete and let setup recreate without resources)
kubectl delete deployment wordpress 2>/dev/null || true

# Q12 - Remove output files
rm -f custom-crd.txt cert-manager-subject.txt 2>/dev/null || true

# Q13 - Remove NetworkPolicies
kubectl delete networkpolicy -n backend --all 2>/dev/null || true

# Q14 - Restore CoreDNS from backup if exists
if [ -f /opt/course/16/coredns_backup.yaml ]; then
  kubectl apply -f /opt/course/16/coredns_backup.yaml 2>/dev/null || true
  kubectl -n kube-system rollout restart deployment coredns 2>/dev/null || true
fi

# Q15 - Remove pod and clear files
kubectl delete pod tigers-reunite -n project-tiger 2>/dev/null || true
rm -f /opt/course/17/pod-container.txt /opt/course/17/pod-container.log /course/17/pod-container.txt 2>/dev/null || true

# Q16 - Remove NetworkPolicy
kubectl delete networkpolicy allow-port-from-namespace -n foobar 2>/dev/null || true

# Q17 - Clear output file
rm -f /opt/KUSC00402/kusc00402.txt 2>/dev/null || true

# Q20 - Will be restored by setup (ConfigMap has TLSv1.2 TLSv1.3)

# Q21 - Remove Ingress
kubectl delete ingress echo-ingress -n sound-repeater 2>/dev/null || true

echo "[2/3] Re-running prerequisites setup..."
echo ""
"$SCRIPT_DIR/setup-cka-prerequisites.sh" 2>/dev/null || true

echo ""
echo "[3/3] Done! Your practice tasks:"
echo ""
echo "================================================================================
  WHAT TO PRACTICE (YOUR EXAM TASKS)
================================================================================
"
cat "$SCRIPT_DIR/../cka-practice-tasks.txt" 2>/dev/null || cat ~/cka-practice-tasks.txt 2>/dev/null || echo "Run setup-cka-prerequisites.sh first for full task list."
echo ""
echo "--------------------------------------------------------------------------------
  QUICK REFERENCE - Run these to practice:
--------------------------------------------------------------------------------
  Q1:  kubectl autoscale + patch stabilizationWindowSeconds
  Q2:  kubectl set container-port + create service nodeport
  Q3:  Edit deploy: add sidecar container (busybox:stable)
  Q4:  Create priorityclass + patch busybox-logger
  Q5:  Create StorageClass local-path (WaitForFirstConsumer, default)
  Q6:  helm template argocd argo/argo-cd --set crds.install=false > ~/argo-helm.yaml
  Q7:  Create PVC + Deployment with PVC
  Q8:  Create Gateway + HTTPRoute
  Q10: Scale 0, add resources, scale 3
  Q12: kubectl get crd | grep cert > custom-crd.txt
  Q14: Backup CoreDNS, add custom-domain, restart
  Q20: Edit ConfigMap ssl_protocols TLSv1.3, rollout restart
  Q21: Create Ingress for /echo
--------------------------------------------------------------------------------
"
echo "Environment reset. Practice your tasks now!"
echo ""
