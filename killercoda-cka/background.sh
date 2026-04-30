#!/bin/bash
# =============================================================================
# CKA PRACTICE - BACKGROUND SETUP (runs when scenario starts)
# Creates ALL exam prerequisites. User sees nothing until foreground completes.
# =============================================================================
set -e
export DEBIAN_FRONTEND=noninteractive

echo "[$(date '+%H:%M:%S')] CKA prerequisites setup starting..." >> /var/log/killercoda/cka-setup.log 2>&1

# Wait for k8s to be ready
while ! kubectl get nodes &>/dev/null; do
  sleep 2
done
echo "[$(date '+%H:%M:%S')] Kubernetes ready" >> /var/log/killercoda/cka-setup.log 2>&1

# Run setup script (try multiple paths for KillerCoda/GitHub structure)
SCENARIO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT=""
for base in "$SCENARIO_DIR" "/root" "/home/scenario"; do
  [ -f "$base/scripts/setup-cka-prerequisites.sh" ] && SETUP_SCRIPT="$base/scripts/setup-cka-prerequisites.sh" && break
done
if [ -n "$SETUP_SCRIPT" ]; then
  bash "$SETUP_SCRIPT" >> /var/log/killercoda/cka-setup.log 2>&1
fi

# Install Helm if missing
if ! command -v helm &>/dev/null; then
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash >> /var/log/killercoda/cka-setup.log 2>&1
fi

echo "[$(date '+%H:%M:%S')] Setup complete" >> /var/log/killercoda/cka-setup.log 2>&1
touch /tmp/cka-prereqs-done
