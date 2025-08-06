#!/usr/bin/env bash
#
# linux-network-tuning/scripts/tune.sh
#
# This script applies a series of network tuning parameters to the current system.
# It is intended for experimentation on a test host. Run with --apply to actually
# change system settings; otherwise it performs a dry‑run and prints the commands.

set -euo pipefail

LOG_FILE="tuning.log"
APPLY=false

if [[ "${1:-}" == "--apply" ]]; then
  APPLY=true
fi

function log_step() {
  echo "[ $(date +%F_%T) ] $*" | tee -a "$LOG_FILE"
}

function run_cmd() {
  local cmd="$1"
  if $APPLY; then
    log_step "Executing: $cmd"
    eval "$cmd"
  else
    log_step "Dry run: $cmd"
  fi
}

# Example tuning steps. Extend this list with your own experiments.

log_step "Starting network tuning script. APPLY=$APPLY"

# 1. Pin NIC interrupts to specific CPU cores
run_cmd "echo 2 > /proc/irq/$(cat /proc/interrupts | grep -m1 eth0 | awk '{print $1}' | sed 's/://')/smp_affinity"

# 2. Enable RPS/XPS on queue 0 of eth0
run_cmd "echo f > /sys/class/net/eth0/queues/rx-0/rps_cpus"
run_cmd "echo f > /sys/class/net/eth0/queues/tx-0/xps_cpus"

# 3. Disable GRO/LRO offloads on eth0
run_cmd "ethtool -K eth0 gro off lro off"

# 4. Increase UDP receive buffer sizes
run_cmd "sysctl -w net.core.rmem_max=16777216"
run_cmd "sysctl -w net.core.rmem_default=16777216"

log_step "Tuning complete. Please reboot or revert settings as needed."
