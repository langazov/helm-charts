# Gitea Helm Chart

A Helm chart for deploying [Gitea](https://gitea.io) - a lightweight, self-hosted Git service - on Kubernetes with built-in PostgreSQL support.

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0+

## Installation

Add the Helm repository and install the chart:

```bash
# Add the repository
helm repo add myrepo https://example.com/helm-charts
helm repo update

# Install the chart
helm install gitea myrepo/gitea -n gitea --create-namespace
```

Or install from the local chart directory:

```bash
helm install gitea ./charts/gitea -n gitea --create-namespace
```

## Configuration

The chart is highly configurable through `values.yaml`. Below are some common configuration examples:

### Basic Configuration

```yaml
# Use default values with ClusterIP service
helm install gitea ./charts/gitea -n gitea --create-namespace
```

### With Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: gitea.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: gitea-tls
      hosts:
        - gitea.example.com
```

### With Custom Domain and SSL

```yaml
gitea:
  server:
    domain: gitea.example.com
    rootUrl: https://gitea.example.com
```

### With PostgreSQL Database (Default)

The chart includes a built-in PostgreSQL deployment that is enabled by default. It automatically manages the database for Gitea:

```bash
# Install with PostgreSQL (default)
helm install gitea ./charts/gitea -n gitea --create-namespace
```

To customize PostgreSQL:

```yaml
postgres:
  enabled: true
  image:
    tag: "15-alpine"  # or other versions like "14-alpine", "13-alpine"
  persistence:
    enabled: true
    size: 20Gi
    storageClassName: "fast-ssd"
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi

gitea:
  database:
    type: postgres
```

To use an external PostgreSQL database:

```yaml
postgres:
  enabled: false

gitea:
  database:
    type: postgres
    host: external-postgres.example.com
    port: 5432
    name: gitea
    username: gitea
    password: secure-password
    sslMode: disable
```

### With MariaDB Database

To deploy with MariaDB instead of PostgreSQL:

```yaml
mariadb:
  enabled: true
  image:
    tag: latest  # or specific version like "11.2", "10.6"
  persistence:
    enabled: true
    size: 20Gi
    storageClassName: "fast-ssd"
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi

postgres:
  enabled: false

gitea:
  database:
    type: mysql
```

### With External MariaDB Database

To use an external MariaDB database:

```yaml
mariadb:
  enabled: false

postgres:
  enabled: false

gitea:
  database:
    type: mysql
    host: external-mariadb.example.com
    port: 3306
    name: gitea
    username: gitea
    password: secure-password
```

### With SSH Server Enabled

```yaml
gitea:
  server:
    startSshServer: true
    sshPort: 2222

service:
  type: LoadBalancer
  # Or use NodePort for SSH access
```

### With Custom Admin Credentials

```yaml
gitea:
  admin:
    username: admin
    password: your-secure-password
    email: admin@example.com
```

### With Resource Limits

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

### With Persistent Storage

```yaml
persistence:
  enabled: true
  storageClassName: "fast-ssd"
  size: 20Gi
  accessMode: ReadWriteOnce
```

### With Node Affinity

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: disktype
              operator: In
              values:
                - ssd
```

## Key Configuration Options

### Gitea Admin User

| Parameter | Description | Default |
| --- | --- | --- |
| `gitea.admin.username` | Admin username | `gitea_admin` |
| `gitea.admin.password` | Admin password (auto-generated if empty) | `""` |
| `gitea.admin.email` | Admin email | `admin@gitea.local` |

### Server Configuration

| Parameter | Description | Default |
| --- | --- | --- |
| `gitea.server.domain` | Gitea domain | `localhost` |
| `gitea.server.rootUrl` | Root URL | `http://localhost:3000` |
| `gitea.server.httpPort` | HTTP port | `3000` |
| `gitea.server.sshPort` | SSH port | `22` |
| `gitea.server.startSshServer` | Enable SSH server | `false` |

### Database Configuration

| Parameter | Description | Default |
| --- | --- | --- |
| `gitea.database.type` | Database type (`sqlite3`, `mysql`, `postgres`) | `sqlite3` |
| `gitea.database.host` | Database host | `localhost` |
| `gitea.database.port` | Database port | `3306` for MySQL, `5432` for PostgreSQL |
| `gitea.database.name` | Database name | `gitea` |
| `gitea.database.username` | Database username | `gitea` |
| `gitea.database.password` | Database password | `""` |

### PostgreSQL Configuration

| Parameter | Description | Default |
| --- | --- | --- |
| `postgres.enabled` | Enable built-in PostgreSQL deployment | `true` |
| `postgres.image.repository` | PostgreSQL container image | `postgres` |
| `postgres.image.tag` | PostgreSQL image tag | `15-alpine` |
| `postgres.replicaCount` | Number of PostgreSQL replicas | `1` |
| `postgres.service.port` | PostgreSQL service port | `5432` |
| `postgres.persistence.enabled` | Enable persistent volume for PostgreSQL | `true` |
| `postgres.persistence.size` | PostgreSQL volume size | `8Gi` |
| `postgres.persistence.storageClassName` | Storage class for PostgreSQL | `""` |
| `postgres.database.name` | PostgreSQL database name | `gitea` |
| `postgres.database.user` | PostgreSQL database user | `gitea` |
| `secrets.postgres.password` | PostgreSQL password (auto-generated if empty) | `""` |

### MariaDB Configuration

| Parameter | Description | Default |
| --- | --- | --- |
| `mariadb.enabled` | Enable built-in MariaDB deployment | `false` |
| `mariadb.image.repository` | MariaDB container image | `mariadb` |
| `mariadb.image.tag` | MariaDB image tag | `latest` |
| `mariadb.replicaCount` | Number of MariaDB replicas | `1` |
| `mariadb.service.port` | MariaDB service port | `3306` |
| `mariadb.persistence.enabled` | Enable persistent volume for MariaDB | `true` |
| `mariadb.persistence.size` | MariaDB volume size | `8Gi` |
| `mariadb.persistence.storageClassName` | Storage class for MariaDB | `""` |
| `mariadb.database.name` | MariaDB database name | `gitea` |
| `mariadb.database.user` | MariaDB database user | `gitea` |
| `secrets.mariadb.rootPassword` | MariaDB root password (auto-generated if empty) | `""` |
| `secrets.mariadb.userPassword` | MariaDB user password (auto-generated if empty) | `""` |

### Persistence

| Parameter | Description | Default |
| --- | --- | --- |
| `persistence.enabled` | Enable persistent volume | `true` |
| `persistence.storageClassName` | Storage class name | `""` |
| `persistence.size` | Volume size | `10Gi` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |

### Kubernetes Resources

| Parameter | Description | Default |
| --- | --- | --- |
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image | `gitea/gitea` |
| `image.tag` | Container image tag | `1.21.11` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `3000` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.requests.memory` | Memory request | `256Mi` |

## Accessing Gitea

### Via Port-Forward (ClusterIP)

```bash
kubectl port-forward -n gitea svc/gitea 3000:3000
# Visit http://localhost:3000
```

### Via LoadBalancer

```bash
kubectl get svc -n gitea
# Use the EXTERNAL-IP from the LoadBalancer service
```

### Via NodePort

```bash
kubectl get svc -n gitea
# Visit http://<node-ip>:<node-port>
```

### Via Ingress

```bash
# Visit the hostname configured in ingress.hosts
# e.g., https://gitea.example.com
```

## Getting Admin Credentials

If you didn't provide an admin password, it will be auto-generated. Retrieve it with:

```bash
kubectl get secret -n gitea gitea-secrets -o jsonpath='{.data.admin-password}' | base64 -d
```

## Getting MariaDB Passwords

If MariaDB is enabled and you didn't provide passwords, they will be auto-generated. Retrieve them with:

```bash
# Get root password
kubectl get secret -n gitea gitea-secrets -o jsonpath='{.data.mariadb-root-password}' | base64 -d

# Get user password
kubectl get secret -n gitea gitea-secrets -o jsonpath='{.data.mariadb-user-password}' | base64 -d
```

## Getting PostgreSQL Password

If PostgreSQL is enabled and you didn't provide a password, it will be auto-generated. Retrieve it with:

```bash
kubectl get secret -n gitea gitea-secrets -o jsonpath='{.data.postgres-password}' | base64 -d
```

## Updating the Chart

To update the Gitea deployment:

```bash
# Update values
helm upgrade gitea ./charts/gitea -n gitea -f values.yaml

# View history
helm history gitea -n gitea

# Rollback if needed
helm rollback gitea -n gitea
```

## Uninstalling

```bash
helm uninstall gitea -n gitea
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n gitea
kubectl describe pod -n gitea <pod-name>
```

### View Logs

```bash
kubectl logs -n gitea -l app.kubernetes.io/name=gitea
```

### Check Service

```bash
kubectl get svc -n gitea
kubectl describe svc -n gitea gitea
```

### Check MariaDB Status

If MariaDB is enabled:

```bash
# Check MariaDB pod
kubectl get pods -n gitea -l app.kubernetes.io/component=mariadb

# View MariaDB logs
kubectl logs -n gitea -l app.kubernetes.io/component=mariadb

# Test MariaDB connection
kubectl exec -it -n gitea <mariadb-pod-name> -- mariadb -u root -p<root-password> -e "SELECT VERSION();"
```

### Check PostgreSQL Status

If PostgreSQL is enabled:

```bash
# Check PostgreSQL pod
kubectl get pods -n gitea -l app.kubernetes.io/component=postgres

# View PostgreSQL logs
kubectl logs -n gitea -l app.kubernetes.io/component=postgres

# Test PostgreSQL connection
kubectl exec -it -n gitea <postgres-pod-name> -- psql -U gitea -d gitea -c "SELECT version();"
```

### Port-Forward for Debugging

```bash
kubectl port-forward -n gitea pod/<pod-name> 3000:3000
```

## Advanced Configuration

### Custom app.ini Configuration

Add custom configuration directly to `values.yaml`:

```yaml
gitea:
  config:
    "[custom.section]":
      "SOME_KEY": "some_value"
```

### Environment Variables

Environment variables can be injected via the deployment spec. To modify this, update the deployment template or use a values override.

### OAuth2 Integration

Gitea supports various OAuth2 providers. Configure them through the app.ini file in the ConfigMap.

### SMTP Configuration

Enable mail notifications:

```yaml
gitea:
  config:
    mailer:
      ENABLED: true
      PROTOCOL: smtp
      SMTP_ADDR: smtp.example.com
      SMTP_PORT: 587
      FROM: gitea@example.com
      USER: your-email@example.com
      PASSWD: your-app-password
```

## Monitoring and Maintenance

### Database Backups

When using the built-in MariaDB:

```bash
# Get the MariaDB pod name
POD=$(kubectl get pods -n gitea -l app.kubernetes.io/component=mariadb -o jsonpath='{.items[0].metadata.name}')

# Create a database dump
kubectl exec -n gitea $POD -- mysqldump -u root -p<root-password> --all-databases > backup.sql

# Store backup securely
```

When using the built-in PostgreSQL:

```bash
# Get the PostgreSQL pod name
POD=$(kubectl get pods -n gitea -l app.kubernetes.io/component=postgres -o jsonpath='{.items[0].metadata.name}')

# Create a database dump
kubectl exec -n gitea $POD -- pg_dump -U gitea gitea > backup.sql

# Store backup securely
```

### Health Checks

The chart includes health checks for all components:

- **Gitea**: HTTP health check on `/api/healthz`
- **MariaDB**: SQL health check using `SELECT 1`
- **PostgreSQL**: Connection check using `pg_isready`

View health status:

```bash
kubectl describe pod -n gitea <pod-name>
```

## Security Considerations

- Use secrets for sensitive data (passwords, tokens)
- Enable RBAC and network policies in your cluster
- Use TLS/SSL for production deployments (via Ingress)
- Set `podSecurityContext` appropriately for your cluster
- Regularly update the Gitea, MariaDB, and PostgreSQL images to the latest versions
- Use strong admin passwords (auto-generated passwords are 32 characters)
- Enable firewall rules for SSH access if needed
- For production: Consider using an external managed database service instead of built-in databases
- Implement network policies to restrict traffic between pods
- Use Pod Security Standards (PSS) or Pod Security Policies (PSP)
- Database credentials are stored in Kubernetes Secrets - ensure your cluster has proper secret management
- Consider using a Secret management solution (Sealed Secrets, External Secrets, Vault) for production

## Support

For issues with Gitea itself, visit [Gitea Documentation](https://docs.gitea.io/)

For issues with this Helm chart, open an issue in the repository.
