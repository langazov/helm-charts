{{/*
Expand the name of the chart.
*/}}
{{- define "mariadb-galera-ha.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mariadb-galera-ha.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mariadb-galera-ha.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mariadb-galera-ha.labels" -}}
helm.sh/chart: {{ include "mariadb-galera-ha.chart" . }}
{{ include "mariadb-galera-ha.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mariadb-galera-ha.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mariadb-galera-ha.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mariadb-galera-ha.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mariadb-galera-ha.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Headless service name for stable pod DNS
*/}}
{{- define "mariadb-galera-ha.headlessServiceName" -}}
{{- printf "%s-headless" (include "mariadb-galera-ha.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Secret name used for credentials
*/}}
{{- define "mariadb-galera-ha.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "mariadb-galera-ha.fullname" . }}
{{- end }}
{{- end }}

{{/*
Resolve root password; reuse existing secret if present to avoid regen on upgrades
*/}}
{{- define "mariadb-galera-ha.rootPassword" -}}
{{- if .Values.auth.existingSecret }}
{{- "<value from existingSecret>" }}
{{- else }}
{{- $secretName := include "mariadb-galera-ha.secretName" . }}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
{{- if and $existing (index $existing.data "mariadb-root-password") }}
{{- index $existing.data "mariadb-root-password" | b64dec }}
{{- else if .Values.auth.rootPassword }}
{{- .Values.auth.rootPassword }}
{{- else }}
{{- randAlphaNum 20 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Resolve user password; reuse existing secret if present to avoid regen on upgrades
*/}}
{{- define "mariadb-galera-ha.password" -}}
{{- if .Values.auth.existingSecret }}
{{- "<value from existingSecret>" }}
{{- else }}
{{- $secretName := include "mariadb-galera-ha.secretName" . }}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
{{- if and $existing (index $existing.data "mariadb-password") }}
{{- index $existing.data "mariadb-password" | b64dec }}
{{- else if .Values.auth.password }}
{{- .Values.auth.password }}
{{- else }}
{{- randAlphaNum 20 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Resolve replication password; reuse existing secret if present to avoid regen on upgrades
*/}}
{{- define "mariadb-galera-ha.replicationPassword" -}}
{{- if .Values.auth.existingSecret }}
{{- "<value from existingSecret>" }}
{{- else }}
{{- $secretName := include "mariadb-galera-ha.secretName" . }}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
{{- if and $existing (index $existing.data "mariadb-replication-password") }}
{{- index $existing.data "mariadb-replication-password" | b64dec }}
{{- else if .Values.auth.replicationPassword }}
{{- .Values.auth.replicationPassword }}
{{- else }}
{{- randAlphaNum 20 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Recovery configmap name
*/}}
{{- define "mariadb-galera-ha.recoveryConfigMapName" -}}
{{- printf "%s-recovery" (include "mariadb-galera-ha.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Build recovery hook image reference
*/}}
{{- define "mariadb-galera-ha.recoveryImage" -}}
{{- if .Values.recovery.image.digest -}}
{{- printf "%s@%s" .Values.recovery.image.repository .Values.recovery.image.digest -}}
{{- else if .Values.recovery.image.tag -}}
{{- printf "%s:%s" .Values.recovery.image.repository .Values.recovery.image.tag -}}
{{- else -}}
{{- .Values.recovery.image.repository -}}
{{- end -}}
{{- end }}

{{/*
Build wsrep_cluster_address from pod DNS names
*/}}
{{- define "mariadb-galera-ha.galeraClusterAddress" -}}
{{- $fullname := include "mariadb-galera-ha.fullname" . -}}
{{- $headless := include "mariadb-galera-ha.headlessServiceName" . -}}
{{- $ns := .Release.Namespace -}}
{{- $count := .Values.replicaCount | int -}}
{{- $addr := "gcomm://" -}}
{{- range $i := until $count -}}
{{- if $i -}}{{- $addr = printf "%s," $addr -}}{{- end -}}
{{- $addr = printf "%s%s-%d.%s.%s.svc.cluster.local" $addr $fullname $i $headless $ns -}}
{{- end -}}
{{- $addr -}}
{{- end }}
