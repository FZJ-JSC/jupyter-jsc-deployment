{{/*
Expand the name of the chart.
*/}}
{{- define "k8smgr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "k8smgr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8smgr.labels" -}}
helm.sh/chart: {{ include "k8smgr.chart" . }}
{{ include "k8smgr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8smgr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8smgr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
sidecar.istio.io/inject: false 
{{- end }}


{{/*
Generate certificates for drf k8smgr service
*/}}
{{- define "k8smgr.gen-certs" -}}
{{- $altNames := list ( printf "%s" (include "k8smgr.name" .) ) ( printf "%s.%s" (include "k8smgr.name" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "k8smgr.name" .) .Release.Namespace ) -}}
{{- $ca := genCA "k8smgr-ca" 1825 -}}
{{- $cert := genSignedCert ( include "k8smgr.name" . ) nil $altNames 1825 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
tls.ca : {{ $ca.Cert | b64enc }}
{{- end -}}
