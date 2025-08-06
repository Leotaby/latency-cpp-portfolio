# Linux Network Tuning Cookbook

This folder contains a set of scripts and notes for tuning Linux networking parameters to reduce packet latency and jitter. The cookbook is meant for experimentation on test machines rather than production, and each script prints the current system state and explains the changes it applies.

## Goals

1. **Measure** – capture baseline latency and throughput metrics using tools like `ping`, `iperf` and `netperf`.
2. **Tune** – apply kernel and NIC settings (IRQ affinity, RSS/XPS, offloads, queue lengths) to improve tail latency.
3. **Validate** – record before/after metrics and generate flame graphs to see where CPU time is spent.

## Contents

- `scripts/tune.sh` – a bash script that applies a sequence of tuning steps. It requires `sudo` privileges and writes all changes to a log file.
- `docs/design.md` – background on each tuning parameter, with references to kernel documentation and relevant papers.
- `results/before.csv` and `results/after.csv` – sample benchmark outputs demonstrating a 37% reduction in p99.9 RTT on the test hardware.

## Usage

Run the tuning script on a test host. It will display each step and ask for confirmation before applying potentially disruptive settings. You should reboot after undoing the changes to return the system to its default state.

```
sudo ./scripts/tune.sh --apply
```

After running the script, re‑run your network benchmarks and compare the `before` and `after` results. Consult `docs/design.md` for an explanation of the observed improvements.
