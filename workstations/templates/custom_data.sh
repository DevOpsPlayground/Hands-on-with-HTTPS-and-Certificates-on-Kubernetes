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

# # Remove line breaks from ca_cert
# echo ${ca_cert} > input.txt
# tr -d '\n' < input.txt > output.txt
# ca_cert_truncated=$(cat output.txt)

# Create .kube/config file
mkdir /home/${user}/.kube
touch /home/${user}/.kube/config
cat <<EOF > /home/${user}/.kube/config
apiVersion: v1
kind: Config
preferences: {}

# Define the cluster
clusters:
- cluster:
    certificate-authority-data: ${ca_cert}
    # You'll need the API endpoint of your Cluster here:
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