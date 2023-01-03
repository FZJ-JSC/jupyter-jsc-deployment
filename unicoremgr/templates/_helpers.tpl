{{/*
Expand the name of the chart.
*/}}
{{- define "drf-unicoremgr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "drf-unicoremgr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "drf-unicoremgr.labels" -}}
helm.sh/chart: {{ include "drf-unicoremgr.chart" . }}
{{ include "drf-unicoremgr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "drf-unicoremgr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "drf-unicoremgr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
