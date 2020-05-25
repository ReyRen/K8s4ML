#!/usr/bin/env bash		

. /etc/os-release		

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"		
cd "${SCRIPT_DIR}/.." || echo "Could not cd to repository root"		

ANSIBLE_OK="2.7.8" # 支持的最低ansible		
ANSIBLE_VERSION="2.9.5" # 将要使用的ansible		
PROXY_USE=`grep -v ^# ${SCRIPT_DIR}/proxy.sh | grep -v ^$ | wc -l`		
PIP="${PIP:-pip}"		

as_sudo(){		
	if [ $PROXY_USE -gt 0 ]; then		
         cmd="sudo -H bash -c '. ${SCRIPT_DIR}/proxy.sh && $1'"		
     else		
         cmd="sudo bash -c '$1'"		
     fi		
     eval $cmd		
 }		

  as_user(){		
     if [ $PROXY_USE -gt 0 ]; then		
         cmd="bash -c '. ${SCRIPT_DIR}/proxy.sh && $1'"		
     else		
         cmd="bash -c '$1'"		
     fi		
     eval $cmd		
 }		

  # Install Software, 目前只针对与Ubuntu		
 case "$ID" in		
     ubuntu*)		
 	# No interactive prompts from apt during this process		
 	export DEBIAN_FRONTEND=noninteractive		
         # Update apt cache		
         echo "Updating apt cache..."		
         as_sudo 'apt-get update' >/dev/null		

          # Install repo tool		
         type apt-add-repository >/dev/null 2>&1 # 查看是否存在		
         if [ $? -ne 0 ] ; then		
             as_sudo 'apt-get -y install software-properties-common' >/dev/null		
         fi		

          # Install sshpass		
         type sshpass >/dev/null 2>&1		
         if [ $? -ne 0 ] ; then		
             as_sudo 'apt-get -y install sshpass' >/dev/null		
         fi		

          # Install pip		
         if ! which ${PIP} >/dev/null 2>&1; then		
             echo "Installing pip..."		
             as_sudo 'apt-get -y install python3-pip python-pip' >/dev/null		
         fi		
         ${PIP} --version		

          # Install setuptools		
         if ! dpkg -l python-setuptools >/dev/null 2>&1; then		
             echo "Installing setuptools..."		
             as_sudo 'apt-get -y install python-setuptools' >/dev/null		
         fi		

          # Check Ansible version and install with pip		
         if ! which ansible >/dev/null 2>&1; then		
             as_sudo "${PIP} install ansible==${ANSIBLE_VERSION}" >/dev/null		
         else		
             current_version=$(ansible --version | head -n1 | awk '{print $2}')		
             if ! python -c "from distutils.version import LooseVersion; print(LooseVersion('$ANSIBLE_OK') <= LooseVersion('$current_version'))" | grep True >/dev/null 2>&1 ; then		
                 echo "Unsupported version of Ansible: ${current_version}"		
                 echo "Version must be ${ANSIBLE_OK} or greater"		
                 exit 1		
             fi		
             if python -c "from distutils.version import LooseVersion; print(LooseVersion('$current_version') < LooseVersion('$ANSIBLE_VERSION'))" | grep True >/dev/null 2>&1 ; then		
                 echo "Upgrading Ansible version to ${ANSIBLE_VERSION}..."		
                 as_sudo "${PIP} install ansible==${ANSIBLE_VERSION}" >/dev/null		
             fi		
         fi		
         ansible --version | head -1		

          # Install python-netaddr		
         python -c 'import netaddr' >/dev/null 2>&1		
         if [ $? -ne 0 ] ; then		
             echo "Installing Python dependencies..."		
             as_sudo 'apt-get -y install python-netaddr python3-netaddr' >/dev/null		
         fi		

          # Install git		
         type git >/dev/null 2>&1		
         if [ $? -ne 0 ] ; then		
             echo "Installing git..."		
             as_sudo 'apt-get -y install git' >/dev/null		
         fi		
         git --version		

          # Install IPMItool		
         type ipmitool >/dev/null 2>&1		
         if [ $? -ne 0 ] ; then		
             echo "Installing IPMITool..."		
             as_sudo 'apt-get -y install ipmitool' >/dev/null		
         fi		
         ipmitool -V		

          # Install wget		
         if ! which wget >/dev/null 2>&1; then		
         echo "Installing wget..."		
             as_sudo 'apt-get -y install wget' >/dev/null		
         fi		
         wget --version | head -1		
         ;;		
     *)		
         echo "Unsupported Operating System $ID_LIKE"		
         echo "Please install Ansible, Git, and python-netaddr manually"		
         ;;		
 esac		

  # Install Ansible Galaxy roles, this is kind of roles used in ansible		
 ansible-galaxy --version >/dev/null 2>&1		
 if [ $? -eq 0 ] ; then		
     echo "Updating Ansible Galaxy roles..."		
     if [ $PROXY_USE -gt 0 ]; then		
         . ${SCRIPT_DIR}/proxy.sh && ansible-galaxy install --force -r requirements.yml >/dev/null		
     else		
         ansible-galaxy install --force -r requirements.yml >/dev/null		
 	#ansible-galaxy collection install community.kubernetes >/dev/null		
     fi		

 
  else		
     echo "ERROR: Unable to install Ansible Galaxy roles"		
 fi		

  # Copy default configuration		
 CONFIG_DIR=${CONFIG_DIR:-./config}		
 if [ ! -d "${CONFIG_DIR}" ] ; then		
     cp -rfp ./config.example "${CONFIG_DIR}"		
     echo "Copied default configuration to ${CONFIG_DIR}"		
 else		
     echo "Configuration directory '${CONFIG_DIR}' exists, not overwriting"		
 fi
