{{/*
Expand the name of the chart.
*/}}
{{- define "gitea.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "gitea.fullname" -}}
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
{{- define "gitea.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gitea.labels" -}}
helm.sh/chart: {{ include "gitea.chart" . }}
{{ include "gitea.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gitea.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gitea.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gitea.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gitea.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate admin password
*/}}
{{- define "gitea.adminPassword" -}}
{{- if .Values.gitea.admin.password }}
{{- .Values.gitea.admin.password }}
{{- else }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace (printf "%s-secrets" (include "gitea.fullname" .)) }}
{{- if $secret }}
{{- index $secret.data "admin-password" | b64dec }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate secret key
*/}}
{{- define "gitea.secretKey" -}}
{{- if .Values.gitea.security.secretKey }}
{{- .Values.gitea.security.secretKey }}
{{- else }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace (printf "%s-secrets" (include "gitea.fullname" .)) }}
{{- if $secret }}
{{- index $secret.data "secret-key" | b64dec }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate internal token URI
*/}}
{{- define "gitea.internalTokenUri" -}}
{{- if .Values.gitea.security.internalTokenUri }}
{{- .Values.gitea.security.internalTokenUri }}
{{- else }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace (printf "%s-secrets" (include "gitea.fullname" .)) }}
{{- if $secret }}
{{- index $secret.data "internal-token-uri" | b64dec }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate MariaDB root password
*/}}
{{- define "gitea.mariadbRootPassword" -}}
{{- if .Values.secrets.mariadb.rootPassword }}
{{- .Values.secrets.mariadb.rootPassword }}
{{- else }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace (printf "%s-secrets" (include "gitea.fullname" .)) }}
{{- if $secret }}
{{- index $secret.data "mariadb-root-password" | b64dec }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate MariaDB user password
*/}}
{{- define "gitea.mariadbUserPassword" -}}
{{- if .Values.secrets.mariadb.userPassword }}
{{- .Values.secrets.mariadb.userPassword }}
{{- else }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace (printf "%s-secrets" (include "gitea.fullname" .)) }}
{{- if $secret }}
{{- index $secret.data "mariadb-user-password" | b64dec }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate PostgreSQL password
*/}}
{{- define "gitea.postgresPassword" -}}
{{- if .Values.secrets.postgres.password }}
{{- .Values.secrets.postgres.password }}
{{- else }}
{{- $secret := lookup "v1" "Secret" .Release.Namespace (printf "%s-secrets" (include "gitea.fullname" .)) }}
{{- if $secret }}
{{- index $secret.data "postgres-password" | b64dec }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}
{{- end }}
