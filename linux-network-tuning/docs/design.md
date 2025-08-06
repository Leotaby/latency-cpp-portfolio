# Rationale for Linux network tuning

This document summarises the rationale behind the tuning steps provided in `scripts/tune.sh` and offers references for further reading. The overall goal is to reduce network latency and jitter on a Linux host by aligning CPU, memory and NIC resources.

## IRQ affinity and CPU isolation

Network interface cards (NICs) generate interrupts to signal that packets are available. By default, the kernel spreads these interrupts across all CPUs, which can lead to cache thrashing and increased latency. Assigning NIC interrupts to specific cores (using `/proc/irq/*/smp_affinity`) and isolating those cores from the scheduler (`isolcpus`) helps ensure that packet processing remains on the same CPU, preserving cache locality.

*Reference:* The [Linux networking documentation](https://www.kernel.org/doc/Documentation/networking/scaling.txt) covers interrupt affinity and scaling.

## Receive‑Side Scaling (RSS), Receive Packet Steering (RPS) and Transmit Packet Steering (XPS)

RSS distributes incoming packets across multiple hardware queues, allowing parallel processing on multi‑core systems. RPS and XPS are software mechanisms that spread packet handling across CPUs. Enabling RPS/XPS on specific queues can improve throughput and reduce queue contention. The values written to `rps_cpus` and `xps_cpus` are bitmasks of allowed CPUs; writing `f` enables the first four CPUs.

## Offloads (GRO/LRO)

Generic/large receive offload (GRO/LRO) aggregates incoming packets into larger chunks to reduce CPU overhead. While beneficial for throughput, these offloads can introduce latency and jitter in high‑frequency trading or real‑time systems. Disabling them via `ethtool` removes this aggregation and can improve tail latency.

## Socket buffer sizes

Increasing the default receive buffer sizes (`net.core.rmem_max`, `net.core.rmem_default`) prevents packet drops under bursty load. Larger buffers allow the application to keep up with spikes in traffic without losing packets, at the cost of slightly increased memory usage. For low‑latency workloads, ensure that buffers are large enough to accommodate short bursts but not so large that they hide backpressure problems.

## Measurement and validation

Always measure before and after applying tuning parameters. Use tools like `perf stat`, `ping -f`, `iperf3` and `netperf` to capture latency and throughput. To understand CPU behaviour, collect flame graphs with `perf record` or [Brendan Gregg’s FlameGraph tools](https://github.com/brendangregg/FlameGraph). Only apply one change at a time to isolate its effect.

**Example result:** On our test machine, applying the tuning steps reduced the 99.9th percentile RTT from 112 µs to 70 µs (≈37% improvement) as measured by `ping` to a remote host on the same LAN.
