{{/*
Expand the name of the chart.
*/}}
{{- define "mongodb-replicaset.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mongodb-replicaset.fullname" -}}
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
{{- define "mongodb-replicaset.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mongodb-replicaset.labels" -}}
helm.sh/chart: {{ include "mongodb-replicaset.chart" . }}
{{ include "mongodb-replicaset.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mongodb-replicaset.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mongodb-replicaset.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "mongodb-replicaset.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mongodb-replicaset.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Headless service name for stable pod DNS
*/}}
{{- define "mongodb-replicaset.headlessServiceName" -}}
{{- printf "%s-headless" (include "mongodb-replicaset.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Secret name used for root credentials
*/}}
{{- define "mongodb-replicaset.secretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- include "mongodb-replicaset.fullname" . }}
{{- end }}
{{- end }}

{{/*
Root password key
*/}}
{{- define "mongodb-replicaset.rootPasswordKey" -}}
{{- default "mongodb-root-password" .Values.auth.rootPasswordKey }}
{{- end }}

{{/*
Return majority value for the given replica count
*/}}
{{- define "mongodb-replicaset.replicaSetMajority" -}}
{{- $count := int . -}}
{{- add (div $count 2) 1 -}}
{{- end }}

{{/*
Resolve max ordinals to search for members (used by reconcile cronjob)
*/}}
{{- define "mongodb-replicaset.maxReplicaSearch" -}}
{{- if .Values.reconcile.maxReplicaSearch }}
{{- .Values.reconcile.maxReplicaSearch | int }}
{{- else if and .Values.autoscaling.enabled .Values.autoscaling.maxReplicas }}
{{- .Values.autoscaling.maxReplicas | int }}
{{- else }}
{{- .Values.replicaCount | int }}
{{- end }}
{{- end }}

{{/*
Effective replica count for resources that need the initial pod count.
When autoscaling is enabled, the StatefulSet starts at autoscaling.minReplicas.
*/}}
{{- define "mongodb-replicaset.effectiveReplicaCount" -}}
{{- if .Values.autoscaling.enabled -}}
{{- .Values.autoscaling.minReplicas | int -}}
{{- else -}}
{{- .Values.replicaCount | int -}}
{{- end -}}
{{- end }}

{{/*
Resolve the MongoDB root password; reuse existing secret if present to avoid regen on upgrades
*/}}
{{- define "mongodb-replicaset.rootPassword" -}}
{{- if .Values.auth.existingSecret }}
{{- "<value from existingSecret>" }}
{{- else }}
{{- $key := include "mongodb-replicaset.rootPasswordKey" . }}
{{- $secretName := include "mongodb-replicaset.secretName" . }}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
{{- if and $existing (index $existing.data $key) }}
{{- index $existing.data $key | b64dec }}
{{- else if .Values.auth.rootPassword }}
{{- .Values.auth.rootPassword }}
{{- else }}
{{- randAlphaNum 20 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Name of the keyfile secret
*/}}
{{- define "mongodb-replicaset.keySecretName" -}}
{{- if .Values.auth.existingKeySecret }}
{{- .Values.auth.existingKeySecret }}
{{- else }}
{{- printf "%s-keyfile" (include "mongodb-replicaset.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Keyfile data key
*/}}
{{- define "mongodb-replicaset.keyFileKey" -}}
{{- default "mongodb-keyfile" .Values.auth.keyFileKey }}
{{- end }}

{{/*
Resolve the keyfile contents; reuse if secret already exists
*/}}
{{- define "mongodb-replicaset.keyFileContent" -}}
{{- if .Values.auth.existingKeySecret }}
{{- "<value from existingKeySecret>" }}
{{- else }}
{{- $key := include "mongodb-replicaset.keyFileKey" . }}
{{- $secretName := include "mongodb-replicaset.keySecretName" . }}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $secretName) }}
{{- if and $existing (index $existing.data $key) }}
{{- index $existing.data $key | b64dec }}
{{- else if .Values.auth.keyFile }}
{{- .Values.auth.keyFile }}
{{- else }}
{{- randAlphaNum 48 }}
{{- end }}
{{- end }}
{{- end }}
