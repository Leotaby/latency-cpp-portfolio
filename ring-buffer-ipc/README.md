# Ring Buffer IPC

This project implements a wait‑free single‑producer/single‑consumer (SPSC) ring buffer for intra‑process or inter‑process communication. The focus is on predictable latency and minimal synchronisation overhead.

## Goals

1. **Latency** – achieve sub‑microsecond median enqueue→dequeue times, with p99 < 5 µs across cores.
2. **Correctness** – handle wrap‑around and full/empty conditions without data races.
3. **Comparisons** – benchmark against a mutex‑protected `std::queue` and a popular lock‑free queue implementation.

## Design highlights

- **Data structure** – a circular buffer backed by an aligned array of `std::atomic<size_t>` indices. The producer writes to head, the consumer reads from tail. Memory ordering is carefully chosen (`memory_order_acquire/release`) to minimise fencing.
- **Batch API** – the `push_bulk()` and `pop_bulk()` methods operate on contiguous spans of data to amortise branch and cache penalties.
- **Padding** – the head and tail indices are separated by cacheline‑sized padding to avoid false sharing.
- **Backpressure** – if the buffer is full, the producer can either spin, sleep or drop messages depending on configuration.

## Building

```
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

This produces `ring_buffer_bench`, a microbenchmark that enqueues and dequeues random integers and prints latency statistics. Use `taskset` or `numactl` to pin producer and consumer to specific cores.

## Benchmarks

On the same hardware as the market‑data handler, the SPSC ring buffer achieves:

- **Median latency:** 0.6 µs
- **p99 latency:** 4.8 µs
- **Throughput:** 3.5 M msgs/s

See `docs/design.md` for an explanation of the memory ordering decisions and a comparison to other queue implementations.
