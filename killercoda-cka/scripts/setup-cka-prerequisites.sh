#!/bin/bash
# =============================================================================
# CKA EXAM PRACTICE - PREREQUISITES SETUP SCRIPT
# =============================================================================
# This script creates EVERYTHING that is ALREADY IN THE EXAM.
# Run this once at the start. Your job is to practice ONLY your tasks.
#
# TO PRACTICE AGAIN: Run ./scripts/reset-and-practice.sh
# =============================================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/../cka-practice-tasks.txt"
LOG_FILE="/tmp/cka-setup.log"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

# -----------------------------------------------------------------------------
# HELPER: Create resource if not exists
# -----------------------------------------------------------------------------
apply_if_missing() {
  local kind=$1 name=$2 ns=$3
  if [ -n "$ns" ]; then
    kubectl get "$kind" "$name" -n "$ns" &>/dev/null || kubectl apply -f - -n "$ns" &>/dev/null || true
  else
    kubectl get "$kind" "$name" &>/dev/null || kubectl apply -f - &>/dev/null || true
  fi
}

log "=== CKA PRACTICE ENVIRONMENT - EXAM PREREQUISITES SETUP ==="

# -----------------------------------------------------------------------------
# Q1: HPA - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q1 (HPA) prerequisites..."
kubectl create namespace auto-scale 2>/dev/null || true
kubectl create deployment apache-server --image=nginx -n auto-scale 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q2: Deployment + NodePort - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q2 (Deployment + NodePort) prerequisites..."
kubectl create namespace spline-reticulator 2>/dev/null || true
kubectl create deployment front-end --image=nginx -n spline-reticulator 2>/dev/null || true
# Note: containerPort 80 is YOUR task - we create deploy without it on purpose for practice

# -----------------------------------------------------------------------------
# Q3: Sidecar - Prerequisites (deployment WITHOUT sidecar - you add it)
# -----------------------------------------------------------------------------
log "Setting up Q3 (Sidecar) prerequisites..."
cat <<'YAML' | kubectl apply -f -
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

# -----------------------------------------------------------------------------
# Q4: PriorityClass - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q4 (PriorityClass) prerequisites..."
kubectl create namespace priority 2>/dev/null || true
kubectl create priorityclass high-priority-existing --value=1000 \
  --description="Existing highest - for exam simulation" --preemption-policy=Never 2>/dev/null || true
kubectl create deployment busybox-logger --image=busybox:stable -n priority 2>/dev/null || true
kubectl create deployment low-priority-app --image=nginx -n priority 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q5: StorageClass - Prerequisites (provisioner may exist; we create SC for practice)
# -----------------------------------------------------------------------------
log "Setting up Q5 (StorageClass) prerequisites..."
# Check if local-path provisioner exists; if not, skip - user can still create SC
kubectl get sc 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q6: ArgoCD Helm - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q6 (ArgoCD Helm) prerequisites..."
kubectl create namespace argocd 2>/dev/null || true
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/application-crd.yaml 2>/dev/null || true
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/applicationset-crd.yaml 2>/dev/null || true
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds/appproject-crd.yaml 2>/dev/null || true
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
helm repo update 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q7: MariaDB + PVC - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q7 (MariaDB + PVC) prerequisites..."
kubectl create namespace mariadb 2>/dev/null || true
mkdir -p /tmp/mariadb
cat <<'YAML' | kubectl apply -f -
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
    path: /tmp/mariadb
YAML

# -----------------------------------------------------------------------------
# Q8: Gateway API - Prerequisites (simplified - GatewayClass, web app, TLS)
# -----------------------------------------------------------------------------
log "Setting up Q8 (Gateway API) prerequisites..."
kubectl create namespace webapp 2>/dev/null || true
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml 2>/dev/null || true
# Web app
kubectl create deployment web --image=nginx -n webapp 2>/dev/null || true
kubectl create service clusterip web-service --tcp=80:80 -n webapp 2>/dev/null || true
# TLS secret
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/CN=gateway.web.k8s.local" \
  -keyout /tmp/tls.key -out /tmp/tls.crt 2>/dev/null
kubectl create secret tls web-tls --cert=/tmp/tls.crt --key=/tmp/tls.key -n webapp 2>/dev/null || true
# Nginx Gateway Fabric (if available)
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.6.2/deploy/crds.yaml 2>/dev/null || true
kubectl apply -f https://raw.githubusercontent.com/nginxinc/nginx-gateway-fabric/v1.6.2/deploy/default/deploy.yaml 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q10: WordPress Resources - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q10 (WordPress) prerequisites..."
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app.kubernetes.io/name: wordpress
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: wordpress
  template:
    metadata:
      labels:
        app.kubernetes.io/name: wordpress
    spec:
      initContainers:
      - name: init-wordpress
        image: busybox:1.28
        command: ['sh', '-c', 'echo initializing wordpress...']
      containers:
      - name: wordpress
        image: busybox:1.28
        command: ['sh', '-c', 'echo WordPress is running! && sleep 3600']
YAML

# -----------------------------------------------------------------------------
# Q11: cri-dockerd - Prerequisites (download .deb to home)
# -----------------------------------------------------------------------------
log "Setting up Q11 (cri-dockerd) prerequisites..."
cd ~
wget -q https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.17/cri-dockerd_0.3.17.3-0.ubuntu-focal_amd64.deb -O ~/cri-dockerd_0.3.17.3-0.ubuntu-focal_amd64.deb 2>/dev/null || \
wget -q https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.1/cri-dockerd_0.3.1.3-0.ubuntu-jammy_amd64.deb -O ~/cri-dockerd_0.3.1.3-0.ubuntu-jammy_amd64.deb 2>/dev/null || \
touch ~/cri-dockerd_placeholder.deb  # placeholder if download fails
ls -la ~/*.deb 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q12: Cert-Manager CRDs - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q12 (Cert-Manager CRDs) prerequisites..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q13: Network Policy - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q13 (Network Policy) prerequisites..."
kubectl create namespace frontend 2>/dev/null || true
kubectl create namespace backend 2>/dev/null || true
kubectl create deployment frontend --image=nginx -n frontend 2>/dev/null || true
kubectl create deployment backend --image=nginx -n backend 2>/dev/null || true
kubectl expose deployment backend --port=8080 -n backend 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q15: crictl - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q15 (crictl) prerequisites..."
kubectl create namespace project-tiger 2>/dev/null || true
mkdir -p /opt/course/17 /course/17 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q16: Network Policy Port - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q16 (Network Policy) prerequisites..."
kubectl create namespace foobar 2>/dev/null || true
kubectl create namespace internal-ns 2>/dev/null || true
kubectl label namespace internal-ns kubernetes.io/metadata.name=internal-ns 2>/dev/null || true
kubectl run nginx --image=nginx -n foobar 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q17: Nodes - Prerequisites (add NoSchedule taint to one node if 2-node)
# -----------------------------------------------------------------------------
log "Setting up Q17 (Nodes) prerequisites..."
if kubectl get nodes -o name | grep -q node; then
  kubectl taint nodes node01 dedicated=exam:NoSchedule 2>/dev/null || true
fi
mkdir -p /opt/KUSC00402 2>/dev/null || true

# -----------------------------------------------------------------------------
# Q20: TLS ConfigMap - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q20 (TLS ConfigMap) prerequisites..."
kubectl create namespace webapp 2>/dev/null || true
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/CN=webapp.local" \
  -keyout /tmp/tls-webapp.key -out /tmp/tls-webapp.crt 2>/dev/null
kubectl create secret tls web-tls --cert=/tmp/tls-webapp.crt --key=/tmp/tls-webapp.key -n webapp 2>/dev/null || true
cat <<'YAML' | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: webapp
data:
  nginx.conf: |
    server {
      listen 443 ssl;
      server_name webapp.local;
      ssl_certificate /etc/nginx/tls/tls.crt;
      ssl_certificate_key /etc/nginx/tls/tls.key;
      ssl_protocols TLSv1.2 TLSv1.3;
      location / {
        return 200 "Hello Secure World!";
      }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: webapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      volumes:
      - name: config-vol
        configMap:
          name: nginx-config
      - name: tls-vol
        secret:
          secretName: web-tls
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 443
        volumeMounts:
        - name: config-vol
          mountPath: /etc/nginx/conf.d
        - name: tls-vol
          mountPath: /etc/nginx/tls
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-svc
  namespace: webapp
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
  - port: 443
    targetPort: 443
    nodePort: 30443
YAML

# -----------------------------------------------------------------------------
# Q21: Ingress - Prerequisites
# -----------------------------------------------------------------------------
log "Setting up Q21 (Ingress) prerequisites..."
kubectl create namespace sound-repeater 2>/dev/null || true
cat <<'YAML' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server
  namespace: sound-repeater
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo-server
  template:
    metadata:
      labels:
        app: echo-server
    spec:
      containers:
      - name: echo
        image: hashicorp/http-echo
        args: ["-text=echo"]
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: echo-server
  namespace: sound-repeater
spec:
  selector:
    app: echo-server
  ports:
  - name: http
    port: 8080
    targetPort: 5678
YAML
# Install Ingress controller if not present
kubectl get svc -n ingress-nginx &>/dev/null || kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.1/deploy/static/provider/cloud/deploy.yaml 2>/dev/null || true

# -----------------------------------------------------------------------------
# CoreDNS path for Q14
# -----------------------------------------------------------------------------
mkdir -p /opt/course/16 2>/dev/null || true

log "=== PREREQUISITES SETUP COMPLETE ==="
touch /tmp/cka-prereqs-done

# -----------------------------------------------------------------------------
# Generate PRACTICE TASKS file (what's in exam vs what YOU do)
# -----------------------------------------------------------------------------
cat > "$OUTPUT_FILE" << 'TASKS'
================================================================================
CKA EXAM PRACTICE - TASK REFERENCE
================================================================================
View this anytime: cat ~/cka-practice-tasks.txt (or cka-practice-tasks.txt in scenario root)
Run "reset-and-practice.sh" to reset and practice again.
================================================================================

Q1 - HPA
--------
EXAM ALREADY HAS: ns auto-scale, deploy apache-server
YOUR TASK:
  1. kubectl autoscale deployment apache-server -n auto-scale --cpu-percent=50 --min=1 --max=4
  2. Add spec.behavior.scaleDown.stabilizationWindowSeconds: 30 (patch or edit)
  3. Verify: kubectl get hpa -n auto-scale
--------------------------------------------------------------------------------

Q2 - Deployment + NodePort
--------------------------
EXAM ALREADY HAS: ns spline-reticulator, deploy front-end
YOUR TASK:
  1. kubectl set container-port deployment/front-end nginx=80 -n spline-reticulator
  2. kubectl create service nodeport front-end-svc -n spline-reticulator --tcp=80:80
  3. Verify: kubectl get svc,deploy -n spline-reticulator
--------------------------------------------------------------------------------

Q3 - Sidecar
-----------
EXAM ALREADY HAS: deploy synergy-leverager (main container only)
YOUR TASK:
  1. Edit deployment: ADD sidecar container (busybox:stable), command: tail -n+1 -f /var/log/synergy-leverager.log
  2. Add volumeMount /var/log to sidecar (volume "data" emptyDir already exists)
  3. Verify: kubectl exec -it <pod> -c sidecar -- tail -f /var/log/synergy-leverager.log
--------------------------------------------------------------------------------

Q4 - PriorityClass
-----------------
EXAM ALREADY HAS: ns priority, deploy busybox-logger, other deploys, PriorityClass value 1000
YOUR TASK:
  1. kubectl create priorityclass high-priority --value=999 --preemption-policy=PreemptLowerPriority
  2. kubectl patch deployment busybox-logger -n priority -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'
  3. Verify: other pods in priority ns evicted
--------------------------------------------------------------------------------

Q5 - StorageClass
----------------
EXAM ALREADY HAS: provisioner rancher.io/local-path (may need install)
YOUR TASK:
  1. Create StorageClass local-path, provisioner rancher.io/local-path
  2. volumeBindingMode: WaitForFirstConsumer
  3. storageclass.kubernetes.io/is-default-class: "true"
  4. DO NOT modify existing Deployments or PVCs
--------------------------------------------------------------------------------

Q6 - ArgoCD Helm
---------------
EXAM ALREADY HAS: ns argocd, ArgoCD CRDs, helm
YOUR TASK:
  1. helm repo add argo https://argoproj.github.io/argo-helm && helm repo update
  2. helm template argocd argo/argo-cd --version 7.7.3 --namespace argocd --set crds.install=false > ~/argo-helm.yaml
  3. kubectl apply -f ~/argo-helm.yaml
--------------------------------------------------------------------------------

Q7 - MariaDB + PVC
-----------------
EXAM ALREADY HAS: ns mariadb, PV (250Mi, storageClassName standard)
YOUR TASK:
  1. Create PVC mariadb (250Mi, storageClassName standard)
  2. Create deployment with volume persistentVolumeClaim claimName: mariadb, mountPath /var/lib/mysql
  3. kubectl apply -f deployment
--------------------------------------------------------------------------------

Q8 - Gateway API
---------------
EXAM ALREADY HAS: GatewayClass nginx, web app, web-service, TLS secret web-tls
YOUR TASK:
  1. Create Gateway web-gateway: gatewayClassName nginx, hostname gateway.web.k8s.local, HTTPS listener, cert ref web-tls
  2. Create HTTPRoute web-route: parentRef web-gateway, hostname gateway.web.k8s.local, backendRef web-service:80
--------------------------------------------------------------------------------

Q9 - CNI
--------
EXAM ALREADY HAS: Cluster (may have CNI; for practice apply Calico)
YOUR TASK:
  1. kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
  OR Flannel v0.26.1
--------------------------------------------------------------------------------

Q10 - WordPress Resources
------------------------
EXAM ALREADY HAS: deploy wordpress (init + main, no resources)
YOUR TASK:
  1. kubectl scale deployment wordpress --replicas=0
  2. Edit: add resources.requests (same for init + main), e.g. cpu 200m, memory 128Mi
  3. kubectl scale deployment wordpress --replicas=3
  4. Verify all pods Running
--------------------------------------------------------------------------------

Q11 - cri-dockerd
-----------------
EXAM ALREADY HAS: ~/cri-dockerd_*.deb
YOUR TASK:
  1. sudo dpkg -i ~/cri-dockerd_*.deb
  2. sudo systemctl enable cri-docker.socket && sudo systemctl start cri-docker.socket
  3. Sysctl: net.bridge.bridge-nf-call-iptables=1, net.ipv4.ip_forward=1, net.ipv6.conf.all.forwarding=1
--------------------------------------------------------------------------------

Q12 - CRDs JSONPath
-------------------
EXAM ALREADY HAS: cert-manager CRDs
YOUR TASK:
  1. kubectl get crd | grep cert > custom-crd.txt
  2. kubectl get crd certificates.cert-manager.io -o jsonpath='{.spec.versions[*].schema.openAPIV3Schema.properties.spec.properties.subject}' > cert-manager-subject.txt
--------------------------------------------------------------------------------

Q13 - Network Policy (least permissive)
--------------------------------------
EXAM ALREADY HAS: ns frontend, backend, deploy frontend, backend
YOUR TASK:
  1. Apply policy with podSelector + namespaceSelector only (no ipBlock) - Policy 2
  2. Ingress from frontend ns + app=frontend to backend:8080
--------------------------------------------------------------------------------

Q14 - CoreDNS
-------------
EXAM ALREADY HAS: CoreDNS running
YOUR TASK:
  1. kubectl -n kube-system get configmap coredns -o yaml > /opt/course/16/coredns_backup.yaml
  2. Edit Corefile: kubernetes custom-domain cluster.local ...
  3. kubectl -n kube-system rollout restart deployment coredns
  4. Test: nslookup kubernetes.default.svc.cluster.local and kubernetes.default.svc.custom-domain
--------------------------------------------------------------------------------

Q15 - crictl
-----------
EXAM ALREADY HAS: ns project-tiger
YOUR TASK:
  1. Create pod tigers-reunite (httpd:2-alpine), labels pod=container, container=pod
  2. kubectl get pod -o wide, SSH to node
  3. crictl ps -a | grep tigers-reunite, crictl inspect <id>, crictl logs <id>
  4. Write container ID + runtimeType to file, logs to file
--------------------------------------------------------------------------------

Q16 - Network Policy Port
-------------------------
EXAM ALREADY HAS: ns foobar, internal-ns, nginx in foobar
YOUR TASK:
  1. Create NetworkPolicy allow-port-from-namespace in foobar
  2. Ingress: from internal-ns only, port 9000
--------------------------------------------------------------------------------

Q17 - Count Nodes
-----------------
EXAM ALREADY HAS: Cluster with some NoSchedule taints
YOUR TASK:
  1. kubectl describe nodes | grep -i taint
  2. Count Ready nodes WITHOUT NoSchedule taint
  3. echo "<number>" > /opt/KUSC00402/kusc00402.txt
--------------------------------------------------------------------------------

Q18 - Node NotReady
-------------------
EXAM ALREADY HAS: 2-node cluster, one node NotReady
YOUR TASK:
  1. SSH to NotReady node
  2. sudo systemctl start kubelet && sudo systemctl enable kubelet
--------------------------------------------------------------------------------

Q19 - kubeadm Upgrade
---------------------
EXAM ALREADY HAS: kubeadm cluster
YOUR TASK:
  1. kubectl drain controlplane --ignore-daemonsets --delete-emptydir-data
  2. SSH to master, upgrade kubeadm/kubelet/kubectl to specified version
  3. kubeadm upgrade apply vX.Y.Z, systemctl restart kubelet
  4. kubectl uncordon controlplane
--------------------------------------------------------------------------------

Q20 - TLS 1.3 Only
------------------
EXAM ALREADY HAS: ConfigMap nginx-config (TLSv1.2 TLSv1.3), deploy webapp, TLS secret
YOUR TASK:
  1. Edit ConfigMap: ssl_protocols TLSv1.3 only
  2. kubectl rollout restart deployment webapp -n webapp
  3. Verify: curl -k --tls-max 1.2 FAILS, curl -k --tls-max 1.3 SUCCEEDS
--------------------------------------------------------------------------------

Q21 - Ingress
-------------
EXAM ALREADY HAS: ns sound-repeater, deploy echo-server, svc echo-server
YOUR TASK:
  1. Create Ingress: host example.org, path /echo, backend echo-server:8080
  2. Add hosts: echo "127.0.0.1 example.org" >> /etc/hosts
  3. curl -o /dev/null -s -w "%{http_code}\n" http://example.org/echo -> 200
--------------------------------------------------------------------------------

Q22 - Cluster Troubleshoot
--------------------------
EXAM ALREADY HAS: Broken cluster (etcd/kube-apiserver)
YOUR TASK:
  1. cd /etc/kubernetes/manifests/, check etcd.yaml, kube-apiserver.yaml
  2. Fix wrong args (--etcd-servers, cert paths)
  3. systemctl restart kubelet
================================================================================
TASKS

cp "$OUTPUT_FILE" ~/cka-practice-tasks.txt 2>/dev/null || true
log "Practice tasks saved to: $OUTPUT_FILE and ~/cka-practice-tasks.txt"
