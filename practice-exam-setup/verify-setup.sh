#!/bin/bash

# CKA Practice Exam - Verify Setup

echo "=================================="
echo "CKA Practice Exam Setup Verification"
echo "=================================="
echo ""

PASS=0
FAIL=0

check() {
    local name=$1
    local command=$2

    if eval "$command" &>/dev/null; then
        echo "✓ $name"
        ((PASS++))
    else
        echo "✗ $name"
        ((FAIL++))
    fi
}

# Question 1: HPA
echo "Question 1: HPA"
check "Namespace auto-scale exists" "kubectl get namespace auto-scale"
check "Deployment apache-server exists" "kubectl get deployment apache-server -n auto-scale"
check "Deployment has resource requests" "kubectl get deployment apache-server -n auto-scale -o yaml | grep -q 'requests:'"
echo ""

# Question 2: Deployment + NodePort
echo "Question 2: Deployment + NodePort"
check "Namespace spline-reticulator exists" "kubectl get namespace spline-reticulator"
check "Deployment front-end exists" "kubectl get deployment front-end -n spline-reticulator"
echo ""

# Question 3: Sidecar
echo "Question 3: Sidecar"
check "Deployment synergy-leverager exists" "kubectl get deployment synergy-leverager"
echo ""

# Question 4: PriorityClass
echo "Question 4: PriorityClass"
check "Namespace priority exists" "kubectl get namespace priority"
check "Deployment busybox-logger exists" "kubectl get deployment busybox-logger -n priority"
check "PriorityClass existing-priority exists" "kubectl get priorityclass existing-priority"
echo ""

# Question 6: ArgoCD Helm
echo "Question 6: ArgoCD Helm"
check "Namespace argocd exists" "kubectl get namespace argocd"
check "ArgoCD CRDs installed" "kubectl get crd applications.argoproj.io"
echo ""

# Question 7: MariaDB + PVC
echo "Question 7: MariaDB + PVC"
check "Namespace mariadb exists" "kubectl get namespace mariadb"
check "PV mariadb-pv exists" "kubectl get pv mariadb-pv"
check "Deployment YAML file exists" "test -f ~/mariadb-deployment.yaml"
echo ""

# Question 8: Gateway API
echo "Question 8: Gateway API"
check "Namespace webapp exists" "kubectl get namespace webapp"
check "Service web-service exists" "kubectl get service web-service -n webapp"
check "TLS secret web-tls exists" "kubectl get secret web-tls -n webapp"
echo ""

# Question 10: WordPress
echo "Question 10: WordPress Resources"
check "Deployment wordpress exists" "kubectl get deployment wordpress"
echo ""

# Question 12: CRDs
echo "Question 12: CRDs + JSONPath"
check "cert-manager CRDs installed" "kubectl get crd certificates.cert-manager.io"
echo ""

# Question 13: Network Policy
echo "Question 13: Network Policy"
check "Namespace frontend exists" "kubectl get namespace frontend"
check "Namespace backend exists" "kubectl get namespace backend"
check "Deployment frontend exists" "kubectl get deployment frontend -n frontend"
check "Deployment backend exists" "kubectl get deployment backend -n backend"
echo ""

# Question 14: CoreDNS
echo "Question 14: CoreDNS"
check "Directory /opt/course/16/ exists" "test -d /opt/course/16/"
echo ""

# Question 15: crictl
echo "Question 15: crictl"
check "Namespace project-tiger exists" "kubectl get namespace project-tiger"
check "Directory /course/17/ exists" "test -d /course/17/"
check "Directory /opt/course/17/ exists" "test -d /opt/course/17/"
echo ""

# Question 16: Network Policy Port
echo "Question 16: Network Policy Port"
check "Namespace foobar exists" "kubectl get namespace foobar"
check "Namespace internal-ns exists" "kubectl get namespace internal-ns"
check "Deployment nginx exists in foobar" "kubectl get deployment nginx -n foobar"
echo ""

# Question 17: Count Nodes
echo "Question 17: Count Nodes"
check "Directory /opt/KUSC00402/ exists" "test -d /opt/KUSC00402/"
echo ""

# Question 20: TLS 1.3
echo "Question 20: TLS 1.3"
check "ConfigMap nginx-config exists" "kubectl get configmap nginx-config -n webapp"
echo ""

# Question 21: Ingress
echo "Question 21: Ingress"
check "Namespace sound-repeater exists" "kubectl get namespace sound-repeater"
check "Deployment echo-server exists" "kubectl get deployment echo-server -n sound-repeater"
check "Service echo-server exists" "kubectl get service echo-server -n sound-repeater"
echo ""

# System checks
echo "System Requirements"
check "kubectl installed" "which kubectl"
check "kubectl configured" "kubectl cluster-info"
check "metrics-server running" "kubectl get deployment metrics-server -n kube-system"
check "Helm installed" "which helm"
echo ""

echo "=================================="
echo "Verification Summary"
echo "=================================="
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "All checks passed! ✓"
    echo "You're ready to practice!"
else
    echo "Some checks failed. Review the output above."
    echo "Run './setup-all-questions.sh' to set up missing prerequisites."
fi
echo ""
