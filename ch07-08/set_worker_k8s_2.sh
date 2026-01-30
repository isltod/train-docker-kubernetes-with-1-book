#!/usr/bin/bash
echo '# worker 역할 설정'
kubectl label node {node} node-role.kubernetes.io/worker=worker