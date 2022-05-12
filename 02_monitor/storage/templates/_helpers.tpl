{{/*
Expand the name of the chart.
*/}}
{{- define "rancher-monitoring-storage.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}
