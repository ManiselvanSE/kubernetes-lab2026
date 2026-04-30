# CKA Exam Practice Environment

Welcome! This environment simulates the **CKA exam setup** so you can practice **only your tasks**.

---

## What's Different from the Real Exam?

| In the Exam | In This Environment |
|-------------|---------------------|
| Prerequisites already exist | This setup creates them for you |
| You do your tasks | Same — you practice your tasks |
| 2 hours, limited resets | Practice as often as you like |

---

## What Has Been Set Up (EXAM ALREADY HAS)

- **Namespaces**: `auto-scale`, `spline-reticulator`, `priority`, `mariadb`, `argocd`, `webapp`, `frontend`, `backend`, `project-tiger`, `foobar`, `internal-ns`, `sound-repeater`
- **Deployments**: `apache-server`, `front-end`, `synergy-leverager`, `busybox-logger`, `wordpress`, `web`, `echo-server`, and others
- **Infrastructure**: PV for MariaDB, ArgoCD CRDs, cert-manager CRDs, TLS secrets, Helm repo `argo`
- **Cluster**: 2-node (controlplane + node01) for node-related tasks

---

## Your Tasks (What You Practice)

Open the terminal and run:

```bash
cat ~/cka-practice-tasks.txt
```

Or see the **Practice Your Tasks** step for question-by-question breakdown.

---

## To Practice Again

Run this to reset and get a fresh environment:

```bash
./scripts/reset-and-practice.sh
```

This removes what you created, restores prerequisites, and shows your tasks again.

---

> **Note**: Setup logs are in `/var/log/killercoda/cka-setup.log` if you need to debug.
