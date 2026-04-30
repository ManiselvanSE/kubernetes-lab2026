# KillerCoda CKA Practice - Detailed Setup Instructions

Step-by-step guide to set up and use this CKA practice environment on KillerCoda.

---

## Part 1: Publish the Scenario on KillerCoda

### Step 1: Prepare the Repository

1. Create a new GitHub repository (e.g. `cka-practice-killercoda`)
2. Copy the entire `killercoda-cka` folder into the repo
3. You can either:
   - Put all files at the **repo root** (so `index.json` is at the top level), or
   - Keep the structure as `killercoda-cka/` and configure KillerCoda to use that path

### Step 2: Connect to KillerCoda

1. Go to [https://killercoda.com](https://killercoda.com) and sign in
2. Go to [https://killercoda.com/creator/scenarios](https://killercoda.com/creator/scenarios)
3. Click **"Add Repository"** or **"Connect GitHub"**
4. Authorize KillerCoda to access your GitHub account
5. Select your repository and the branch (e.g. `main`)
6. If the scenario is in a subfolder (`killercoda-cka`), set the **Scenario Path** in KillerCoda to that folder

### Step 3: Verify the Scenario

1. KillerCoda will scan the repo and list scenarios
2. Your scenario **"CKA Exam Practice Environment"** should appear
3. Click **"Start"** to launch it
4. Wait for the intro (foreground + background scripts) to complete (~1–3 minutes)

---

## Part 2: Using the Environment

### When the Scenario Starts

1. **Foreground** runs first and shows:
   - "Preparing CKA exam practice environment..."
   - "Setting up exam prerequisites..."
   - A summary of what is pre-set vs what you practice

2. **Background** runs in parallel and:
   - Creates all namespaces
   - Creates all deployments
   - Installs CRDs, adds Helm repos
   - Generates `~/cka-practice-tasks.txt`

3. When both finish, you see:
   - **"Environment READY"**
   - A short task list
   - The command to view full tasks: `cat ~/cka-practice-tasks.txt`

### Your First Practice Session

1. Open the **terminal** (if not already open)
2. Run: `cat ~/cka-practice-tasks.txt`
3. Choose a question (e.g. Q1)
4. Do **only** the steps listed under "YOUR TASK"
5. Verify with the suggested commands

### Example: Practice Q1

```bash
# IN THE EXAM: namespace auto-scale and deploy apache-server already exist
# YOUR TASK:

# 1. Create HPA
kubectl autoscale deployment apache-server -n auto-scale --cpu-percent=50 --min=1 --max=4

# 2. Add stabilization (patch)
kubectl patch hpa apache-server -n auto-scale --type='merge' -p '{"spec":{"behavior":{"scaleDown":{"stabilizationWindowSeconds":30}}}}'

# 3. Verify
kubectl get hpa -n auto-scale -o yaml | grep -A3 behavior
```

---

## Part 3: Practice Again (Reset)

### When You Want a Fresh Run

1. In the terminal, run:
   ```bash
   ./scripts/reset-and-practice.sh
   ```

2. The script will:
   - Remove your HPA, services, network policies, etc.
   - Restore prerequisites to their initial state
   - Re-run the setup script
   - Print the task list again

3. You can then practice the same or different questions again

### Run Reset Multiple Times

You can run:

```bash
./scripts/reset-and-practice.sh
```

as often as you like. Each run resets the environment so you can repeat your practice.

---

## Part 4: Layout Summary

### What the Scripts Do

| Script | When It Runs | Purpose |
|--------|----------------|---------|
| `background.sh` | When scenario starts | Creates all exam prerequisites |
| `foreground.sh` | When scenario starts | Waits, then shows summary |
| `setup-cka-prerequisites.sh` | Called by background | Actual setup logic |
| `reset-and-practice.sh` | When you run it | Reset and practice again |

### What You See on the Screen

```
IN THE EXAM, THESE ARE ALREADY DONE (you do NOT create them):
  • Namespaces, Deployments, PV, CRDs, etc.

YOUR TASK - PRACTICE THESE:
  • Q1: Create HPA + stabilizationWindowSeconds
  • Q2: Add containerPort + NodePort service
  ...

View full task list:     cat ~/cka-practice-tasks.txt
Reset and practice:      ./scripts/reset-and-practice.sh
```

---

## Part 5: Alternative - Manual Setup

If you use an existing KillerCoda Kubernetes scenario (not this one):

1. Start a scenario with **kubernetes-kubeadm-2nodes**
2. Copy or upload the `scripts/` folder
3. Run:
   ```bash
   chmod +x scripts/*.sh
   ./scripts/setup-cka-prerequisites.sh
   ```
4. View tasks: `cat ~/cka-practice-tasks.txt`
5. To reset: `./scripts/reset-and-practice.sh`

---

## Quick Reference Card

| Action | Command |
|--------|---------|
| View all tasks | `cat ~/cka-practice-tasks.txt` |
| Reset and practice again | `./scripts/reset-and-practice.sh` |
| Re-run setup only | `./scripts/setup-cka-prerequisites.sh` |
| Check setup logs | `tail -100 /var/log/killercoda/cka-setup.log` |
| Verify cluster | `kubectl get nodes` |

---

## Troubleshooting

| Problem | What to Do |
|---------|------------|
| "Setup not complete" / tasks file missing | Wait 1–2 minutes, then run `./scripts/setup-cka-prerequisites.sh` manually |
| `./scripts/reset-and-practice.sh: Permission denied` | Run `chmod +x scripts/reset-and-practice.sh` |
| Some prerequisites fail (Gateway API, etc.) | This can happen due to network. Skip those questions or retry |
| Scenario timeout | KillerCoda sessions have time limits; start a new scenario to continue |
| Need 2-node cluster | Scenario uses `kubernetes-kubeadm-2nodes`; confirm this in `index.json` |
