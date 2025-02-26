#!/bin/bash
set -e

# WARNING: This file was auto-generated. Do not edit!
#          All your edit might be overwritten!
DEPLOY_DIR={{.DeployDir}}
cd "${DEPLOY_DIR}" || exit 1

{{- define "PDList"}}
  {{- range $idx, $pd := .}}
    {{- if eq $idx 0}}
      {{- $pd.Scheme}}://{{$pd.IP}}:{{$pd.ClientPort}}
    {{- else -}}
      ,{{- $pd.Scheme}}://{{$pd.IP}}:{{$pd.ClientPort}}
    {{- end}}
  {{- end}}
{{- end}}

{{- if .NumaNode}}
exec numactl --cpunodebind={{.NumaNode}} --membind={{.NumaNode}} bin/tikv-cdc server \
{{- else}}
exec bin/tikv-cdc server \
{{- end}}
    --addr "0.0.0.0:{{.Port}}" \
    --advertise-addr "{{.IP}}:{{.Port}}" \
    --pd "{{template "PDList" .Endpoints}}" \
{{- if .DataDir}}
    --data-dir="{{.DataDir}}" \
{{- end}}
{{- if .TLSEnabled}}
    --ca tls/ca.crt \
    --cert tls/cdc.crt \
    --key tls/cdc.pem \
{{- end}}
{{- if .GCTTL}}
    --gc-ttl {{.GCTTL}} \
{{- end}}
{{- if .TZ}}
    --tz "{{.TZ}}" \
{{- end}}
    --config conf/tikv-cdc.toml \
    --log-file "{{.LogDir}}/tikv-cdc.log" 2>> "{{.LogDir}}/tikv-cdc_stderr.log"
