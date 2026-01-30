#!/usr/bin/bash
echo '# k8s 초기화'
sudo kubeadm init

echo '# kubectl 사용을 위한 환경 설정'
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo '# vi .profile 후에 export KUBECONFIG=$HOME/.kube/config 추가'
source .profile
echo $KUBECONFIG

echo '# 확인: node 상태가 Reday가 되어야 함 - 근데 안됨, 다음으로...'
kubectl get node
kubectl get pod -A

echo '# calico 설치'
curl -O https://raw.githubusercontent.com/gasida/KANS/main/kans3/calico-kans.yaml
kubectl apply -f calico-kans.yaml
kubectl get pod -A
echo '# 계속 kubectl get pod -A 해서 모두 running 확인'
echo '# sudo scp /etc/kubernetes/admin.conf wolf@server2:~/ 로 설정 파일 넘기기'
