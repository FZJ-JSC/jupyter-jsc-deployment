{{/*
Expand the name of the chart.
*/}}
{{- define "drf-k8smgr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "drf-k8smgr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "drf-k8smgr.labels" -}}
helm.sh/chart: {{ include "drf-k8smgr.chart" . }}
{{ include "drf-k8smgr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "drf-k8smgr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "drf-k8smgr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Generate certificates for drf k8smgr service
*/}}
{{- define "drf-k8smgr.gen-certs" -}}
{{- $altNames := list ( printf "drf-k8smgr.svc" ) ( printf "drf-k8smgr.staging.svc" ) ( printf "%s" (include "drf-k8smgr.name" .) ) ( printf "%s.%s" (include "drf-k8smgr.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "drf-k8smgr.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "drf-k8smgr-ca" 1825 -}}
{{- $cert := genSignedCert ( include "drf-k8smgr.name" . ) nil $altNames 1825 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
tls.ca : {{ $ca.Cert | b64enc }}
{{- end -}}
