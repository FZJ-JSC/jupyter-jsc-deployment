{{/*
Expand the name of the chart.
*/}}
{{- define "drf-tunnel.name" -}}
{{- $name := default .Chart.Name .Values.nameOverride }}
  {{- if .Values.uniqueid }}
  {{- ( printf "%s-%s" $name .Values.uniqueid ) | trunc 63 | trimSuffix "-" }}
  {{- else }}
  {{- ( printf "%s" $name ) | trunc 63 | trimSuffix "-" }}
  {{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "drf-tunnel.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "drf-tunnel.labels" -}}
helm.sh/chart: {{ include "drf-tunnel.chart" . }}
{{ include "drf-tunnel.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "drf-tunnel.selectorLabels" -}}
app.kubernetes.io/name: {{ include "drf-tunnel.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}




