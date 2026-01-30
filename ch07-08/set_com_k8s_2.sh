#!/usr/bin/bash

echo '# containerd 재시작'
sudo systemctl restart containerd.service
sudo systemctl status containerd.service

echo '# repository 공개키 다운로드 및 설정'
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-cache policy kubeadm

echo '# kubelet kubeadm kubectl 설치'
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

kubeadm version
kubectl version
kubelet --version

echo '# 자동 시작 등록'
sudo systemctl daemon-reload
sudo systemctl restart kubelet.service
sudo systemctl enable --now kubelet.service
