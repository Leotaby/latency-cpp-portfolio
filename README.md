# Low‑Latency C++ Portfolio

Welcome! This monorepo contains a set of small, focused projects demonstrating how I design, implement and benchmark low‑latency components on Linux. Each directory below contains a self‑contained project with a clear goal, design notes, reproducible benchmarks and automation scripts. The common thread across them is an emphasis on correctness, observability and repeatability; every result is accompanied by a `README` describing the hardware, OS and kernel tuning used to collect it.

## What I work on

- **High‑Performance C++** – C++20/17 with STL and Boost; custom allocators; zero‑overhead abstractions; lock‑free patterns using `std::atomic` and memory orderings.
- **Concurrency & IPC** – ring buffers, wait‑free structures and batching techniques; measuring tail latency and throughput under load.
- **Market‑Data and Order Books** – parsers for feed messages, in‑memory order book data structures and snapshot publishing.
- **Linux Systems Tuning** – understanding NUMA, CPU isolation and NIC offloads; applying kernel and BIOS tweaks to improve p99 latency.

## Flagship projects

| Project | Result highlights |
|---|---|
| **[market‑data‑handler](./market-data-handler/)** | Feed handler and order book built from scratch. Sustains ≈2M messages/s on commodity hardware with p99 add/update/snapshot latency of ~16 µs. Includes design doc and benchmark scripts. |
| **[ring‑buffer‑ipc](./ring-buffer-ipc/)** | Single‑producer/single‑consumer circular buffer with a wait‑free API. Cross‑core enqueue→dequeue median ≈0.6 µs and p99 ≈3 µs. Benchmarks compare against `std::queue` and a widely used lock‑free queue. |
| **[linux‑network‑tuning](./linux-network-tuning/)** | Scriptable cookbook demonstrating how IRQ pinning, RSS/XPS, hugepages and NIC offload tuning reduce network p99.9 latency by 37%. Comes with before/after measurements and flame graphs. |

Each project folder contains:

1. A **README** describing the problem, design choices and results.
2. **Source code** in C++ or shell scripts.
3. A **`docs/`** or **`design.md`** file explaining trade‑offs and rationale.
4. **Benchmark scripts** and instructions to reproduce the numbers.

## Tooling & methodology

All projects are intended to be reproducible. Benchmarks are run on a fixed hardware baseline using pinned cores, huge pages and pre‑allocated memory pools. Results are presented as latency cumulative distribution functions (CDFs) with p50/p90/p99/p99.9 statistics. CPU profiles are generated with `perf` and visualised using flame graphs. Observability tools (`perf stat`, `ftrace`, `bpftrace`) are used to understand bottlenecks and validate improvements.

## Getting started

To build the C++ components, install a recent Clang or GCC compiler with C++20 support and CMake. Each directory contains its own `CMakeLists.txt` which you can use to configure and build the target.

```
cd market-data-handler
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
./md_handler_bench
```

For the tuning scripts, run them on a test machine (preferably not a production host). Each script prints the current system state and the deltas applied. Always read the README in each folder before running the scripts.

## Contact

Feel free to reach out via the contact information on my GitHub profile if you have questions or suggestions. I'm always eager to learn and collaborate on performance‑critical systems.
