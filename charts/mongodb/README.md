# MongoDB Helm Chart

A Helm chart for deploying MongoDB on Kubernetes with authentication and automatic password generation.

## Features

- MongoDB 8.0 with configurable version
- Automatic random password generation for root and user accounts
- Persistent storage support with StatefulSet
- Configurable resource limits and requests
- Security context with non-root user
- Liveness and readiness probes
- Service account support
- Flexible service type configuration

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `my-mongodb`:

```bash
helm install my-mongodb ./mongodb
```

This command deploys MongoDB on the Kubernetes cluster with the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

## Uninstalling the Chart

To uninstall/delete the `my-mongodb` deployment:

```bash
helm uninstall my-mongodb
```

## Parameters

### Common parameters

| Name                      | Description                                        | Value                 |
|---------------------------|----------------------------------------------------|-----------------------|
| `replicaCount`            | Number of MongoDB replicas                         | `1`                   |
| `nameOverride`            | String to partially override mongodb.fullname      | `""`                  |
| `fullnameOverride`        | String to fully override mongodb.fullname          | `""`                  |

### Image parameters

| Name                | Description                                    | Value           |
|---------------------|------------------------------------------------|-----------------|
| `image.repository`  | MongoDB image repository                       | `mongo`         |
| `image.tag`         | MongoDB image tag (immutable tags recommended) | `8.0`           |
| `image.pullPolicy`  | MongoDB image pull policy                      | `IfNotPresent`  |
| `imagePullSecrets`  | Specify image pull secrets                     | `[]`            |

### MongoDB authentication parameters

| Name                  | Description                                           | Value    |
|-----------------------|-------------------------------------------------------|----------|
| `auth.rootUsername`   | MongoDB root username                                 | `root`   |
| `auth.rootPassword`   | MongoDB root password (random if empty)               | `""`     |
| `auth.database`       | Database to create                                    | `mydb`   |
| `auth.username`       | Custom user to create (leave empty to skip)           | `user`   |
| `auth.password`       | Password for custom user (random if empty)            | `""`     |

### Security parameters

| Name                                    | Description                                      | Value     |
|-----------------------------------------|--------------------------------------------------|-----------|
| `podSecurityContext.fsGroup`            | Group ID for the pod                             | `999`     |
| `securityContext.runAsUser`             | User ID for the container                        | `999`     |
| `securityContext.runAsGroup`            | Group ID for the container                       | `999`     |
| `securityContext.runAsNonRoot`          | Run container as non-root user                   | `true`    |
| `securityContext.allowPrivilegeEscalation` | Allow privilege escalation                    | `false`   |

### Service parameters

| Name           | Description                        | Value       |
|----------------|------------------------------------|-------------|
| `service.type` | Kubernetes service type            | `ClusterIP` |
| `service.port` | MongoDB service port               | `27017`     |

### Persistence parameters

| Name                        | Description                              | Value              |
|-----------------------------|------------------------------------------|--------------------|
| `persistence.enabled`       | Enable persistence using PVC             | `true`             |
| `persistence.storageClass`  | PVC Storage Class                        | `""`               |
| `persistence.accessMode`    | PVC Access Mode                          | `ReadWriteOnce`    |
| `persistence.size`          | PVC Storage Request                      | `8Gi`              |

### Resource parameters

| Name                      | Description                          | Value      |
|---------------------------|--------------------------------------|------------|
| `resources.limits.cpu`    | CPU resource limits                  | `1000m`    |
| `resources.limits.memory` | Memory resource limits               | `1Gi`      |
| `resources.requests.cpu`  | CPU resource requests                | `250m`     |
| `resources.requests.memory` | Memory resource requests           | `256Mi`    |

### Health check parameters

| Name                                  | Description                              | Value   |
|---------------------------------------|------------------------------------------|---------|
| `livenessProbe.enabled`               | Enable liveness probe                    | `true`  |
| `livenessProbe.initialDelaySeconds`   | Initial delay seconds for liveness probe | `30`    |
| `livenessProbe.periodSeconds`         | Period seconds for liveness probe        | `10`    |
| `readinessProbe.enabled`              | Enable readiness probe                   | `true`  |
| `readinessProbe.initialDelaySeconds`  | Initial delay seconds for readiness probe| `15`    |
| `readinessProbe.periodSeconds`        | Period seconds for readiness probe       | `10`    |

### Other parameters

| Name                            | Description                                | Value   |
|---------------------------------|--------------------------------------------|---------|
| `serviceAccount.create`         | Create service account                     | `true`  |
| `serviceAccount.annotations`    | Annotations for service account            | `{}`    |
| `serviceAccount.name`           | Name of service account                    | `""`    |
| `podAnnotations`                | Annotations for MongoDB pods               | `{}`    |
| `nodeSelector`                  | Node labels for pod assignment             | `{}`    |
| `tolerations`                   | Tolerations for pod assignment             | `[]`    |
| `affinity`                      | Affinity for pod assignment                | `{}`    |

## Configuration Examples

### Using custom passwords

```bash
helm install my-mongodb ./mongodb \
  --set auth.rootPassword=myRootPassword \
  --set auth.password=myUserPassword
```

### Disable persistence

```bash
helm install my-mongodb ./mongodb \
  --set persistence.enabled=false
```

### Use NodePort service

```bash
helm install my-mongodb ./mongodb \
  --set service.type=NodePort
```

### Custom resource limits

```bash
helm install my-mongodb ./mongodb \
  --set resources.limits.memory=2Gi \
  --set resources.requests.memory=512Mi
```

## Accessing MongoDB

After installation, follow the instructions in the NOTES output to:

1. Retrieve the root password
2. Connect to MongoDB from within the cluster
3. Connect to MongoDB from outside the cluster (if configured)

## Persistence

The chart mounts a Persistent Volume at `/data/db`. The volume is created using dynamic volume provisioning.

If you want to use an existing PersistentVolumeClaim, you can set `persistence.existingClaim`.

## Security

This chart implements several security best practices:

- Runs as non-root user (UID 999)
- Drops all capabilities
- Uses read-only root filesystem where possible
- Stores credentials in Kubernetes secrets
- Generates random passwords if not specified

## License

This chart is provided as-is under the same license as the helm-charts repository.
