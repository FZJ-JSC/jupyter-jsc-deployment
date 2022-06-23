{{/*
Expand the name of the chart.
*/}}
{{- define "nbviewer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nbviewer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- /* configmap name */}}
{{- define "nbviewer.cm.name" -}}
    {{- include "nbviewer.name" . }}-cm
{{- end }}


{{/*
Common labels
*/}}
{{- define "nbviewer.labels" -}}
helm.sh/chart: {{ include "nbviewer.chart" . }}
{{ include "nbviewer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nbviewer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nbviewer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nbviewer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nbviewer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
