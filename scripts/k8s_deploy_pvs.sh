#!/bin/bash

docker run -d --name nfs-server --privileged --restart always -p 2049:2049 -v /nfs-share:/nfs-share -e SHARED_DIRECTORY=/nfs-share itsthenetwork/nfs-server-alpine:latest

echo "waiting for the nfs server container running...."
sleep 10

echo "please use apt-get install nfs-common on all nodes"

helm repo add apphub https://apphub.aliyuncs.com

helm repo update

helm install nfs-client-provisioner --set storageClass.name=nfs-client --set storageClass.defaultClass=true --set nfs.server=192.168.0.113 --set nfs.path=/ apphub/nfs-client-provisioner

echo "Finished! storageClass.name is 'nfs-client'(default storageclass)"
echo "kubectl get pods"
echo "kubectl get sc (storageclass lookup)"
