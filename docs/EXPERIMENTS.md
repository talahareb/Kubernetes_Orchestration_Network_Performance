# Experiment notes and provenance

All observed values below are **from the group's 2025/26 Mobile and Sensor Networks Lab 04 report**. They are **not** outputs of a new cluster run.

| Task | Reported result | Report section |
|---|---|---|
| NGINX self-healing | After deleting one pod, deployment moved 4/4 -> 3/4 -> 4/4 | Q1, p. 2 |
| ClusterIP | Internal-only service reachable on cluster node, not external client VM | Q2, p. 2 |
| NodePort | HTTP access via node port 30100 | Q3, p. 2 |
| MySQL persistence | `trains` database remained after MySQL pod replacement; RWO 1Gi local PV on worker-2 | Q4, p. 3 |
| Resource limit | Stress pod CPU decreased from roughly 1000m to about 300m after a 300m limit | Q5-Q6, pp. 3-4 |
| Autoscaling | `php-apache` scaled to 7 replicas under load and later down to 1; CPU target 27% | Q7, p. 4 |
| iperf3 on control-plane node | ~32.2 Gbit/s, 0 retransmissions | Q10, p. 6 |
| iperf3 from worker-2 | ~3.55 Gbit/s, 70 retransmissions | Q10, p. 6 |
| iperf3 from worker-1 | ~3.45 Gbit/s, 1168 retransmissions | Q10, p. 6 |

## Reconstructed files vs. primary evidence

The original submission contains written explanations, commands, and screenshots. It **does not include the full source manifests**. All files under `manifests/` and `scripts/` have therefore been **reconstructed for a reusable reference implementation**. They are **not asserted to be the original submitted configuration**. Where the report supplies a concrete setting, it is mirrored (for example: replicas, MySQL storage parameters, HPA target, NodePort, iperf3 topology). Values absent from the report (specific container image tags, probes, CPU/memory default settings, authentication implementation) are chosen as reasonable teaching examples and must be validated against the target cluster.

The photos in `docs/images/` are extracted directly from the team report. They document the team's historical lab environment and cannot be reproduced identically on another cluster.

## Safety and reproducibility

- Never commit MySQL credentials. The `mysql-credentials` Secret is created at runtime.
- The local PV requires a prepared `/data` directory on the worker labeled `worker-2`; it persists beyond pod deletion and may outlive PVC deletion due to `Retain`.
- `NodePort: 30100` may be unavailable or disallowed on some Kubernetes clusters.
- HPA scaling requires metrics-server and should be tested in a disposable lab namespace/cluster.
- Network throughput is topology-dependent; colocated server/client paths can be much faster than inter-node paths.
- The exact versions of Kubernetes, CNI, and the classroom cluster image registry were not provided by the report.
