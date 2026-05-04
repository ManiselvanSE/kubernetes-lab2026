# CKA Exam: Deep Guide — Question by Question

A detailed breakdown of each question: **understanding**, **how to practice**, and **what you must do in the exam**.

---

# Table of Contents

1. [Question 1: HPA](#question-1-horizontal-pod-autoscaler-hpa)
2. [Question 2: Deployment + NodePort](#question-2-deployment--nodeport-service-weight-10)
3. [Question 3: Sidecar Container](#question-3-sidecar-container-weight-15)
4. [Question 4: PriorityClass](#question-4-priorityclass-weight-11)
5. [Question 5: StorageClass](#question-5-storageclass-weight-8)
6. [Question 6: ArgoCD Helm](#question-6-argocd-via-helm-weight-7--13)
7. [Question 7: MariaDB + PVC](#question-7-mariadb--pvc-weight-13)
8. [Question 8: Gateway API](#question-8-ingress--gateway-api-weight-12)
9. [Question 9: CNI](#question-9-cni-installation-weight-9)
10. [Question 10: WordPress Resources](#question-10-wordpress-resource-requests-weight-9)
11. [Question 11: cri-dockerd](#question-11-cri-dockerd--sysctl-weight-7)
12. [Question 12: CRDs JSONPath](#question-12-crds--jsonpath-weight-7)
13. [Question 13: Network Policy](#question-13-network-policy-least-permissive-weight-10)
14. [Question 14: CoreDNS](#question-14-coredns-custom-domain)
15. [Question 15: crictl](#question-15-node--crictl-pod-container-id--logs)
16. [Question 16: Network Policy Port](#question-16-network-policy-port--namespace)
17. [Question 17: Count Nodes](#question-17-count-ready-nodes-excluding-noschedule)
18. [Question 18: Node NotReady](#question-18-node-notready--fix-kubelet)
19. [Question 19: kubeadm Upgrade](#question-19-kubeadm-upgrade-v1301)
20. [Question 20: TLS 1.3](#question-20-tls-13-only-nginx-configmap)
21. [Question 21: Ingress](#question-21-ingress-echo-server)
22. [Question 22: Cluster Troubleshoot](#question-22-cluster-broken-etcd--kube-apiserver)

---

# What to Do in the Exam — Quick Summary

> Use this to see exactly what YOU must perform in the exam vs what is pre-set.


| Q#  | **EXAM: You Must Do**                                               | **EXAM: Already There (Don't Create)**                         |
| --- | ------------------------------------------------------------------- | -------------------------------------------------------------- |
| 1   | Create HPA, add `stabilizationWindowSeconds: 30`                    | ns `auto-scale`, deploy `apache-server`                        |
| 2   | Add containerPort 80, create NodePort svc `front-end-svc`           | ns `spline-reticulator`, deploy `front-end`                    |
| 3   | Edit deployment: add sidecar + shared volume                        | deploy `synergy-leverager`                                     |
| 4   | Create `high-priority` (value=highest-1), patch `busybox-logger`    | ns `priority`, deploy `busybox-logger`, existing PriorityClass |
| 5   | Create StorageClass `local-path`, set default                       | Provisioner exists                                             |
| 6   | `helm repo add`, `helm template`, save to `~/argo-helm.yaml`, apply | ns `argocd`, ArgoCD CRDs                                       |
| 7   | Create PVC `mariadb`, edit deployment, apply                        | ns `mariadb`, retained PV                                      |
| 8   | Create Gateway + HTTPRoute                                          | GatewayClass, Ingress, app, TLS secret                         |
| 9   | Apply Calico/Flannel manifest                                       | Cluster without CNI / removable CNI                            |
| 10  | Scale 0 → edit resources → scale 3                                  | deploy `wordpress`                                             |
| 11  | `dpkg -i`, enable/start cri-docker.socket, sysctl                   | Package in `~/`                                                |
| 12  | `kubectl get crd | grep cert >`, JSONPath to `subject`              | cert-manager CRDs                                              |
| 13  | Apply least permissive NetworkPolicy (pod+ns selector)              | Deployments, CNI                                               |
| 14  | Backup CoreDNS, add `custom-domain`, restart CoreDNS                | CoreDNS running                                                |
| 15  | Create pod, SSH to node, crictl ID+runtimeType+logs to files        | ns `project-tiger`, SSH                                        |
| 16  | Create NetworkPolicy `allow-port-from-namespace`                    | ns `foobar`, `internal-ns`                                     |
| 17  | Count ready non-NoSchedule nodes, write to file                     | —                                                              |
| 18  | SSH to worker, start+enable kubelet                                 | —                                                              |
| 19  | Drain, upgrade kubeadm/kubelet/kubectl, uncordon                    | —                                                              |
| 20  | Edit ConfigMap `ssl_protocols TLSv1.3`, rollout restart             | Deploy, ConfigMap, TLS                                         |
| 21  | Create Ingress for `/echo`                                          | Namespace, deploy, svc, ingress controller                     |
| 22  | Fix etcd/kube-apiserver manifests, restart kubelet                  | —                                                              |


---

# Legend: Exam vs Practice


| Symbol        | Meaning                                                          |
| ------------- | ---------------------------------------------------------------- |
| **EXAM ONLY** | Actions you perform during the actual exam (prerequisites exist) |
| **PRACTICE**  | Setup you do in your lab before simulating the question          |
| **BOTH**      | Do in both exam and practice                                     |


---

---

# Question 1: Horizontal Pod Autoscaler (HPA)

---

## 🎯 IN THE EXAM — DO THIS

1. Create HPA: `kubectl autoscale deployment apache-server -n auto-scale --cpu-percent=50 --min=1 --max=4`
2. Add `spec.behavior.scaleDown.stabilizationWindowSeconds: 30` via edit or patch
3. Verify: `kubectl get hpa -n auto-scale`

---

## Understanding

- **HPA** scales pods based on CPU/memory metrics.
- **stabilizationWindowSeconds** delays downscaling so the cluster avoids rapid scale-downs.
- The question asks for: create HPA, target deployment, 50% CPU, min 1 / max 4 pods, downscale stabilization = 30 seconds.

## Prerequisites


| Item                       | Exam   | Practice                                                                      |
| -------------------------- | ------ | ----------------------------------------------------------------------------- |
| namespace `auto-scale`     | Exists | Create: `kubectl create ns auto-scale`                                        |
| deployment `apache-server` | Exists | Create: `kubectl create deployment apache-server --image=nginx -n auto-scale` |


## What to do in the exam

### Step 1: Create HPA

```bash
kubectl autoscale deployment apache-server -n auto-scale \
  --cpu-percent=50 --min=1 --max=4
```

### Step 2: Add downscale stabilization (30 seconds)

`kubectl autoscale` does not set behavior. Use edit or patch:

```bash
kubectl get hpa -n auto-scale -o yaml > hpa.yaml
# Edit hpa.yaml and add under spec:
#   behavior:
#     scaleDown:
#       stabilizationWindowSeconds: 30
kubectl apply -f hpa.yaml
```

Or patch:

```bash
kubectl patch hpa apache-server -n auto-scale --type='merge' -p '
{
  "spec": {
    "behavior": {
      "scaleDown": {
        "stabilizationWindowSeconds": 30
      }
    }
  }
}'
```

### Step 3: Verify

```bash
kubectl get hpa -n auto-scale
```

## How to Practice

1. Create Kind/minikube cluster. 2. `kubectl create ns auto-scale && kubectl create deployment apache-server --image=nginx -n auto-scale`. 3. Follow "IN THE EXAM" steps. 4. Verify HPA and `kubectl get hpa -n auto-scale -o yaml` shows behavior.

## Docs

[https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

---

---

# Question 2: Deployment + NodePort Service (Weight: 10%)

---

## 🎯 IN THE EXAM — DO THIS

1. Add `containerPort: 80` to deployment `front-end` (kubectl set or edit)
2. Create NodePort service `front-end-svc` exposing port 80, selector `app: front-end`
3. Verify: `kubectl get svc,deploy -n spline-reticulator`

---

## Understanding

- Deployment `front-end` must expose port 80 on its nginx container.
- A NodePort service `front-end-svc` must expose that port on the node (30000–32767 range).

## Prerequisites


| Item                              | Exam   | Practice                                       |
| --------------------------------- | ------ | ---------------------------------------------- |
| namespace `spline-reticulator`    | Exists | Create: `kubectl create ns spline-reticulator` |
| deployment `front-end` with nginx | Exists | Create with `--port=80`                        |


## What to do in the exam

### Step 1: Add containerPort 80 to deployment

```bash
kubectl set container-port deployment/front-end nginx=80 -n spline-reticulator
```

or edit deployment YAML and add `containerPort: 80` under the nginx container.

### Step 2: Create NodePort service

```bash
kubectl create service nodeport front-end-svc -n spline-reticulator \
  --tcp=80:80 --dry-run=client -o yaml
```

Add `namespace: spline-reticulator` under metadata, and optionally set `nodePort` (e.g. 30080). Then apply.

Or imperative with nodePort:

```bash
kubectl create service nodeport front-end-svc -n spline-reticulator --tcp=80:80 --node-port=30080
```

### Step 3: Verify

```bash
kubectl get svc -n spline-reticulator
kubectl get deploy front-end -n spline-reticulator -o yaml | grep -A2 containerPort
```

## How to Practice

1. `kubectl create ns spline-reticulator && kubectl create deployment front-end --image=nginx --port=80 -n spline-reticulator`. 2. Follow exam steps. 3. Test: `kubectl port-forward svc/front-end-svc -n spline-reticulator 8080:80` then `curl localhost:8080`.

## Docs

[https://kubernetes.io/docs/concepts/services-networking/service/](https://kubernetes.io/docs/concepts/services-networking/service/)

---

---

# Question 3: Sidecar Container (Weight: 15%)

---

## 🎯 IN THE EXAM — DO THIS

1. Edit deployment `synergy-leverager`: add sidecar container `sidecar` (busybox:stable)
2. Add shared `emptyDir` volume at `/var/log`; both containers mount it
3. Sidecar command: `["/bin/sh","-c","tail -n+1 -f /var/log/synergy-leverager.log"]`
4. Apply and verify with `kubectl exec`

---

## Understanding

- **Sidecar**: extra container that shares resources (e.g. logs) with the main container.
- Both containers need:
  - A shared volume (e.g. `emptyDir`) mounted at the same path
  - Main app writing to that path, sidecar reading from it.
- Question: add a sidecar container `sidecar` with `busybox:stable` running `tail -n+1 -f /var/log/synergy-leverager.log`.

## Prerequisites


| Item                           | Exam   | Practice                    |
| ------------------------------ | ------ | --------------------------- |
| deployment `synergy-leverager` | Exists | Apply full YAML below first |


## What to do in the exam

Edit the deployment so the pod spec has:

1. Main container: `synergy-leverager`, writing to `/var/log/synergy-leverager.log`, with volume mount at `/var/log`
2. Sidecar container: `sidecar`, `busybox:stable`, command `["/bin/sh","-c","tail -n+1 -f /var/log/synergy-leverager.log"]`, same volume mount
3. Volume: `emptyDir` shared by both

```yaml
spec:
  containers:
  - name: synergy-leverager
    image: alpine:latest
    command: ["/bin/sh", "-c", "while true; do echo logging >> /var/log/synergy-leverager.log; sleep 1; done"]
    volumeMounts:
    - name: data
      mountPath: /var/log
  - name: sidecar
    image: busybox:stable
    command: ["/bin/sh", "-c", "tail -n+1 -f /var/log/synergy-leverager.log"]
    volumeMounts:
    - name: data
      mountPath: /var/log
  volumes:
  - name: data
    emptyDir: {}
```

Verify:

```bash
kubectl exec -it <pod> -n <ns> -c synergy-leverager -- cat /var/log/synergy-leverager.log
```

## How to Practice

1. Apply full sidecar deployment YAML from the guide to create `synergy-leverager`. 2. Run exam steps (edit if needed). 3. Verify: `kubectl exec -it <pod> -c sidecar -- tail -f /var/log/synergy-leverager.log` shows logs.

## Docs

[https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/)

---

---

# Question 4: PriorityClass (Weight: 11%)

---

## 🎯 IN THE EXAM — DO THIS

1. `kubectl get priorityclass` → find highest value (e.g. 1000)
2. Create `high-priority` with value 999, `preemptionPolicy: PreemptLowerPriority`
3. Patch `busybox-logger` deployment: `priorityClassName: high-priority`
4. Verify other pods in namespace are evicted

---

## Understanding

- PriorityClass sets pod scheduling priority; higher value = higher priority.
- `preemptionPolicy: PreemptLowerPriority` allows eviction of lower-priority pods.
- Question: create `high-priority` with value = (highest user-defined value) − 1; patch `busybox-logger` to use it so other pods in the namespace are evicted.

## Prerequisites


| Item                                             | Exam   | Practice                                                                              |
| ------------------------------------------------ | ------ | ------------------------------------------------------------------------------------- |
| namespace `priority`                             | Exists | Create: `kubectl create ns priority`                                                  |
| deployment `busybox-logger`                      | Exists | Create: `kubectl create deployment busybox-logger --image=busybox:stable -n priority` |
| Existing highest PriorityClass (e.g. value 1000) | Exists | Create one if needed: `kubectl create priorityclass existing-priority --value=1000`   |


## What to do in the exam

### Step 1: Check highest PriorityClass value

```bash
kubectl get priorityclass
```

### Step 2: Create `high-priority` (value = highest − 1)

```bash
kubectl create priorityclass high-priority --value=999 \
  --description="High priority for user workloads" --preemption-policy=PreemptLowerPriority
```

### Step 3: Patch `busybox-logger` to use it

```bash
kubectl patch deployment busybox-logger -n priority --type='merge' -p '
{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}
'
```

### Step 4: Verify

```bash
kubectl get pods -n priority
# Other deployments' pods should be evicted or pending
```

## How to Practice

1. Create ns `priority`, PriorityClass with value 1000, deploy `busybox-logger`, another low-priority deploy. 2. Create `high-priority` (999), patch `busybox-logger`. 3. Observe eviction of lower-priority pods.

## Docs

[https://kubernetes.io/docs/reference/kubectl/generated/kubectl_patch/](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_patch/)

---

---

# Question 5: StorageClass (Weight: 8%)

---

## 🎯 IN THE EXAM — DO THIS

1. Create StorageClass `local-path`, provisioner `rancher.io/local-path`
2. Set `volumeBindingMode: WaitForFirstConsumer`
3. Set `storageclass.kubernetes.io/is-default-class: "true"`
4. **Do NOT modify existing Deployments or PVCs**

---

## Understanding

- StorageClass defines how PVs are provisioned.
- **volumeBindingMode: WaitForFirstConsumer** delays binding until a pod uses the PVC.
- **Default StorageClass**: annotation `storageclass.kubernetes.io/is-default-class: "true"`.
- Important: do not modify existing Deployments or PVCs.

## Prerequisites


| Item                                | Exam   | Practice                          |
| ----------------------------------- | ------ | --------------------------------- |
| Provisioner `rancher.io/local-path` | Exists | Usually pre-installed in exam lab |


## What to do in the exam

Create this StorageClass YAML and apply:

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
```

```bash
kubectl apply -f storageclass.yaml
```

Verify:

```bash
kubectl get sc
# local-path should show (default)
```

## How to Practice

1. Ensure local-path-provisioner is installed (Kind has it). 2. Create StorageClass YAML and apply. 3. Remove default annotation from other StorageClass if needed. 4. `kubectl get sc` to confirm default.

## Docs

[https://kubernetes.io/docs/concepts/storage/storage-classes/](https://kubernetes.io/docs/concepts/storage/storage-classes/)

---

---

# Question 6: ArgoCD via Helm (Weight: 7% / 13%)

---

## 🎯 IN THE EXAM — DO THIS

1. `helm repo add argo https://argoproj.github.io/argo-helm` + `helm repo update`
2. `helm template argocd argo/argo-cd --version 7.7.3 --namespace argocd --set crds.install=false > ~/argo-helm.yaml`
3. `kubectl apply -f ~/argo-helm.yaml`
4. Verify: `cat ~/argo-helm.yaml | head -20` (check namespace)

---

## Understanding

- Install ArgoCD using Helm.
- CRDs are already installed; chart must not install them.
- Output: Helm template saved to `~/argo-helm.yaml`, then applied.

## Prerequisites


| Item               | Exam          | Practice                                                                                                                                                         |
| ------------------ | ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| namespace `argocd` | Exists        | Create: `kubectl create ns argocd`                                                                                                                               |
| ArgoCD CRDs        | Pre-installed | For practice: `kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml` (CRDs only) or install CRDs manually |
| Helm               | Available     | Install: `curl .../get-helm-3 | bash` if needed                                                                                                                  |


## What to do in the exam

### Step 1: Add Helm repo

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

### Step 2: Generate template (no CRDs, correct path)

```bash
helm template argocd argo/argo-cd --version 7.7.3 \
  --namespace argocd \
  --set crds.install=false \
  > ~/argo-helm.yaml
```

### Step 3: Apply

```bash
kubectl apply -f ~/argo-helm.yaml
```

### Step 4: Verify

```bash
cat ~/argo-helm.yaml | head -50   # Check namespace in resources
kubectl get pods -n argocd
```

## How to Practice

1. Install Helm, create ns `argocd`. 2. For CRDs: `kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml` (or CRDs only). 3. Add repo, template, apply. 4. Verify pods in argocd namespace.

## Docs

Argo CD Helm: [https://argoproj.github.io/argo-helm](https://argoproj.github.io/argo-helm)

---

---

# Question 7: MariaDB + PVC (Weight: 13%)

---

## 🎯 IN THE EXAM — DO THIS

1. Create PVC `mariadb` in ns `mariadb`: 250Mi, storageClassName matching existing PV
2. Edit `mariadb-deployment.yaml`: add volume + volumeMount for PVC at `/var/lib/mysql`
3. `kubectl apply -f mariadb-deployment.yaml`
4. Verify: `kubectl get pvc,pods -n mariadb`

---

## Understanding

- Restore a deleted MariaDB deployment with persistent storage.
- Use an existing retained PV and create a PVC that binds to it.
- Deployment must use the PVC for `/var/lib/mysql`.

## Prerequisites


| Item                                                  | Exam                   | Practice                            |
| ----------------------------------------------------- | ---------------------- | ----------------------------------- |
| namespace `mariadb`                                   | Exists                 | Create: `kubectl create ns mariadb` |
| Retained PV (e.g. 250Mi, storageClassName `standard`) | Exists                 | Create PV and hostPath for practice |
| mariadb-deployment.yaml file                          | Provided or you create | Use YAML below for practice         |


## What to do in the exam

### Step 1: Create PVC (250Mi, match PV storageClassName)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb
  namespace: mariadb
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: standard   # Match existing PV
  resources:
    requests:
      storage: 250Mi
```

```bash
kubectl apply -f pvc.yaml
```

### Step 2: Edit deployment to use PVC

Add/update volumes and volumeMounts:

```yaml
volumes:
- name: mariadb-storage
  persistentVolumeClaim:
    claimName: mariadb
# and in container:
volumeMounts:
- name: mariadb-storage
  mountPath: /var/lib/mysql
```

### Step 3: Apply deployment

```bash
kubectl apply -f mariadb-deployment.yaml
```

### Step 4: Verify

```bash
kubectl get pvc -n mariadb
kubectl get deploy,pods -n mariadb
```

## How to Practice

1. Create ns `mariadb`, PV (hostPath 250Mi, storageClassName `standard`), apply PV. 2. Create PVC, deployment with PVC. 3. Delete deployment, re-run exam steps to simulate restore.

## Docs

Persistent Volumes: [https://kubernetes.io/docs/concepts/storage/persistent-volumes/](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

---

---

# Question 8: Ingress → Gateway API (Weight: 12%)

---

## 🎯 IN THE EXAM — DO THIS

1. Create **Gateway** `web-gateway`: gatewayClassName nginx, hostname `gateway.web.k8s.local`, HTTPS+HTTP listeners, TLS from secret `web-tls`
2. Create **HTTPRoute** `web-route`: parentRef web-gateway, hostname `gateway.web.k8s.local`, backendRef web-service:80
3. Apply both; verify with curl

---

## Understanding

- Migrate existing Ingress-based web app to Gateway API while keeping HTTPS.
- Create a **Gateway** and **HTTPRoute** that replicate the existing Ingress behavior.
- Question: create `web-gateway` with hostname `gateway.web.k8s.local`, use existing TLS; create `web-route` with same hostname and routing rules.

## Prerequisites


| Item                                       | Exam      | Practice                                  |
| ------------------------------------------ | --------- | ----------------------------------------- |
| GatewayClass `nginx`                       | Installed | Install nginx-gateway-fabric for practice |
| Ingress, web app, service `web-service`    | Present   | Deploy for practice                       |
| TLS Secret `web-tls` in `webapp` namespace | Present   | Create self-signed for practice           |


## What to do in the exam

### Step 1: Create Gateway

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: web-gateway
  namespace: webapp
spec:
  gatewayClassName: nginx
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    hostname: gateway.web.k8s.local
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: web-tls
  - name: http
    protocol: HTTP
    port: 80
    hostname: gateway.web.k8s.local
```

### Step 2: Create HTTPRoute

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-route
  namespace: webapp
spec:
  parentRefs:
  - name: web-gateway
  hostnames:
  - gateway.web.k8s.local
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web-service
      port: 80
```

### Step 3: Apply and verify

```bash
kubectl apply -f gateway.yaml -f httproute.yaml
kubectl get gateway,httproute -n webapp
curl -k https://gateway.web.k8s.local:443
```

## How to Practice

1. Install Gateway API CRDs + nginx-gateway-fabric. 2. Deploy web app, create TLS secret. 3. Create Gateway + HTTPRoute. 4. Add hosts entry, test with `curl -k https://gateway.web.k8s.local`.

## Docs

[https://gateway-api.sigs.k8s.io/](https://gateway-api.sigs.k8s.io/) (Migrating from Ingress)

---

---

# Question 9: CNI Installation (Weight: 9%)

---

## 🎯 IN THE EXAM — DO THIS

1. Choose Calico (recommended) or Flannel per question
2. Apply manifest: Calico `tigera-operator.yaml` v3.28.2 OR Flannel v0.26.1
3. Verify: `kubectl get pods -A | grep -E calico\|flannel`

---

## Understanding

- Install a CNI that supports **native network policies**.
- Options: Flannel v0.26.1 or Calico v3.28.2.
- Calico is usually preferred because of full NetworkPolicy support.

## Prerequisites


| Item                                      | Exam    | Practice                            |
| ----------------------------------------- | ------- | ----------------------------------- |
| Cluster without CNI or with removable CNI | Depends | Use Kind config without default CNI |


## What to do in the exam

Choose one CNI and apply its manifest:

**Calico (recommended):**

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml
```

**Flannel:**

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml
```

Verify:

```bash
kubectl get pods -A | grep -E 'calico|flannel'
kubectl get networkpolicies -A   # Calico supports this
```

## How to Practice

1. Use Kind config with `networking.disabled: true` or remove default CNI. 2. Apply Calico or Flannel manifest. 3. Verify all nodes Ready and NetworkPolicy CRD exists.

## Docs

Calico: [https://docs.tigera.io/calico/latest/getting-started/kubernetes/](https://docs.tigera.io/calico/latest/getting-started/kubernetes/)

---

---

# Question 10: WordPress Resource Requests (Weight: 9%)

---

## 🎯 IN THE EXAM — DO THIS

1. `kubectl scale deployment wordpress --replicas=0`
2. Edit deployment: add same `resources.requests` (and limits) to init + main containers
3. `kubectl scale deployment wordpress --replicas=3`
4. Verify all pods Running

---

## Understanding

- Fix failing pods by setting proper `resources.requests` (and optionally `limits`).
- Divide node capacity evenly across 3 replicas.
- Main and init containers must use the same requests.
- Workflow: scale to 0 → update YAML → scale back to 3.

## Prerequisites


| Item                                               | Exam   | Practice                        |
| -------------------------------------------------- | ------ | ------------------------------- |
| WordPress deployment (with init + main containers) | Exists | Deploy sample YAML for practice |


## What to do in the exam

### Step 1: Scale to 0

```bash
kubectl scale deployment wordpress --replicas=0
```

### Step 2: Edit deployment

Add the same `resources` to both init container and main container:

```yaml
resources:
  requests:
    cpu: "200m"
    memory: "128Mi"
  limits:
    cpu: "300m"
    memory: "192Mi"
```

Adjust values so 3 pods fit on the node.

### Step 3: Scale back to 3

```bash
kubectl scale deployment wordpress --replicas=3
```

### Step 4: Verify

```bash
kubectl get pods
kubectl rollout status deployment wordpress
```

## How to Practice

1. Deploy sample WordPress with init + main containers (no resources). 2. Scale to 0, add resources (e.g. 200m CPU, 128Mi memory), scale to 3. 3. Verify pods stay Running.

## Docs

Resource management: [https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

---

---

# Question 11: cri-dockerd + Sysctl (Weight: 7%)

---

## 🎯 IN THE EXAM — DO THIS

1. `sudo dpkg -i ~/cri-dockerd_*.deb`
2. `sudo systemctl enable cri-docker.socket && sudo systemctl start cri-docker.socket`
3. Add sysctl: `net.bridge.bridge-nf-call-iptables=1`, `net.ipv4.ip_forward=1`, `net.ipv6.conf.all.forwarding=1`
4. `sudo sysctl --system`

---

## Understanding

- Install and enable **cri-dockerd** (CRI for Docker).
- Set sysctl parameters for Kubernetes networking.

## Prerequisites


| Item                          | Exam        | Practice                    |
| ----------------------------- | ----------- | --------------------------- |
| Package `~/cri-dockerd_*.deb` | In home dir | `wget` from GitHub releases |


## What to do in the exam

### Step 1: Install cri-dockerd

```bash
sudo dpkg -i ~/cri-dockerd_*.deb
```

### Step 2: Enable and start service

```bash
sudo systemctl enable cri-docker.socket
sudo systemctl start cri-docker.socket
sudo systemctl status cri-docker.socket
```

### Step 3: Set sysctl

Create/update `/etc/sysctl.d/kubernetes.conf`:

```
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

Apply:

```bash
sudo sysctl --system
```

## How to Practice

1. Download cri-dockerd .deb to home dir. 2. Run dpkg, enable/start socket. 3. Create sysctl config, run `sysctl --system`. 4. Verify: `systemctl status cri-docker.socket`.

## Docs

[https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/dual-stack-support/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/dual-stack-support/)

---

---

# Question 12: CRDs + JSONPath (Weight: 7%)

---

## 🎯 IN THE EXAM — DO THIS

1. `kubectl get crd | grep cert > custom-crd.txt`
2. `kubectl get crd certificates.cert-manager.io -o jsonpath='{.spec.versions[*].schema.openAPIV3Schema.properties.spec.properties.subject}' > cert-manager-subject.txt`
3. Verify file contents

---

## Understanding

- List cert-manager CRDs → save to file.
- Extract `subject` field from `certificates.cert-manager.io` CRD schema → save to file.

## Prerequisites


| Item                        | Exam          | Practice                                                                                                        |
| --------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------- |
| cert-manager CRDs installed | Pre-installed | `kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml` |


## What to do in the exam

### Step 1: List cert-manager CRDs

```bash
kubectl get crd | grep cert > custom-crd.txt
```

### Step 2: Get subject field from certificates CRD

```bash
kubectl get crd certificates.cert-manager.io -o jsonpath='{.spec.versions[*].schema.openAPIV3Schema.properties.spec.properties.subject}' > cert-manager-subject.txt
```

Verify:

```bash
cat custom-crd.txt
cat cert-manager-subject.txt
```

## How to Practice

1. `kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml`. 2. Run both commands. 3. Verify files contain expected output.

## Docs

cert-manager: [https://cert-manager.io/docs/](https://cert-manager.io/docs/)

---

---

# Question 13: Network Policy (Least Permissive) (Weight: 10%)

---

## 🎯 IN THE EXAM — DO THIS

1. Choose the YAML with **podSelector + namespaceSelector only** (no ipBlock)
2. Apply in backend namespace
3. Verify frontend can reach backend, others cannot

---

## Understanding

- Apply the **least permissive** policy that allows frontend → backend.
- Policy 1: too open (empty selectors).
- Policy 2: podSelector + namespaceSelector (recommended).
- Policy 3: adds ipBlock (CIDR) – more open if not needed.
- Choose Policy 2 unless CIDR is required.

## Prerequisites


| Item                                                           | Exam    | Practice            |
| -------------------------------------------------------------- | ------- | ------------------- |
| Deployments `frontend` (ns: frontend), `backend` (ns: backend) | Exist   | Create for practice |
| CNI with NetworkPolicy support                                 | Present | Calico / Cilium     |


## What to do in the exam

Choose the YAML that uses **podSelector + namespaceSelector** only (no ipBlock). Apply it in the backend namespace:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-backend
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: frontend
      podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

## How to Practice

1. Create ns `frontend` and `backend`, deploy frontend + backend. 2. Apply Policy 2. 3. From frontend pod: `curl backend.backend:8080` should work. 4. From other ns: should be denied (if default deny).

## Docs

Network Policies: [https://kubernetes.io/docs/concepts/services-networking/network-policies/](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

---

---

# Question 14: CoreDNS Custom Domain

---

## 🎯 IN THE EXAM — DO THIS

1. `kubectl -n kube-system get configmap coredns -o yaml > /opt/course/16/coredns_backup.yaml`
2. Edit ConfigMap: add `custom-domain` to kubernetes block (`kubernetes custom-domain cluster.local ...`)
3. `kubectl -n kube-system rollout restart deployment coredns`
4. Test: `nslookup kubernetes.default.svc.cluster.local` and `nslookup kubernetes.default.svc.custom-domain` (both return same IP)

---

## Understanding

- Add DNS resolution for `SERVICE.NAMESPACE.custom-domain` so it works like `SERVICE.NAMESPACE.svc.cluster.local`.
- Backup CoreDNS ConfigMap before changes.
- Edit Corefile to add `custom-domain` to the kubernetes plugin.

## Prerequisites


| Item                                     | Exam  | Practice         |
| ---------------------------------------- | ----- | ---------------- |
| Path for backup (e.g. `/opt/course/16/`) | Given | Create directory |


## What to do in the exam

### Step 1: Backup

```bash
kubectl -n kube-system get configmap coredns -o yaml > /opt/course/16/coredns_backup.yaml
```

### Step 2: Edit CoreDNS ConfigMap

```bash
kubectl -n kube-system edit configmap coredns
```

In the `Corefile` block, change:

```
kubernetes cluster.local in-addr.arpa ip6.arpa
```

to:

```
kubernetes custom-domain cluster.local in-addr.arpa ip6.arpa
```

### Step 3: Restart CoreDNS

```bash
kubectl -n kube-system rollout restart deployment coredns
```

### Step 4: Test

```bash
kubectl run dns-test --rm -it --image=busybox:1 -- nslookup kubernetes.default.svc.cluster.local
kubectl run dns-test --rm -it --image=busybox:1 -- nslookup kubernetes.default.svc.custom-domain
```

Both should return the same IP.

## How to Practice

1. Backup CoreDNS ConfigMap first. 2. Edit ConfigMap, add `custom-domain` to Corefile. 3. Restart CoreDNS. 4. Run busybox nslookup for both domains; both should resolve to same IP.

## Docs

CoreDNS: [https://coredns.io/plugins/kubernetes/](https://coredns.io/plugins/kubernetes/)

---

---

# Question 15: Node + crictl (Pod Container ID & Logs)

---

## 🎯 IN THE EXAM — DO THIS

1. Create pod `tigers-reunite` with labels; find node with `kubectl get pod -o wide`
2. SSH to that node
3. `crictl ps -a | grep tigers-reunite` → get container ID
4. Write to files: container ID + runtimeType, then `crictl logs <id>` (paths per question)

---

## Understanding

- Create a pod on a specific node, SSH to that node, and use **crictl** to find the container, get its ID and `runtimeType`, and export logs.
- Outputs: container ID + `info.runtimeType` → file; logs → file.

## Prerequisites


| Item                                            | Exam      | Practice              |
| ----------------------------------------------- | --------- | --------------------- |
| Namespace `project-tiger`                       | Exists    | Create                |
| SSH access to worker nodes                      | Available | Use exam-provided SSH |
| Paths (e.g. `/course/17/` or `/opt/course/17/`) | Given     | Create directories    |


## What to do in the exam

### Step 1: Create pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tigers-reunite
  namespace: project-tiger
  labels:
    pod: container
    container: pod
spec:
  containers:
  - name: webserver
    image: httpd:2-alpine
```

```bash
kubectl apply -f pod.yaml
```

### Step 2: Find node

```bash
kubectl get pod tigers-reunite -n project-tiger -o wide
```

### Step 3: SSH to node

```bash
ssh cka2556-node1   # or node2, per question
```

### Step 4: Find container with crictl

```bash
crictl ps -a | grep tigers-reunite
# Note the CONTAINER_ID
```

### Step 5: Get runtimeType

```bash
crictl inspect <container-id> | grep runtimeType
```

### Step 6: Write to files (paths as per question)

```bash
echo "<container-id>" > /course/17/pod-container.txt
crictl inspect <container-id> | grep runtimeType >> /course/17/pod-container.txt
crictl logs <container-id> > /opt/course/17/pod-container.log
```

## How to Practice

1. Create ns `project-tiger`, create pod. 2. Use `kubectl debug node/<node> -it --image=busybox` or SSH if you have multi-node. 3. Use `crictl` to find container ID, inspect, logs. 4. Write to files in /tmp for practice.

## Docs

crictl: [https://github.com/kubernetes-sigs/cri-tools](https://github.com/kubernetes-sigs/cri-tools)

---

---

# Question 16: Network Policy (Port + Namespace)

---

## 🎯 IN THE EXAM — DO THIS

1. Create NetworkPolicy `allow-port-from-namespace` in ns `foobar`
2. Ingress: from `internal-ns` only, to port 9000
3. `kubectl apply -f networkpolicy.yaml`

---

## Understanding

- Allow only pods in namespace `internal-ns` to connect to port 9000 of pods in namespace `foobar`.
- Policy must not allow access to pods that don’t listen on 9000 (use `podSelector` + `ports`).
- Policy must not allow access from pods outside `internal-ns` (use `namespaceSelector`).

## Prerequisites


| Item                               | Exam   | Practice |
| ---------------------------------- | ------ | -------- |
| Namespaces `foobar`, `internal-ns` | Exist  | Create   |
| nginx pod in `foobar`              | Exists | Deploy   |


## What to do in the exam

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-port-from-namespace
  namespace: foobar
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: internal-ns
    ports:
    - protocol: TCP
      port: 9000
```

```bash
kubectl apply -f networkpolicy.yaml
kubectl get networkpolicies -n foobar
```

## How to Practice

1. Create ns `foobar`, `internal-ns` (label if needed). 2. Deploy nginx in foobar listening on 9000. 3. Apply policy. 4. From internal-ns: curl foobar:9000 works; from elsewhere: denied.

## Docs

Network Policies: [https://kubernetes.io/docs/concepts/services-networking/network-policies/](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

---

---

# Question 17: Count Ready Nodes (Excluding NoSchedule)

---

## 🎯 IN THE EXAM — DO THIS

1. `kubectl describe nodes` → identify nodes with NoSchedule taint
2. Count nodes that are Ready and NOT NoSchedule
3. `echo "<number>" > /opt/KUSC00402/kusc00402.txt`

---

## Understanding

- Count nodes that are Ready and do **not** have a NoSchedule taint.
- Write the number to the specified file.

## What to do in the exam

### Step 1: List nodes and taints

```bash
kubectl describe nodes | grep -A5 Taints
kubectl get nodes
```

### Step 2: Exclude NoSchedule nodes and count

```bash
# Manually count or use:
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.taints[*].key}{"\n"}{end}' | grep -v NoSchedule
```

### Step 3: Write count to file

```bash
echo "2" > /opt/KUSC00402/kusc00402.txt   # Replace 2 with actual count
```

## How to Practice

1. Create cluster with some nodes. 2. Taint one node with NoSchedule. 3. Count ready non-NoSchedule nodes manually. 4. Write count to file.

## Docs

Taints/Tolerations: [https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

---

---

# Question 18: Node NotReady — Fix kubelet

---

## 🎯 IN THE EXAM — DO THIS

1. SSH to NotReady worker node
2. `sudo systemctl start kubelet && sudo systemctl enable kubelet`
3. Exit; `kubectl get nodes` → node should be Ready

---

## Understanding

- Worker node is NotReady.
- Often caused by stopped kubelet.
- Fix by starting and enabling kubelet on that node.

## What to do in the exam

### Step 1: Switch context and identify node

```bash
kubectl get nodes
```

### Step 2: SSH to NotReady worker

```bash
ssh wk8s-node-0K0032005   # or node name from question
```

### Step 3: Start and enable kubelet

```bash
sudo systemctl start kubelet
sudo systemctl enable kubelet
sudo systemctl status kubelet
```

### Step 4: Exit and verify

```bash
exit
kubectl get nodes
```

## How to Practice

1. Use kubeadm cluster. 2. SSH to worker, `systemctl stop kubelet` to simulate NotReady. 3. Fix with start+enable. 4. Verify node becomes Ready.

## Docs

Troubleshooting: [https://kubernetes.io/docs/tasks/debug/](https://kubernetes.io/docs/tasks/debug/)

---

---

# Question 19: kubeadm Upgrade (v1.30.1)

---

## 🎯 IN THE EXAM — DO THIS

1. Drain control plane (if asked)
2. SSH to master, upgrade kubeadm/kubelet/kubectl to specified version
3. `kubeadm upgrade apply vX.Y.Z`
4. `systemctl restart kubelet`; uncordon control plane

---

## Understanding

- Upgrade control plane to a specified version (e.g. 1.30.1) using kubeadm.
- Drain control plane first if instructed.
- Run upgrade on master node only.

## What to do in the exam

### Step 1: Switch context

```bash
kubectl config use-context <context>
```

### Step 2: Drain control plane (if required)

```bash
kubectl drain controlplane --ignore-daemonsets --delete-emptydir-data
```

### Step 3: SSH to master

```bash
ssh controlplane   # or master node name
sudo -i
```

### Step 4: Upgrade kubeadm, kubelet, kubectl

```bash
# Example for 1.30.1
apt-mark unhold kubeadm kubelet kubectl
apt-get update && apt-get install -y kubeadm=1.30.1-00 kubelet=1.30.1-00 kubectl=1.30.1-00
apt-mark hold kubeadm kubelet kubectl

kubeadm upgrade plan
kubeadm upgrade apply v1.30.1

systemctl daemon-reload
systemctl restart kubelet
```

### Step 5: Uncordon (from another terminal)

```bash
kubectl uncordon controlplane
```

## How to Practice

1. Create kubeadm cluster. 2. Note current version. 3. Drain, upgrade kubeadm/kubelet/kubectl per docs. 4. Apply upgrade, restart kubelet, uncordon. 5. Verify `kubectl version`.

## Docs

[https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

---

---

# Question 20: TLS 1.3 Only (Nginx ConfigMap)

---

## 🎯 IN THE EXAM — DO THIS

1. Edit ConfigMap: change `ssl_protocols TLSv1.2 TLSv1.3` → `ssl_protocols TLSv1.3`
2. `kubectl rollout restart deployment <name> -n webapp`
3. Verify: `curl -k --tls-max 1.2` fails, `curl -k --tls-max 1.3` succeeds

---

## Understanding

- Nginx is configured via ConfigMap.
- Disable TLS 1.2, allow only TLS 1.3.
- Update ConfigMap and restart deployment so changes take effect.

## Prerequisites


| Item                              | Exam   | Practice            |
| --------------------------------- | ------ | ------------------- |
| Deployment with nginx + ConfigMap | Exists | Create for practice |
| TLS secret                        | Exists | Create for practice |


## What to do in the exam

### Step 1: Edit ConfigMap

```bash
kubectl edit configmap nginx-config -n webapp
# Or: kubectl get configmap nginx-config -n webapp -o yaml > cm.yaml, edit, apply
```

Change:

```
ssl_protocols TLSv1.2 TLSv1.3;
```

to:

```
ssl_protocols TLSv1.3;
```

### Step 2: Restart deployment

```bash
kubectl rollout restart deployment webapp -n webapp
```

### Step 3: Verify

```bash
curl -k --tls-max 1.2 https://localhost:30443   # Should FAIL
curl -k --tls-max 1.3 https://localhost:30443   # Should SUCCEED
```

## How to Practice

1. Create ns webapp, TLS secret, ConfigMap with `ssl_protocols TLSv1.2 TLSv1.3`, deployment, NodePort svc. 2. Verify both TLS 1.2 and 1.3 work. 3. Edit ConfigMap to TLSv1.3 only, rollout restart. 4. Verify TLS 1.2 fails, 1.3 works.

## Docs

ConfigMaps: [https://kubernetes.io/docs/concepts/configuration/configmap/](https://kubernetes.io/docs/concepts/configuration/configmap/)

---

---

# Question 21: Ingress (echo server)

---

## 🎯 IN THE EXAM — DO THIS

1. Create Ingress: host `example.org`, path `/echo`, backend `echo-server:8080`
2. Add annotation `nginx.ingress.kubernetes.io/rewrite-target: /` if needed
3. Verify: `curl -o /dev/null -s -w "%{http_code}\n" http://example.org/echo` → 200

---

## Understanding

- Expose `echo-server` service at `http://example.org/echo` on port 80.
- Use Nginx Ingress with path `/echo`, pathType `Prefix`.

## Prerequisites


| Item                           | Exam      | Practice                                     |
| ------------------------------ | --------- | -------------------------------------------- |
| Namespace, deployment, service | May exist | Create deployment + service                  |
| Ingress controller             | Installed | Install ingress-nginx for practice           |
| Host entry for example.org     | May exist | `echo "127.0.0.1 example.org" >> /etc/hosts` |


## What to do in the exam

### Step 1: Create deployment + service (if needed)

Ensure `echo-server` deployment and service exist, selector `app: echo-server`, service port 8080 → targetPort 5678 (or as per app).

### Step 2: Create Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo-ingress
  namespace: sound-repeater
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: example.org
    http:
      paths:
      - path: /echo
        pathType: Prefix
        backend:
          service:
            name: echo-server
            port:
              number: 8080
```

### Step 3: Verify

```bash
curl -o /dev/null -s -w "%{http_code}\n" http://example.org/echo
# Expect 200
```

## How to Practice

1. Install ingress-nginx. 2. Create ns, deployment (hashicorp/http-echo), service. 3. Create Ingress for host example.org, path /echo. 4. Add hosts entry. 5. curl [http://example.org/echo](http://example.org/echo), check 200.

## Docs

Ingress: [https://kubernetes.io/docs/concepts/services-networking/ingress/](https://kubernetes.io/docs/concepts/services-networking/ingress/)

---

---

# Question 22: Cluster Broken (etcd / kube-apiserver)

---

## 🎯 IN THE EXAM — DO THIS

1. SSH to control plane
2. Check `/etc/kubernetes/manifests/` — etcd.yaml, kube-apiserver.yaml
3. Fix wrong args (e.g. --etcd-servers, cert paths)
4. `systemctl restart kubelet`
5. Verify `kubectl get nodes` works

---

## Understanding

- Cluster is broken (e.g. after migration).
- Often caused by incorrect manifests in `/etc/kubernetes/manifests/` (etcd, kube-apiserver).
- Static pods are managed by kubelet; fixing YAML and restarting kubelet can restore them.

## What to do in the exam

### Step 1: SSH to control plane

```bash
ssh controlplane
```

### Step 2: Check manifests

```bash
cd /etc/kubernetes/manifests/
ls -la
```

### Step 3: Inspect and fix

- `etcd.yaml`: verify paths, certs, `--etcd-servers`, etc.
- `kube-apiserver.yaml`: verify `--etcd-servers` and other flags.

Common issues:

- Wrong `--etcd-servers` URL
- Missing or wrong cert paths
- Typos in args

### Step 4: Restart kubelet

```bash
systemctl restart kubelet
```

### Step 5: Verify

```bash
kubectl get nodes
kubectl get pods -A
```

## How to Practice

1. Use kubeadm cluster. 2. Corrupt etcd.yaml (e.g. wrong --etcd-servers). 3. Observe cluster broken. 4. Fix YAML, restart kubelet. 5. Verify cluster recovers.

## Docs

Static Pods: [https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/](https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/)

---

---

# Practice Lab Setup (Summary)

For local practice, use Kind or minikube and:

1. Create namespaces as needed.
2. Deploy sample apps (nginx, MariaDB, WordPress, etc.).
3. Install ArgoCD CRDs, cert-manager CRDs, Gateway API, nginx-gateway-fabric.
4. Create PVs, StorageClasses, TLS secrets.
5. Run through each question end-to-end and verify with `kubectl`, `curl`, and file checks.

---

# Quick Exam Checklist

- Switch to correct cluster context
- Verify prerequisites before creating resources
- Use `--dry-run=client -o yaml` when helpful
- Match namespaces, names, ports, and file paths exactly
- Restart deployment after ConfigMap changes
- Do not modify existing Deployments/PVCs unless asked
- Save outputs to the exact paths specified
- Use docs for YAML structure and examples

