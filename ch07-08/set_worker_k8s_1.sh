#!/usr/bin/bash
echo '# worker node 등록'
echo '# kubeadm 리셋'
sudo kubeadm reset -f

echo '# kubelet/컨테이너 런타임 정리'
sudo systemctl stop kubelet || true
# containerd 사용 시
sudo systemctl restart containerd || true
# (도커 사용 시) sudo systemctl restart docker || true

echo '# CNI 잔여물 정리'
sudo rm -rf /etc/cni/net.d/* /var/lib/cni/* /var/run/cni/* 2>/dev/null || true

echo '# kubeadm가 남긴 파일(에러에 나온 경로 포함) 정리'
sudo rm -rf /etc/kubernetes/kubelet.conf /etc/kubernetes/pki/ca.crt 2>/dev/null || true
echo '# (필요 시) 전체 디렉터리 정리 — 다른 설정 없다는 전제'
sudo rm -rf /etc/kubernetes/* 2>/dev/null || true

echo '# 컨트롤플레인으로 재구성할 게 아니라면 etcd 데이터도 제거(해당 노드에 etcd 데이터가 있다면)'
sudo rm -rf /var/lib/etcd 2>/dev/null || true

echo '# iptables/ipvs 정리'
sudo iptables -F; sudo iptables -t nat -F; sudo iptables -t mangle -F; sudo iptables -X
sudo ipvsadm -C 2>/dev/null || true

echo '# 스왑 꺼짐 확인 (필수)'
sudo swapoff -a
sudo sed -i.bak '/\sswap\s/s/^/#/' /etc/fstab


echo '# 재시작 및 상태 점검'
sudo systemctl daemon-reload
sudo systemctl enable kubelet --now
sudo systemctl status kubelet --no-pager || true

echo '# 10250 포트가 비었는지 재확인'
sudo ss -lntp | grep 10250 || echo "10250 is free"


echo '# kubectl 실행하도록 적용'
echo '# 마스터 노드의 admin.conf 파일 복사'
# 앞서 마스터 노드에서 scp 해놔야 함
sudo mv admin.conf /etc/kubernetes/

echo '# config 설정'
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


echo '# 마스터 노드 kubeadm join 명령어 확인 - 그대로 입력'
kubeadm token create --print-join-command
