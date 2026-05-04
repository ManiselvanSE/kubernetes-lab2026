#!/bin/bash

# CKA Practice Exam - Cleanup All Resources

set -e

echo "=================================="
echo "CKA Practice Exam Cleanup"
echo "=================================="
echo ""
echo "This will DELETE all practice exam resources including:"
echo "  - All practice namespaces"
echo "  - PersistentVolumes"
echo "  - PriorityClasses"
echo "  - CRDs"
echo "  - Files in /opt/course/"
echo ""
read -p "Are you sure? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled"
    exit 1
fi

echo ""
echo "Deleting namespaces..."
kubectl delete namespace auto-scale --ignore-not-found=true
kubectl delete namespace spline-reticulator --ignore-not-found=true
kubectl delete namespace priority --ignore-not-found=true
kubectl delete namespace argocd --ignore-not-found=true
kubectl delete namespace mariadb --ignore-not-found=true
kubectl delete namespace webapp --ignore-not-found=true
kubectl delete namespace frontend --ignore-not-found=true
kubectl delete namespace backend --ignore-not-found=true
kubectl delete namespace project-tiger --ignore-not-found=true
kubectl delete namespace foobar --ignore-not-found=true
kubectl delete namespace internal-ns --ignore-not-found=true
kubectl delete namespace sound-repeater --ignore-not-found=true

echo ""
echo "Deleting deployments in default namespace..."
kubectl delete deployment synergy-leverager --ignore-not-found=true
kubectl delete deployment wordpress --ignore-not-found=true

echo ""
echo "Deleting PersistentVolumes..."
kubectl delete pv mariadb-pv --ignore-not-found=true

echo ""
echo "Deleting PriorityClasses..."
kubectl delete priorityclass existing-priority --ignore-not-found=true
kubectl delete priorityclass high-priority --ignore-not-found=true

echo ""
echo "Deleting StorageClasses..."
kubectl delete storageclass local-path --ignore-not-found=true

echo ""
echo "Cleaning up files..."
rm -f ~/mariadb-deployment.yaml
rm -f ~/argo-helm.yaml
sudo rm -rf /opt/course/ 2>/dev/null || true
sudo rm -rf /opt/KUSC00402/ 2>/dev/null || true
rm -rf /course/ 2>/dev/null || true

echo ""
echo "Cleanup complete!"
echo ""
