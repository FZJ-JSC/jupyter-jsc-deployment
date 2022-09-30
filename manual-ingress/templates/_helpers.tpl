{{/*
Expand the name of the chart.
*/}}
{{- define "manualIngress.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "manualIngress.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "manualIngress.labels" -}}
helm.sh/chart: {{ include "manualIngress.chart" . }}
{{ include "manualIngress.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "manualIngress.selectorLabels" -}}
app.kubernetes.io/name: {{ include "manualIngress.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
