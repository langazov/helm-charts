{{/*
Expand the name of the chart (short, DNS-safe fragment used in resource names).
*/}}
{{- define "go-freeradius.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Fully-qualified app name: release-name + chart-name unless overridden.
We truncate at 63 chars because Kubernetes field names are limited to this
and we want the helpers to be safe for use in label *values* as well as names.
*/}}
{{- define "go-freeradius.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{-   .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{-   $name := default .Chart.Name .Values.nameOverride -}}
{{-   if contains $name .Release.Name -}}
{{-     .Release.Name | trunc 63 | trimSuffix "-" -}}
{{-   else -}}
{{-     printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{-   end -}}
{{- end -}}
{{- end -}}

{{/*
Chart name + version label, used by the standard Helm label set.
*/}}
{{- define "go-freeradius.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The docker image (repository:tag) used by the radiusd Deployment.
*/}}
{{- define "go-freeradius.image" -}}
{{- $tag := default .Chart.AppVersion .Values.image.tag -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end -}}

{{/*
Common labels applied to every rendered object. Follows the Helm "well-known
labels" convention so `helm ls` and label-based selectors work consistently.
*/}}
{{- define "go-freeradius.labels" -}}
helm.sh/chart: {{ include "go-freeradius.chart" . }}
{{ include "go-freeradius.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: radius-server
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Selector labels. Must be a stable subset that does not change between upgrades
(or the Deployment selector becomes immutable and the upgrade fails).
*/}}
{{- define "go-freeradius.selectorLabels" -}}
app.kubernetes.io/name: {{ include "go-freeradius.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
The service account name to use. Defaults to the fullname; lets operators
reuse a pre-existing SA via `serviceAccount.name`.
*/}}
{{- define "go-freeradius.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{-   default (include "go-freeradius.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{-   default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
The ConfigMap that holds radiusd.conf. Honours existingConfigMap so operators
can supply a fully custom config out-of-band.
*/}}
{{- define "go-freeradius.configMapName" -}}
{{- if .Values.radiusd.existingConfigMap -}}
{{-   .Values.radiusd.existingConfigMap -}}
{{- else -}}
{{-   printf "%s-config" (include "go-freeradius.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
The ConfigMap that holds the users file (consumed by rlm_files).
*/}}
{{- define "go-freeradius.usersConfigMapName" -}}
{{- if .Values.radiusd.files.existingConfigMap -}}
{{-   .Values.radiusd.files.existingConfigMap -}}
{{- else -}}
{{-   printf "%s-users" (include "go-freeradius.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
The Secret that holds the RADIUS shared secret.
*/}}
{{- define "go-freeradius.secretName" -}}
{{- if .Values.radiusd.sharedSecret.existingSecret -}}
{{-   .Values.radiusd.sharedSecret.existingSecret -}}
{{- else -}}
{{-   printf "%s-secret" (include "go-freeradius.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
The key inside the shared-secret Secret that contains the cleartext secret.
*/}}
{{- define "go-freeradius.secretKey" -}}
{{- default "radius-secret" .Values.radiusd.sharedSecret.existingSecretKey -}}
{{- end -}}

{{/*
Resolve the Redis service host. Prefers an externally-supplied host, then the
Bitnami subchart service name (imported via Chart.yaml importValues), then a
plain "redis" name as a last-resort convention.
*/}}
{{- define "go-freeradius.redisHost" -}}
{{- if .Values.redis.enabled -}}
{{-   printf "%s-redis-master.%s.svc.%s" (include "go-freeradius.fullname" .) .Release.Namespace .Values.clusterDomain -}}
{{- else if .Values.redis.external.host -}}
{{-   .Values.redis.external.host -}}
{{- else -}}
{{-   .Values.redis.host | default "redis" -}}
{{- end -}}
{{- end -}}

{{- define "go-freeradius.redisPort" -}}
{{- if .Values.redis.external.port -}}
{{-   .Values.redis.external.port -}}
{{- else -}}
{{-   .Values.redis.port | default 6379 -}}
{{- end -}}
{{- end -}}

{{/*
Resolve the SQL (MySQL or MariaDB) DSN ingredients. The driver is always
"mysql" because the go-freeradius rlm_sql module uses the Go mysql driver for
both MySQL and MariaDB.
*/}}
{{- define "go-freeradius.sqlDriver" -}}
{{- "mysql" -}}
{{- end -}}

{{- define "go-freeradius.sqlHost" -}}
{{- if .Values.mysql.enabled -}}
{{-   printf "%s-mysql.%s.svc.%s" (include "go-freeradius.fullname" .) .Release.Namespace .Values.clusterDomain -}}
{{- else if .Values.mariadb.enabled -}}
{{-   printf "%s-mariadb.%s.svc.%s" (include "go-freeradius.fullname" .) .Release.Namespace .Values.clusterDomain -}}
{{- else if .Values.sql.external.host -}}
{{-   .Values.sql.external.host -}}
{{- else -}}
{{-   .Values.sql.host | default "mysql" -}}
{{- end -}}
{{- end -}}

{{- define "go-freeradius.sqlPort" -}}
{{- if .Values.mysql.enabled -}}
{{-   3306 -}}
{{- else if .Values.mariadb.enabled -}}
{{-   3306 -}}
{{- else if .Values.sql.external.port -}}
{{-   .Values.sql.external.port -}}
{{- else -}}
{{-   .Values.sql.port | default 3306 -}}
{{- end -}}
{{- end -}}

{{- define "go-freeradius.sqlDatabase" -}}
{{- if .Values.mysql.enabled -}}
{{-   .Values.mysql.auth.database | default "radius" -}}
{{- else if .Values.mariadb.enabled -}}
{{-   .Values.mariadb.auth.database | default "radius" -}}
{{- else -}}
{{-   .Values.sql.database | default "radius" -}}
{{- end -}}
{{- end -}}

{{- define "go-freeradius.sqlUsername" -}}
{{- if .Values.mysql.enabled -}}
{{-   .Values.mysql.auth.username | default "radius" -}}
{{- else if .Values.mariadb.enabled -}}
{{-   .Values.mariadb.auth.username | default "radius" -}}
{{- else -}}
{{-   .Values.sql.username | default "radius" -}}
{{- end -}}
{{- end -}}

{{/*
The MySQL/MariaDB root/user password secret name + key. When the Bitnami
subchart is enabled it creates its own Secret; we reference that directly. When
an external DB is used we create a Secret from .Values.sql.password (or refer
to one supplied by the operator).
*/}}
{{- define "go-freeradius.sqlSecretName" -}}
{{- if .Values.mysql.enabled -}}
{{-   printf "%s-mysql" (include "go-freeradius.fullname" .) -}}
{{- else if .Values.mariadb.enabled -}}
{{-   printf "%s-mariadb" (include "go-freeradius.fullname" .) -}}
{{- else if .Values.sql.existingSecret -}}
{{-   .Values.sql.existingSecret -}}
{{- else -}}
{{-   printf "%s-sql" (include "go-freeradius.fullname" .) -}}
{{- end -}}
{{- end -}}

{{- define "go-freeradius.sqlSecretKey" -}}
{{- if .Values.mysql.enabled -}}
{{-   "mysql-password" -}}
{{- else if .Values.mariadb.enabled -}}
{{-   "mariadb-password" -}}
{{- else -}}
{{-   .Values.sql.existingSecretKey | default "sql-password" -}}
{{- end -}}
{{- end -}}

{{/*
MongoDB service resolution.
*/}}
{{- define "go-freeradius.mongoHost" -}}
{{- if .Values.mongodb.enabled -}}
{{-   printf "%s-mongodb.%s.svc.%s" (include "go-freeradius.fullname" .) .Release.Namespace .Values.clusterDomain -}}
{{- else if .Values.mongo.external.host -}}
{{-   .Values.mongo.external.host -}}
{{- else -}}
{{-   .Values.mongo.host | default "mongodb" -}}
{{- end -}}
{{- end -}}

{{- define "go-freeradius.mongoPort" -}}
{{- if .Values.mongodb.enabled -}}
{{-   27017 -}}
{{- else if .Values.mongo.external.port -}}
{{-   .Values.mongo.external.port -}}
{{- else -}}
{{-   .Values.mongo.port | default 27017 -}}
{{- end -}}
{{- end -}}

{{/*
Resource list snippet used in NOTES.txt and elsewhere.
*/}}
{{- define "go-freeradius.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride -}}
{{- end -}}
