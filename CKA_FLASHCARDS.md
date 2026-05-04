# CKA Exam Flashcards

Study these flashcards to reinforce key Kubernetes concepts!

---

## Category: Core Concepts

### Card 1
**Q:** What is a Pod?

<details>
<summary>Answer</summary>

A Pod is the smallest deployable unit in Kubernetes. It represents one or more containers that run together on the same node, sharing network and storage.
</details>

---

### Card 2
**Q:** What's the difference between a Pod and a Deployment?

<details>
<summary>Answer</summary>

- **Pod**: Single instance, no self-healing
- **Deployment**: Manages multiple pod replicas, provides self-healing, scaling, and rolling updates
</details>

---

### Card 3
**Q:** What are the three main Service types?

<details>
<summary>Answer</summary>

1. **ClusterIP** - Internal access only (default)
2. **NodePort** - External access via node IP:port (30000-32767)
3. **LoadBalancer** - Cloud load balancer (external access)
</details>

---

### Card 4
**Q:** What is the DNS format for a service in Kubernetes?

<details>
<summary>Answer</summary>

```
<service-name>.<namespace>.svc.<cluster-domain>

Example: backend.production.svc.cluster.local
```

Within same namespace, just use: `<service-name>`
</details>

---

### Card 5
**Q:** What command switches the kubectl context?

<details>
<summary>Answer</summary>

```bash
kubectl config use-context <context-name>
```

Always do this FIRST in exam questions!
</details>

---

### Card 6
**Q:** How do you set a default namespace for current context?

<details>
<summary>Answer</summary>

```bash
kubectl config set-context --current --namespace=<namespace>
```
</details>

---

## Category: Workloads & Scheduling

### Card 7
**Q:** What does HPA do?

<details>
<summary>Answer</summary>

Horizontal Pod Autoscaler automatically scales the number of pods based on CPU/memory metrics. It increases pods when load is high and decreases when load is low.
</details>

---

### Card 8
**Q:** What's required in a deployment for HPA to work?

<details>
<summary>Answer</summary>

Resource requests must be defined in the pod spec:
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
```

HPA calculates scaling based on these requests.
</details>

---

### Card 9
**Q:** What does stabilizationWindowSeconds do in HPA?

<details>
<summary>Answer</summary>

It delays scaling decisions to prevent flapping (rapid scale up/down). For example, `stabilizationWindowSeconds: 30` waits 30 seconds before scaling down to ensure load is consistently low.
</details>

---

### Card 10
**Q:** What is a PriorityClass?

<details>
<summary>Answer</summary>

PriorityClass determines pod scheduling priority. Higher priority pods:
- Schedule before lower priority pods
- Can evict (preempt) lower priority pods when resources are scarce

Higher value = higher priority
</details>

---

### Card 11
**Q:** What's the difference between CPU requests and limits?

<details>
<summary>Answer</summary>

- **Request**: Minimum guaranteed (used for scheduling)
- **Limit**: Maximum allowed

**Request** = "I need at least this much"  
**Limit** = "Don't use more than this"
</details>

---

### Card 12
**Q:** What happens when a container exceeds its memory limit?

<details>
<summary>Answer</summary>

The container is killed (OOMKilled - Out Of Memory Killed) and enters CrashLoopBackOff. Kubernetes restarts it automatically.
</details>

---

### Card 13
**Q:** What happens when a container exceeds its CPU limit?

<details>
<summary>Answer</summary>

The container is throttled (slowed down) but NOT killed. Performance degrades.
</details>

---

### Card 14
**Q:** What are the three QoS classes?

<details>
<summary>Answer</summary>

1. **Guaranteed**: requests == limits (highest priority)
2. **Burstable**: requests < limits (medium priority)
3. **BestEffort**: no requests/limits (lowest priority)

During resource pressure, BestEffort pods are evicted first.
</details>

---

## Category: Storage

### Card 15
**Q:** What's the difference between PV and PVC?

<details>
<summary>Answer</summary>

- **PV (PersistentVolume)**: Actual storage resource in cluster (created by admin or dynamically)
- **PVC (PersistentVolumeClaim)**: Request for storage by user

Think: PV = warehouse space, PVC = order form
</details>

---

### Card 16
**Q:** What are the common access modes for PV/PVC?

<details>
<summary>Answer</summary>

- **RWO (ReadWriteOnce)**: One node can mount as read-write
- **ROX (ReadOnlyMany)**: Many nodes can mount as read-only
- **RWX (ReadWriteMany)**: Many nodes can mount as read-write
- **RWOP (ReadWriteOncePod)**: One pod can mount as read-write

Most common: RWO
</details>

---

### Card 17
**Q:** What is a StorageClass?

<details>
<summary>Answer</summary>

StorageClass defines how storage is dynamically provisioned. When you create a PVC referencing a StorageClass, it automatically creates a matching PV.

Think: automated warehouse that allocates space on demand
</details>

---

### Card 18
**Q:** What does volumeBindingMode: WaitForFirstConsumer do?

<details>
<summary>Answer</summary>

It delays PV binding until a pod actually uses the PVC. This ensures the PV is created on the same node/zone as the pod.

Useful for local storage and multi-zone clusters.
</details>

---

### Card 19
**Q:** How do you make a StorageClass the default?

<details>
<summary>Answer</summary>

Add annotation:
```yaml
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
```
</details>

---

### Card 20
**Q:** What's the difference between emptyDir and PersistentVolume?

<details>
<summary>Answer</summary>

- **emptyDir**: Temporary, deleted when pod deleted, tied to pod lifecycle
- **PersistentVolume**: Permanent, survives pod deletion, independent lifecycle

emptyDir = scratch space  
PV = long-term storage
</details>

---

## Category: Networking

### Card 21
**Q:** What is a NetworkPolicy?

<details>
<summary>Answer</summary>

NetworkPolicy is a firewall rule for pods. It controls:
- **Ingress**: Who can connect TO these pods
- **Egress**: Where these pods can connect TO

Default without policies: all pods can talk to all pods.
</details>

---

### Card 22
**Q:** Does NetworkPolicy work without a CNI that supports it?

<details>
<summary>Answer</summary>

No! You need a CNI that supports NetworkPolicy enforcement:
- ✅ Calico
- ✅ Cilium
- ✅ Weave
- ❌ Flannel (basic version)

Always verify CNI support.
</details>

---

### Card 23
**Q:** What's the difference between podSelector and namespaceSelector in NetworkPolicy?

<details>
<summary>Answer</summary>

- **podSelector**: Which pods within a namespace
- **namespaceSelector**: Which namespace(s)

Both together = AND (pods with label X in namespace Y)
</details>

---

### Card 24
**Q:** What does an empty podSelector {} mean in NetworkPolicy?

<details>
<summary>Answer</summary>

Applies to ALL pods in the namespace.

```yaml
podSelector: {}  # All pods
```
</details>

---

### Card 25
**Q:** What's the difference between Ingress and Gateway API?

<details>
<summary>Answer</summary>

- **Ingress**: HTTP/HTTPS only, simpler, older
- **Gateway API**: HTTP/HTTPS/TCP/UDP/gRPC, more powerful, role-based, next-generation

Gateway API is the evolution of Ingress.
</details>

---

### Card 26
**Q:** What is CoreDNS responsible for?

<details>
<summary>Answer</summary>

CoreDNS is Kubernetes' DNS server. It:
- Resolves service names to IPs
- Enables service discovery (pods find each other by name)
- Runs as a deployment in kube-system namespace
</details>

---

## Category: Security

### Card 27
**Q:** What does RBAC stand for and what does it do?

<details>
<summary>Answer</summary>

**R**ole-**B**ased **A**ccess **C**ontrol

Controls WHO can do WHAT in the cluster:
- Defines permissions (verbs: get, list, create, delete, etc.)
- Assigns permissions to users/groups/service accounts
</details>

---

### Card 28
**Q:** What's the difference between Role and ClusterRole?

<details>
<summary>Answer</summary>

- **Role**: Namespace-scoped (permissions within one namespace)
- **ClusterRole**: Cluster-scoped (permissions across all namespaces + cluster resources)
</details>

---

### Card 29
**Q:** What's the difference between RoleBinding and ClusterRoleBinding?

<details>
<summary>Answer</summary>

- **RoleBinding**: Grants permissions in a specific namespace
- **ClusterRoleBinding**: Grants permissions cluster-wide

You can bind a ClusterRole with a RoleBinding to limit it to one namespace.
</details>

---

### Card 30
**Q:** What is a ServiceAccount?

<details>
<summary>Answer</summary>

ServiceAccount is an identity for pods. It allows pods to:
- Authenticate to Kubernetes API
- Access resources based on RBAC permissions

Think: user account for applications instead of humans
</details>

---

## Category: Cluster Maintenance

### Card 31
**Q:** What's the difference between drain, cordon, and uncordon?

<details>
<summary>Answer</summary>

- **drain**: Evict all pods + mark unschedulable (for maintenance)
- **cordon**: Mark unschedulable (don't evict existing pods)
- **uncordon**: Mark schedulable again (allow new pods)

Drain = empty + lock  
Cordon = just lock  
Uncordon = unlock
</details>

---

### Card 32
**Q:** What flags are commonly needed with kubectl drain?

<details>
<summary>Answer</summary>

```bash
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data
```

- `--ignore-daemonsets`: Don't fail on DaemonSet pods (they can't be evicted)
- `--delete-emptydir-data`: Allow deletion of pods with emptyDir volumes
</details>

---

### Card 33
**Q:** What are the steps to upgrade a control plane with kubeadm?

<details>
<summary>Answer</summary>

1. Drain node (if asked)
2. SSH to control plane
3. Upgrade kubeadm package
4. `kubeadm upgrade plan`
5. `kubeadm upgrade apply vX.Y.Z`
6. Upgrade kubelet and kubectl packages
7. Restart kubelet
8. Uncordon node
9. Verify
</details>

---

### Card 34
**Q:** How do you backup etcd?

<details>
<summary>Answer</summary>

```bash
ETCDCTL_API=3 etcdctl snapshot save /tmp/backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

etcd = cluster database (all state stored here)
</details>

---

## Category: Troubleshooting

### Card 35
**Q:** What are common pod states and what do they mean?

<details>
<summary>Answer</summary>

- **Pending**: Waiting to be scheduled (resource shortage or node selector)
- **Running**: Pod is running on a node
- **Succeeded**: All containers completed successfully
- **Failed**: Containers exited with error
- **CrashLoopBackOff**: Container keeps crashing and restarting
- **ImagePullBackOff**: Can't pull container image
</details>

---

### Card 36
**Q:** What does CrashLoopBackOff mean?

<details>
<summary>Answer</summary>

Container starts, crashes, Kubernetes restarts it, it crashes again, repeat. Causes:
- Application bug
- Wrong command in container
- Missing dependencies
- Configuration errors

Check logs: `kubectl logs <pod> --previous`
</details>

---

### Card 37
**Q:** What does ImagePullBackOff mean?

<details>
<summary>Answer</summary>

Kubernetes can't download the container image. Causes:
- Wrong image name or tag
- Image doesn't exist
- Registry authentication failed
- Network issues

Check: `kubectl describe pod <name>` → Events section
</details>

---

### Card 38
**Q:** What is crictl and when do you use it?

<details>
<summary>Answer</summary>

crictl is a CLI for container runtimes (like docker but for containerd/CRI-O).

**Use on nodes** (via SSH) to:
- List containers: `crictl ps`
- Get logs: `crictl logs <id>`
- Inspect: `crictl inspect <id>`
- Find runtime type

Not used on kubectl control machine!
</details>

---

### Card 39
**Q:** How do you fix a NotReady node?

<details>
<summary>Answer</summary>

Common cause: kubelet stopped

Fix:
```bash
ssh <node>
sudo systemctl start kubelet
sudo systemctl enable kubelet
sudo systemctl status kubelet
```
</details>

---

### Card 40
**Q:** Where are static pod manifests located?

<details>
<summary>Answer</summary>

```
/etc/kubernetes/manifests/
```

Files here:
- etcd.yaml
- kube-apiserver.yaml
- kube-controller-manager.yaml
- kube-scheduler.yaml

kubelet watches this directory and manages pods defined there.
</details>

---

## Category: Commands & Shortcuts

### Card 41
**Q:** Quick way to generate a deployment YAML?

<details>
<summary>Answer</summary>

```bash
kubectl create deployment <name> --image=<image> --replicas=3 --dry-run=client -o yaml > deploy.yaml
```

`--dry-run=client -o yaml` is your best friend!
</details>

---

### Card 42
**Q:** How do you quickly test if you have permission for an action?

<details>
<summary>Answer</summary>

```bash
kubectl auth can-i <verb> <resource>
kubectl auth can-i create pods
kubectl auth can-i get pods --namespace=dev --as=user

# Returns "yes" or "no"
```
</details>

---

### Card 43
**Q:** How do you get a pod's YAML definition?

<details>
<summary>Answer</summary>

```bash
kubectl get pod <name> -o yaml

# Or export to file
kubectl get pod <name> -o yaml > pod.yaml
```
</details>

---

### Card 44
**Q:** How do you view resource usage (CPU/memory)?

<details>
<summary>Answer</summary>

```bash
# Nodes
kubectl top nodes

# Pods
kubectl top pods
kubectl top pods -A
kubectl top pods --containers  # Per container
```

Requires metrics-server running!
</details>

---

### Card 45
**Q:** How do you patch a resource quickly?

<details>
<summary>Answer</summary>

```bash
kubectl patch <resource> <name> -p '{"spec":{"field":"value"}}'

# Example: Add priority class
kubectl patch deployment app -p '{"spec":{"template":{"spec":{"priorityClassName":"high"}}}}'
```

Faster than edit for single field changes.
</details>

---

### Card 46
**Q:** How do you scale a deployment?

<details>
<summary>Answer</summary>

```bash
kubectl scale deployment <name> --replicas=5

# Scale to 0 (useful before editing resources)
kubectl scale deployment <name> --replicas=0
```
</details>

---

### Card 47
**Q:** How do you rollback a deployment?

<details>
<summary>Answer</summary>

```bash
# Rollback to previous version
kubectl rollout undo deployment/<name>

# Rollback to specific revision
kubectl rollout history deployment/<name>
kubectl rollout undo deployment/<name> --to-revision=2
```
</details>

---

### Card 48
**Q:** How do you get events sorted by time?

<details>
<summary>Answer</summary>

```bash
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

Very useful for troubleshooting!
</details>

---

## Category: YAML Gotchas

### Card 49
**Q:** What's the correct indentation for YAML in Kubernetes?

<details>
<summary>Answer</summary>

**2 spaces** (not tabs!)

Set in vim:
```bash
set expandtab
set tabstop=2
set shiftwidth=2
```
</details>

---

### Card 50
**Q:** What does apiVersion depend on?

<details>
<summary>Answer</summary>

Resource type:
- Pod, Service, PVC: `v1`
- Deployment, ReplicaSet: `apps/v1`
- HPA: `autoscaling/v2`
- Ingress: `networking.k8s.io/v1`
- NetworkPolicy: `networking.k8s.io/v1`
- StorageClass: `storage.k8s.io/v1`
- RBAC: `rbac.authorization.k8s.io/v1`

Use `kubectl explain <resource>` to find it!
</details>

---

## Category: Exam Strategy

### Card 51
**Q:** What's the first thing to do on every exam question?

<details>
<summary>Answer</summary>

**Switch context!**

```bash
kubectl config use-context <context-name>
```

Each question may use a different cluster. Always check!
</details>

---

### Card 52
**Q:** How should you prioritize questions by weight?

<details>
<summary>Answer</summary>

- **15%+**: Critical - don't skip
- **10-14%**: Important - do if possible
- **7-9%**: Medium priority
- **<7%**: Low priority - skip if stuck

Focus on high-value questions first!
</details>

---

### Card 53
**Q:** What should you always do after completing a question?

<details>
<summary>Answer</summary>

**Verify your work!**

```bash
# Created a pod?
kubectl get pod <name>

# Created a deployment?
kubectl get deployment <name>
kubectl get pods

# Created a service?
kubectl get svc <name>
curl http://...

# Created NetworkPolicy?
kubectl get networkpolicy
kubectl describe networkpolicy <name>
```
</details>

---

### Card 54
**Q:** What's a quick way to test DNS in the cluster?

<details>
<summary>Answer</summary>

```bash
kubectl run test --rm -it --image=busybox -- nslookup <service-name>
```

`--rm` = delete pod when done  
`-it` = interactive terminal
</details>

---

### Card 55
**Q:** How much time should you spend on a question before flagging it?

<details>
<summary>Answer</summary>

**Maximum 5 minutes** if you're stuck.

Flag it and move on. Come back with fresh eyes if time permits. Better to answer more questions than perfect one.
</details>

---

## Study Tips

### How to Use These Flashcards

1. **First Pass**: Read question, think of answer, then check
2. **Second Pass**: Only cards you got wrong
3. **Third Pass**: Random order
4. **Quiz Yourself**: Cover the answer, explain out loud

### Spaced Repetition Schedule

- Day 1: All cards
- Day 2: All cards
- Day 4: Cards you missed
- Day 7: All cards
- Day 14: All cards
- Exam day: Quick review

---

**Total Cards: 55**

Keep practicing! Repetition is key to retention. 🧠✨
