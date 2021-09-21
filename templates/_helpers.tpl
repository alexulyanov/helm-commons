{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}

{{- define "common.fullname" -}}
{{- default "" .Values.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Renders a value that contains template.

Usage: {{ include "common.tplValue" ( dict "value" .Values.path.to.the.Value "context" $) }}

*/}}

{{- define "common.renderTplValue" -}}
{{- if typeIs "string" .value }}
  {{- tpl .value .context }}
{{- else }}
  {{- tpl (.value | toYaml) .context }}
{{- end }}
{{- end -}}


{{- define "common.listEnvVarsFromFile"}}
{{- range $key, $val := .Values.secrets.file }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secret
      key: {{ $key }}
{{- end}}


{{- range $key, $val := .Values.env.normal }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end}}
{{- end }}



{{- define "common.metadata" -}}
metadata:
  name: {{ template "common.fullname" . }}
  labels:
    k8s-monitoring: {{ .Values.servicemonitor.enabled | default "false" | quote }}
    app: {{ template "common.fullname" . }}
    service: {{ .Release.Service | quote }}
    release: {{ .Release.Name | quote }}
    chart: {{ replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name }}
{{- end -}}


{{- /* DEPERECATED 

common.injectNamespace used to inject real namespace value instead of fake placeholder in values.yaml
since values.yaml file does not support templates.

This functions accepts two objects:
  - .top - global context ($)
  - .targetString - string to inject an actual namespace value

Used for the formation of URL's for ingresses.

*/ -}}

{{- define "common.injectNamespace" -}}
{{- $namespace := .top.Release.Namespace -}}
{{ .targetString | replace "{{ .Release.Namespace }}" $namespace | quote }}
{{- end -}}