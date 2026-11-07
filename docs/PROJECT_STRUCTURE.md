# Project structure

```text
Kubernetes_Orchestration_Network_Performance/
├── README.md
├── manifests/
│   ├── nginx/         # Four replica web deployment; internal and NodePort access
│   ├── mysql/         # 1Gi local PersistentVolume, PVC, database deployment
│   ├── resources/     # CPU baseline versus 300m-limited stress deployment
│   ├── hpa/           # php-apache test service and CPU-targeted autoscaler
│   └── iperf3/        # Server Deployment, ClusterIP Service, client DaemonSet
├── scripts/           # Stepwise cluster experiments and cleanup
├── tests/             # Static checks; do not require a live cluster
└── docs/
    ├── images/        # Figures extracted from the group report
    ├── report/         # Public-safe PDF report (student IDs redacted)
    ├── EXPERIMENTS.md  # Historical results / provenance notes
    └── PROJECT_STRUCTURE.md
```
