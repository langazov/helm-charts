# Redis Helm Chart

This Helm chart deploys Redis 8.2.2-alpine3.22 on a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `my-redis`:

```bash
helm install my-redis ./redis
```

The command deploys Redis on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-redis` deployment:

```bash
helm delete my-redis
```

## Parameters

### Common parameters

| Name                     | Description                                          | Value                    |
| ------------------------ | ---------------------------------------------------- | ------------------------ |
| `replicaCount`           | Number of Redis replicas to deploy                  | `1`                      |
| `image.repository`       | Redis image repository                               | `redis`                  |
| `image.tag`              | Redis image tag                                      | `8.2.2-alpine3.22`      |
| `image.pullPolicy`       | Redis image pull policy                             | `IfNotPresent`           |
| `nameOverride`           | String to partially override redis.fullname         | `""`                     |
| `fullnameOverride`       | String to fully override redis.fullname             | `""`                     |

### Redis Configuration parameters

| Name                     | Description                                          | Value                    |
| ------------------------ | ---------------------------------------------------- | ------------------------ |
| `redis.config`           | Redis configuration                                  | `see values.yaml`        |
| `redis.auth.enabled`     | Enable Redis auth                                    | `false`                  |
| `redis.auth.password`    | Redis password                                       | `""`                     |

### Persistence parameters

| Name                        | Description                                       | Value               |
| --------------------------- | ------------------------------------------------- | ------------------- |
| `persistence.enabled`       | Enable persistence using PVC                     | `true`              |
| `persistence.storageClass`  | PVC Storage Class for Redis volume               | `""`                |
| `persistence.accessMode`    | PVC Access Mode for Redis volume                 | `ReadWriteOnce`     |
| `persistence.size`          | PVC Storage Request for Redis volume             | `8Gi`               |

### Service parameters

| Name                  | Description                               | Value       |
| --------------------- | ----------------------------------------- | ----------- |
| `service.type`        | Redis service type                        | `ClusterIP` |
| `service.port`        | Redis service port                        | `6379`      |

### Resource parameters

| Name                        | Description                                       | Value       |
| --------------------------- | ------------------------------------------------- | ----------- |
| `resources.limits.cpu`      | The CPU limit for the Redis container            | `500m`      |
| `resources.limits.memory`   | The memory limit for the Redis container         | `512Mi`     |
| `resources.requests.cpu`    | The requested CPU for the Redis container        | `100m`      |
| `resources.requests.memory` | The requested memory for the Redis container     | `128Mi`     |

## Examples

### Installing with custom values

```bash
# Install with persistence disabled
helm install my-redis ./redis --set persistence.enabled=false

# Install with custom resource limits
helm install my-redis ./redis \
  --set resources.limits.memory=1Gi \
  --set resources.limits.cpu=1000m

# Install with Redis authentication
helm install my-redis ./redis \
  --set redis.auth.enabled=true \
  --set redis.auth.password=mypassword
```

### Connecting to Redis

After installation, connect to Redis using:

```bash
# Port forward to access Redis locally
kubectl port-forward svc/my-redis 6379:6379

# Connect using redis-cli
redis-cli -h localhost -p 6379

# Or run redis-cli in a pod
kubectl run redis-client --rm --tty -i --restart='Never' --image redis:8.2.2-alpine3.22 -- redis-cli -h my-redis -p 6379
```

### Testing the installation

```bash
# Run the included test
helm test my-redis
```

## Configuration and Installation Details

### Persistence

The Redis image stores the Redis data and configurations at the `/data` path of the container. Persistent Volume Claims are used to keep the data across deployments.

### Custom Redis Configuration

You can provide custom Redis configuration through the `redis.config` parameter in values.yaml.

### Security

The chart includes security contexts and follows Kubernetes security best practices:

- Runs as non-root user (999)
- Drops all capabilities
- Read-only root filesystem capability (configurable)

## Upgrading

To upgrade the chart:

```bash
helm upgrade my-redis ./redis
```

## Troubleshooting

### Check pod status
```bash
kubectl get pods -l app.kubernetes.io/name=redis
```

### Check logs
```bash
kubectl logs -l app.kubernetes.io/name=redis
```

### Check Redis info
```bash
kubectl exec -it deployment/my-redis -- redis-cli info
```