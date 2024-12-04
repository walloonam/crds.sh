#!/bin/bash

# 원본 YAML 파일
input_file="argocd_v2.12.3_add_ns.yaml"

# CRD가 저장될 파일
crd_file="crds.yaml"

# CRD를 제외한 나머지 리소스를 저장할 파일
output_file="deployment_without_crds.yaml"

# CRD 분리
awk '
BEGIN { in_crd = 0 }
/\r$/ { sub(/\r$/, ""); } # 줄 끝에 있는 \r 제거
/^---/ {
    if (in_crd) {
        in_crd = 0
    } else if ($0 ~ /^---/) {
        if (!in_crd) print "---" > "'$output_file'"
    }
}
/^apiVersion: apiextensions.k8s.io\/v1/ { in_crd = 1; print "---" > "'$crd_file'" }
in_crd { print > "'$crd_file'" }
!in_crd && $0 !~ /^---/ { print > "'$output_file'" }
' "$input_file"

echo "CRD 부분은 $crd_file에 저장되었고, 나머지 리소스는 $output_file에 저장되었습니다."
