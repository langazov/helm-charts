# go-freeradius Helm Chart

> **AI Disclosure (per `AGENTS.md`):** This chart was generated with AI
> assistance and **must be reviewed, edited, and approved by a person** before
> being relied upon in production. It is a starting point, not a turnkey
> solution. Verify every value against the upstream FreeRADIUS documentation
> at <https://www.freeradius.org/documentation/freeradius-server/>.

Installs the [go-freeradius](https://github.com/freeRADIUS/freeradius-server)
`radiusd` server — the Go port of FreeRADIUS 3.2.10 — as a Kubernetes
`Deployment`. Optional Redis, MySQL/MariaDB and MongoDB backends are pulled in
as Bitnami subcharts and toggled on or off in `values.yaml`.

The same chart installs:

* a standalone server,
* a server with a Redis cache,
* a full SQL-backed deployment (the upstream `docker/example/radiusd.conf`
  topology, with `files`, `pap`, `chap`, `redis`, `sql`),
* or a server that talks to *existing* external backends.

## Quick start

```sh
cd deploy/helm
helm dependency update ./go-freeradius            # fetch the optional subcharts
helm install radius ./go-freeradius \
  --namespace radius --create-namespace \
  --set redis.enabled=true \
  --set mysql.enabled=true
helm test radius -n radius
```

Standalone (no backends):

```sh
helm install radius ./go-freeradius --namespace radius --create-namespace
```

## Backends

| Backend  | Enable                                     | Subchart                             | Notes |
|----------|--------------------------------------------|--------------------------------------|-------|
| Redis    | `redis.enabled=true`                       | `bitnami/redis` ^20                  | In-memory cache for `rlm_sql` / `rlm_redis`. |
| MySQL    | `mysql.enabled=true`                       | `bitnami/mysql` ^12                  | Ships the FreeRADIUS schema (`radcheck`, `radreply`, `radacct`, `radpostauth`). |
| MariaDB  | `mariadb.enabled=true`                     | `bitnami/mariadb` ^20                | Drop-in alternative to MySQL; radiusd uses `driver=mysql` either way. |
| MongoDB  | `mongodb.enabled=true`                     | `bitnami/mongodb` ^16                | For `rlm_mongo`. |

> **Mutual exclusion:** enable **at most one** of `mysql.enabled` /
> `mariadb.enabled`. If both are set the chart will still render but the
> `radiusd.conf` template will prefer MySQL.

### External backends

Leave the subchart `enabled: false` and supply the connection details under
the matching flat section:

```yaml
redis:
  enabled: false
  external:
    host: redis.cache.svc.cluster.local
    port: 6379

sql:
  host: mysql.db.svc.cluster.local
  port: 3306
  database: radius
  username: radius
  password: my-db-password     # or: existingSecret / existingSecretKey

mongo:
  external:
    host: mongo.db.svc.cluster.local
    port: 27017
```

The chart emits a `Secret` for the SQL password only when no subchart is
enabled. For Redis/Mongo with authentication, supply the credentials through
the upstream module's config under `radiusd.moduleConfig`.

## Configuration reference

The following table lists the most useful knobs. The complete surface is in
[`values.yaml`](./values.yaml).

| Key | Default | Description |
|-----|---------|-------------|
| `image.repository` | `go-freeradius-radiusd` | Image built by `docker/radiusd.Dockerfile`. |
| `image.tag` | `""` (Chart.appVersion) | Tag override. |
| `image.pullPolicy` | `IfNotPresent` | Standard Kubernetes pull policy. |
| `image.pullSecrets` | `[]` | List of `{name: …}` entries for private registries. |
| `replicaCount` | `1` | Number of radiusd Pods. |
| `podSecurityContext` | runAsUser 10001 | The image's non-root user. |
| `securityContext.readOnlyRootFilesystem` | `true` | The chart already mounts `emptyDir` on `/tmp`. |
| `containerPorts` | auth 1812 / acct 1813 / status 18120 / coa 3799 | Listener ports inside the container. |
| `service.type` | `ClusterIP` | Use `LoadBalancer` or `NodePort` to expose externally. |
| `service.externalTrafficPolicy` | `Cluster` | Set to `Local` to preserve client source IP. |
| `service.ports` | all four listeners | Drop entries to hide a listener from outside the cluster. |
| `resources` | 250m/256Mi → 1CPU/512Mi | Default requests/limits. |
| `radiusd.sharedSecret.value` | `"testing123"` | Cleartext RADIUS shared secret. |
| `radiusd.sharedSecret.existingSecret` | `""` | Use a Secret you manage. |
| `radiusd.clients` | `[{name: all, ipaddr: 0.0.0.0/0}]` | client blocks appended to radiusd.conf. **Tighten in production.** |
| `radiusd.files.content` | a sample `bob` user | The rlm_files users file. |
| `radiusd.modules.instantiate` | `[files,pap,chap,redis,sql]` | Module instantiation order. |
| `radiusd.modules.authorize` | `[files,sql,chap,pap]` | Authorize chain. |
| `radiusd.moduleConfig.sql` | (see values.yaml) | Templated `sql { }` block referencing the helpers. |
| `radiusd.tls.enabled` | `false` | RadSec / RADIUS-over-TLS listener (RFC 6614). |
| `extraArgs` | `[]` | Extra CLI flags (e.g. `-X` for debug). |
| `extraEnv` | `[]` | Extra environment variables. |
| `extraVolumes` / `extraVolumeMounts` | `[]` | Custom volumes (TLS, dictionaries, etc.). |
| `namespaceOverride` | `""` | Pin the install namespace from values. |
| `autoscaling.enabled` | `false` | HPA on CPU/memory. |
| `pdb.enabled` | `false` | PodDisruptionBudget (recommended when `replicaCount > 1`). |
| `networkPolicy.enabled` | `false` | NetworkPolicy restricting ingress/egress. |

### Templated vs fully-custom `radiusd.conf`

By default the chart renders `radiusd.conf` from `values.yaml` so that it
automatically picks up whichever subchart services exist. To take full
control:

1. Render your own `ConfigMap` containing `radiusd.conf`.
2. Set `radiusd.existingConfigMap: my-radiusd-config`.
3. The chart will mount it instead of templating.

### Database schema

When `mysql.enabled=true` the chart ships an init script that creates the
four canonical FreeRADIUS tables (`radcheck`, `radreply`, `radacct`,
`radpostauth`). For MariaDB use the subchart's own initdbScripts or mount the
schema from the upstream `raddb/mods-config/sql/main/mysql/schema.sql`.

## Probes

`radiusd` has no HTTP endpoint — it speaks RADIUS over UDP. The chart ships an
`exec` probe that verifies the auth socket is bound. To use a real
Status-Server probe, run a `radclient` sidecar and override
`readinessProbe.exec.command` to send a Status-Server packet to
`127.0.0.1:{{ .Values.containerPorts.status }}`.

## Upgrading

The Deployment carries `checksum/config`, `checksum/users`, `checksum/secret`
annotations, so any change in the rendered ConfigMap/Secret triggers a rolling
restart.

## Uninstall

```sh
helm uninstall radius -n radius
kubectl delete namespace radius   # if you created it
```

PVCs created by the subcharts (Redis, MySQL, …) are owned by the subcharts
and are removed with them. Set `*.persistence.enabled=true` on a subchart to
opt into persistent data.
