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

{{/*
Generate certificates for drf unicoremgr service
*/}}
{{- define "drf-unicoremgr.gen-certs" -}}
{{- $altNames := list ( printf "%s" (include "drf-unicoremgr.name" .) ) ( printf "%s.%s" (include "drf-unicoremgr.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "drf-unicoremgr.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "drf-unicoremgr-ca" 1825 -}}
{{- $cert := genSignedCert ( include "drf-unicoremgr.name" . ) nil $altNames 1825 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
tls.ca: {{ $ca.Cert | b64enc }}
{{- end -}}
