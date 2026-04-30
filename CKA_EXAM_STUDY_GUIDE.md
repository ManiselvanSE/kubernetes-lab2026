# CKA Exam Practice Study Guide

Based on your practice document, here’s what to focus on: **what to learn**, **what’s pre-set in the exam**, and **how to approach each question**.

---

## What’s Already Set Up in the Exam (Prerequisites)

You typically **don’t** need to create these during the exam:

| Component | Status in Exam |
|-----------|----------------|
| **Namespaces** (mariadb, argocd, priority, webapp, spline-reticulator, etc.) | Already exist |
| **ArgoCD CRDs** | Pre-installed |
| **Cert-Manager CRDs** | Pre-installed |
| **GatewayClass (nginx)** | Installed |
| **Ingress & web app** (Gateway API Q8) | Already present |
| **TLS secrets** (e.g., web-tls) | Already present |
| **PersistentVolume** (MariaDB Q7) | Already retained |
| **Deployments** (front-end, synergy-leverager, busybox-logger, wordpress, etc.) | Already exist |
| **cri-dockerd package** | Available in home directory (`~/cri-dockerd_*.deb`) |
| **Kind/minikube cluster** | Provided, ready to use |
| **Documentation** | Accessible via browser during exam |

**Important:** For local practice you need to create namespaces, PVs, ingress, etc., but in the exam they are usually provided.

---

## What to Learn (Core Concepts by Topic)

### 1. **Autoscaling**
- HPA: `kubectl autoscale deployment <name> --cpu-percent=50 --min=1 --max=4 -n <ns>`
- Edit HPA for `spec.behavior.scaleDown.stabilizationWindowSeconds`
- [ docs: Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

### 2. **Services & Networking**
- Expose deployment: `containerPort`, `kubectl set container-port deployment/front-end nginx=80`
- NodePort Service: `kubectl create service nodeport <name> --tcp=80 --dry-run=client -o yaml`
- [ docs: Service](https://kubernetes.io/docs/concepts/services-networking/service/)

### 3. **Sidecar Containers**
- Shared volume (`emptyDir`) between main and sidecar
- `volumeMounts` on both containers
- [ docs: Sidecar Containers](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/)

### 4. **Priority Classes**
- `kubectl create priorityclass <name> --value=999 --description="..."`
- Patch deployment: `kubectl patch deployment <name> -n <ns> --type='merge' -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'`
- [ docs: kubectl patch](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_patch/)

### 5. **Storage**
- StorageClass: `provisioner`, `volumeBindingMode: WaitForFirstConsumer`
- Default StorageClass: `storageclass.kubernetes.io/is-default-class: "true"`
- PVC + Deployment `volumes.persistentVolumeClaim`
- [ docs: Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)

### 6. **Helm**
- Add repo: `helm repo add argo https://argoproj.github.io/argo-helm`
- Template: `helm template argocd argo/argo-cd --version 7.7.3 --namespace argocd --set crds.install=false > ~/argo-helm.yaml`

### 7. **Gateway API (Migration from Ingress)**
- Gateway resource with `gatewayClassName`, listeners, TLS
- HTTPRoute with `parentRefs`, `hostnames`, `rules`, `backendRefs`
- [ docs: Gateway API](https://gateway-api.sigs.k8s.io/)

### 8. **CNI**
- Flannel or Calico (Calico preferred for network policies)
- Apply manifest from official releases (e.g. Calico v3.28.2)

### 9. **Resource Management**
- `resources.requests` and `resources.limits` for containers and initContainers
- Scale down to 0 before changing requests: `kubectl scale deployment wordpress --replicas=0`
- Same requests for main and init containers as required

### 10. **Cluster Setup (cri-dockerd & sysctl)**
- `dpkg -i ~/cri-dockerd_*.deb`
- `systemctl enable cri-docker.socket && systemctl start cri-docker.socket`
- Sysctl: `net.bridge.bridge-nf-call-iptables=1`, `net.ipv6.conf.all.forwarding=1`, `net.ipv4.ip_forward=1`

### 11. **CRDs & JSONPath**
- `kubectl get crd | grep cert > custom-crd.txt`
- `kubectl get crd certificates.cert-manager.io -o jsonpath='{.spec.versions[*].schema.openAPIV3Schema.properties.spec.properties.subject}' > cert-manager-subject.txt`

### 12. **Network Policies**
- Least permissive: podSelector + namespaceSelector (no ipBlock unless needed)
- Ingress/Egress rules, `ports`, `from` with selectors

### 13. **CoreDNS**
- Backup: `kubectl -n kube-system get configmap coredns -o yaml > /opt/course/16/coredns_backup.yaml`
- Add custom domain in Corefile: `kubernetes custom-domain cluster.local ...`
- Restart: `kubectl -n kube-system rollout restart deployment coredns`

### 14. **Node & crictl**
- `crictl ps -a | grep <pod-name>`
- `crictl inspect <container-id>` for `runtimeType`
- `crictl logs <container-id>`

### 15. **TLS & ConfigMaps**
- Edit nginx ConfigMap: `ssl_protocols TLSv1.3` (remove TLSv1.2)
- `kubectl rollout restart deployment <name>` after ConfigMap change
- Verify: `curl -k --tls-max 1.2` (fail) vs `curl -k --tls-max 1.3` (success)

### 16. **Troubleshooting**
- Node NotReady: SSH to node → `systemctl start kubelet` + `systemctl enable kubelet`
- Cluster down: Check `/etc/kubernetes/manifests/` (etcd, api-server) → fix YAML → `systemctl restart kubelet`
- Count schedulable nodes: `kubectl describe nodes` → exclude NoSchedule taints

### 17. **kubeadm Upgrade**
- Drain: `kubectl drain controlplane --ignore-daemonsets --delete-emptydir-data`
- [ docs: kubeadm upgrade](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

### 18. **Ingress**
- Ingress rules, host, path, `pathType: Prefix`
- Annotation: `nginx.ingress.kubernetes.io/rewrite-target: /`

---

## How to Approach Each Question (Step-by-Step)

### General Workflow for Every Question

1. **Switch context** – Confirm you’re on the right cluster/context.
2. **Verify prerequisites** – Check namespaces, deployments, services, etc.
3. **Use docs** – Open the relevant Kubernetes docs and skim the structure (YAML, fields, examples).
4. **Dry-run when possible** – `kubectl ... --dry-run=client -o yaml` to generate manifests.
5. **Apply and verify** – `kubectl get`, `kubectl describe`, `kubectl logs`, `curl`, etc.

---

## Question-by-Question Focus

| # | Topic | Main Skill | Key Commands |
|---|-------|------------|--------------|
| 1 | HPA | Create and edit HPA, stabilization | `kubectl autoscale`, edit `behavior.scaleDown.stabilizationWindowSeconds` |
| 2 | Services | Deployment port, NodePort service | `kubectl set container-port`, `kubectl create service nodeport` |
| 3 | Sidecars | Shared volume, two containers | `emptyDir` volume, `volumeMounts` on both |
| 4 | Priority Class | Create and patch | `kubectl create priorityclass`, `kubectl patch deployment` |
| 5 | StorageClass | Volume binding, default class | `volumeBindingMode: WaitForFirstConsumer`, `is-default-class` |
| 6 | Helm/ArgoCD | Helm template without CRDs | `helm template ... --set crds.install=false` |
| 7 | PVC + Deployment | Restore MariaDB with PVC | Create PVC, edit deployment to use `persistentVolumeClaim` |
| 8 | Gateway API | Ingress → Gateway + HTTPRoute | Gateway + HTTPRoute YAML, TLS config |
| 9 | CNI | Install CNI with network policy | Apply Calico/Flannel manifest |
| 10 | Resources | Requests/limits, scaling | Scale to 0, set requests, scale to 3 |
| 11 | cri-dockerd | Install service, sysctl | `dpkg -i`, `systemctl`, sysctl config |
| 12 | CRDs | kubectl + JSONPath | `kubectl get crd`, `-o jsonpath=...` |
| 13 | Network Policy | Least permissive policy | Pod + namespace selectors only |
| 14 | CoreDNS | Backup, add domain, restart | ConfigMap backup, Corefile edit, rollout restart |
| 15 | Node/crictl | Find container, logs, runtime | `crictl ps`, `crictl inspect`, `crictl logs` |
| 16 | Network Policy | Port and namespace restrictions | Ingress from specific NS to specific port |
| 17 | Nodes | Count ready (non-NoSchedule) | `kubectl describe nodes`, grep taint |
| 18 | Troubleshooting | Node NotReady | SSH, `systemctl start/enable kubelet` |
| 19 | kubeadm | Upgrade control plane | Drain, upgrade, uncordon |
| 20 | TLS/ConfigMap | TLS 1.3 only in nginx | Edit ConfigMap, rollout restart |
| 21 | Ingress | Nginx Ingress with path | Ingress YAML, host, path, backend |
| 22 | Cluster | etcd / API server issues | Edit manifests, restart kubelet |

---

## Quick Reference: Essential Commands

```bash
# Context & Basics
kubectl config get-contexts
kubectl get ns, pods, svc, deploy -A

# Generate YAML (dry-run)
kubectl create deployment x --image=nginx --dry-run=client -o yaml
kubectl create service nodeport x --tcp=80 --dry-run=client -o yaml

# Patches
kubectl patch deployment <name> -n <ns> -p '{"spec":{"template":{"spec":{"priorityClassName":"x"}}}}'

# Restart (for ConfigMap changes)
kubectl rollout restart deployment <name> -n <ns>

# Debug
kubectl describe pod <name> -n <ns>
kubectl logs <pod> -n <ns> -c <container>
kubectl exec -it <pod> -n <ns> -- sh
```

---

## Practice Environment Setup (For Local Lab)

Create a small lab (e.g., Kind or minikube) and:

1. Create namespaces as needed.
2. Deploy example apps (nginx, MariaDB, etc.).
3. Create PVs/PVCs, StorageClasses, Ingress, etc.
4. Practice each question end-to-end, including verification.

For Gateway API and CNI, use Kind with custom config (e.g. `kind: Cluster` without default CNI) so you can install Calico and Gateway API from scratch.

---

## Exam Tips

1. **Read carefully** – Namespaces, names, ports, and file paths must match exactly.
2. **Use documentation** – Docs are available; use them for YAML structure and examples.
3. **Verify each step** – `kubectl get`, `describe`, `logs` before moving on.
4. **Time management** – Spend more time on high-weight questions but avoid getting stuck.
5. **Precedence of work** – In the exam, do not create or change prerequisites that are already given (e.g. namespaces, CRDs, PVs).
