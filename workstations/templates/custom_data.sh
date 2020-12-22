#!/bin/bash
set -e

# Send the log output from this script to user-data.log, syslog, and the console
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Install Kubectl
apt-get update && apt-get install -y apt-transport-https gnupg2 curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list 
apt-get update 
apt-get install -y kubectl

# Install Helm
curl https://baltocdn.com/helm/signing.asc | apt-key add -
apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install helm

# Install git
apt-get install git -y

# Install Azure CLI and add service principal creds to .bashrc as environment variables
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
echo "export APP_ID=${az_user}" >> /home/${linux_user}/.bashrc
echo "export APP_PW=${az_password}" >> /home/${linux_user}/.bashrc
echo "export TENANT_ID=${az_tenant}" >> /home/${linux_user}/.bashrc

# Create .kube/config file
mkdir /home/${linux_user}/.kube
touch /home/${linux_user}/.kube/config
cat <<EOF > /home/${linux_user}/.kube/config
apiVersion: v1
kind: Config
preferences: {}

# Define the cluster
clusters:
- cluster:
    certificate-authority-data: ${ca_cert}
    server: ${host}
  name: verified-drake-aks

# Define the user
users:
- name: ${sa}
  user:
    as-user-extra: {}
    client-key-data: ${ca_cert}
    token: ${token}

# Define the context: linking a user to a cluster
contexts:
- context:
    cluster: verified-drake-aks
    namespace: ${namespace}
    user: ${sa}
  name: ${namespace}

# Define current context
current-context: ${namespace}
EOF