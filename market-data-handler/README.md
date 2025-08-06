# Market Data Handler & Order Book

This project implements a simplified market‑data feed handler and an in‑memory order book to demonstrate low‑latency parsing, state management and snapshot dissemination. It is inspired by public protocols such as NASDAQ ITCH/OUCH but uses a synthetic feed format to avoid any proprietary dependencies.

## Goals

1. **Throughput** – handle ≥2 M messages per second on commodity hardware.
2. **Low latency** – maintain p99 update→snapshot latency under 20 µs.
3. **Zero allocations** – pre‑allocate all objects and avoid dynamic memory in hot paths.
4. **Observability** – provide detailed metrics, CDF plots and perf profiles.

## Design highlights

- **Parser** – the feed format is fixed‑length to simplify parsing and enable vectorisation. Each message contains a symbol ID, side (bid/ask), price level and quantity. Messages are read from a file or UDP socket.
- **Order book** – per‑symbol book implemented as a two‑level map: a hash map from price to a small array of order IDs. Data structures are laid out using a structure‑of‑arrays (SoA) layout to minimise cache misses.
- **Memory management** – an arena allocator holds all book entries. A freelist is used to recycle entries when orders are cancelled.
- **Concurrency** – single thread ingests messages and updates the book; snapshots are published via a lock‑free ring buffer to one or more consumers.
- **Benchmark harness** – a replay tool reads a pcap of messages and feeds them to the handler at full speed. Latencies are measured with `std::chrono::steady_clock` and validated using TSC stamping.

## Building

This project uses CMake. You need a C++20 compiler (e.g. GCC 11+ or Clang 12+) and Boost headers.

```
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

This produces an executable `md_handler_bench` which runs the benchmark and prints summary statistics. Use `-h` for options.

## Benchmarks

Benchmarks are run on an Ubuntu 22.04 host with a 6‑core Intel CPU at 3.5 GHz, 32 GiB RAM and an Intel NIC. CPU isolation (`isolcpus`), huge pages and NIC offloads are configured via the scripts in the root of the repository. The following is a representative result:

- **Throughput:** 2.1 M messages/s
- **Latency:** p50 = 7.2 µs, p90 = 12.5 µs, p99 = 16.3 µs, p99.9 = 24.8 µs
- **CPU utilisation:** 62% user, 3% system

See `docs/design.md` for details on memory layout and concurrency considerations. Generated FlameGraphs are stored in `perf/`.
