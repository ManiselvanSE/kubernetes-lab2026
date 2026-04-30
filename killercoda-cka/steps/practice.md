# Practice Your Exam Tasks

Use this step as your checklist. Each question shows **what's already there** and **what you do**.

---

## Quick Reference

| Q# | Your Task (In Exam) |
|----|---------------------|
| 1 | Create HPA (50% CPU, 1-4 pods) + `stabilizationWindowSeconds: 30` |
| 2 | Add `containerPort: 80` + create NodePort service `front-end-svc` |
| 3 | Add sidecar container (`busybox:stable`) with shared volume |
| 4 | Create `high-priority` (value 999) + patch `busybox-logger` |
| 5 | Create StorageClass `local-path` (WaitForFirstConsumer, default) |
| 6 | `helm template` ArgoCD v7.7.3, save to `~/argo-helm.yaml`, apply |
| 7 | Create PVC `mariadb` + deployment using PVC |
| 8 | Create Gateway `web-gateway` + HTTPRoute `web-route` |
| 10 | Scale 0 → add resources → scale 3 (wordpress) |
| 12 | `kubectl get crd \| grep cert > custom-crd.txt` + JSONPath to subject |
| 14 | Backup CoreDNS, add `custom-domain`, restart CoreDNS |
| 20 | Edit ConfigMap: `ssl_protocols TLSv1.3` only, rollout restart |
| 21 | Create Ingress for `example.org/echo` |

---

## View Full Task List

```bash
cat ~/cka-practice-tasks.txt
```

---

## Verify Your Work

After each task:

- **Q1**: `kubectl get hpa -n auto-scale -o yaml | grep -A2 stabilizationWindowSeconds`
- **Q2**: `kubectl get svc -n spline-reticulator` (NodePort)
- **Q3**: `kubectl get deploy synergy-leverager -o yaml | grep -A5 sidecar`
- **Q4**: `kubectl get pods -n priority` (others evicted)
- **Q5**: `kubectl get sc` (local-path default)
- **Q6**: `kubectl get pods -n argocd`
- **Q7**: `kubectl get pvc,pods -n mariadb`
- **Q20**: `curl -k --tls-max 1.2 https://localhost:30443` (fail) vs `--tls-max 1.3` (ok)
- **Q21**: `curl -o /dev/null -s -w "%{http_code}\n" http://example.org/echo` → 200

---

## Switch Context

Make sure you're on the right cluster:

```bash
kubectl config get-contexts
```
