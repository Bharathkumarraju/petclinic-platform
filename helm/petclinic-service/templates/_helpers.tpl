{{/*
Expand the name of the release (used as the service/resource name).
nameOverride is set per-service so resources are named after the service,
not the Helm release (which may be "customers-service-linkerd" etc.).
*/}}
{{- define "petclinic-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride }}
{{- else if .Values.nameOverride }}
{{- .Values.nameOverride }}
{{- else }}
{{- .Release.Name }}
{{- end }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "petclinic-service.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ include "petclinic-service.fullname" . }}
app.kubernetes.io/part-of: petclinic
app.kubernetes.io/managed-by: Helm
app.kubernetes.io/component: {{ .Values.component }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
{{- end }}

{{/*
Selector labels — used in matchLabels and Service selector (must be stable).
*/}}
{{- define "petclinic-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "petclinic-service.fullname" . }}
{{- end }}

{{/*
Full image reference: registry/repository:tag
*/}}
{{- define "petclinic-service.image" -}}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository .Values.image.tag }}
{{- end }}

{{/*
ConfigMap name — always {fullname}-config
*/}}
{{- define "petclinic-service.configMapName" -}}
{{- printf "%s-config" (include "petclinic-service.fullname" .) }}
{{- end }}
