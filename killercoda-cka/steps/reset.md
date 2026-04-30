# Reset and Practice Again

When you want to **practice again** with a clean state:

---

## Run the Reset Script

```bash
./scripts/reset-and-practice.sh
```

This will:

1. **Remove** what you created (HPAs, services, network policies, Gateways, etc.)
2. **Restore** prerequisites to their original state
3. **Re-run** setup to ensure everything is ready
4. **Display** your practice tasks again

---

## What Gets Reset

| Removed (Your Work) | Restored |
|--------------------|----------|
| HPA `apache-server` | Deployment `apache-server` |
| Service `front-end-svc` | Deployment `front-end` |
| Sidecar container | Deployment `synergy-leverager` (main only) |
| PriorityClass `high-priority` | Deployment `busybox-logger` |
| StorageClass `local-path` | — |
| ArgoCD from `~/argo-helm.yaml` | — |
| PVC `mariadb`, deploy mariadb | PV retained |
| Gateway, HTTPRoute | — |
| NetworkPolicies | — |
| Ingress `echo-ingress` | — |
| ConfigMap changes (Q20) | TLSv1.2 + TLSv1.3 |

---

## Practice Again

After reset, run the commands from the task list and practice the same questions again.

---

## Manual Reset (Alternative)

If the script fails, you can manually:

```bash
# Re-run setup only
./scripts/setup-cka-prerequisites.sh
```

Then manually delete any resources you created.
