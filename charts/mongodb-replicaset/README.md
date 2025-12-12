# mongodb-replicaset

Deploy a MongoDB replica set with configurable member count, persistence, and automation for initiation, reconciliation, and safe scale-down.

## TL;DR
```bash
helm install my-mongo charts/mongodb-replicaset
```

## Features
- StatefulSet with headless and client Services.
- Post-install/upgrade init Job to run `rs.initiate`.
- Reconcile Job to add new members (runs as Helm hook).
- Optional periodic reconcile CronJob for HPA/manual scale changes.
- Pre-stop removal hook to safely remove members on scale-down/termination.
- Optional HPA for CPU/memory-based scaling.
- PDB majority by default when replicas > 1.
- Anti-affinity default to spread across nodes.

## Installing the Chart
```bash
helm install my-mongo charts/mongodb-replicaset \
  --set auth.rootPassword="changeme" \
  --set persistence.size=20Gi
```

## Uninstalling the Chart
```bash
helm uninstall my-mongo
```

## Configuration

| Key | Description | Default |
| --- | --- | --- |
| replicaCount | Pods when autoscaling is off | `3` |
| image.repository | MongoDB image repo | `mongo` |
| image.tag | MongoDB image tag | `7.0` |
| auth.rootUsername | Root username | `root` |
| auth.rootPassword | Root password (generate if empty) | `""` |
| auth.existingSecret | Use an existing secret for root password | `""` |
| auth.keyFile | Keyfile contents for internal auth (auto-generate if empty) | `""` |
| auth.existingKeySecret | Use an existing secret for keyfile | `""` |
| service.type | Service type | `ClusterIP` |
| service.port | MongoDB port | `27017` |
| replicaSet.name | Replica set name | `rs0` |
| replicaSet.initTimeoutSeconds | Wait for init job | `300` |
| persistence.enabled | Enable PVC | `true` |
| persistence.size | PVC size | `10Gi` |
| autoscaling.enabled | Enable HPA | `false` |
| autoscaling.minReplicas | HPA min | `3` |
| autoscaling.maxReplicas | HPA max | `6` |
| autoscaling.targetCPUUtilizationPercentage | CPU target | `70` |
| autoscaling.targetMemoryUtilizationPercentage | Memory target | `null` |
| reconcile.enabled | Enable reconciliation job | `true` |
| reconcile.hook | Run reconcile as Helm hook | `true` |
| reconcile.schedule | Cron schedule for periodic reconcile (empty disables) | `"*/5 * * * *"` |
| reconcile.ttlSecondsAfterFinished | TTL for reconcile job objects | `600` |
| reconcile.maxReplicaSearch | Max ordinals to consider | `null` (uses HPA max or replicaCount) |
| removeOnTerminate.enabled | Remove member on termination | `true` |
| removeOnTerminate.stepDownSeconds | Step down delay if primary | `30` |
| removeOnTerminate.maxAttempts | Removal retries | `10` |
| removeOnTerminate.retryIntervalSeconds | Interval between retries | `3` |
| podDisruptionBudget.enabled | Create PDB | `true` |
| podDisruptionBudget.minAvailable | Min available (defaults to majority) | `null` |
| resources | Pod resources | `{}` |
| nodeSelector | Node selector | `{}` |
| tolerations | Tolerations | `[]` |
| affinity | Custom affinity | `{}` |

## Notes and Operational Guidance
- Always set `auth.rootPassword` or provide an `auth.existingSecret` for production.
- After scale-out via Helm, the reconcile hook adds new members automatically.
- If pods are added by HPA or `kubectl scale` without a Helm upgrade, the periodic reconcile CronJob (if `reconcile.schedule` is set) will add them within the schedule interval.
- For scale-down/eviction, the preStop hook will step down if primary and call `rs.remove` to avoid stale members.
- Keep majority available during maintenance; PDB uses majority by default when replicas > 1.
- Persistence: PVCs remain unless your storage class is reclaiming; ensure you understand your storage policy.

## Example: Enable HPA and Reconcile
```bash
helm upgrade --install my-mongo charts/mongodb-replicaset \
  --set auth.rootPassword="changeme" \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=3 \
  --set autoscaling.maxReplicas=9 \
  --set autoscaling.targetCPUUtilizationPercentage=60
```
