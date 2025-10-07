# MariaDB Helm Chart

A Helm chart for deploying MariaDB LTS on Kubernetes with automatic random password generation.

## Features

- Uses `mariadb:lts` Docker image
- Automatic random password generation for root and database user
- StatefulSet with persistent storage
- Configurable resource limits
- Health checks (liveness and readiness probes)
- Service Account support
- Security context configuration

## Installation

```bash
helm install my-mariadb ./charts/mariadb
```

## Configuration

The following table lists the configurable parameters and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of MariaDB replicas | `1` |
| `image.repository` | MariaDB image repository | `mariadb` |
| `image.tag` | MariaDB image tag | `lts` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `auth.rootPassword` | Root password (leave empty for random) | `""` |
| `auth.database` | Database to create | `mydb` |
| `auth.username` | Database user to create | `user` |
| `auth.password` | User password (leave empty for random) | `""` |
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.size` | Persistent volume size | `8Gi` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `3306` |
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `1Gi` |
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.requests.memory` | Memory request | `256Mi` |

## Random Password Generation

By default, both `auth.rootPassword` and `auth.password` are empty, which triggers automatic generation of random 16-character alphanumeric passwords during deployment.

To retrieve the passwords after installation:

```bash
# Get root password
kubectl get secret my-mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 -d

# Get user password
kubectl get secret my-mariadb -o jsonpath="{.data.mariadb-password}" | base64 -d
```

## Connecting to MariaDB

```bash
# Port forward to localhost
kubectl port-forward svc/my-mariadb 3306:3306

# Connect using mariadb client
mariadb -h 127.0.0.1 -P 3306 -u root -p
```

## Uninstallation

```bash
helm uninstall my-mariadb
```

Note: PersistentVolumeClaims are not automatically deleted and must be removed manually if desired.
