# Certified Kubernetes Administrator (CKA) Exam
## Complete Hands-On Practice Guide - Step by Step

**Your Complete Guide to Passing the CKA Exam**

This guide provides detailed, beginner-friendly explanations with hands-on practice for every topic in the CKA exam. Follow this step-by-step to build your Kubernetes skills from the ground up.

---

## Table of Contents

### Part 1: Exam Overview & Setup
1. [Understanding the CKA Exam](#understanding-the-cka-exam)
2. [Setting Up Your Practice Environment](#setting-up-your-practice-environment)
3. [Essential kubectl Commands](#essential-kubectl-commands)
4. [Time Management & Exam Strategy](#time-management--exam-strategy)

### Part 2: Core Concepts (13% of exam)
5. [Pods - The Basic Building Block](#pods---the-basic-building-block)
6. [Deployments - Managing Multiple Pods](#deployments---managing-multiple-pods)
7. [Services - Connecting to Your Applications](#services---connecting-to-your-applications)
8. [Namespaces - Organizing Your Cluster](#namespaces---organizing-your-cluster)

### Part 3: Workloads & Scheduling (15% of exam)
9. [ReplicaSets & Scaling](#replicasets--scaling)
10. [Horizontal Pod Autoscaling (HPA)](#horizontal-pod-autoscaling-hpa)
11. [Priority Classes](#priority-classes)
12. [Multi-Container Pods & Sidecars](#multi-container-pods--sidecars)
13. [Resource Requests & Limits](#resource-requests--limits)

### Part 4: Storage (10% of exam)
14. [Understanding Storage in Kubernetes](#understanding-storage-in-kubernetes)
15. [Persistent Volumes (PV) & Claims (PVC)](#persistent-volumes--claims)
16. [Storage Classes](#storage-classes)
17. [Configuring Database Storage](#configuring-database-storage)

### Part 5: Networking (20% of exam)
18. [Kubernetes Networking Basics](#kubernetes-networking-basics)
19. [Network Policies - Controlling Traffic](#network-policies---controlling-traffic)
20. [Ingress - External Access](#ingress---external-access)
21. [Gateway API - Next Generation Ingress](#gateway-api---next-generation-ingress)
22. [CoreDNS - Service Discovery](#coredns---service-discovery)
23. [CNI Installation & Configuration](#cni-installation--configuration)

### Part 6: Security (15% of exam)
24. [RBAC - Role-Based Access Control](#rbac---role-based-access-control)
25. [Service Accounts](#service-accounts)
26. [Security Contexts](#security-contexts)
27. [TLS Configuration](#tls-configuration)

### Part 7: Cluster Maintenance (11% of exam)
28. [Node Maintenance & Draining](#node-maintenance--draining)
29. [Cluster Upgrades with kubeadm](#cluster-upgrades-with-kubeadm)
30. [Backup & Restore etcd](#backup--restore-etcd)

### Part 8: Troubleshooting (30% of exam)
31. [Troubleshooting Application Failures](#troubleshooting-application-failures)
32. [Troubleshooting Cluster Components](#troubleshooting-cluster-components)
33. [Troubleshooting Networking](#troubleshooting-networking)
34. [Working with crictl](#working-with-crictl)
35. [Node Troubleshooting](#node-troubleshooting)

### Part 9: Advanced Topics
36. [Custom Resource Definitions (CRDs)](#custom-resource-definitions-crds)
37. [JSONPath Queries](#jsonpath-queries)
38. [Helm Basics](#helm-basics)
39. [Container Runtime Configuration](#container-runtime-configuration)

### Part 10: Exam Practice Questions
40. [22 Practice Questions with Solutions](#22-practice-questions-with-solutions)

---

# Part 1: Exam Overview & Setup

## Understanding the CKA Exam

### What is the CKA?
The Certified Kubernetes Administrator (CKA) exam is a **hands-on, performance-based test** where you solve real-world Kubernetes problems in a live environment. Unlike multiple-choice tests, you actually work with real clusters.

### Exam Format
- **Duration:** 2 hours
- **Format:** Performance-based (hands-on tasks)
- **Passing Score:** 66%
- **Number of Questions:** 15-20 questions
- **Environment:** Remote-proctored, browser-based terminal
- **Allowed Resources:** Official Kubernetes documentation (kubernetes.io)

### What You Can and Cannot Do
✅ **Allowed:**
- Access kubernetes.io documentation
- Use kubectl commands
- Copy-paste from documentation
- Use built-in terminal tools (vim, nano, grep, etc.)

❌ **Not Allowed:**
- External websites (except kubernetes.io)
- Personal notes or cheat sheets
- Communication with others
- Multiple monitors (unless approved)

### Exam Domains & Weights
1. **Cluster Architecture, Installation & Configuration:** 25%
2. **Workloads & Scheduling:** 15%
3. **Services & Networking:** 20%
4. **Storage:** 10%
5. **Troubleshooting:** 30%

---

## Setting Up Your Practice Environment

### Option 1: Using Kind (Kubernetes in Docker) - Recommended for Beginners

**What is Kind?**
Kind (Kubernetes IN Docker) runs Kubernetes clusters using Docker containers as nodes. It's fast, lightweight, and perfect for practice.

**Step 1: Install Docker**
```bash
# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
# Log out and log back in for group changes to take effect
```

**Step 2: Install Kind**
```bash
# Download Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify installation
kind version
```

**Step 3: Install kubectl**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

**Step 4: Create Your First Cluster**
```bash
# Create a simple cluster
kind create cluster --name cka-practice

# Verify cluster is running
kubectl cluster-info
kubectl get nodes
```

**Step 5: Create a Multi-Node Cluster (More Realistic)**
```bash
# Create a config file for multi-node cluster
cat <<EOF > kind-multi-node.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOF

# Create the cluster
kind create cluster --name cka-multi --config kind-multi-node.yaml

# Verify
kubectl get nodes
```

### Option 2: Using Minikube

**Install Minikube**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start minikube
minikube start --nodes=2 --driver=docker

# Verify
kubectl get nodes
```

### Option 3: Using Killercoda (Online, No Installation)

Visit: https://killercoda.com/playgrounds/scenario/kubernetes
- Free online Kubernetes playground
- No installation required
- Great for quick practice
- Limited to 1 hour sessions

---

## Essential kubectl Commands

### Understanding kubectl Structure
Every kubectl command follows this pattern:
```bash
kubectl [command] [TYPE] [NAME] [flags]
```

**Examples:**
```bash
kubectl get pods                    # List all pods
kubectl describe pod my-pod         # Show details of a pod
kubectl delete deployment my-app    # Delete a deployment
kubectl create -f pod.yaml          # Create from file
```

### Most Important Commands for the Exam

#### 1. Getting Information (READ)
```bash
# List resources
kubectl get pods                          # All pods in current namespace
kubectl get pods -A                       # All pods in all namespaces
kubectl get pods -n my-namespace          # Pods in specific namespace
kubectl get pods -o wide                  # More details (IP, Node)
kubectl get pods -o yaml                  # Full YAML output
kubectl get pods -o json                  # JSON output

# Describe (detailed information)
kubectl describe pod my-pod
kubectl describe node worker-1
kubectl describe deployment my-app

# Logs
kubectl logs my-pod                       # View logs
kubectl logs my-pod -c container-name     # Logs from specific container
kubectl logs my-pod --previous            # Logs from previous container
kubectl logs -f my-pod                    # Follow logs (stream)
```

#### 2. Creating Resources (CREATE)
```bash
# Imperative (quick creation)
kubectl create deployment nginx --image=nginx
kubectl create service nodeport my-svc --tcp=80:80
kubectl create namespace dev

# From file
kubectl create -f pod.yaml
kubectl apply -f deployment.yaml

# Dry run (test without creating)
kubectl create deployment test --image=nginx --dry-run=client -o yaml
kubectl create deployment test --image=nginx --dry-run=client -o yaml > deployment.yaml
```

#### 3. Editing Resources (UPDATE)
```bash
# Edit in default editor
kubectl edit pod my-pod
kubectl edit deployment my-app

# Patch (partial update)
kubectl patch deployment my-app -p '{"spec":{"replicas":3}}'

# Set image
kubectl set image deployment/my-app nginx=nginx:1.19

# Scale
kubectl scale deployment my-app --replicas=5
```

#### 4. Deleting Resources (DELETE)
```bash
kubectl delete pod my-pod
kubectl delete deployment my-app
kubectl delete -f pod.yaml
kubectl delete pod --all                  # Delete all pods in namespace
```

#### 5. Executing Commands in Pods
```bash
kubectl exec my-pod -- ls /                        # Run command
kubectl exec -it my-pod -- /bin/bash              # Interactive shell
kubectl exec my-pod -c my-container -- env        # Execute in specific container
```

#### 6. Copying Files
```bash
kubectl cp my-pod:/path/to/file ./local-file      # From pod to local
kubectl cp ./local-file my-pod:/path/to/file      # From local to pod
```

#### 7. Context & Namespace
```bash
# View contexts
kubectl config get-contexts

# Switch context
kubectl config use-context my-cluster

# Set default namespace
kubectl config set-context --current --namespace=my-namespace

# View current context
kubectl config current-context
```

### Time-Saving Aliases (Set These Up!)
```bash
# Add to ~/.bashrc or ~/.zshrc
alias k=kubectl
alias kg='kubectl get'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias kaf='kubectl apply -f'
alias kcf='kubectl create -f'

# Auto-completion (VERY IMPORTANT for exam)
source <(kubectl completion bash)
# If using alias
complete -F __start_kubectl k
```

### Pro Tips for kubectl
1. **Use tab completion** - Press Tab to auto-complete commands
2. **Use --dry-run=client -o yaml** - Generate YAML templates quickly
3. **Use -o wide** - Get more information without describe
4. **Use -A** - See all namespaces at once
5. **Use explain** - Get field documentation: `kubectl explain pod.spec`

---

## Time Management & Exam Strategy

### Time Allocation Strategy

**Total Time: 120 minutes for ~17-20 questions**

#### Priority System
- **Flag questions** - If you're stuck for more than 5 minutes, flag it and move on
- **Do easy questions first** - Build confidence and bank points
- **Come back to flagged questions** - Use remaining time wisely

#### Time Budget
- **Easy questions (2-3 min each):** ~40 min for 15 questions
- **Medium questions (5-7 min each):** ~30 min for 5 questions
- **Hard questions (10+ min each):** ~30 min for 2-3 questions
- **Review time:** ~20 min

### Question Weight Strategy
Focus on high-weight questions:
- **13% question** = worth 2x as much as **7% question**
- If short on time, prioritize higher-weight questions

### Exam Tips

#### Before the Exam
1. **Know the documentation structure** - Practice finding information quickly
2. **Set up aliases and completion** - You can do this at the start of the exam
3. **Practice typing speed** - You'll be typing a lot
4. **Get comfortable with vim/nano** - You'll edit YAML files

#### During the Exam
1. **Read questions carefully** - Note the context, namespace, and exact requirements
2. **Switch context immediately** - Each question may use a different cluster
3. **Verify your work** - Run `kubectl get` to confirm your changes
4. **Save often** - If editing files, save frequently
5. **Watch for typos** - YAML is indentation-sensitive

#### Common Mistakes to Avoid
❌ Forgetting to switch context
❌ Creating resources in wrong namespace
❌ Not verifying your changes
❌ Spending too long on one question
❌ Forgetting to use the correct node (in SSH questions)

### Setup Script for Exam Start
```bash
# Run this at the beginning of the exam
# Set up aliases
alias k=kubectl
source <(kubectl completion bash)
complete -F __start_kubectl k

# Set vim preferences
echo "set expandtab" >> ~/.vimrc
echo "set tabstop=2" >> ~/.vimrc
echo "set shiftwidth=2" >> ~/.vimrc

# Export editor
export EDITOR=vim
```

---

# Part 2: Core Concepts

## Pods - The Basic Building Block

### What is a Pod?

**Simple Explanation:**
A Pod is the smallest deployable unit in Kubernetes. Think of it as a wrapper around one or more containers that run together on the same machine (node).

**Real-World Analogy:**
Imagine a pod as a small apartment. Just like an apartment can have one or more rooms (containers) that share utilities (network, storage), a Kubernetes pod groups containers that need to work closely together.

### Why Do We Need Pods?

Pods solve several problems:
1. **Co-location:** Containers in a pod run on the same machine
2. **Shared resources:** They share network and storage
3. **Lifecycle management:** Start, stop, and restart together
4. **Communication:** Containers can talk via localhost

### Hands-On: Create Your First Pod

#### Method 1: Imperative (Quick)
```bash
# Create a pod running nginx
kubectl run nginx-pod --image=nginx

# Verify it's running
kubectl get pods

# See more details
kubectl describe pod nginx-pod

# View logs
kubectl logs nginx-pod

# Delete the pod
kubectl delete pod nginx-pod
```

#### Method 2: Declarative (YAML - Preferred for exam)
```bash
# Generate YAML template
kubectl run nginx-pod --image=nginx --dry-run=client -o yaml > pod.yaml

# Edit the file
cat > pod.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    environment: development
spec:
  containers:
  - name: nginx-container
    image: nginx:1.21
    ports:
    - containerPort: 80
EOF

# Create the pod
kubectl apply -f pod.yaml

# Verify
kubectl get pod nginx-pod
kubectl describe pod nginx-pod
```

### Understanding Pod YAML

Let's break down each part:

```yaml
apiVersion: v1              # API version for this resource type
kind: Pod                   # Type of resource
metadata:                   # Information about the pod
  name: nginx-pod          # Name (must be unique in namespace)
  labels:                  # Key-value pairs for organization
    app: nginx            
    environment: dev       
spec:                      # Specification (what the pod should look like)
  containers:              # List of containers in this pod
  - name: nginx-container  # Container name
    image: nginx:1.21      # Docker image to use
    ports:                 # Ports the container exposes
    - containerPort: 80    # Port number
```

### Practice Exercise 1: Create a Multi-Container Pod

**Scenario:** Create a pod with two containers: a web server and a logging sidecar.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-with-logger
spec:
  containers:
  # Main web container
  - name: web-server
    image: nginx:alpine
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  
  # Logging sidecar container
  - name: log-reader
    image: busybox:latest
    command: ["/bin/sh"]
    args: ["-c", "tail -f /var/log/nginx/access.log"]
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  
  # Shared volume
  volumes:
  - name: logs
    emptyDir: {}
```

**Apply and Test:**
```bash
# Create the pod
kubectl apply -f multi-container-pod.yaml

# Verify both containers are running
kubectl get pod web-with-logger

# Check logs from the log-reader container
kubectl logs web-with-logger -c log-reader

# Execute into the web-server container
kubectl exec -it web-with-logger -c web-server -- /bin/sh
```

### Practice Exercise 2: Pod with Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
spec:
  containers:
  - name: env-test
    image: busybox:stable
    command: ['sh', '-c', 'echo "Database: $DB_HOST:$DB_PORT" && sleep 3600']
    env:
    - name: DB_HOST
      value: "mysql.database.svc.cluster.local"
    - name: DB_PORT
      value: "3306"
```

```bash
# Apply
kubectl apply -f env-pod.yaml

# Check logs to see environment variables
kubectl logs env-pod
```

### Pod Troubleshooting Commands

```bash
# Get pod status
kubectl get pods

# Detailed information
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous   # Previous container logs

# Execute commands in pod
kubectl exec <pod-name> -- <command>
kubectl exec -it <pod-name> -- /bin/bash

# Debug a failing pod
kubectl describe pod <pod-name> | grep -A 10 Events
kubectl logs <pod-name> --previous
```

### Common Pod States

| State | Meaning | Common Causes |
|-------|---------|---------------|
| `Pending` | Pod accepted but not running | Scheduling issues, image pull |
| `Running` | Pod is running on a node | Normal state |
| `Succeeded` | All containers terminated successfully | Completed job |
| `Failed` | All containers terminated, at least one failed | Application error |
| `CrashLoopBackOff` | Container keeps crashing | Application bug, wrong command |
| `ImagePullBackOff` | Cannot pull container image | Wrong image name, auth issues |

---

## Deployments - Managing Multiple Pods

### What is a Deployment?

**Simple Explanation:**
A Deployment manages a group of identical pods and ensures the desired number are always running. It handles updates, scaling, and self-healing automatically.

**Real-World Analogy:**
Think of a Deployment as a factory manager. If you tell the manager "I need 5 workers," they ensure exactly 5 are always working. If one quits (pod crashes), they hire a replacement automatically.

### Why Use Deployments Instead of Pods?

| Feature | Pod | Deployment |
|---------|-----|------------|
| Self-healing | ❌ If deleted, stays deleted | ✅ Automatically recreates |
| Scaling | ❌ Manual creation | ✅ Change replica count |
| Rolling updates | ❌ Delete and recreate | ✅ Zero-downtime updates |
| Rollback | ❌ Not possible | ✅ Undo to previous version |

### Hands-On: Create Your First Deployment

#### Quick Creation
```bash
# Create deployment with 3 replicas
kubectl create deployment nginx-app --image=nginx --replicas=3

# Verify
kubectl get deployments
kubectl get pods
kubectl get all
```

#### YAML Method (Exam Approach)
```bash
# Generate template
kubectl create deployment nginx-app --image=nginx --replicas=3 --dry-run=client -o yaml > deployment.yaml

# Create full YAML
cat > deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  labels:
    app: nginx
spec:
  replicas: 3                    # Number of pod copies
  selector:                      # How to find pods to manage
    matchLabels:
      app: nginx
  template:                      # Pod template
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
EOF

# Apply
kubectl apply -f deployment.yaml

# Watch pods being created
kubectl get pods -w
```

### Understanding Deployment Components

```
Deployment
    ↓ creates
ReplicaSet
    ↓ manages
Pods (replicas)
```

**Check this hierarchy:**
```bash
kubectl get deployment nginx-app
kubectl get replicaset
kubectl get pods
```

### Scaling Deployments

```bash
# Method 1: Imperative
kubectl scale deployment nginx-app --replicas=5

# Method 2: Edit
kubectl edit deployment nginx-app
# Change spec.replicas to desired number

# Method 3: Patch
kubectl patch deployment nginx-app -p '{"spec":{"replicas":10}}'

# Verify scaling
kubectl get pods
kubectl get deployment nginx-app
```

### Rolling Updates (Zero-Downtime Updates)

**What is a Rolling Update?**
Kubernetes gradually replaces old pods with new ones, ensuring your application stays available.

```bash
# Update image
kubectl set image deployment/nginx-app nginx=nginx:1.22

# Watch the rollout
kubectl rollout status deployment/nginx-app

# Check rollout history
kubectl rollout history deployment/nginx-app

# Rollback to previous version
kubectl rollout undo deployment/nginx-app

# Rollback to specific revision
kubectl rollout undo deployment/nginx-app --to-revision=2
```

### Practice Exercise 3: Complete Deployment Workflow

**Step 1: Create Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
  namespace: development
spec:
  replicas: 3
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
        version: v1
    spec:
      containers:
      - name: app
        image: nginx:1.21-alpine
        ports:
        - containerPort: 80
```

```bash
# Create namespace
kubectl create namespace development

# Apply deployment
kubectl apply -f webapp-deployment.yaml

# Verify
kubectl get deployment -n development
kubectl get pods -n development
```

**Step 2: Scale Up**
```bash
kubectl scale deployment webapp --replicas=5 -n development
kubectl get pods -n development -w
```

**Step 3: Update Image**
```bash
kubectl set image deployment/webapp app=nginx:1.22-alpine -n development
kubectl rollout status deployment/webapp -n development
```

**Step 4: Rollback**
```bash
kubectl rollout undo deployment/webapp -n development
kubectl rollout status deployment/webapp -n development
```

**Step 5: View History**
```bash
kubectl rollout history deployment/webapp -n development
kubectl rollout history deployment/webapp -n development --revision=2
```

### Deployment Strategies

#### 1. Rolling Update (Default)
Gradually replaces old pods with new ones.
```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1        # Max pods above desired count
      maxUnavailable: 0  # Max pods unavailable during update
```

#### 2. Recreate
Deletes all old pods before creating new ones (causes downtime).
```yaml
spec:
  strategy:
    type: Recreate
```

### Troubleshooting Deployments

```bash
# Check deployment status
kubectl get deployment
kubectl describe deployment <name>

# Check replicaset
kubectl get replicaset
kubectl describe replicaset <name>

# Check events
kubectl get events --sort-by=.metadata.creationTimestamp

# View rollout status
kubectl rollout status deployment/<name>

# Common issue: Image pull error
kubectl describe pod <pod-name> | grep -A 5 Events
```

---

## Services - Connecting to Your Applications

### What is a Service?

**Simple Explanation:**
A Service is a stable way to access a group of pods. While pods come and go (with changing IP addresses), a Service provides a permanent IP and DNS name.

**Real-World Analogy:**
Think of a Service like a restaurant's phone number. Even if the staff (pods) changes, customers always call the same number to reach the restaurant.

### Why Do We Need Services?

**Problems Services Solve:**
1. **Pods have temporary IPs:** When a pod dies, its replacement gets a new IP
2. **Load balancing:** Services distribute traffic across multiple pods
3. **Service discovery:** Access pods by name instead of IP
4. **External access:** Expose applications outside the cluster

### Types of Services

| Type | Use Case | Access From |
|------|----------|-------------|
| **ClusterIP** | Internal communication only | Inside cluster only |
| **NodePort** | External access via node IP:port | Outside cluster (development) |
| **LoadBalancer** | Production external access | Outside cluster (cloud providers) |
| **ExternalName** | Alias to external service | Inside cluster |

### Hands-On: ClusterIP Service (Internal Access)

**Scenario:** You have a deployment of web servers. Create a service to access them from other pods.

```yaml
# First, create a deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: app
        image: nginx:alpine
        ports:
        - containerPort: 80
---
# Create ClusterIP Service
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP          # Default type
  selector:
    app: backend           # Matches pod labels
  ports:
  - protocol: TCP
    port: 80               # Service port
    targetPort: 80         # Pod port
```

```bash
# Apply
kubectl apply -f backend-with-service.yaml

# Verify
kubectl get service backend-service
kubectl get endpoints backend-service    # Shows pod IPs

# Test from another pod
kubectl run test-pod --rm -it --image=busybox -- wget -O- http://backend-service
```

**What Just Happened?**
1. Service got a stable ClusterIP (e.g., 10.96.100.50)
2. DNS entry created: `backend-service.default.svc.cluster.local`
3. Traffic to service IP is load-balanced across all backend pods

### Hands-On: NodePort Service (External Access)

**Scenario:** Expose your application on each node's IP at a specific port (30000-32767).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: webapp-nodeport
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
  - protocol: TCP
    port: 80              # Service port
    targetPort: 80        # Pod port
    nodePort: 30080       # Port on each node (optional, auto-assigned if omitted)
```

```bash
# Create deployment first
kubectl create deployment webapp --image=nginx --replicas=2

# Apply service
kubectl apply -f nodeport-service.yaml

# Get node IP
kubectl get nodes -o wide

# Access from outside
# http://<NODE-IP>:30080
curl http://192.168.1.10:30080
```

**Quick Creation:**
```bash
kubectl expose deployment webapp --type=NodePort --port=80 --target-port=80 --name=webapp-nodeport
```

### Practice Exercise 4: Multi-Port Service

**Scenario:** Your application serves HTTP on 80 and HTTPS on 443.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: multi-port-service
spec:
  selector:
    app: web
  ports:
  - name: http           # Name is required for multi-port
    protocol: TCP
    port: 80
    targetPort: 8080
  - name: https
    protocol: TCP
    port: 443
    targetPort: 8443
```

### Service Discovery (DNS)

**Inside the Cluster:**
Kubernetes automatically creates DNS records for services.

**Format:**
```
<service-name>.<namespace>.svc.cluster.local
```

**Examples:**
```bash
# Same namespace
curl http://backend-service

# Different namespace
curl http://backend-service.production

# Fully qualified
curl http://backend-service.production.svc.cluster.local
```

**Test DNS:**
```bash
kubectl run dns-test --rm -it --image=busybox -- nslookup backend-service
```

### Practice Exercise 5: Complete Frontend-Backend Setup

```yaml
# Backend Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: webapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
      tier: api
  template:
    metadata:
      labels:
        app: backend
        tier: api
    spec:
      containers:
      - name: api
        image: nginx:alpine
        ports:
        - containerPort: 80
---
# Backend Service (ClusterIP)
apiVersion: v1
kind: Service
metadata:
  name: backend-api
  namespace: webapp
spec:
  type: ClusterIP
  selector:
    app: backend
    tier: api
  ports:
  - port: 80
    targetPort: 80
---
# Frontend Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
      tier: web
  template:
    metadata:
      labels:
        app: frontend
        tier: web
    spec:
      containers:
      - name: web
        image: nginx:alpine
        ports:
        - containerPort: 80
        env:
        - name: BACKEND_URL
          value: "http://backend-api"
---
# Frontend Service (NodePort)
apiVersion: v1
kind: Service
metadata:
  name: frontend-web
  namespace: webapp
spec:
  type: NodePort
  selector:
    app: frontend
    tier: web
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
```

```bash
# Create namespace
kubectl create namespace webapp

# Apply all resources
kubectl apply -f complete-app.yaml

# Verify
kubectl get all -n webapp

# Test frontend → backend communication
kubectl exec -it <frontend-pod> -n webapp -- wget -O- http://backend-api
```

### Service Troubleshooting

```bash
# Check service
kubectl get service <service-name>
kubectl describe service <service-name>

# Check endpoints (shows backend pod IPs)
kubectl get endpoints <service-name>

# If no endpoints, check:
# 1. Pod labels match service selector
kubectl get pods --show-labels
kubectl describe service <service-name> | grep Selector

# 2. Pods are running
kubectl get pods -l app=backend

# Test DNS resolution
kubectl run test --rm -it --image=busybox -- nslookup <service-name>

# Test connectivity
kubectl run test --rm -it --image=busybox -- wget -O- http://<service-name>
```

**Common Issues:**

| Issue | Cause | Solution |
|-------|-------|----------|
| No endpoints | Label mismatch | Fix selector or pod labels |
| Connection refused | Wrong port | Check targetPort matches containerPort |
| DNS not working | CoreDNS down | Check CoreDNS pods in kube-system |
| Service unreachable | Network policy | Check NetworkPolicies |

---

## Namespaces - Organizing Your Cluster

### What are Namespaces?

**Simple Explanation:**
Namespaces are virtual clusters within a physical cluster. They let you divide cluster resources between multiple teams or projects.

**Real-World Analogy:**
Think of namespaces like departments in a company. Each department (namespace) has its own resources, budgets (quotas), and access rules, but they all share the same building (cluster).

### Why Use Namespaces?

1. **Organization:** Separate dev, staging, and production
2. **Access control:** Different teams, different permissions
3. **Resource quotas:** Limit resources per namespace
4. **Name scoping:** Same resource name in different namespaces

### Default Namespaces

```bash
# List all namespaces
kubectl get namespaces
```

| Namespace | Purpose |
|-----------|---------|
| `default` | Default namespace for resources without a namespace |
| `kube-system` | Kubernetes system components (CoreDNS, kube-proxy) |
| `kube-public` | Public resources (readable by all) |
| `kube-node-lease` | Node heartbeat data |

### Hands-On: Working with Namespaces

```bash
# Create namespace (imperative)
kubectl create namespace development
kubectl create namespace staging
kubectl create namespace production

# Create namespace (declarative)
cat > namespace.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: testing
  labels:
    environment: test
EOF

kubectl apply -f namespace.yaml

# List namespaces
kubectl get namespaces

# Delete namespace (deletes all resources in it!)
kubectl delete namespace testing
```

### Working in Specific Namespaces

```bash
# Create resource in namespace
kubectl create deployment app --image=nginx -n development

# Get resources in namespace
kubectl get pods -n development
kubectl get all -n development

# Get resources in all namespaces
kubectl get pods -A
kubectl get pods --all-namespaces

# Set default namespace for current context
kubectl config set-context --current --namespace=development

# Verify current namespace
kubectl config view --minify | grep namespace:
```

### Practice Exercise 6: Multi-Namespace Application

**Scenario:** Deploy the same application to dev, staging, and production namespaces.

```bash
# Create namespaces
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace production

# Create deployment YAML
cat > app.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: app
        image: nginx:alpine
---
apiVersion: v1
kind: Service
metadata:
  name: webapp-service
spec:
  selector:
    app: webapp
  ports:
  - port: 80
EOF

# Deploy to each namespace
kubectl apply -f app.yaml -n dev
kubectl apply -f app.yaml -n staging
kubectl apply -f app.yaml -n production

# Verify
kubectl get all -n dev
kubectl get all -n staging
kubectl get all -n production
```

### Namespace Resource Quotas

**What are Resource Quotas?**
Limits on total resources (CPU, memory, pods) that a namespace can use.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    requests.cpu: "4"              # Total CPU requests
    requests.memory: 8Gi            # Total memory requests
    limits.cpu: "8"                 # Total CPU limits
    limits.memory: 16Gi             # Total memory limits
    pods: "10"                      # Max number of pods
    services: "5"                   # Max number of services
```

```bash
# Apply quota
kubectl apply -f resource-quota.yaml

# View quotas
kubectl get resourcequota -n development
kubectl describe resourcequota dev-quota -n development
```

### Namespace LimitRanges

**What are LimitRanges?**
Default and maximum resource limits for individual pods/containers in a namespace.

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-limits
  namespace: development
spec:
  limits:
  - max:                           # Maximum per container
      cpu: "1"
      memory: 1Gi
    min:                           # Minimum per container
      cpu: "100m"
      memory: 128Mi
    default:                       # Default limit if not specified
      cpu: "500m"
      memory: 512Mi
    defaultRequest:                # Default request if not specified
      cpu: "200m"
      memory: 256Mi
    type: Container
```

```bash
# Apply limit range
kubectl apply -f limit-range.yaml

# View limit ranges
kubectl get limitrange -n development
kubectl describe limitrange dev-limits -n development
```

### Cross-Namespace Communication

**Accessing Services Across Namespaces:**

```bash
# Format: <service-name>.<namespace>.svc.cluster.local

# From dev namespace, access staging service
curl http://webapp-service.staging.svc.cluster.local
```

**Example:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: dev
spec:
  containers:
  - name: app
    image: nginx
    env:
    - name: BACKEND_URL
      value: "http://backend-api.production.svc.cluster.local"
```

### Exam Tips for Namespaces

**⚠️ ALWAYS check the namespace in exam questions!**

```bash
# Common exam mistakes:
# ❌ Wrong: Creating in default namespace when question asks for specific namespace
kubectl create deployment app --image=nginx

# ✅ Correct: Creating in specified namespace
kubectl create deployment app --image=nginx -n webapp

# Set namespace for current session
kubectl config set-context --current --namespace=webapp
# Now all commands use webapp namespace by default

# Or use -n flag every time
kubectl get pods -n webapp
kubectl apply -f deployment.yaml -n webapp
```

---

# Part 3: Workloads & Scheduling

## Horizontal Pod Autoscaling (HPA)

### What is HPA?

**Simple Explanation:**
Horizontal Pod Autoscaler automatically scales the number of pods based on CPU usage, memory, or custom metrics. When load increases, it adds pods; when load decreases, it removes pods.

**Real-World Analogy:**
Think of HPA like a restaurant manager who calls in more waiters during busy hours and sends them home when it's quiet.

### How HPA Works

```
Metrics Server → Collects CPU/Memory metrics
       ↓
HPA Controller → Checks current vs target metrics
       ↓
Deployment/ReplicaSet → Adjusts replica count
       ↓
Pods → Scaled up or down
```

### Prerequisites: Install Metrics Server

```bash
# For Kind/Minikube
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# For Kind specifically, patch to disable TLS
kubectl patch deployment metrics-server -n kube-system --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# Verify metrics server is running
kubectl get pods -n kube-system | grep metrics-server

# Test metrics (wait 1-2 minutes after installation)
kubectl top nodes
kubectl top pods
```

### Hands-On: Create HPA

**Step 1: Create Deployment with Resource Requests**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-apache
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:                    # REQUIRED for HPA!
          requests:
            cpu: 200m                 # HPA calculates based on this
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
```

```bash
kubectl apply -f deployment.yaml
```

**Step 2: Create HPA (Imperative)**
```bash
# Scale between 1-10 pods when CPU > 50%
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

# Verify
kubectl get hpa
kubectl describe hpa php-apache
```

**Step 3: Create HPA (Declarative - Exam Method)**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50      # Scale when avg CPU > 50%
  behavior:                          # Optional: control scaling behavior
    scaleDown:
      stabilizationWindowSeconds: 30  # Wait 30s before scaling down
      policies:
      - type: Percent
        value: 50                     # Max 50% of pods removed at once
        periodSeconds: 15
    scaleUp:
      stabilizationWindowSeconds: 0   # Scale up immediately
      policies:
      - type: Percent
        value: 100                    # Max 100% of pods added at once
        periodSeconds: 15
```

```bash
kubectl apply -f hpa.yaml
kubectl get hpa
```

### Testing HPA

```bash
# Generate load
kubectl run load-generator --rm -it --image=busybox -- /bin/sh
# Inside the pod:
while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done

# In another terminal, watch HPA
kubectl get hpa -w

# Watch pods scaling up
kubectl get pods -w

# Stop load generator (Ctrl+C in first terminal)
# Watch pods scaling down
kubectl get hpa -w
```

### Practice Exercise 7: HPA with Custom Stabilization

**Exam Question Style:**
*Create an HPA for the deployment `apache-server` in namespace `auto-scale`. Set CPU target to 50%, min replicas 1, max replicas 4. Configure scale-down stabilization window to 30 seconds.*

**Solution:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: apache-server-hpa
  namespace: auto-scale
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: apache-server
  minReplicas: 1
  maxReplicas: 4
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

```bash
# Create namespace and deployment first (exam prerequisite)
kubectl create namespace auto-scale
kubectl create deployment apache-server --image=nginx -n auto-scale
kubectl set resources deployment apache-server -n auto-scale --requests=cpu=100m

# Apply HPA
kubectl apply -f hpa.yaml

# Verify
kubectl get hpa -n auto-scale
kubectl describe hpa apache-server-hpa -n auto-scale
```

### HPA with Memory Metrics

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: memory-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 70       # Scale when avg memory > 70%
```

### HPA with Multiple Metrics (CPU + Memory)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: multi-metric-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: webapp
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 60
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Troubleshooting HPA

```bash
# Check HPA status
kubectl get hpa
kubectl describe hpa <hpa-name>

# Common issues:

# 1. Metrics not available
kubectl top pods              # Should show CPU/memory
kubectl get pods -n kube-system | grep metrics-server

# 2. No resource requests defined
kubectl describe deployment <name> | grep -A 5 Requests

# 3. Check events
kubectl describe hpa <hpa-name> | grep Events

# 4. Current metrics
kubectl get hpa <hpa-name> -o yaml | grep currentMetrics -A 10
```

**Common Error Messages:**

| Error | Cause | Solution |
|-------|-------|----------|
| `unable to get metrics` | Metrics server not running | Install/fix metrics-server |
| `missing request for cpu` | No resource requests in deployment | Add resources.requests.cpu |
| `failed to get cpu utilization` | Pods not ready | Wait for pods to be Running |

### Exam Tips for HPA

1. **Always check if metrics-server is running** (usually pre-installed in exam)
2. **Deployment MUST have resource requests** - HPA can't work without them
3. **Use kubectl autoscale for quick creation, then edit YAML for behavior**
4. **Verify HPA is working:** `kubectl get hpa` shows current/target metrics
5. **Know the stabilization window** - prevents flapping (rapid scale up/down)

---

## Priority Classes

### What is PriorityClass?

**Simple Explanation:**
PriorityClass determines which pods are more important. When resources are scarce, Kubernetes can evict (kill) lower-priority pods to make room for higher-priority ones.

**Real-World Analogy:**
Think of priority classes like emergency room triage. Critical patients (high-priority pods) get treatment first, and less urgent cases (low-priority pods) might wait or be sent elsewhere.

### How Priority Works

1. **Scheduling:** Higher priority pods are scheduled before lower priority
2. **Preemption:** Higher priority pods can evict lower priority pods to get resources
3. **Value:** Higher number = higher priority

### Hands-On: Create PriorityClass

**Step 1: Check Existing PriorityClasses**
```bash
kubectl get priorityclass
```

You'll see system priority classes:
```
NAME                      VALUE        GLOBAL-DEFAULT   AGE
system-cluster-critical   2000000000   false            30d
system-node-critical      2000001000   false            30d
```

**Step 2: Create Custom PriorityClass**
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000                           # Priority value (higher = more important)
preemptionPolicy: PreemptLowerPriority  # Can evict lower priority pods
globalDefault: false                  # Not default for all pods
description: "High priority for critical workloads"
```

```bash
kubectl apply -f priorityclass.yaml
kubectl get priorityclass high-priority
```

**Step 3: Use PriorityClass in Pod/Deployment**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: critical-pod
spec:
  priorityClassName: high-priority    # Use the PriorityClass
  containers:
  - name: nginx
    image: nginx
```

### Practice Exercise 8: Priority and Preemption

**Exam Question Style:**
*In namespace `priority`, there's a deployment `busybox-logger`. Find the highest user-defined PriorityClass value, create a new PriorityClass named `high-priority` with value one less than the highest, and configure it to allow preemption. Then update the `busybox-logger` deployment to use this PriorityClass.*

**Solution:**

**Step 1: Find Highest Priority Value**
```bash
# Get all priority classes
kubectl get priorityclass

# Example output:
# NAME                      VALUE
# system-cluster-critical   2000000000
# system-node-critical      2000001000
# existing-priority         1000          ← Highest user-defined

# Highest user-defined is 1000, so create with value 999
```

**Step 2: Create PriorityClass**
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 999                            # One less than 1000
preemptionPolicy: PreemptLowerPriority
globalDefault: false
description: "High priority class"
```

```bash
kubectl apply -f high-priority.yaml
```

**Step 3: Patch Deployment**
```bash
# Method 1: Patch
kubectl patch deployment busybox-logger -n priority --type='merge' -p '
{
  "spec": {
    "template": {
      "spec": {
        "priorityClassName": "high-priority"
      }
    }
  }
}'

# Method 2: Edit
kubectl edit deployment busybox-logger -n priority
# Add under spec.template.spec:
#   priorityClassName: high-priority

# Verify
kubectl get deployment busybox-logger -n priority -o yaml | grep priorityClassName
```

### Testing Priority and Preemption

**Setup: Create Scenario with Limited Resources**

```yaml
# Low priority deployment (will be evicted)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: low-priority-app
  namespace: priority
spec:
  replicas: 3
  selector:
    matchLabels:
      app: low
  template:
    metadata:
      labels:
        app: low
    spec:
      priorityClassName: low-priority
      containers:
      - name: app
        image: nginx
        resources:
          requests:
            memory: "500Mi"
            cpu: "500m"
---
# High priority deployment (will cause preemption)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: high-priority-app
  namespace: priority
spec:
  replicas: 3
  selector:
    matchLabels:
      app: high
  template:
    metadata:
      labels:
        app: high
    spec:
      priorityClassName: high-priority
      containers:
      - name: app
        image: nginx
        resources:
          requests:
            memory: "1Gi"
            cpu: "1"
```

```bash
# Create priority classes first
cat <<EOF | kubectl apply -f -
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 100
preemptionPolicy: PreemptLowerPriority
---
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000
preemptionPolicy: PreemptLowerPriority
EOF

# Apply deployments
kubectl apply -f priority-test.yaml

# Watch pods being evicted and rescheduled
kubectl get pods -n priority -w

# Check events for preemption
kubectl get events -n priority --sort-by='.lastTimestamp'
```

### Understanding Preemption

**What Happens During Preemption:**
1. High-priority pod needs to be scheduled
2. Not enough resources available
3. Scheduler finds lower-priority pods
4. Lower-priority pods are evicted (deleted)
5. Resources freed up
6. High-priority pod is scheduled

**Check Preemption Events:**
```bash
kubectl describe pod <preempted-pod-name>
# Look for: "Preempted in order to admit <high-priority-pod>"
```

### Global Default PriorityClass

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: default-priority
value: 0
globalDefault: true           # All pods without priorityClassName use this
description: "Default priority for all pods"
```

⚠️ **Note:** Only one PriorityClass can have `globalDefault: true`

### Exam Tips for PriorityClass

1. **Use kubectl get priorityclass** to see existing values
2. **Don't use system priorities** (system-cluster-critical, system-node-critical) - they're for Kubernetes components only
3. **Remember:** Higher value = higher priority
4. **Patch is faster than edit** for adding priorityClassName to deployments
5. **Verify changes:** `kubectl get deployment <name> -o yaml | grep priorityClassName`

---

## Multi-Container Pods & Sidecars

### What is a Sidecar Container?

**Simple Explanation:**
A sidecar is a helper container that runs alongside your main application container in the same pod. It shares the same network and storage volumes.

**Real-World Analogy:**
Think of a sidecar like a motorcycle sidecar - it's attached to the main vehicle, goes wherever it goes, and provides additional functionality (extra passenger space = extra features).

### Common Sidecar Patterns

| Pattern | Purpose | Example |
|---------|---------|---------|
| **Log Collector** | Reads and ships logs | Filebeat reading app logs |
| **Proxy** | Network traffic management | Envoy, Istio sidecar |
| **Data Sync** | Sync data to/from main app | Git sync for config files |
| **Monitoring** | Metrics collection | Prometheus exporter |
| **Adapter** | Transform/adapt data | Log format converter |

### Hands-On: Log Sidecar Pattern

**Scenario:** Your main application writes logs to a file. A sidecar container reads and processes these logs.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-with-logging
spec:
  # Shared volume for both containers
  volumes:
  - name: shared-logs
    emptyDir: {}
  
  containers:
  # Main application container
  - name: webapp
    image: alpine:latest
    command: ["/bin/sh"]
    args:
    - -c
    - |
      while true; do
        echo "$(date) - User request processed" >> /var/log/app.log
        sleep 2
      done
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
  
  # Sidecar container (log processor)
  - name: log-processor
    image: busybox:stable
    command: ["/bin/sh"]
    args:
    - -c
    - |
      tail -f /var/log/app.log
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log
```

```bash
# Apply
kubectl apply -f log-sidecar.yaml

# View main app logs
kubectl logs webapp-with-logging -c webapp

# View sidecar logs (processed logs)
kubectl logs webapp-with-logging -c log-processor

# Follow sidecar logs
kubectl logs -f webapp-with-logging -c log-processor
```

### Practice Exercise 9: Exam-Style Sidecar Question

**Exam Question:**
*Edit the deployment `synergy-leverager` to add a sidecar container named `sidecar` using image `busybox:stable`. The sidecar should run the command `tail -n+1 -f /var/log/synergy-leverager.log`. Both containers must share an emptyDir volume mounted at `/var/log`.*

**Solution:**

**Step 1: Get Current Deployment**
```bash
kubectl get deployment synergy-leverager -o yaml > deployment.yaml
```

**Step 2: Edit YAML to Add Sidecar**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: synergy-leverager
spec:
  selector:
    matchLabels:
      app: synergy
  template:
    metadata:
      labels:
        app: synergy
    spec:
      # Add shared volume
      volumes:
      - name: data
        emptyDir: {}
      
      containers:
      # Main container (original)
      - name: synergy-leverager
        image: alpine:latest
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            echo "Logging data" >> /var/log/synergy-leverager.log
            sleep 1
          done
        volumeMounts:
        - name: data
          mountPath: /var/log
      
      # Sidecar container (new)
      - name: sidecar
        image: busybox:stable
        command: ["/bin/sh", "-c", "tail -n+1 -f /var/log/synergy-leverager.log"]
        volumeMounts:
        - name: data
          mountPath: /var/log
```

**Step 3: Apply**
```bash
kubectl apply -f deployment.yaml

# Verify both containers are running
kubectl get pods
kubectl describe pod <pod-name>

# Test sidecar
kubectl exec -it <pod-name> -c synergy-leverager -- cat /var/log/synergy-leverager.log
kubectl logs <pod-name> -c sidecar
```

### Init Containers vs Sidecar Containers

| Feature | Init Container | Sidecar Container |
|---------|----------------|-------------------|
| **When runs** | Before main app starts | Runs alongside main app |
| **Purpose** | Setup/initialization | Ongoing helper tasks |
| **Lifecycle** | Runs once and completes | Runs for pod lifetime |
| **Example** | Database schema setup | Log shipping |

**Init Container Example:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-with-init
spec:
  # Init containers run first
  initContainers:
  - name: init-database
    image: busybox:stable
    command: ['sh', '-c', 'echo Initializing database; sleep 5']
  
  - name: download-config
    image: busybox:stable
    command: ['sh', '-c', 'wget -O /config/app.conf http://config-server/app.conf']
    volumeMounts:
    - name: config
      mountPath: /config
  
  # Main container starts after all init containers succeed
  containers:
  - name: myapp
    image: nginx
    volumeMounts:
    - name: config
      mountPath: /etc/config
  
  volumes:
  - name: config
    emptyDir: {}
```

```bash
kubectl apply -f init-container.yaml

# Watch init containers complete
kubectl get pod myapp-with-init -w

# See init container logs
kubectl logs myapp-with-init -c init-database
kubectl logs myapp-with-init -c download-config
```

### Practice Exercise 10: Complete Multi-Container Pattern

**Scenario:** Deploy a pod with:
1. Init container to download initial data
2. Main application container
3. Sidecar for logging
4. Sidecar for metrics

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: complex-app
  labels:
    app: complex
spec:
  # Shared volumes
  volumes:
  - name: data
    emptyDir: {}
  - name: logs
    emptyDir: {}
  
  # Init container - runs first
  initContainers:
  - name: init-data
    image: busybox:stable
    command: ['sh', '-c']
    args:
    - |
      echo "Downloading initial data..."
      echo "Data downloaded" > /data/initial.txt
    volumeMounts:
    - name: data
      mountPath: /data
  
  # Main application container
  containers:
  - name: app
    image: nginx:alpine
    ports:
    - containerPort: 80
    volumeMounts:
    - name: data
      mountPath: /usr/share/nginx/html
    - name: logs
      mountPath: /var/log/nginx
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "200m"
        memory: "256Mi"
  
  # Sidecar 1: Log shipper
  - name: log-shipper
    image: busybox:stable
    command: ['/bin/sh']
    args:
    - -c
    - |
      while true; do
        if [ -f /var/log/nginx/access.log ]; then
          tail -f /var/log/nginx/access.log
        else
          sleep 2
        fi
      done
    volumeMounts:
    - name: logs
      mountPath: /var/log/nginx
  
  # Sidecar 2: Metrics collector
  - name: metrics
    image: busybox:stable
    command: ['/bin/sh']
    args:
    - -c
    - |
      while true; do
        echo "$(date): Collecting metrics..."
        sleep 10
      done
```

```bash
# Apply
kubectl apply -f complex-pod.yaml

# Verify all containers
kubectl get pod complex-app
# Should show: READY 3/3

# Check init container ran
kubectl logs complex-app -c init-data

# Check main container
kubectl exec -it complex-app -c app -- cat /usr/share/nginx/html/initial.txt

# Check sidecar containers
kubectl logs complex-app -c log-shipper
kubectl logs complex-app -c metrics
```

### Troubleshooting Multi-Container Pods

```bash
# Get pod status
kubectl get pod <pod-name>

# Check which containers are running
kubectl describe pod <pod-name>

# View specific container logs
kubectl logs <pod-name> -c <container-name>

# View previous container logs (if crashed)
kubectl logs <pod-name> -c <container-name> --previous

# Execute into specific container
kubectl exec -it <pod-name> -c <container-name> -- /bin/sh

# Get resource usage per container
kubectl top pod <pod-name> --containers
```

**Common Issues:**

| Issue | Cause | Solution |
|-------|-------|----------|
| Init container stuck | Wrong command/image | Check logs: `kubectl logs pod -c init-container` |
| Sidecar not seeing files | Volume not shared | Verify volumeMounts in both containers |
| Pod not ready | One container failing | Check all containers: `kubectl describe pod` |

### Exam Tips for Multi-Container Pods

1. **Always share volumes** - Sidecars need access to same files/data
2. **Use emptyDir** - Most common volume type for sidecar patterns
3. **Know the command format** - `command: ["/bin/sh", "-c", "..."]`
4. **Test with exec** - Verify files are accessible from both containers
5. **Check logs per container** - Use `-c <container-name>` flag

---

## Resource Requests & Limits

### What are Resource Requests and Limits?

**Simple Explanation:**
- **Request:** Minimum resources guaranteed to a container
- **Limit:** Maximum resources a container can use

**Real-World Analogy:**
Think of a hotel reservation:
- **Request** = Guaranteed room (you'll definitely get this)
- **Limit** = Maximum room size (you can't use more than this)

### Why Use Resource Requests and Limits?

1. **Scheduling:** Kubernetes uses requests to find nodes with enough resources
2. **Quality of Service:** Determines pod priority during eviction
3. **Resource Management:** Prevents one pod from hogging all resources
4. **Performance:** Ensures critical apps get enough resources

### Understanding CPU and Memory Units

#### CPU Units
```bash
# CPU is measured in cores
1000m = 1 CPU core
500m  = 0.5 CPU core = 50% of one core
100m  = 0.1 CPU core = 10% of one core

# Can also use decimal
0.5 = 500m
1.0 = 1000m
```

#### Memory Units
```bash
# Memory can be in bytes or with suffixes
128Mi  = 128 Mebibytes (134,217,728 bytes)
1Gi    = 1 Gibibyte (1,073,741,824 bytes)
512M   = 512 Megabytes (512,000,000 bytes)

# Common suffixes:
Ki (Kibibyte) = 1024 bytes
Mi (Mebibyte) = 1024 Ki
Gi (Gibibyte) = 1024 Mi

K (Kilobyte)  = 1000 bytes
M (Megabyte)  = 1000 K
G (Gigabyte)  = 1000 M
```

### Hands-On: Adding Resources to Pods

**Basic Pod with Resources:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: app
    image: nginx
    resources:
      requests:                # Minimum guaranteed
        memory: "128Mi"        # 128 Mebibytes
        cpu: "100m"            # 10% of one CPU
      limits:                  # Maximum allowed
        memory: "256Mi"        # 256 Mebibytes
        cpu: "200m"            # 20% of one CPU
```

```bash
kubectl apply -f resource-pod.yaml

# View resource allocation
kubectl describe pod resource-demo | grep -A 10 "Requests"

# Check actual usage
kubectl top pod resource-demo
```

### Practice Exercise 11: WordPress Resource Fix

**Exam Question:**
*The `wordpress` deployment in namespace `production` has pods failing to schedule. The deployment has both init and main containers. Scale to 0, add appropriate resource requests and limits to both init and main containers so 3 replicas can run on available nodes, then scale back to 3.*

**Solution:**

**Step 1: Check Node Resources**
```bash
# See available node resources
kubectl describe nodes

# Check allocatable resources
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.allocatable.cpu,MEMORY:.status.allocatable.memory
```

**Step 2: Scale Down**
```bash
kubectl scale deployment wordpress --replicas=0 -n production

# Wait for pods to terminate
kubectl get pods -n production -w
```

**Step 3: Edit Deployment**
```bash
kubectl edit deployment wordpress -n production
```

**Add resources to BOTH init and main containers:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  namespace: production
spec:
  replicas: 0
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      # Init container
      initContainers:
      - name: init-database
        image: busybox
        resources:                    # ADD THESE
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      
      # Main container
      containers:
      - name: wordpress
        image: wordpress:latest
        resources:                    # ADD THESE (same as init)
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
```

**Step 4: Scale Up**
```bash
kubectl scale deployment wordpress --replicas=3 -n production

# Verify all pods are running
kubectl get pods -n production
kubectl rollout status deployment wordpress -n production
```

**Step 5: Verify**
```bash
# Check resource allocation
kubectl describe deployment wordpress -n production | grep -A 10 Requests

# Check pod distribution
kubectl get pods -n production -o wide
```

### Quality of Service (QoS) Classes

Kubernetes assigns QoS classes based on requests/limits:

| QoS Class | Definition | Priority | Example |
|-----------|------------|----------|---------|
| **Guaranteed** | requests == limits (both CPU and memory) | Highest | Production databases |
| **Burstable** | requests < limits OR only requests set | Medium | Web apps |
| **BestEffort** | No requests or limits | Lowest | Batch jobs |

**Guaranteed QoS:**
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "500m"
  limits:
    memory: "256Mi"    # Same as request
    cpu: "500m"        # Same as request
```

**Burstable QoS:**
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"    # Higher than request
    cpu: "200m"        # Higher than request
```

**BestEffort QoS:**
```yaml
# No resources section at all
```

**Check QoS Class:**
```bash
kubectl get pod <pod-name> -o jsonpath='{.status.qosClass}'
kubectl describe pod <pod-name> | grep "QoS Class"
```

### What Happens When Limits are Exceeded?

#### CPU Limit Exceeded
- Container is **throttled** (slowed down)
- NOT killed
- Performance degrades

```bash
# Simulate CPU stress
kubectl run cpu-test --image=vish/stress --restart=Never -- -cpus 2
kubectl top pod cpu-test  # Watch CPU usage
```

#### Memory Limit Exceeded
- Container is **killed** (OOMKilled = Out Of Memory Killed)
- Pod enters CrashLoopBackOff
- Restarts automatically

```bash
# Check for OOMKilled
kubectl get pods
kubectl describe pod <pod-name> | grep -i oom

# Example output:
# Last State: Terminated
#   Reason: OOMKilled
```

### LimitRange - Setting Defaults

**What is LimitRange?**
Automatically applies default requests/limits to containers without them.

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: development
spec:
  limits:
  - max:                        # Maximum per container
      cpu: "1"
      memory: "1Gi"
    min:                        # Minimum per container
      cpu: "100m"
      memory: "64Mi"
    default:                    # Default limit if not specified
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:             # Default request if not specified
      cpu: "200m"
      memory: "256Mi"
    type: Container
```

```bash
kubectl apply -f limitrange.yaml

# Create pod without resources - gets defaults automatically
kubectl run test --image=nginx -n development

# Check applied resources
kubectl describe pod test -n development | grep -A 5 Limits
```

### ResourceQuota - Limiting Total Namespace Resources

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: namespace-quota
  namespace: development
spec:
  hard:
    requests.cpu: "10"          # Total CPU requests
    requests.memory: "20Gi"     # Total memory requests
    limits.cpu: "20"            # Total CPU limits
    limits.memory: "40Gi"       # Total memory limits
    pods: "50"                  # Max number of pods
```

```bash
kubectl apply -f resourcequota.yaml

# Check quota usage
kubectl get resourcequota -n development
kubectl describe resourcequota namespace-quota -n development
```

### Practice Exercise 12: Complete Resource Management

**Scenario:** Set up a namespace with resource limits.

```bash
# Create namespace
kubectl create namespace app-dev

# Create LimitRange (defaults)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: app-limits
  namespace: app-dev
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    max:
      cpu: "2"
      memory: "2Gi"
    min:
      cpu: "50m"
      memory: "64Mi"
    type: Container
EOF

# Create ResourceQuota (namespace total)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: app-quota
  namespace: app-dev
spec:
  hard:
    requests.cpu: "5"
    requests.memory: "10Gi"
    limits.cpu: "10"
    limits.memory: "20Gi"
    pods: "20"
EOF

# Test: Create deployment without resources
kubectl create deployment test-app --image=nginx --replicas=3 -n app-dev

# Check that defaults were applied
kubectl describe pod -n app-dev | grep -A 5 "Limits:"

# Check quota usage
kubectl describe resourcequota -n app-dev
```

### Troubleshooting Resources

```bash
# Pod pending due to insufficient resources
kubectl describe pod <pod-name>
# Look for: "Insufficient cpu" or "Insufficient memory"

# Check node available resources
kubectl describe node <node-name>

# Check what's using resources
kubectl top nodes
kubectl top pods -A

# See pod QoS class
kubectl get pod <pod-name> -o yaml | grep qosClass

# Check for OOMKilled pods
kubectl get pods
kubectl describe pod <pod-name> | grep -i oom
```

**Common Issues:**

| Issue | Cause | Solution |
|-------|-------|----------|
| Pod pending | Not enough node resources | Reduce requests or add nodes |
| OOMKilled | Memory limit too low | Increase memory limit |
| CPU throttling | CPU limit too low | Increase CPU limit or optimize app |
| Quota exceeded | Namespace quota reached | Increase quota or delete pods |

### Exam Tips for Resources

1. **HPA requires requests** - Can't autoscale without resource requests
2. **Use kubectl top** - Check if metrics-server is available
3. **Scale to 0 first** - When editing deployment resources
4. **Same resources for init** - Init and main containers often need same resources
5. **Remember units** - `m` for CPU (millicores), `Mi` for memory (Mebibytes)
6. **Quick view:** `kubectl describe node | grep -A 5 "Allocated resources"`

---

# Part 4: Storage

## Understanding Storage in Kubernetes

### Why is Storage Complex in Kubernetes?

**The Problem:**
- Pods are **ephemeral** (temporary) - when deleted, data is lost
- Pods can move between nodes
- Multiple pods might need to share data

**The Solution:**
- **Volumes:** Mount storage into containers
- **Persistent Volumes (PV):** Cluster-level storage resources
- **Persistent Volume Claims (PVC):** Pods request storage
- **Storage Classes:** Dynamic provisioning of storage

### Storage Hierarchy

```
StorageClass (how to provision storage)
       ↓
Persistent Volume (actual storage)
       ↓
Persistent Volume Claim (request for storage)
       ↓
Pod (uses the storage)
```

---

## Persistent Volumes & Claims

### What is a Persistent Volume (PV)?

**Simple Explanation:**
A Persistent Volume is a piece of storage in the cluster that exists independently of pods. It's like a USB drive that can be plugged into different computers (pods).

**What is a Persistent Volume Claim (PVC)?**

A PVC is a request for storage. It's like saying "I need 10GB of storage" without caring about the details of where it comes from.

### Hands-On: Create PV and PVC

**Step 1: Create a Persistent Volume (Manual Provisioning)**
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv
spec:
  capacity:
    storage: 1Gi                    # Size
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce                  # One pod can mount as read-write
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual         # Links PV to PVC
  hostPath:                        # Type of storage (for testing only!)
    path: /mnt/data
    type: DirectoryOrCreate
```

```bash
kubectl apply -f pv.yaml
kubectl get pv
kubectl describe pv my-pv
```

**Step 2: Create a Persistent Volume Claim**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
  - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 1Gi                 # Request 1GB
  storageClassName: manual         # Must match PV
```

```bash
kubectl apply -f pvc.yaml
kubectl get pvc

# Check binding
kubectl get pv
# Status should change: Available → Bound
```

**Step 3: Use PVC in a Pod**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-pvc
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: my-pvc            # Reference the PVC
```

```bash
kubectl apply -f pod.yaml

# Write data
kubectl exec -it pod-with-pvc -- /bin/bash
echo "Hello from PVC!" > /usr/share/nginx/html/index.html
exit

# Delete pod
kubectl delete pod pod-with-pvc

# Create pod again
kubectl apply -f pod.yaml

# Data persists!
kubectl exec -it pod-with-pvc -- cat /usr/share/nginx/html/index.html
```

### Access Modes

| Access Mode | Abbreviation | Description |
|-------------|--------------|-------------|
| **ReadWriteOnce** | RWO | One node can mount as read-write |
| **ReadOnlyMany** | ROX | Many nodes can mount as read-only |
| **ReadWriteMany** | RWX | Many nodes can mount as read-write |
| **ReadWriteOncePod** | RWOP | One pod can mount as read-write |

**Most Common:** `ReadWriteOnce` (RWO)

### Reclaim Policies

What happens to PV when PVC is deleted?

| Policy | Behavior |
|--------|----------|
| **Retain** | PV kept, manual cleanup required |
| **Delete** | PV and underlying storage deleted automatically |
| **Recycle** | Basic data wipe (deprecated) |

### Practice Exercise 13: MariaDB with Persistent Storage

**Exam Question:**
*In namespace `mariadb`, create a PersistentVolumeClaim named `mariadb` with 250Mi storage using storageClassName `standard`. Update the deployment `mariadb-deployment.yaml` to use this PVC mounted at `/var/lib/mysql`.*

**Solution:**

**Step 1: Check if PV Exists**
```bash
kubectl get pv
# Look for a PV with 250Mi and storageClassName: standard
```

**Step 2: Create PVC**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb
  namespace: mariadb
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: standard       # Must match available PV
  resources:
    requests:
      storage: 250Mi
```

```bash
kubectl apply -f pvc.yaml

# Verify binding
kubectl get pvc -n mariadb
# STATUS should be "Bound"
```

**Step 3: Edit Deployment**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mariadb
  namespace: mariadb
spec:
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
        volumeMounts:
        - name: mariadb-storage      # Mount the volume
          mountPath: /var/lib/mysql
      volumes:
      - name: mariadb-storage
        persistentVolumeClaim:
          claimName: mariadb          # Reference the PVC
```

```bash
kubectl apply -f mariadb-deployment.yaml

# Verify
kubectl get pods -n mariadb
kubectl describe pod <mariadb-pod> -n mariadb | grep -A 5 Volumes
```

**Step 4: Test Persistence**
```bash
# Create database
kubectl exec -it <mariadb-pod> -n mariadb -- mysql -uroot -ppassword123 -e "CREATE DATABASE testdb;"

# Delete pod (deployment recreates it)
kubectl delete pod <mariadb-pod> -n mariadb

# Wait for new pod
kubectl get pods -n mariadb -w

# Check database still exists
kubectl exec -it <new-mariadb-pod> -n mariadb -- mysql -uroot -ppassword123 -e "SHOW DATABASES;"
```

### Volume Types

#### 1. emptyDir (Temporary, Pod Lifetime)
```yaml
volumes:
- name: temp-storage
  emptyDir: {}
```
- Created when pod starts
- Deleted when pod deleted
- Shared between containers in same pod

#### 2. hostPath (Node's Filesystem)
```yaml
volumes:
- name: host-storage
  hostPath:
    path: /data
    type: DirectoryOrCreate
```
- Maps to directory on node
- **Testing only!** Not recommended for production
- Data persists if pod moves to same node

#### 3. PersistentVolumeClaim (Recommended)
```yaml
volumes:
- name: storage
  persistentVolumeClaim:
    claimName: my-pvc
```
- Decouples storage from pod
- Portable across nodes
- Survives pod deletion

#### 4. ConfigMap (Configuration Files)
```yaml
volumes:
- name: config
  configMap:
    name: app-config
```

#### 5. Secret (Sensitive Data)
```yaml
volumes:
- name: secrets
  secret:
    secretName: db-credentials
```

### Practice Exercise 14: Multiple Volume Types

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-volume-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    # Persistent storage
    - name: data
      mountPath: /data
    # Temporary scratch space
    - name: temp
      mountPath: /tmp
    # Configuration
    - name: config
      mountPath: /etc/config
      readOnly: true
  
  volumes:
  # PVC for persistent data
  - name: data
    persistentVolumeClaim:
      claimName: my-pvc
  
  # emptyDir for temporary files
  - name: temp
    emptyDir: {}
  
  # ConfigMap for configuration
  - name: config
    configMap:
      name: app-config
```

### Troubleshooting PV/PVC

```bash
# Check PV status
kubectl get pv
# States: Available, Bound, Released, Failed

# Check PVC status
kubectl get pvc
# States: Pending, Bound, Lost

# Describe for details
kubectl describe pv <pv-name>
kubectl describe pvc <pvc-name>

# Common issues:

# 1. PVC stuck in Pending
kubectl describe pvc <pvc-name>
# Possible causes:
# - No matching PV (check storageClassName, capacity, accessMode)
# - StorageClass doesn't exist
# - No provisioner available

# 2. Check events
kubectl get events --sort-by='.lastTimestamp' | grep pvc

# 3. Check binding
kubectl get pvc <pvc-name> -o yaml | grep -A 5 volume
```

**Common Issues:**

| Issue | Cause | Solution |
|-------|-------|----------|
| PVC Pending | No matching PV | Check storageClass, capacity, accessMode |
| Pod Pending | PVC not bound | Wait for or create matching PV |
| Mount failed | Volume already in use | Check if accessMode allows multiple mounts |
| Permission denied | Wrong volume permissions | Check fsGroup in securityContext |

---

## Storage Classes

### What is a StorageClass?

**Simple Explanation:**
A StorageClass defines how storage is dynamically provisioned. Instead of manually creating PVs, the StorageClass automatically creates them when you create a PVC.

**Real-World Analogy:**
Think of a StorageClass like an automated warehouse. When you request storage (PVC), it automatically allocates and provisions the space for you without manual intervention.

### Static vs Dynamic Provisioning

| Static Provisioning | Dynamic Provisioning |
|---------------------|----------------------|
| Admin creates PV manually | StorageClass creates PV automatically |
| PVC finds existing PV | PVC triggers PV creation |
| Limited scalability | Scales automatically |
| More control | More convenience |

### Hands-On: Create StorageClass

**Step 1: Create StorageClass**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: kubernetes.io/no-provisioner  # For manual binding
volumeBindingMode: WaitForFirstConsumer     # Bind when pod created
reclaimPolicy: Retain
```

```bash
kubectl apply -f storageclass.yaml
kubectl get storageclass
kubectl describe storageclass fast-storage
```

### Volume Binding Modes

| Mode | Behavior | Use Case |
|------|----------|----------|
| **Immediate** | Bind PVC to PV immediately | Most storage types |
| **WaitForFirstConsumer** | Bind when pod uses PVC | Multi-zone clusters, local storage |

### Practice Exercise 15: Create Local-Path StorageClass

**Exam Question:**
*Create a StorageClass named `local-path` using provisioner `rancher.io/local-path` with `volumeBindingMode: WaitForFirstConsumer`. Set it as the default StorageClass.*

**Solution:**
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-path
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"  # Makes it default
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
```

```bash
kubectl apply -f storageclass.yaml

# Verify it's default
kubectl get storageclass
# NAME                   PROVISIONER             DEFAULT
# local-path (default)   rancher.io/local-path   true

# Test with PVC (no storageClassName specified - uses default)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

kubectl get pvc test-pvc
# Should automatically use local-path StorageClass
```

### Making a StorageClass the Default

**Method 1: Annotation (Preferred)**
```yaml
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
```

**Method 2: Patch Existing StorageClass**
```bash
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Remove default from another StorageClass
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

### Common Provisioners

| Provisioner | Use Case |
|-------------|----------|
| `kubernetes.io/aws-ebs` | AWS EBS volumes |
| `kubernetes.io/azure-disk` | Azure Disk |
| `kubernetes.io/gce-pd` | Google Persistent Disk |
| `rancher.io/local-path` | Local path provisioner (Kind, testing) |
| `kubernetes.io/no-provisioner` | Manual/static provisioning |

### Practice Exercise 16: Test Dynamic Provisioning

```yaml
# StorageClass
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: dynamic-storage
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
---
# PVC using the StorageClass
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
spec:
  storageClassName: dynamic-storage
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
---
# Pod using the PVC
apiVersion: v1
kind: Pod
metadata:
  name: pod-dynamic-storage
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    persistentVolumeClaim:
      claimName: dynamic-pvc
```

```bash
# Apply all
kubectl apply -f dynamic-storage-test.yaml

# Watch PVC status
kubectl get pvc dynamic-pvc -w
# Status: Pending (waiting for pod)

# Check PV (none created yet)
kubectl get pv

# Pod creation triggers PV creation
kubectl get pods
# Pod: Running

# Now PV is created automatically!
kubectl get pv
kubectl get pvc dynamic-pvc
# STATUS: Bound
```

### Reclaim Policies in StorageClass

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: retain-storage
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Retain           # or Delete
```

**Test Reclaim Policy:**
```bash
# Delete PVC
kubectl delete pvc dynamic-pvc

# Check PV status
kubectl get pv

# If reclaimPolicy: Retain
# PV status: Released (needs manual cleanup)

# If reclaimPolicy: Delete
# PV is automatically deleted
```

### Exam Tips for Storage

1. **Match storageClassName** - PVC and PV must have same storageClassName
2. **Check provisioner** - Know if provisioner exists/works in environment
3. **Don't modify existing PVCs** - Exam often says "do not modify existing Deployments/PVCs"
4. **volumeBindingMode** - Use `WaitForFirstConsumer` for local storage
5. **Default annotation** - `storageclass.kubernetes.io/is-default-class: "true"`
6. **Verify binding** - `kubectl get pvc` should show STATUS: Bound

---

# Part 5: Networking

## Kubernetes Networking Basics

### The Three Network Types in Kubernetes

**1. Pod Network**
- Every pod gets its own IP address
- Pods can communicate with each other directly
- No NAT (Network Address Translation) needed

**2. Service Network**
- Services get ClusterIP addresses
- Stable endpoint for accessing pods
- Load balancing built-in

**3. Node Network**
- Nodes have their own IPs
- NodePort services expose on node IPs
- External traffic enters through nodes

### Network Requirements

Kubernetes networking must satisfy these rules:
1. Pods can communicate with all other pods without NAT
2. Nodes can communicate with all pods without NAT
3. The IP a pod sees itself as is the same IP others see it as

### Hands-On: Understanding Pod Networking

```bash
# Create two pods
kubectl run pod1 --image=nginx
kubectl run pod2 --image=nginx

# Get pod IPs
kubectl get pods -o wide

# Pod1 can ping Pod2 directly
kubectl exec pod1 -- ping -c 2 <pod2-ip>

# Check pod's view of its own IP
kubectl exec pod1 -- hostname -i
```

---

## Network Policies - Controlling Traffic

### What are Network Policies?

**Simple Explanation:**
Network Policies are firewall rules for your pods. They control which pods can talk to each other.

**Real-World Analogy:**
Think of Network Policies like security guards at building entrances. They check who's allowed in (ingress) and who can leave (egress) based on specific rules.

### Default Behavior

**Without Network Policies:**
- All pods can talk to all other pods
- All pods can reach the internet
- All pods accept traffic from anywhere

**With Network Policies:**
- Only explicitly allowed traffic is permitted
- Everything else is denied

### Hands-On: Create Your First Network Policy

**Scenario:** Allow only frontend pods to access backend pods.

**Step 1: Create Namespaces and Pods**
```bash
# Create namespaces
kubectl create namespace frontend
kubectl create namespace backend

# Create backend app
kubectl create deployment backend --image=nginx -n backend
kubectl expose deployment backend --port=80 -n backend

# Create frontend app
kubectl create deployment frontend --image=nginx -n frontend

# Test: Frontend can access backend (before policy)
kubectl exec -it <frontend-pod> -n frontend -- curl http://backend.backend.svc.cluster.local
# Should work
```

**Step 2: Create Network Policy (Block All)**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: backend
spec:
  podSelector: {}        # Applies to all pods
  policyTypes:
  - Ingress             # Block incoming traffic
```

```bash
kubectl apply -f deny-all.yaml

# Test: Frontend cannot access backend now
kubectl exec -it <frontend-pod> -n frontend -- curl --max-time 5 http://backend.backend.svc.cluster.local
# Should timeout
```

**Step 3: Allow Frontend Access**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend       # Apply to backend pods
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
      port: 80
```

```bash
kubectl apply -f allow-frontend.yaml

# Test: Frontend can access backend again
kubectl exec -it <frontend-pod> -n frontend -- curl http://backend.backend.svc.cluster.local
# Should work
```

### Practice Exercise 17: Least Permissive Network Policy

**Exam Question:**
*Three network policy YAMLs are provided. Choose and apply the LEAST permissive policy that allows pods with label `app: frontend` in namespace `frontend` to access pods with label `app: backend` in namespace `backend` on port 8080.*

**Policy Options:**

**Policy 1: Too Open (Empty Selectors)**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy1
  namespace: backend
spec:
  podSelector: {}
  ingress:
  - from: []           # Allows ALL traffic!
```

**Policy 2: Correct (Pod + Namespace Selector)**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy2
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

**Policy 3: Too Open (Includes CIDR)**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: policy3
  namespace: backend
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: frontend
      podSelector:
        matchLabels:
          app: frontend
    - ipBlock:          # Opens to external IPs too!
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 8080
```

**Answer: Policy 2** (Most restrictive while meeting requirements)

```bash
kubectl apply -f policy2.yaml
```

### Practice Exercise 18: Port and Namespace Policy

**Exam Question:**
*Create NetworkPolicy `allow-port-from-namespace` in namespace `foobar` that allows pods from namespace `internal-ns` to access port 9000, denying all other traffic.*

**Solution:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-port-from-namespace
  namespace: foobar
spec:
  podSelector: {}        # Apply to all pods in namespace
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
kubectl apply -f netpol.yaml

# Verify
kubectl get networkpolicy -n foobar
kubectl describe networkpolicy allow-port-from-namespace -n foobar
```

### Egress Network Policies

**Control Outbound Traffic:**
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-egress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: webapp
  policyTypes:
  - Egress
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # Allow HTTPS to external
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 169.254.169.254/32   # Block metadata service
    ports:
    - protocol: TCP
      port: 443
```

### Network Policy Selectors

**1. podSelector** - Which pods the policy applies to
```yaml
spec:
  podSelector:
    matchLabels:
      app: backend
```

**2. namespaceSelector** - Which namespaces can connect
```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        environment: production
```

**3. podSelector + namespaceSelector (AND)**
```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        environment: production
    podSelector:
      matchLabels:
        app: frontend
```

**4. Multiple from clauses (OR)**
```yaml
ingress:
- from:
  - namespaceSelector:
      matchLabels:
        env: prod
  - namespaceSelector:
      matchLabels:
        env: staging
```

### Troubleshooting Network Policies

```bash
# Check if NetworkPolicy is applied
kubectl get networkpolicy -A
kubectl describe networkpolicy <name> -n <namespace>

# Verify pod labels match
kubectl get pods --show-labels -n <namespace>

# Test connectivity
kubectl run test --rm -it --image=busybox -n <source-namespace> -- wget -O- <service-url>

# Check CNI supports NetworkPolicy
kubectl get pods -n kube-system | grep -E 'calico|cilium|weave'
```

**Common Issues:**

| Issue | Cause | Solution |
|-------|-------|----------|
| Policy not working | CNI doesn't support NetworkPolicy | Install Calico/Cilium |
| All traffic blocked | Default deny with no allow rules | Add ingress/egress rules |
| Labels don't match | Pod labels ≠ policy selectors | Fix labels or selectors |

---

## CNI Installation & Configuration

### What is CNI?

**Simple Explanation:**
Container Network Interface (CNI) is a plugin that sets up networking for containers. It assigns IPs, creates routes, and enforces network policies.

**Popular CNI Plugins:**
- **Calico** - Network policy enforcement, BGP routing
- **Flannel** - Simple overlay network
- **Cilium** - eBPF-based, advanced features
- **Weave** - Encrypted overlay network

### Practice Exercise 19: Install CNI

**Exam Question:**
*Install a CNI that supports native Network Policies. Choose either Calico v3.28.2 or Flannel v0.26.1.*

**Solution: Install Calico (Recommended)**

```bash
# Apply Calico manifest
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml

# Wait for Calico pods
kubectl get pods -n calico-system -w

# Verify all nodes are Ready
kubectl get nodes

# Verify Calico is running
kubectl get pods -A | grep calico
```

**Alternative: Install Flannel**
```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml

# Verify
kubectl get pods -n kube-flannel -w
```

### Testing CNI Installation

```bash
# Create test pods
kubectl run pod1 --image=nginx
kubectl run pod2 --image=nginx

# Get pod IPs
kubectl get pods -o wide

# Test connectivity
kubectl exec pod1 -- ping -c 2 <pod2-ip>

# Test DNS
kubectl exec pod1 -- nslookup kubernetes.default

# Create and test NetworkPolicy
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-policy
spec:
  podSelector:
    matchLabels:
      run: pod2
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          run: pod1
EOF

kubectl get networkpolicy
```

---

## Ingress - External Access

### What is Ingress?

**Simple Explanation:**
Ingress manages external HTTP/HTTPS access to services. It's like a smart reverse proxy that routes traffic based on hostnames and paths.

**Real-World Analogy:**
Think of Ingress as a hotel receptionist. External visitors (traffic) arrive, and the receptionist routes them to the right room (service) based on who they're visiting (hostname/path).

### Ingress vs Service

| Feature | NodePort Service | LoadBalancer Service | Ingress |
|---------|------------------|----------------------|---------|
| **L7 routing** | ❌ No | ❌ No | ✅ Yes (host/path) |
| **TLS termination** | ❌ No | ❌ No | ✅ Yes |
| **Cost** | Free | $$ per service | $ shared |
| **Use case** | Development | Cloud production | Production |

### Hands-On: Create Ingress

**Prerequisites: Install Ingress Controller**

```bash
# Install nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml

# Wait for controller
kubectl get pods -n ingress-nginx -w

# Verify
kubectl get svc -n ingress-nginx
```

**Step 1: Create Backend Application**
```bash
# Create deployment
kubectl create deployment echo-server --image=ealen/echo-server --port=80

# Create service
kubectl expose deployment echo-server --port=8080 --target-port=80
```

**Step 2: Create Ingress**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo-ingress
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

```bash
kubectl apply -f ingress.yaml

# Get Ingress
kubectl get ingress

# Add to /etc/hosts (for testing)
echo "127.0.0.1 example.org" | sudo tee -a /etc/hosts

# Test
curl http://example.org/echo
```

### Practice Exercise 20: Create Ingress for Echo Server

**Exam Question:**
*In namespace `sound-repeater`, create Ingress that exposes service `echo-server` (port 8080) at `http://example.org/echo` on port 80.*

**Solution:**
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

```bash
kubectl apply -f ingress.yaml -n sound-repeater

# Verify
kubectl get ingress -n sound-repeater
kubectl describe ingress echo-ingress -n sound-repeater

# Test (returns HTTP 200)
curl -o /dev/null -s -w "%{http_code}\n" http://example.org/echo
```

### Ingress with TLS

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-cert>
  tls.key: <base64-encoded-key>
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
spec:
  tls:
  - hosts:
    - example.org
    secretName: tls-secret
  rules:
  - host: example.org
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

---

## Gateway API - Next Generation Ingress

### What is Gateway API?

**Simple Explanation:**
Gateway API is the successor to Ingress. It's more powerful, role-oriented, and supports more protocols (HTTP, TCP, UDP, gRPC).

### Gateway API vs Ingress

| Feature | Ingress | Gateway API |
|---------|---------|-------------|
| **Protocols** | HTTP/HTTPS only | HTTP, HTTPS, TCP, UDP, gRPC |
| **Multi-tenancy** | Limited | Built-in (separate roles) |
| **Traffic splitting** | Extensions only | Native support |
| **Header matching** | Limited | Advanced |

### Gateway API Components

```
GatewayClass (like StorageClass)
       ↓
Gateway (like LoadBalancer)
       ↓
HTTPRoute, TCPRoute, etc. (routing rules)
       ↓
Service (backend)
```

### Practice Exercise 21: Migrate Ingress to Gateway API

**Exam Question:**
*Migrate existing Ingress in namespace `webapp` to Gateway API. Create Gateway `web-gateway` with hostname `gateway.web.k8s.local`, using HTTPS (TLS secret `web-tls`). Create HTTPRoute `web-route` routing to service `web-service` on port 80.*

**Solution:**

**Step 1: Create Gateway**
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

**Step 2: Create HTTPRoute**
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

```bash
# Apply both
kubectl apply -f gateway.yaml -f httproute.yaml

# Verify
kubectl get gateway -n webapp
kubectl get httproute -n webapp

# Test
curl -k https://gateway.web.k8s.local
```

---

## CoreDNS - Service Discovery

### What is CoreDNS?

**Simple Explanation:**
CoreDNS is Kubernetes' DNS server. It resolves service names to IP addresses so pods can find each other by name instead of IP.

### DNS Format in Kubernetes

```
<service-name>.<namespace>.svc.<cluster-domain>
```

**Examples:**
```bash
# Same namespace
curl http://backend

# Different namespace
curl http://backend.production

# Fully qualified
curl http://backend.production.svc.cluster.local
```

### Practice Exercise 22: Add Custom DNS Domain

**Exam Question:**
*Backup CoreDNS ConfigMap to `/opt/course/16/coredns_backup.yaml`. Add `custom-domain` to the kubernetes plugin so services are also accessible via `service.namespace.custom-domain`. Restart CoreDNS.*

**Solution:**

**Step 1: Backup ConfigMap**
```bash
kubectl -n kube-system get configmap coredns -o yaml > /opt/course/16/coredns_backup.yaml
```

**Step 2: Edit CoreDNS ConfigMap**
```bash
kubectl -n kube-system edit configmap coredns
```

Change:
```
kubernetes cluster.local in-addr.arpa ip6.arpa {
```

To:
```
kubernetes custom-domain cluster.local in-addr.arpa ip6.arpa {
```

**Step 3: Restart CoreDNS**
```bash
kubectl -n kube-system rollout restart deployment coredns

# Wait for restart
kubectl -n kube-system rollout status deployment coredns
```

**Step 4: Test**
```bash
# Test original domain
kubectl run test --rm -it --image=busybox -- nslookup kubernetes.default.svc.cluster.local

# Test custom domain
kubectl run test --rm -it --image=busybox -- nslookup kubernetes.default.svc.custom-domain

# Both should return same IP
```

### Troubleshooting DNS

```bash
# Check CoreDNS pods
kubectl get pods -n kube-system | grep coredns

# Check CoreDNS logs
kubectl logs -n kube-system -l k8s-app=kube-dns

# Test DNS resolution
kubectl run test --rm -it --image=busybox -- nslookup kubernetes.default

# Check DNS config in pod
kubectl run test --rm -it --image=busybox -- cat /etc/resolv.conf
```

---

# Part 6: Security

## RBAC - Role-Based Access Control

### What is RBAC?

**Simple Explanation:**
RBAC controls who can do what in your cluster. It defines permissions (what actions) and assigns them to users, groups, or service accounts.

**Real-World Analogy:**
Think of RBAC like office access cards. Different employees (users) have different access levels (roles) - some can enter all rooms (cluster-admin), others only specific offices (namespace-specific roles).

### RBAC Components

```
User/Group/ServiceAccount
       ↓
RoleBinding / ClusterRoleBinding
       ↓
Role / ClusterRole (permissions)
       ↓
Resources (pods, services, etc.)
```

### Role vs ClusterRole

| Feature | Role | ClusterRole |
|---------|------|-------------|
| **Scope** | Single namespace | Cluster-wide |
| **Resources** | Namespaced resources | All resources + cluster resources |
| **Example** | Dev team access to dev namespace | Admin access to all namespaces |

### Hands-On: Create Role and RoleBinding

**Scenario:** Give user `john` permission to view pods in `development` namespace.

**Step 1: Create Role**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: development
rules:
- apiGroups: [""]       # "" = core API group
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
```

**Step 2: Create RoleBinding**
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: development
subjects:
- kind: User
  name: john
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

```bash
kubectl apply -f role.yaml -f rolebinding.yaml

# Test as user john
kubectl auth can-i get pods --namespace=development --as=john
# yes

kubectl auth can-i delete pods --namespace=development --as=john
# no
```

### Common Verbs

| Verb | Description |
|------|-------------|
| `get` | Read a single resource |
| `list` | List all resources |
| `watch` | Watch for changes |
| `create` | Create new resources |
| `update` | Update existing resources |
| `patch` | Partially update resources |
| `delete` | Delete resources |
| `*` | All verbs |

### ClusterRole Example

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-pods-global
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-pod-reader
  apiGroup: rbac.authorization.k8s.io
```

---

## Service Accounts

### What are Service Accounts?

**Simple Explanation:**
Service Accounts are identities for pods. They allow pods to authenticate to the API server and access resources based on RBAC permissions.

### Hands-On: Create Service Account

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: production
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: configmap-reader
  namespace: production
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-sa-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: production
roleRef:
  kind: Role
  name: configmap-reader
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: production
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: nginx
```

---

## TLS Configuration

### Practice Exercise 23: Configure TLS 1.3 Only

**Exam Question:**
*Edit ConfigMap `nginx-config` in namespace `webapp` to support only TLS 1.3 (disable TLS 1.2). Restart deployment to apply changes.*

**Solution:**

```bash
# Edit ConfigMap
kubectl edit configmap nginx-config -n webapp

# Change:
# ssl_protocols TLSv1.2 TLSv1.3;
# To:
# ssl_protocols TLSv1.3;

# Restart deployment
kubectl rollout restart deployment webapp -n webapp

# Verify
kubectl rollout status deployment webapp -n webapp

# Test
curl -k --tls-max 1.2 https://localhost:30443  # Should FAIL
curl -k --tls-max 1.3 https://localhost:30443  # Should SUCCEED
```

---

# Part 7: Cluster Maintenance

## Node Maintenance & Draining

### What is Draining?

**Simple Explanation:**
Draining safely removes all pods from a node before maintenance. It reschedules pods to other nodes and marks the node as unschedulable.

### Hands-On: Drain and Uncordon Node

```bash
# View nodes
kubectl get nodes

# Drain node (safely evict pods)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Node is now SchedulingDisabled
kubectl get nodes

# Perform maintenance...
# (e.g., kernel update, hardware repair)

# Uncordon node (make schedulable again)
kubectl uncordon <node-name>

# Verify
kubectl get nodes
```

### Cordon (Without Eviction)

```bash
# Mark node unschedulable (don't evict existing pods)
kubectl cordon <node-name>

# Uncordon
kubectl uncordon <node-name>
```

---

## Cluster Upgrades with kubeadm

### Practice Exercise 24: Upgrade Control Plane

**Exam Question:**
*Upgrade control plane node to v1.30.1. Drain if necessary, upgrade kubeadm/kubelet/kubectl, apply upgrade, restart kubelet, uncordon.*

**Solution:**

**Step 1: Drain Control Plane** (if asked)
```bash
kubectl drain controlplane --ignore-daemonsets --delete-emptydir-data
```

**Step 2: SSH to Control Plane**
```bash
ssh controlplane
sudo -i
```

**Step 3: Upgrade kubeadm**
```bash
apt-mark unhold kubeadm
apt-get update
apt-get install -y kubeadm=1.30.1-00
apt-mark hold kubeadm

# Verify
kubeadm version
```

**Step 4: Plan and Apply Upgrade**
```bash
kubeadm upgrade plan
kubeadm upgrade apply v1.30.1
```

**Step 5: Upgrade kubelet and kubectl**
```bash
apt-mark unhold kubelet kubectl
apt-get install -y kubelet=1.30.1-00 kubectl=1.30.1-00
apt-mark hold kubelet kubectl

# Restart kubelet
systemctl daemon-reload
systemctl restart kubelet
systemctl status kubelet
```

**Step 6: Uncordon**
```bash
# Exit SSH
exit

# Uncordon
kubectl uncordon controlplane

# Verify
kubectl get nodes
kubectl version
```

---

## Backup & Restore etcd

### Backup etcd

```bash
# Backup etcd
ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Verify backup
ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-backup.db
```

### Restore etcd

```bash
# Restore from backup
ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-backup.db \
  --data-dir=/var/lib/etcd-restore

# Update etcd manifest to use new data-dir
# Edit /etc/kubernetes/manifests/etcd.yaml
# Change: --data-dir=/var/lib/etcd
# To: --data-dir=/var/lib/etcd-restore

# Restart kubelet
systemctl restart kubelet
```

---

# Part 8: Troubleshooting

## Working with crictl

### What is crictl?

**Simple Explanation:**
crictl is a CLI for container runtimes (like docker but for containerd/CRI-O). Use it on nodes to inspect containers.

### Practice Exercise 25: Get Container ID and Logs

**Exam Question:**
*Create pod `tigers-reunite` in namespace `project-tiger` with labels `pod: container` and `container: pod`, using image `httpd:2-alpine`. SSH to the node, find container ID and runtimeType, save to files. Export container logs.*

**Solution:**

**Step 1: Create Pod**
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
kubectl create namespace project-tiger
kubectl apply -f pod.yaml
```

**Step 2: Find Node**
```bash
kubectl get pod tigers-reunite -n project-tiger -o wide
# Note the NODE column
```

**Step 3: SSH to Node**
```bash
ssh <node-name>
```

**Step 4: Find Container**
```bash
# List containers
crictl ps -a | grep tigers-reunite

# Get container ID
CONTAINER_ID=$(crictl ps -a | grep tigers-reunite | awk '{print $1}')
echo $CONTAINER_ID
```

**Step 5: Get Runtime Type**
```bash
# Inspect container
crictl inspect $CONTAINER_ID | grep runtimeType
```

**Step 6: Save to Files**
```bash
# Save container ID and runtime type
echo $CONTAINER_ID > /course/17/pod-container.txt
crictl inspect $CONTAINER_ID | grep runtimeType >> /course/17/pod-container.txt

# Save logs
crictl logs $CONTAINER_ID > /opt/course/17/pod-container.log
```

---

## Node Troubleshooting

### Practice Exercise 26: Fix NotReady Node

**Exam Question:**
*Worker node is NotReady. SSH to node, fix kubelet, ensure it starts on boot.*

**Solution:**

**Step 1: Identify Node**
```bash
kubectl get nodes
# Look for NotReady status
```

**Step 2: SSH to Node**
```bash
ssh <worker-node>
```

**Step 3: Check kubelet**
```bash
sudo systemctl status kubelet
# Likely: inactive (dead)
```

**Step 4: Start and Enable**
```bash
sudo systemctl start kubelet
sudo systemctl enable kubelet
sudo systemctl status kubelet
```

**Step 5: Verify**
```bash
# Exit SSH
exit

# Check node status
kubectl get nodes
# Should be Ready now
```

---

## Cluster Component Troubleshooting

### Practice Exercise 27: Fix Broken Cluster

**Exam Question:**
*Cluster is broken. Fix etcd and kube-apiserver manifests, restart kubelet.*

**Solution:**

**Step 1: SSH to Control Plane**
```bash
ssh controlplane
```

**Step 2: Check Manifests**
```bash
cd /etc/kubernetes/manifests/
ls -la

# Check etcd.yaml
sudo vim etcd.yaml

# Common issues:
# - Wrong --etcd-servers URL
# - Wrong cert paths
# - Typos in arguments
```

**Step 3: Fix etcd.yaml**
Example fix:
```yaml
# Change incorrect:
--listen-client-urls=https://127.0.0.1:2379

# To correct:
--listen-client-urls=https://127.0.0.1:2379,https://<control-plane-ip>:2379
```

**Step 4: Fix kube-apiserver.yaml**
```yaml
# Verify --etcd-servers matches etcd URL
--etcd-servers=https://127.0.0.1:2379
```

**Step 5: Restart kubelet**
```bash
sudo systemctl restart kubelet

# Check status
sudo systemctl status kubelet
```

**Step 6: Verify**
```bash
# Exit SSH
exit

# Check cluster
kubectl get nodes
kubectl get pods -A
```

---

# Part 9: Advanced Topics

## Custom Resource Definitions (CRDs)

### Practice Exercise 28: Work with CRDs

**Exam Question:**
*List all CRDs containing "cert", save to file. Extract `subject` field from `certificates.cert-manager.io` CRD using JSONPath.*

**Solution:**

**Step 1: List CRDs**
```bash
kubectl get crd | grep cert > custom-crd.txt

# Verify
cat custom-crd.txt
```

**Step 2: JSONPath Query**
```bash
kubectl get crd certificates.cert-manager.io \
  -o jsonpath='{.spec.versions[*].schema.openAPIV3Schema.properties.spec.properties.subject}' \
  > cert-manager-subject.txt

# Verify
cat cert-manager-subject.txt
```

---

## Container Runtime Configuration

### Practice Exercise 29: Install cri-dockerd

**Exam Question:**
*Install cri-dockerd package from `~/cri-dockerd_*.deb`, enable service, configure sysctl for Kubernetes networking.*

**Solution:**

**Step 1: Install Package**
```bash
sudo dpkg -i ~/cri-dockerd_*.deb
```

**Step 2: Enable Service**
```bash
sudo systemctl enable cri-docker.socket
sudo systemctl start cri-docker.socket
sudo systemctl status cri-docker.socket
```

**Step 3: Configure sysctl**
```bash
# Create config file
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF

# Apply
sudo sysctl --system

# Verify
sysctl net.bridge.bridge-nf-call-iptables
```

---

## Helm Basics

### Practice Exercise 30: Deploy with Helm

**Exam Question:**
*Install ArgoCD using Helm chart version 7.7.3 in namespace `argocd`. CRDs already exist, so disable CRD installation. Save template to `~/argo-helm.yaml` then apply.*

**Solution:**

**Step 1: Add Helm Repo**
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

**Step 2: Generate Template**
```bash
helm template argocd argo/argo-cd \
  --version 7.7.3 \
  --namespace argocd \
  --set crds.install=false \
  > ~/argo-helm.yaml
```

**Step 3: Apply**
```bash
kubectl apply -f ~/argo-helm.yaml
```

**Step 4: Verify**
```bash
kubectl get pods -n argocd
cat ~/argo-helm.yaml | head -20  # Check namespace
```

---

# Part 10: 22 Practice Questions

## Complete Exam Simulation

### Question 1: HPA with Stabilization (Weight: 7%)

**Task:**
Create HPA for deployment `apache-server` in namespace `auto-scale`:
- CPU target: 50%
- Min replicas: 1
- Max replicas: 4
- Scale-down stabilization: 30 seconds

**Solution:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: apache-server-hpa
  namespace: auto-scale
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: apache-server
  minReplicas: 1
  maxReplicas: 4
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

```bash
kubectl apply -f hpa.yaml
kubectl get hpa -n auto-scale
```

---

### Question 2: Deployment + NodePort (Weight: 10%)

**Task:**
In namespace `spline-reticulator`, deployment `front-end` exists:
- Add containerPort 80 to deployment
- Create NodePort service `front-end-svc` exposing port 80

**Solution:**
```bash
# Add containerPort
kubectl set image deployment/front-end nginx=nginx -n spline-reticulator
kubectl edit deployment front-end -n spline-reticulator
# Add:
#   ports:
#   - containerPort: 80

# Create service
kubectl expose deployment front-end --type=NodePort --port=80 --name=front-end-svc -n spline-reticulator

# Verify
kubectl get svc,deploy -n spline-reticulator
```

---

### Question 3: Sidecar Container (Weight: 15%)

**Task:**
Edit deployment `synergy-leverager`:
- Add sidecar container `sidecar` (image: `busybox:stable`)
- Command: `tail -n+1 -f /var/log/synergy-leverager.log`
- Share emptyDir volume at `/var/log`

**Solution:**
```bash
kubectl edit deployment synergy-leverager
```

Add to spec.template.spec:
```yaml
volumes:
- name: data
  emptyDir: {}

containers:
- name: synergy-leverager
  # ... existing config
  volumeMounts:
  - name: data
    mountPath: /var/log

- name: sidecar
  image: busybox:stable
  command: ["/bin/sh", "-c", "tail -n+1 -f /var/log/synergy-leverager.log"]
  volumeMounts:
  - name: data
    mountPath: /var/log
```

---

### Question 4: PriorityClass (Weight: 11%)

**Task:**
- Find highest user-defined PriorityClass value
- Create `high-priority` with value (highest - 1)
- Patch deployment `busybox-logger` to use it

**Solution:**
```bash
# Find highest
kubectl get priorityclass

# Create (assuming highest is 1000)
kubectl create priorityclass high-priority --value=999 --preemption-policy=PreemptLowerPriority

# Patch deployment
kubectl patch deployment busybox-logger -n priority -p '{"spec":{"template":{"spec":{"priorityClassName":"high-priority"}}}}'
```

---

### Question 5: StorageClass (Weight: 8%)

**Task:**
Create StorageClass `local-path`:
- Provisioner: `rancher.io/local-path`
- volumeBindingMode: `WaitForFirstConsumer`
- Set as default

**Solution:**
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
kubectl get sc
```

---

### Question 6: Helm ArgoCD (Weight: 7%)

**Task:**
Install ArgoCD via Helm:
- Chart: `argo/argo-cd` version 7.7.3
- Namespace: `argocd`
- Disable CRD installation
- Save template to `~/argo-helm.yaml`

**Solution:**
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm template argocd argo/argo-cd --version 7.7.3 --namespace argocd --set crds.install=false > ~/argo-helm.yaml
kubectl apply -f ~/argo-helm.yaml
```

---

### Question 7: MariaDB + PVC (Weight: 13%)

**Task:**
- Create PVC `mariadb` (250Mi, storageClassName: `standard`)
- Edit deployment to mount PVC at `/var/lib/mysql`

**Solution:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb
  namespace: mariadb
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 250Mi
```

Edit deployment:
```yaml
volumes:
- name: mariadb-storage
  persistentVolumeClaim:
    claimName: mariadb

# In container:
volumeMounts:
- name: mariadb-storage
  mountPath: /var/lib/mysql
```

---

### Question 8: Gateway API (Weight: 12%)

**Task:**
Create Gateway + HTTPRoute:
- Gateway: `web-gateway`, hostname `gateway.web.k8s.local`, HTTPS with TLS secret `web-tls`
- HTTPRoute: `web-route`, route to service `web-service:80`

**Solution:**
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
---
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
  - backendRefs:
    - name: web-service
      port: 80
```

---

### Question 9: CNI Installation (Weight: 9%)

**Task:**
Install CNI with NetworkPolicy support (Calico v3.28.2 or Flannel v0.26.1)

**Solution:**
```bash
# Calico (recommended)
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/tigera-operator.yaml

# Verify
kubectl get pods -A | grep calico
```

---

### Question 10: WordPress Resources (Weight: 9%)

**Task:**
Fix WordPress deployment:
- Scale to 0
- Add same resource requests/limits to init and main containers
- Scale to 3

**Solution:**
```bash
kubectl scale deployment wordpress --replicas=0
kubectl edit deployment wordpress

# Add to both init and main containers:
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "200m"
    memory: "256Mi"

kubectl scale deployment wordpress --replicas=3
```

---

### Question 11: cri-dockerd (Weight: 7%)

**Task:**
- Install `~/cri-dockerd_*.deb`
- Enable/start cri-docker.socket
- Configure sysctl

**Solution:**
```bash
sudo dpkg -i ~/cri-dockerd_*.deb
sudo systemctl enable cri-docker.socket
sudo systemctl start cri-docker.socket

sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF

sudo sysctl --system
```

---

### Question 12: CRDs + JSONPath (Weight: 7%)

**Task:**
- List CRDs with "cert", save to file
- Extract `subject` field from `certificates.cert-manager.io` CRD

**Solution:**
```bash
kubectl get crd | grep cert > custom-crd.txt
kubectl get crd certificates.cert-manager.io -o jsonpath='{.spec.versions[*].schema.openAPIV3Schema.properties.spec.properties.subject}' > cert-manager-subject.txt
```

---

### Question 13: Network Policy Least Permissive (Weight: 10%)

**Task:**
Choose most restrictive NetworkPolicy allowing frontend → backend

**Solution:**
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

---

### Question 14: CoreDNS Custom Domain

**Task:**
- Backup CoreDNS ConfigMap
- Add `custom-domain` to kubernetes plugin
- Restart CoreDNS

**Solution:**
```bash
kubectl -n kube-system get configmap coredns -o yaml > /opt/course/16/coredns_backup.yaml
kubectl -n kube-system edit configmap coredns

# Change:
# kubernetes cluster.local ...
# To:
# kubernetes custom-domain cluster.local ...

kubectl -n kube-system rollout restart deployment coredns
```

---

### Question 15: crictl Pod Info

**Task:**
- Create pod `tigers-reunite`
- SSH to node, find container ID and runtimeType
- Export logs

**Solution:**
```bash
# Create pod
kubectl apply -f pod.yaml

# Find node
kubectl get pod tigers-reunite -n project-tiger -o wide

# SSH to node
ssh <node>

# Find container
crictl ps -a | grep tigers-reunite
CONTAINER_ID=$(crictl ps -a | grep tigers-reunite | awk '{print $1}')

# Save info
echo $CONTAINER_ID > /course/17/pod-container.txt
crictl inspect $CONTAINER_ID | grep runtimeType >> /course/17/pod-container.txt

# Save logs
crictl logs $CONTAINER_ID > /opt/course/17/pod-container.log
```

---

### Question 16: Network Policy Port

**Task:**
Create NetworkPolicy `allow-port-from-namespace` allowing namespace `internal-ns` to access port 9000 in namespace `foobar`

**Solution:**
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

---

### Question 17: Count Ready Nodes

**Task:**
Count Ready nodes excluding NoSchedule taint, write to file

**Solution:**
```bash
kubectl describe nodes | grep -A5 Taints
# Count Ready nodes without NoSchedule

echo "2" > /opt/KUSC00402/kusc00402.txt
```

---

### Question 18: Fix NotReady Node

**Task:**
SSH to NotReady worker, start/enable kubelet

**Solution:**
```bash
ssh <worker-node>
sudo systemctl start kubelet
sudo systemctl enable kubelet
exit
kubectl get nodes
```

---

### Question 19: kubeadm Upgrade

**Task:**
Upgrade control plane to v1.30.1

**Solution:**
```bash
kubectl drain controlplane --ignore-daemonsets --delete-emptydir-data
ssh controlplane
sudo -i

apt-mark unhold kubeadm kubelet kubectl
apt-get update
apt-get install -y kubeadm=1.30.1-00 kubelet=1.30.1-00 kubectl=1.30.1-00
apt-mark hold kubeadm kubelet kubectl

kubeadm upgrade apply v1.30.1
systemctl daemon-reload
systemctl restart kubelet

exit
kubectl uncordon controlplane
```

---

### Question 20: TLS 1.3 Only

**Task:**
Edit ConfigMap to support only TLS 1.3, restart deployment

**Solution:**
```bash
kubectl edit configmap nginx-config -n webapp

# Change:
# ssl_protocols TLSv1.2 TLSv1.3;
# To:
# ssl_protocols TLSv1.3;

kubectl rollout restart deployment webapp -n webapp
```

---

### Question 21: Ingress

**Task:**
Create Ingress for `echo-server` at `http://example.org/echo`

**Solution:**
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

---

### Question 22: Cluster Troubleshoot

**Task:**
Fix broken cluster (etcd/kube-apiserver manifests)

**Solution:**
```bash
ssh controlplane
cd /etc/kubernetes/manifests/

# Fix etcd.yaml
sudo vim etcd.yaml
# Check: --etcd-servers, cert paths

# Fix kube-apiserver.yaml
sudo vim kube-apiserver.yaml
# Check: --etcd-servers matches

sudo systemctl restart kubelet
exit
kubectl get nodes
```

---

# Final Exam Checklist

## Before the Exam
- [ ] Set up aliases and bash completion
- [ ] Bookmark important documentation pages
- [ ] Practice typing YAML without errors
- [ ] Know where to find examples in docs
- [ ] Get comfortable with vim/nano

## During the Exam
- [ ] Read question completely before starting
- [ ] Check cluster context and namespace
- [ ] Use dry-run for generating YAML templates
- [ ] Verify your changes after each question
- [ ] Flag difficult questions and move on
- [ ] Save work frequently
- [ ] Watch the clock

## Common kubectl Patterns
```bash
# Generate templates
kubectl create deployment ... --dry-run=client -o yaml > file.yaml

# Switch context
kubectl config use-context <context>

# Set namespace
kubectl config set-context --current --namespace=<namespace>

# Quick describe
kubectl describe <resource> <name>

# Check logs
kubectl logs <pod> -c <container>

# Execute commands
kubectl exec -it <pod> -- /bin/bash
```

## Time-Saving Tips
1. Use tab completion aggressively
2. Generate YAML, don't write from scratch
3. Copy examples from documentation
4. Use kubectl explain for field details
5. Verify with get/describe, not trial-and-error

---

**Good luck on your CKA exam! You've got this! 🚀**
