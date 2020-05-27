#!/usr/bin/env python2
#-*- coding: UTF-8 -*-

import yaml
import logging
import os

#nodeSelector = raw_input("please choose a node you want to bind: ")
#
#with open('pp.yaml', 'r') as f:
#    config = yaml.load(f, Loader=yaml.FullLoader)
#    
#config['spec']['template']['spec']['nodeSelector']['disktype'] = nodeSelector
#
#with open('pp.yaml', 'w') as fname:
#    yaml_string = yaml.dump(config)
#    fname.write(yaml_string)

#with open('pod-pod.yaml') as f:
#    docs = yaml.load_all(f, Loader=yaml.FullLoader)
#    for doc in docs:
#        for k, v in doc.items():
#            print(k, "->", v)
def generate_yaml_doc(yaml_file):
    deploymentName = raw_input("输入想要创建的Deployment名称(pod-testing): ")
    replicasNum = raw_input("输入想要创建的replicas数量(1): ")
    matchLabels = raw_input("输入想要创建的matchLabels名称(testing-label): ")
    containerName = raw_input("输入想要创建的容器的名称(testing-container): ")
    imageName = raw_input("输入想要创建的image的名称: ")
    commandStr = raw_input("输入想要提前执行的命令: ")
    gpuNum = raw_input("输入想要使用的GPU个数(0): ")
    volumeMountsName = raw_input("输入想要挂在的逻辑卷名称(mount-name-testing): ")
    mountPath = raw_input("输入想要挂在的pod中的目录(/usr/share/horovod): ")
    pvcName = raw_input("输入要使用的pvc(pod-pvc-volume-1): ")
    disktype = raw_input("输入想要绑定的node(none, optional: cpu-master gpu-node1/2/3): ")

    if deploymentName == "":
        deploymentName = "pod-testing"
    if replicasNum == "":
        replicasNum = "1"
    if matchLabels == "":
        matchLabels = "testing-label"
    if containerName == "":
        containerName = "testing-container"
    if imageName == "":
        print('ERROR: 请指定imageName')
        os._exit(1)
    if commandStr == "":
        commandStr = "[ \"/bin/bash\", \"-ce\", \"tail -f /dev/null\" ]"
    if gpuNum == "":
        gpuNum = 0
    if volumeMountsName == "":
        volumeMountsName = "mount-name-testing"
    if mountPath == "":
        mountPath = "/usr/share/horovod"
    if pvcName == "":
        pvcName = "pod-pvc-volume-1"

    py_object = {
                'apiVersion':'apps/v1',
                'kind':'Deployment',
                'metadata':{'name':deploymentName,'namespace':'ai'},
                'spec':{'replicas':int(replicasNum),
                        'selector':{'matchLabels':{'run':matchLabels}},
                        'template':{'metadata':{'labels':{'run':matchLabels}},
                            'spec':{'containers':[{'name':containerName,'image':imageName,'command':commandStr, 'resources':{'limits':{'nvidia.com/gpu':int(gpuNum)}},'volumeMounts':[{'name':volumeMountsName, 'mountPath':mountPath}]}],
                                    'nodeSelector':{'disktype':disktype},
                                    'volumes':[{'name':volumeMountsName,'persistentVolumeClaim':{'claimName':pvcName}}]}}
                        },
                '---'
                }
    file = open(yaml_file, 'w')
    yaml.dump(py_object, file)
    file.close()


if __name__ == '__main__':
    try:
        current_path = os.path.abspath(".")
        yaml_path = os.path.join(current_path, "generate.yaml")
        generate_yaml_doc(yaml_path)
        logging.info("Created deployments/service/pvc in ai namespaces.")
    except IOError as e:
        logging.error("Failed to create deployments/service/pvc in ai namespaces: {}".format(e))
