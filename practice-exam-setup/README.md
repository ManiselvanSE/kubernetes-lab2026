# CKA Practice Exam Setup Scripts

Automated setup scripts for all 22 CKA practice questions.

## Quick Start

```bash
# Make scripts executable
chmod +x *.sh

# Set up all practice questions
./setup-all-questions.sh

# Or set up individual questions
./setup-question-01.sh
./setup-question-02.sh
# ... etc
```

## What These Scripts Do

Each script creates the **prerequisites** for practice questions, simulating the exam environment where:
- Namespaces already exist
- Some deployments are already created
- You need to perform specific tasks

## Requirements

- Kubernetes cluster (Kind, Minikube, or real cluster)
- kubectl configured
- metrics-server installed (for HPA questions)
- Helm installed (for Question 6)

## Script Organization

```
practice-exam-setup/
├── README.md                    # This file
├── setup-all-questions.sh       # Run all setup scripts
├── setup-question-01.sh         # HPA prerequisites
├── setup-question-02.sh         # Deployment + NodePort
├── setup-question-03.sh         # Sidecar prerequisites
├── ...
├── setup-question-22.sh         # Cluster troubleshooting
├── cleanup-all.sh               # Remove all practice resources
└── verify-setup.sh              # Verify prerequisites are ready
```

## Individual Question Setup

### Question 1: HPA
```bash
./setup-question-01.sh
```
Creates:
- Namespace `auto-scale`
- Deployment `apache-server`

### Question 2: Deployment + NodePort
```bash
./setup-question-02.sh
```
Creates:
- Namespace `spline-reticulator`
- Deployment `front-end` (without containerPort)

### Question 3: Sidecar
```bash
./setup-question-03.sh
```
Creates:
- Deployment `synergy-leverager` (without sidecar)

### Question 4: PriorityClass
```bash
./setup-question-04.sh
```
Creates:
- Namespace `priority`
- Deployment `busybox-logger`
- Existing PriorityClass with value 1000

### Question 5: StorageClass
```bash
./setup-question-05.sh
```
No prerequisites - just create the StorageClass.

### Question 6: ArgoCD Helm
```bash
./setup-question-06.sh
```
Creates:
- Namespace `argocd`
- ArgoCD CRDs (without main application)

### Question 7: MariaDB + PVC
```bash
./setup-question-07.sh
```
Creates:
- Namespace `mariadb`
- PV (retained, 250Mi)
- Deployment YAML file

### Question 8: Gateway API
```bash
./setup-question-08.sh
```
Creates:
- Namespace `webapp`
- Existing Ingress
- Service `web-service`
- TLS secret `web-tls`

### Question 9: CNI Installation
```bash
./setup-question-09.sh
```
Note: Requires cluster without CNI or removable CNI.

### Question 10: WordPress Resources
```bash
./setup-question-10.sh
```
Creates:
- WordPress deployment with init + main containers (no resources)

### Question 11: cri-dockerd
```bash
./setup-question-11.sh
```
Downloads cri-dockerd package to ~/

### Question 12: CRDs + JSONPath
```bash
./setup-question-12.sh
```
Installs cert-manager CRDs.

### Question 13: Network Policy
```bash
./setup-question-13.sh
```
Creates:
- Namespace `frontend`, `backend`
- Deployments in each namespace

### Question 14: CoreDNS
```bash
./setup-question-14.sh
```
Creates directory `/opt/course/16/` for backup.

### Question 15: crictl
```bash
./setup-question-15.sh
```
Creates:
- Namespace `project-tiger`
- Directories for output files

### Question 16: Network Policy Port
```bash
./setup-question-16.sh
```
Creates:
- Namespace `foobar`, `internal-ns`
- Nginx deployment in `foobar`

### Question 17: Count Nodes
```bash
./setup-question-17.sh
```
Creates:
- Directory `/opt/KUSC00402/`
- Taints some nodes (if multi-node cluster)

### Question 18: NotReady Node
```bash
./setup-question-18.sh
```
Note: Stops kubelet on worker node (requires multi-node cluster).

### Question 19: kubeadm Upgrade
```bash
./setup-question-19.sh
```
Note: No prerequisites, just follow upgrade procedure.

### Question 20: TLS 1.3
```bash
./setup-question-20.sh
```
Creates:
- Namespace `webapp`
- Nginx deployment with ConfigMap
- TLS configuration

### Question 21: Ingress
```bash
./setup-question-21.sh
```
Creates:
- Namespace `sound-repeater`
- Deployment `echo-server`
- Service `echo-server`

### Question 22: Cluster Troubleshoot
```bash
./setup-question-22.sh
```
Note: Intentionally breaks etcd/kube-apiserver manifests (requires control plane access).

## Cleanup

```bash
# Remove all practice resources
./cleanup-all.sh

# Or clean up individual questions
kubectl delete namespace auto-scale
kubectl delete namespace spline-reticulator
# ... etc
```

## Verification

```bash
# Verify all prerequisites are ready
./verify-setup.sh
```

## Tips for Using These Scripts

1. **Run one at a time** - Practice each question individually
2. **Reset between attempts** - Delete resources and re-run setup to practice again
3. **Time yourself** - Track how long each question takes
4. **Verify results** - Use `kubectl get`, `kubectl describe` to confirm your work
5. **Simulate exam pressure** - Set a timer, switch contexts, use only docs

## Practice Workflow

```bash
# 1. Set up question
./setup-question-01.sh

# 2. Read the question (from main guide)
# Task: Create HPA for apache-server...

# 3. Attempt the solution
kubectl autoscale deployment apache-server -n auto-scale --cpu-percent=50 --min=1 --max=4
# ... etc

# 4. Verify
kubectl get hpa -n auto-scale

# 5. Clean up
kubectl delete namespace auto-scale

# 6. Next question
./setup-question-02.sh
```

## Troubleshooting

### Script fails with "namespace already exists"
```bash
# Clean up first
./cleanup-all.sh
# Then re-run setup
```

### metrics-server not found
```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# For Kind/minikube, disable TLS
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
```

### Helm not found
```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

## Full Practice Exam Simulation

```bash
# Set up all questions
./setup-all-questions.sh

# Set a 2-hour timer
# Work through all questions in order
# Verify each answer before moving to next
# Track your score

# Clean up when done
./cleanup-all.sh
```

## Expected Time Per Question

Based on exam weights:

| Question | Weight | Expected Time | Topic |
|----------|--------|---------------|-------|
| Q1 | 7% | 8-10 min | HPA |
| Q2 | 10% | 5-7 min | Deployment + Service |
| Q3 | 15% | 10-12 min | Sidecar |
| Q4 | 11% | 6-8 min | PriorityClass |
| Q5 | 8% | 4-6 min | StorageClass |
| Q6 | 7% | 8-10 min | Helm |
| Q7 | 13% | 10-12 min | PVC + Deployment |
| Q8 | 12% | 12-15 min | Gateway API |
| Q9 | 9% | 5-7 min | CNI |
| Q10 | 9% | 8-10 min | Resources |
| Q11 | 7% | 5-7 min | cri-dockerd |
| Q12 | 7% | 4-6 min | JSONPath |
| Q13 | 10% | 8-10 min | NetworkPolicy |
| Q14 | - | 6-8 min | CoreDNS |
| Q15 | - | 10-12 min | crictl |
| Q16 | - | 6-8 min | NetworkPolicy |
| Q17 | - | 3-5 min | Count nodes |
| Q18 | - | 5-7 min | Fix node |
| Q19 | - | 15-20 min | kubeadm upgrade |
| Q20 | - | 5-7 min | TLS config |
| Q21 | - | 6-8 min | Ingress |
| Q22 | - | 10-15 min | Troubleshoot |

**Total:** ~120 minutes (2 hours)

## Additional Resources

- Main exam guide: `CKA_COMPLETE_HANDS_ON_EXAM_GUIDE.md`
- Quick reference: `CKA_QUICK_REFERENCE.md`
- Flashcards: `CKA_FLASHCARDS.md`

Good luck with your practice! 🚀
