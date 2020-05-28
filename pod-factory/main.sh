#!/usr/bin/env bash

RSTYPE_SERVICE=""
RSTYPE_DEPLOYMENT=""
RSTYPE_POD=""
RSTYPE_JOB=""
RSTYPE=""
ARG=""


function help_me() {
	echo "Usage: ./main.sh [hD] [Service/Deployment/Pod/Job]"
#
# ./main.sh Service/Deployment/Pod/Job
# ./main.sh -h
# ./main.sh -D
#
	echo "-h	This message."
	echo "-D	Delete all balabala"
}

function get_opts() {
	while getopts "hD" option; do
		case $option in
			D)
				bala_DELETE=true
				;;
			h)
				help_me
				exit 1
				;;
			*)
				help_me
				exit 1
				;;
		esac
	done

	
	if [ $1 = "Service" ]; then
		RSTYPE_SERVICE="Service"
	elif [ $1 = "Deployment" ]; then
		RSTYPE_DEPLOYMENT="Deployment"
	elif [ $1 = "Pod" ]; then
		RSTYPE_POD="Pod"
	elif [ $1 = "Job" ]; then
		RSTYPE_JOB="Job"
	elif [ -n "$NAMESPACE" ]; then
		NAMESPACE="default"
	else
		help_me
		exit 3
	fi
}

function create_namespace(){
	echo "Namespace需要指定吗(default)?"
	read Arg
	if [ "$Arg" = "" ] || [ "$Arg" = "default" ]; then
		Arg="default"
	else
		#kubectl get ns | grep $1 >/dev/null 2>&1
	#if [ $? -eq 1 ]; then
		kubectl create namespace $Arg
	#else
	#	echo "The $1 namespace already exists!"
	fi
	ARG=$Arg
}

get_opts ${@}

create_namespace

if [ -n "${RSTYPE_SERVICE}" ]; then
	RSTYPE=${RSTYPE_SERVICE}
elif [ -n "${RSTYPE_DEPLOYMENT}" ]; then
	RSTYPE=${RSTYPE_DEPLOYMENT}
elif [ -n "${RSTYPE_POD}" ]; then
	RSTYPE=${RSTYPE_POD}
elif [ -n "${RSTYPE_JOB}" ]; then
	RSTYPE=${RSTYPE_JOB}
fi

./yaml_generate.py $ARG ${RSTYPE}
