# CKA Exam Quick Reference Cheat Sheet

## Essential kubectl Commands

### Context & Namespace
```bash
# Switch context (ALWAYS DO THIS FIRST!)
kubectl config use-context <context>

# Set default namespace
kubectl config set-context --current --namespace=<namespace>

# View current context
kubectl config current-context
```

### Quick Aliases (Set these up in exam!)
```bash
alias k=kubectl
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kaf='kubectl apply -f'
export do='--dry-run=client -o yaml'
source <(kubectl completion bash)
complete -F __start_kubectl k
```

### Generate YAML Templates
```bash
# Pod
kubectl run <name> --image=<image> $do > pod.yaml

# Deployment
kubectl create deployment <name> --image=<image> --replicas=3 $do > deploy.yaml

# Service
kubectl expose deployment <name> --port=80 --type=NodePort $do > svc.yaml

# Namespace
kubectl create namespace <name> $do > ns.yaml

# ConfigMap
kubectl create configmap <name> --from-literal=key=value $do > cm.yaml

# Secret
kubectl create secret generic <name> --from-literal=key=value $do > secret.yaml
```

---

## Core Resources

### Pods
```bash
# Create
kubectl run <name> --image=<image>

# Get
kubectl get pods -o wide
kubectl get pods -A

# Describe
kubectl describe pod <name>

# Logs
kubectl logs <pod>
kubectl logs <pod> -c <container>
kubectl logs <pod> --previous

# Execute
kubectl exec -it <pod> -- /bin/bash
kubectl exec <pod> -c <container> -- <command>

# Delete
kubectl delete pod <name>
```

### Deployments
```bash
# Create
kubectl create deployment <name> --image=<image> --replicas=3

# Scale
kubectl scale deployment <name> --replicas=5

# Update image
kubectl set image deployment/<name> <container>=<image>:tag

# Rollout status
kubectl rollout status deployment/<name>

# Rollback
kubectl rollout undo deployment/<name>

# History
kubectl rollout history deployment/<name>
```

### Services
```bash
# Expose deployment
kubectl expose deployment <name> --port=80 --target-port=8080 --type=ClusterIP

# NodePort
kubectl expose deployment <name> --port=80 --type=NodePort --node-port=30080

# Get services
kubectl get svc

# Test from pod
kubectl run test --rm -it --image=busybox -- wget -O- http://<service>
```

---

## Scaling & Autoscaling

### HPA (Horizontal Pod Autoscaler)
```bash
# Create HPA
kubectl autoscale deployment <name> --cpu-percent=50 --min=1 --max=10

# Get HPA
kubectl get hpa

# Describe HPA
kubectl describe hpa <name>
```

**HPA YAML with Stabilization:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: <name>
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: <deployment>
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 30
```

---

## Storage

### PersistentVolumeClaim
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: <name>
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: <class>
  resources:
    requests:
      storage: 1Gi
```

### StorageClass (Default)
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: <name>
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
```

### Pod with PVC
```yaml
volumes:
- name: data
  persistentVolumeClaim:
    claimName: <pvc-name>

# In container:
volumeMounts:
- name: data
  mountPath: /data
```

---

## Networking

### Network Policy Template
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: <name>
  namespace: <namespace>
spec:
  podSelector:
    matchLabels:
      app: <app>
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: <namespace>
      podSelector:
        matchLabels:
          app: <app>
    ports:
    - protocol: TCP
      port: 80
```

### Ingress Template
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <name>
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: <hostname>
    http:
      paths:
      - path: /path
        pathType: Prefix
        backend:
          service:
            name: <service>
            port:
              number: 80
```

### DNS Format
```
<service>.<namespace>.svc.cluster.local
```

Test DNS:
```bash
kubectl run test --rm -it --image=busybox -- nslookup <service>
```

---

## Security

### PriorityClass
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
```

Patch deployment:
```bash
kubectl patch deployment <name> -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'
```

### Resources (Requests & Limits)
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "200m"
    memory: "256Mi"
```

---

## Multi-Container Pods

### Sidecar Pattern
```yaml
spec:
  volumes:
  - name: shared-logs
    emptyDir: {}
  
  containers:
  # Main container
  - name: app
    image: nginx
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
  
  # Sidecar
  - name: sidecar
    image: busybox
    command: ["/bin/sh", "-c", "tail -f /var/log/app.log"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
```

---

## Cluster Maintenance

### Drain Node
```bash
# Drain (safely evict pods)
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data

# Uncordon (make schedulable)
kubectl uncordon <node>

# Cordon (mark unschedulable, don't evict)
kubectl cordon <node>
```

### Upgrade Control Plane (kubeadm)
```bash
# Drain
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data

# SSH to node
ssh <node>
sudo -i

# Upgrade kubeadm
apt-mark unhold kubeadm
apt-get update && apt-get install -y kubeadm=1.30.1-00
apt-mark hold kubeadm

# Upgrade cluster
kubeadm upgrade plan
kubeadm upgrade apply v1.30.1

# Upgrade kubelet and kubectl
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=1.30.1-00 kubectl=1.30.1-00
apt-mark hold kubelet kubectl

systemctl daemon-reload
systemctl restart kubelet

# Uncordon
exit
kubectl uncordon <node>
```

### etcd Backup
```bash
ETCDCTL_API=3 etcdctl snapshot save /tmp/backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

---

## Troubleshooting

### Check Node Status
```bash
kubectl get nodes
kubectl describe node <name>
kubectl top nodes
```

### Check Pod Issues
```bash
kubectl get pods
kubectl describe pod <name>
kubectl logs <pod>
kubectl logs <pod> --previous

# Common issues
# ImagePullBackOff - wrong image name/tag
# CrashLoopBackOff - app crashes on start
# Pending - insufficient resources or scheduling issue
# OOMKilled - out of memory
```

### Check Events
```bash
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

### crictl (on nodes)
```bash
# List containers
crictl ps -a

# Get container ID
crictl ps -a | grep <pod-name>

# Inspect container
crictl inspect <container-id>

# Logs
crictl logs <container-id>

# Runtime type
crictl inspect <container-id> | grep runtimeType
```

### Fix NotReady Node
```bash
ssh <node>
sudo systemctl status kubelet
sudo systemctl start kubelet
sudo systemctl enable kubelet
```

### Fix Broken Cluster
```bash
ssh <control-plane>
cd /etc/kubernetes/manifests/

# Check etcd.yaml and kube-apiserver.yaml
sudo vim etcd.yaml
sudo vim kube-apiserver.yaml

# Restart kubelet
sudo systemctl restart kubelet
```

---

## Advanced Topics

### CNI Installation
```bash
# Calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml

# Flannel
kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml

# Verify
kubectl get pods -A | grep -E 'calico|flannel'
```

### CoreDNS Custom Domain
```bash
# Backup
kubectl -n kube-system get configmap coredns -o yaml > backup.yaml

# Edit
kubectl -n kube-system edit configmap coredns

# Change:
# kubernetes cluster.local ...
# To:
# kubernetes custom-domain cluster.local ...

# Restart
kubectl -n kube-system rollout restart deployment coredns
```

### Helm Template
```bash
helm repo add <repo> <url>
helm repo update
helm template <release> <chart> --version <version> --namespace <ns> --set key=value > output.yaml
kubectl apply -f output.yaml
```

### JSONPath Queries
```bash
# Get field
kubectl get <resource> <name> -o jsonpath='{.spec.field}'

# Multiple fields
kubectl get <resource> <name> -o jsonpath='{.metadata.name}{"\t"}{.status.phase}'

# Array element
kubectl get <resource> <name> -o jsonpath='{.spec.containers[0].image}'
```

---

## Exam Time Management

### Question Weights
- **15%+** = Critical, don't skip
- **10-14%** = Important, do if possible
- **7-9%** = Medium priority
- **<7%** = Low priority, skip if stuck

### Time Strategy
1. **Read all questions** (5 min)
2. **Do easy questions first** (40 min)
3. **Do medium questions** (40 min)
4. **Attempt hard questions** (25 min)
5. **Review flagged** (10 min)

### Before Each Question
- [ ] Switch context: `kubectl config use-context <context>`
- [ ] Note namespace (use `-n` flag or set default)
- [ ] Read question completely
- [ ] Check what already exists

### After Each Question
- [ ] Verify: `kubectl get ...`
- [ ] Test if possible
- [ ] Move to next

---

## Common Exam Patterns

### Pattern 1: Create & Configure
```bash
# Generate template
kubectl create ... --dry-run=client -o yaml > file.yaml

# Edit
vim file.yaml

# Apply
kubectl apply -f file.yaml

# Verify
kubectl get ...
kubectl describe ...
```

### Pattern 2: Edit Existing
```bash
# Option 1: Edit directly
kubectl edit <resource> <name>

# Option 2: Export, edit, apply
kubectl get <resource> <name> -o yaml > file.yaml
vim file.yaml
kubectl apply -f file.yaml

# Option 3: Patch
kubectl patch <resource> <name> -p '{"spec":{"field":"value"}}'
```

### Pattern 3: SSH to Node
```bash
# Find node
kubectl get pod <name> -o wide

# SSH
ssh <node>

# Do work (crictl, systemctl, etc.)

# Exit
exit

# Verify
kubectl get nodes
```

---

## Vim Quick Reference

### Exam vim Setup
```bash
echo "set expandtab" >> ~/.vimrc
echo "set tabstop=2" >> ~/.vimrc
echo "set shiftwidth=2" >> ~/.vimrc
```

### Essential Vim Commands
```
i          - Insert mode
Esc        - Normal mode
:wq        - Save and quit
:q!        - Quit without saving
dd         - Delete line
yy         - Copy line
p          - Paste
u          - Undo
Ctrl+r     - Redo
/pattern   - Search
n          - Next search result
:set nu    - Show line numbers
```

---

## Documentation Quick Links

**Bookmark these before exam:**

- **Pods:** https://kubernetes.io/docs/concepts/workloads/pods/
- **Deployments:** https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- **Services:** https://kubernetes.io/docs/concepts/services-networking/service/
- **Ingress:** https://kubernetes.io/docs/concepts/services-networking/ingress/
- **Network Policies:** https://kubernetes.io/docs/concepts/services-networking/network-policies/
- **PV/PVC:** https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- **Storage Classes:** https://kubernetes.io/docs/concepts/storage/storage-classes/
- **RBAC:** https://kubernetes.io/docs/reference/access-authn-authz/rbac/
- **HPA:** https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
- **kubeadm upgrade:** https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

---

## Common Mistakes to Avoid

1. **Forgetting to switch context** ❌
2. **Creating in wrong namespace** ❌
3. **Not verifying changes** ❌
4. **Spending too long on one question** ❌
5. **Typos in YAML indentation** ❌
6. **Not using --dry-run** ❌
7. **Forgetting to save files** ❌

---

## Resource Units Cheat Sheet

### CPU
```
1 = 1000m (1 core)
500m = 0.5 (half core)
100m = 0.1 (10% of core)
```

### Memory
```
1Gi = 1024Mi (Gibibyte)
1G = 1000M (Gigabyte)
Use Mi/Gi for Kubernetes
```

---

## Access Modes

```
RWO = ReadWriteOnce (one node)
ROX = ReadOnlyMany (many nodes)
RWX = ReadWriteMany (many nodes)
```

---

## Final Pre-Exam Checklist

- [ ] Set up aliases and bash completion
- [ ] Configure vim settings
- [ ] Know documentation structure
- [ ] Practice switching contexts quickly
- [ ] Know common YAML templates
- [ ] Understand time management strategy
- [ ] Get comfortable with crictl
- [ ] Practice JSONPath queries

**Good luck! You've got this!** 🚀
