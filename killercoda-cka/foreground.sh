#!/bin/bash
# =============================================================================
# CKA PRACTICE - FOREGROUND (user sees this while waiting)
# =============================================================================
echo "Preparing CKA exam practice environment..."
echo ""

# Wait for background setup
echo "Setting up exam prerequisites (namespaces, deployments, etc.)..."
while [ ! -f /tmp/cka-prereqs-done ]; do
  sleep 2
  printf "."
done
echo " Done!"
echo ""

# Print clear summary
cat << 'BANNER'

================================================================================
  CKA EXAM PRACTICE - ENVIRONMENT READY
================================================================================

  IN THE EXAM, THESE ARE ALREADY DONE (you do NOT create them):
  -----------------------------------------------------------------------
  • Namespaces: auto-scale, spline-reticulator, priority, mariadb, argocd,
    webapp, frontend, backend, project-tiger, foobar, internal-ns, sound-repeater
  • Deployments: apache-server, front-end, synergy-leverager, busybox-logger,
    wordpress, web, echo-server, etc.
  • PV, PriorityClass, CRDs (ArgoCD, cert-manager), TLS secrets
  • Helm repo 'argo' added

  YOUR TASK - PRACTICE THESE (what you DO in the exam):
  -----------------------------------------------------------------------
  • Q1:  Create HPA + stabilizationWindowSeconds
  • Q2:  Add containerPort 80 + NodePort service
  • Q3:  Add sidecar container to deployment
  • Q4:  Create high-priority class + patch deployment
  • Q5:  Create StorageClass (WaitForFirstConsumer, default)
  • Q6:  helm template + apply ArgoCD
  • Q7:  Create PVC + deployment with PVC
  • Q8:  Create Gateway + HTTPRoute
  • Q10: Scale 0, add resources, scale 3
  • Q12: kubectl get crd | grep cert > files
  • Q14: Backup CoreDNS, add custom-domain
  • Q20: Edit ConfigMap TLSv1.3 only, rollout restart
  • Q21: Create Ingress for /echo

================================================================================

  View full task list:     cat ~/cka-practice-tasks.txt
  Reset and practice:      ./scripts/reset-and-practice.sh

================================================================================

BANNER

# Copy tasks to home if exists
[ -f "$(dirname "$0")/cka-practice-tasks.txt" ] && cp "$(dirname "$0")/cka-practice-tasks.txt" ~/ 2>/dev/null || true

echo "You can start practicing now. Good luck!"
