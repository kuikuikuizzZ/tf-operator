{{- define "container.image" }}
{{- $imageRegistry := .platformConfig.imageRegistry }}
{{- $imageRepository := .platformConfig.imageRepositoryRelease }}
{{- $imageName := (default .context.Chart .image.name )}}
{{- $imageTag := (default .context.Chart.AppVersion .image.tag )}}
{{- $imagePullPolicy := (default "Always" .platformConfig.imagePullPolicy )}}
image: {{ $imageRegistry }}/{{ $imageRepository }}/{{ $imageName }}:{{ $imageTag }}
imagePullPolicy: {{ $imagePullPolicy }}
{{- end }}

{{- define "container.container" }}
{{- $context := .context }}
- name: {{ .containerName }}
  {{- include "container.image" (dict "image" .container.image "context" $context "platformConfig" .context.Values.platformConfig) | indent 2 }}
  env:
  - name: "POD_NAME"
    valueFrom:
      fieldRef:
        fieldPath: metadata.name
  {{- if .container.env }}
  {{- include "common.tplvalues.render" (dict "value" .container.env "context" $context) | nindent 2 }}
  {{- end }}
  {{- if .container.command }}
  command: {{- include "common.tplvalues.render" (dict "value" .container.command "context" $context) | nindent 2 }}
  {{- end }}
  {{- if .container.args }}
  args: {{- include "common.tplvalues.render" (dict "value" .container.args "context" $context) | nindent 2 }}
  {{- end }}
  {{- if .container.ports }}
  ports:
  {{- range $portName, $port := .container.ports }}
  - name: {{ $portName }}
    {{- include "common.tplvalues.render" (dict "value" $port "context" $context) | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- if .container.livenessProbe }}
  livenessProbe:
    {{- if .container.livenessProbe.useDefault }}
    initialDelaySeconds: 10
    failureThreshold: 3
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
    httpGet:
      path: /healthz?type=liveness
      port: 8080
    {{- else }}
      {{- include "common.tplvalues.render" (dict "value" (omit .container.livenessProbe "useDefault") "context" $context) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if .container.readinessProbe }}
  readinessProbe:
    {{- if .container.readinessProbe.useDefault }}
    initialDelaySeconds: 10
    failureThreshold: 3
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
    httpGet:
      path: /healthz?type=liveness
      port: 8080
    {{- else }}
      {{- include "common.tplvalues.render" (dict "value" (omit .container.readinessProbe "useDefault") "context" $context) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if .container.resources }}
  resources:
    {{- if .container.resources.useDefault }}
    limits:
      cpu: 100m
      memory: 200Mi
    requests:
      cpu: 50m
      memory: 100Mi
    {{- else }}
      {{- include "common.tplvalues.render" (dict "value" (omit .container.resources "useDefault") "context" $context) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if .container.mounts }}
  volumeMounts:
  {{- range $mountName, $mount := .container.mounts }}
  - name: {{ $mountName }}
    mountPath: {{ $mount.path }}
    {{- if $mount.subPath }}
    subPath: {{ $mount.subPath }}
    {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
