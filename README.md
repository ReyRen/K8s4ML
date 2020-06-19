# K8s4ML
K8s platform specialized in Machine learning


## HOW TO USE

```
git clone
./scripts/setup.sh
vi config/inventory # modify by yourself
# MAKE passwordless access from Ansible system to Universal GPU servers
ssh-keygen
ssh-copy-id <username>@<host>
ansible all -m raw -a "hostname" # verify the configuration
ansible-playbook -l k8s-cluster playbooks/k8s-cluster.yml # install kubernetes using ansible and kubespray
kubectl get nodes # Verify
kubectl run gpu-test --rm -t -i --restart=Never --image=nvidia/cuda --limits=nvidia.com/gpu=1 nvidia-smi # test a GPU job to ensure that your kubernetes setup can tap into GPUs
```
**NOTE**
在双网卡情况下，/etc/hosts默认会去找default路由所对应的网卡，有时候并不符合inventory所指定的，如果也遇到这种情况，那么就将`K8s4ML/kubespray/roles/kubernetes/preinstall/tasks/0090-etchosts.yml`中的“populate inventory into hosts file”注掉，然后自己写hosts文件并且populate到各个节点

**Persistent Storage** (please modified by yourself)
```
./scripts/k8s_deploy_pvs.sh
```

**Monitoring**
```
./scripts/k8s_deploy_monitoring.sh
```

**Kubeflow**(can't work properly at present)
```
./scripts/k8s_deploy_kubeflow.sh
```

**Removing  nodes**
```
ansible-playbook kubespray/remove-node.yml --extra-vars "node=nodename0,nodename1"
```
This will drain nodename0 & nodename1, stop Kubernetes services, delete certificates, and finally execute the kubectl command to delete the nodes.

**Reset the Cluster**
```
ansible-playbook kubespray/remove-node.yml --extra-vars "node=nodename0,nodename1,<...>"
```
Note: There is also a Kubespray reset.yml playbook, but this does not do a complete tear-down of the cluster. Certificates and other artifacts might persist on each host, leading to a problematic redeployment in the future. The remove-node.yml playbook runs reset.yml as part of the process.



----------------------------------------------------------------------------------------------------

## 2020.4.13
持续更新代码(使用deepos & kubespary........)

## 2020.4.25
目前kubelow v1.0社区是不兼容kubernetes v1.16+的, [Minimum system requirements](https://www.kubeflow.org/docs/started/k8s/overview/#minimum-system-requirements)
但是在[kubeflow-project-card](https://github.com/orgs/kubeflow/projects/36#card-36657274)可以看到其实是将要release的Kubeflow v1.1是会对kubernetes v1.17和v1.16双双支持. 

细品的话[PR#375](https://github.com/kubeflow/manifests/issues/375)中已然开始修复，并且有大量的人在kubernetes v1.17和v1.16上测试, 社区人员[yanniszark](https://github.com/kubeflow/kubeflow/issues/4822#issuecomment-595257956)也表示了，有很多需要修改的地方, 并且不断有在v1.16上出现问题的reports. 但是其中的某些问题和`kfctl-k8s-istio`目前也是一头雾水. 因为要实际场景应用, 所以选择一个
kubespray v2.11.2, 其中支持的是Kubernetes v1.15.11

**PS**, 解释以下纠结于这个的原因是: kubespray中[PR#5628](https://github.com/kubernetes-sigs/kubespray/pull/5628)
激烈的讨论关于在master分支上出现`kube_version`和`kube_version_min_required`的问题. 

记录一个通过repository:tag的方式删除相同image id的image的方式
```
docker images|grep "redis关键字"|awk '{print $1":"$2}'|xargs docker rmi 
```

Move all necessary container images from gcr or others to "my docker hub", which is in the private NAS platform 172.18.12.16:4000/XXX:tag. Fucking the Firewall....

## 2020.5.15
因为在与kubespray社区一些列的躺坑和讨论之后，最终决定使用最新的kuberspray进行

https://github.com/kubernetes-sigs/kubespray/issues/6131

https://github.com/kubernetes-sigs/kubespray/issues/6137

https://github.com/ansible/ansible/issues/69247

https://github.com/docker/distribution/issues/3162

现阶段已经将集群调试成功了

**Reset the Cluster**

Sometimes a cluster will get into a bad state - perhaps one where certs are misconfigured or different across nodes. When this occurs it's often helpful to completely reset the cluster. To accomplish this, run the remove-node.yml playbook for all k8s nodes...
```
# NOTE: Explicitly list ALL nodes in the cluster. Do not use an ansible group name such as k8s-cluster.
ansible-playbook kubespray/remove-node.yml --extra-vars "node=nodename0,nodename1,<...>"
```
NOTE: There is also a Kubespray reset.yml playbook, but this does not do a complete tear-down of the cluster. Certificates and other artifacts might persist on each host, leading to a problematic redeployment in the future. The remove-node.yml playbook runs reset.yml as part of the process.


## 2020.5.15
**Removing Nodes**

Removing nodes can be performed with Kubespray's `remove-node.yml` playbook and supplying the node names as extra vars...
```
# NOTE: If SSH requires a password, add: `-k`
# NOTE: If sudo on remote machine requires a password, add: `-K`
# NOTE: If SSH user is different than current user, add: `-u ubuntu`
ansible-playbook kubespray/remove-node.yml --extra-vars "node=nodename0,nodename1"
```
This will drain `nodename0` & `nodename1`, stop Kubernetes services, delete certificates, and finally execute the kubectl command to delete the nodes.

More information no the topic may be found in the (Kubespray docs)[ttps://github.com/kubernetes-sigs/kubespray/blob/master/docs/getting-started.md#remove-nodes]

## 2020.5.22

**kubeflow** it doesn't work for now, unfortunately. I will update later. 

The script is in `K8s4ml/scripts/k8s_deploy_kubeflow.sh`

**monitor**

The script is in `K8s4ml/scripts/k8s_deploy_monitoring.sh`

**pvs**

The script is in `K8s4ml/scripts/k8s_deploy_pvs.sh`


Restore tons of images, digests and files in subnet NAS and reyren.cn:8001. This work really make me crazy :)

**How to save all Docker images and copy to another machine**

```
docker save $(docker images --format '{{.Repository}}:{{.Tag}}') -o allinone.tar
docker load -i allinone.tar
```
