{{/*
Return the full name of the release
*/}}
{{- define "polybot.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end }}