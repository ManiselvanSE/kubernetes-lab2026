#!/bin/bash

# CKA Practice Exam - Setup All Questions
# This script creates prerequisites for all 22 practice questions

set -e

echo "=================================="
echo "CKA Practice Exam Setup"
echo "=================================="
echo ""
echo "This will create all prerequisites for the 22 practice questions."
echo "Make sure you have:"
echo "  - kubectl configured"
echo "  - metrics-server installed"
echo "  - Helm installed"
echo ""
read -p "Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Question 1: HPA
echo ""
echo "Setting up Question 1: HPA..."
kubectl create namespace auto-scale --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment apache-server --image=nginx -n auto-scale --dry-run=client -o yaml | kubectl apply -f -
kubectl set resources deployment apache-server -n auto-scale --requests=cpu=100m,memory=128Mi --limits=cpu=200m,memory=256Mi
echo "✓ Question 1 setup complete"

# Question 2: Deployment + NodePort
echo ""
echo "Setting up Question 2: Deployment + NodePort..."
kubectl create namespace spline-reticulator --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment front-end --image=nginx -n spline-reticulator --dry-run=client -o yaml | kubectl apply -f -
echo "✓ Question 2 setup complete"

# Question 3: Sidecar
echo ""
echo "Setting up Question 3: Sidecar..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: synergy-leverager
spec:
  replicas: 1
  selector:
    matchLabels:
      app: synergy
  template:
    metadata:
      labels:
        app: synergy
    spec:
      containers:
      - name: synergy-leverager
        image: alpine:latest
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            echo "\$(date) - Synergy data" >> /var/log/synergy-leverager.log
            sleep 2
          done
EOF
echo "✓ Question 3 setup complete"

# Question 4: PriorityClass
echo ""
echo "Setting up Question 4: PriorityClass..."
kubectl create namespace priority --dry-run=client -o yaml | kubectl apply -f -
kubectl create priorityclass existing-priority --value=1000 --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment busybox-logger --image=busybox:stable -n priority --dry-run=client -o yaml | kubectl apply -f -
kubectl patch deployment busybox-logger -n priority -p '{"spec":{"template":{"spec":{"containers":[{"name":"busybox","command":["sh","-c","while true; do echo logging; sleep 5; done"]}]}}}}'
echo "✓ Question 4 setup complete"

# Question 5: StorageClass
echo ""
echo "Setting up Question 5: StorageClass..."
echo "No prerequisites needed - you'll create the StorageClass"
echo "✓ Question 5 setup complete"

# Question 6: ArgoCD Helm
echo ""
echo "Setting up Question 6: ArgoCD Helm..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/application-crd.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/applicationset-crd.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/appproject-crd.yaml
echo "✓ Question 6 setup complete"

# Question 7: MariaDB + PVC
echo ""
echo "Setting up Question 7: MariaDB + PVC..."
kubectl create namespace mariadb --dry-run=client -o yaml | kubectl apply -f -

# Create PV
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv
spec:
  capacity:
    storage: 250Mi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: standard
  hostPath:
    path: /mnt/mariadb-data
    type: DirectoryOrCreate
EOF

# Create deployment YAML file
cat <<EOF > ~/mariadb-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: mariadb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mariadb
  template:
    metadata:
      labels:
        app: mariadb
    spec:
      containers:
      - name: mariadb
        image: mariadb:latest
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "password123"
EOF

echo "✓ Question 7 setup complete (PV created, deployment YAML at ~/mariadb-deployment.yaml)"

# Question 8: Gateway API
echo ""
echo "Setting up Question 8: Gateway API..."
kubectl create namespace webapp --dry-run=client -o yaml | kubectl apply -f -

# Create deployment and service
kubectl create deployment web-app --image=nginx -n webapp --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deployment web-app --port=80 --name=web-service -n webapp --dry-run=client -o yaml | kubectl apply -f -

# Create TLS secret
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/tls.key -out /tmp/tls.crt \
  -subj "/CN=gateway.web.k8s.local" 2>/dev/null
kubectl create secret tls web-tls --key=/tmp/tls.key --cert=/tmp/tls.crt -n webapp --dry-run=client -o yaml | kubectl apply -f -
rm /tmp/tls.key /tmp/tls.crt

# Create existing Ingress
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: existing-ingress
  namespace: webapp
spec:
  rules:
  - host: example.web.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
EOF

echo "✓ Question 8 setup complete"

# Question 9: CNI Installation
echo ""
echo "Setting up Question 9: CNI Installation..."
echo "Note: This requires a cluster without CNI or with removable CNI"
echo "Skipping automated setup for CNI question"
echo "✓ Question 9 noted"

# Question 10: WordPress Resources
echo ""
echo "Setting up Question 10: WordPress Resources..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      initContainers:
      - name: init-db
        image: busybox:stable
        command: ['sh', '-c', 'echo Initializing; sleep 2']
      containers:
      - name: wordpress
        image: wordpress:latest
        env:
        - name: WORDPRESS_DB_HOST
          value: "mysql"
EOF
echo "✓ Question 10 setup complete"

# Question 11: cri-dockerd
echo ""
echo "Setting up Question 11: cri-dockerd..."
echo "Note: This requires downloading cri-dockerd package"
echo "Skipping automated download (platform-specific)"
echo "✓ Question 11 noted"

# Question 12: CRDs + JSONPath
echo ""
echo "Setting up Question 12: CRDs + JSONPath..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml
echo "✓ Question 12 setup complete"

# Question 13: Network Policy
echo ""
echo "Setting up Question 13: Network Policy..."
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment frontend --image=nginx -n frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment backend --image=nginx -n backend --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deployment backend --port=8080 --target-port=80 -n backend --dry-run=client -o yaml | kubectl apply -f -
echo "✓ Question 13 setup complete"

# Question 14: CoreDNS
echo ""
echo "Setting up Question 14: CoreDNS..."
mkdir -p /opt/course/16/
echo "✓ Question 14 setup complete (directory created)"

# Question 15: crictl
echo ""
echo "Setting up Question 15: crictl..."
kubectl create namespace project-tiger --dry-run=client -o yaml | kubectl apply -f -
mkdir -p /course/17/
mkdir -p /opt/course/17/
echo "✓ Question 15 setup complete (directories created)"

# Question 16: Network Policy Port
echo ""
echo "Setting up Question 16: Network Policy Port..."
kubectl create namespace foobar --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace internal-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace internal-ns kubernetes.io/metadata.name=internal-ns --overwrite
kubectl create deployment nginx --image=nginx -n foobar --dry-run=client -o yaml | kubectl apply -f -
echo "✓ Question 16 setup complete"

# Question 17: Count Nodes
echo ""
echo "Setting up Question 17: Count Nodes..."
mkdir -p /opt/KUSC00402/
echo "✓ Question 17 setup complete (directory created)"

# Question 18: NotReady Node
echo ""
echo "Setting up Question 18: NotReady Node..."
echo "Note: This requires stopping kubelet on a worker node"
echo "Skipping automated setup (requires multi-node cluster)"
echo "✓ Question 18 noted"

# Question 19: kubeadm Upgrade
echo ""
echo "Setting up Question 19: kubeadm Upgrade..."
echo "No prerequisites - follow upgrade procedure"
echo "✓ Question 19 noted"

# Question 20: TLS 1.3
echo ""
echo "Setting up Question 20: TLS 1.3..."
# Namespace created in Question 8
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: webapp
data:
  nginx.conf: |
    server {
      listen 443 ssl;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_certificate /etc/nginx/ssl/tls.crt;
      ssl_certificate_key /etc/nginx/ssl/tls.key;
      location / {
        root /usr/share/nginx/html;
      }
    }
EOF
echo "✓ Question 20 setup complete"

# Question 21: Ingress
echo ""
echo "Setting up Question 21: Ingress..."
kubectl create namespace sound-repeater --dry-run=client -o yaml | kubectl apply -f -
kubectl create deployment echo-server --image=ealen/echo-server -n sound-repeater --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deployment echo-server --port=8080 --target-port=80 -n sound-repeater --dry-run=client -o yaml | kubectl apply -f -
echo "✓ Question 21 setup complete"

# Question 22: Cluster Troubleshoot
echo ""
echo "Setting up Question 22: Cluster Troubleshoot..."
echo "Note: This requires intentionally breaking cluster components"
echo "Skipping automated setup (requires control plane access)"
echo "✓ Question 22 noted"

echo ""
echo "=================================="
echo "Setup Complete!"
echo "=================================="
echo ""
echo "All question prerequisites have been created."
echo "Run './verify-setup.sh' to verify everything is ready."
echo ""
echo "To start practicing:"
echo "  1. Read the question in CKA_COMPLETE_HANDS_ON_EXAM_GUIDE.md"
echo "  2. Attempt the solution"
echo "  3. Verify your answer"
echo "  4. Move to next question"
echo ""
echo "To clean up: ./cleanup-all.sh"
echo ""
