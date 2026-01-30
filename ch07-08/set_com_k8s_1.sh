#!/usr/bin/bash

echo '# 패키지 설정'
sudo apt-get install -y net-tools openssh-server vim tree htop

echo '# 방화벽 제거(필요한 경우만)'
sudo ufw disable
sudo ufw status

echo '# 메모리 swap 제거'
sudo swapoff -a
free
sudo sed -i '/swap/s/^/#/' /etc/fstab

echo '# NTP 설정'
sudo apt-get install -y ntp
sudo systemctl restart ntp 
sudo systemctl status ntp
sudo ntpq -p

echo '# containerd 환경구성'
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat /etc/modules-load.d/containerd.conf
sudo modprobe overlay
sudo modprobe br_netfilter

echo '# 통신 구성'
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat /etc/modules-load.d/k8s.conf

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

cat /etc/sysctl.d/k8s.conf

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

cat /etc/sysctl.d/99-kubernetes-cri.conf

sudo sysctl --system

sudo apt install -y containerd

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

echo 'sudo vi /etc/containerd/config.toml 후에 SystemdCgroup = true 변경'
