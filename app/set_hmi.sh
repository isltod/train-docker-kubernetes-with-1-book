#!/usr/bin/bash

echo '# helm 설치'
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
helm version

echo '# metallb 설치'
helm repo add metallb https://metallb.github.io/metallb
helm repo update

echo '# metallb-system 네임스페이스에 설치(+ CRD 생성)'
helm upgrade --install metallb metallb/metallb --namespace metallb-system --create-namespace --set crds.create=true

echo '# 확인'
kubectl get crd ipaddresspools.metallb.io l2advertisements.metallb.io
kubectl -n metallb-system get pods

echo '# metallb.yml 확인'

echo '# 적용'
kubectl apply -f metallb.yml

echo '# Ingress 설정'
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace

echo '# 결과 확인'
kubectl get namespace
kubectl get all --namespace metallb-system
kubectl get all --namespace ingress-nginx

