#!/usr/bin/env python2
#-*- coding: UTF-8 -*-

import yaml
import logging
import os
import sys

def generate_service_doc(yaml_file):
    serviceName = raw_input("输入想要创建的service name(svc-testing): ")
    svcSelector = raw_input("输入想要被service管理的label name(testing-label): ")
    portName = raw_input("输入想要映射端口的别名: ")
    portProtocol = raw_input("输入映射端口的protocol: ")
    nodePort = raw_input("输入外部访问svc的端口: ")
    port = raw_input("请输入集群访问svc的端口: ")
    targetPort = raw_input("请输入pod内部的端口: ")

    if serviceName == "":
        serviceName = "svc-testing"
    if svcSelector == "":
        svcSelector = "testing-label"
    if nodePort != "":
        nodePort = int(nodePort)
    if port != "":
        port = int(port)
    if targetPort != "":
        targetPort = int(targetPort)
    
    py_object = {
                'apiVersion':'v1',
                'kind':'Service',
                'metadata':{'name':serviceName,'namespace':namespace},
                'spec':{'type':'NodePort','selector':{'run':svcSelector},'ports':[{'name':portName,'protocol':portProtocol,'nodePort':nodePort,'port':port,'targetPort':targetPort}]}
                }
    file = open(yaml_file, 'w')
    yaml.dump(py_object, file)
    file.close()

if __name__ == '__main__':
    try:
        namespace = sys.argv[1]
        rstype = sys.argv[2]

        current_path = os.path.abspath(".")
        if rstype == "Deployment":
            yaml_path = os.path.join(current_path, "Deployment.yaml")
            generate_deployment_doc(yaml_path)
        elif rstype == "Service":
            yaml_path = os.path.join(current_path, "Service.yaml")
            generate_service_doc(yaml_path)
        elif rstype == "Pod":
            yaml_path = os.path.join(current_path, "Pod.yaml")
            generate_pod_doc(yaml_path)
        elif rstype == "Job":
            yaml_path = os.path.join(current_path, "Job.yaml")
            generate_job_doc(yaml_path)

        logging.info("Created RS in %s namespaces." %(namespace))
    except IOError as e:
        logging.error("Failed to create RS in %s namespaces: {}" %(namespace))
