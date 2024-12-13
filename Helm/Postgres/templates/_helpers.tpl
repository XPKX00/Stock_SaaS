{{/*
Generate a fullname for the resource. Uses Release.Name or defaults to "default" if Release.Name is unavailable.
*/}}
{{- define "postgres.fullname" -}}
{{- if .Release.Name -}}
{{ printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- else -}}
{{ printf "default-%s" .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}
{{- end -}}
