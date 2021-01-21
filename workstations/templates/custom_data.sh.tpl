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
chown ${linux_user}:${linux_user} /home/${linux_user}/.kube/config
chmod 600 /home/${linux_user}/.kube/config

# Install web terminal - WeTTY
echo "--> Installing nodejs and nginx"
curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash -
sudo apt-get install -y nginx nodejs gcc g++ make
echo "--> Installing yarn"
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
echo "--> Installing Wetty web terminal"
sudo yarn global add wetty@v2.0.2
echo "--> Configuring Nginx proxy for Wetty web terminal"
sudo tee /etc/nginx/nginx.conf > /dev/null <<"EOF"
user www-data;
worker_processes auto;
pid /run/nginx.pid;
events {
    worker_connections 768;
}
http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
  server {
      listen 80 default_server;
      listen [::]:80 default_server;
      server_name _;
      location / {
        proxy_pass http://127.0.0.1:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 43200000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
      }
      location /apache {
          proxy_pass http://127.0.0.1:8080;
          proxy_set_header Host $host;
          proxy_set_header   X-Real-IP         $remote_addr;
          proxy_set_header   X-Forwarded-For   $proxy_add_x_forwarded_for;
          proxy_set_header   X-Forwarded-Proto $scheme;
      }
  }
}
EOF
echo "--> Create wetty service account"
sudo useradd wetty \
   --shell /bin/bash \
   --create-home
echo 'wetty:${wetty_pw}' | sudo chpasswd
sudo tee /etc/sudoers.d/wetty > /dev/null <<"EOF"
wetty ALL=(ALL:ALL) ALL
EOF
sudo chmod 0440 /etc/sudoers.d/wetty
sudo usermod -a -G sudo wetty
echo "--> Installing systemd script for Wetty web terminal"
sudo tee /etc/systemd/system/wetty.service > /dev/null <<"SERVICE"
[Unit]
Description=Wetty Web Terminal
After=network.target
[Service]
User=wetty
Group=wetty
ExecStart=/usr/local/bin/wetty -p 3000 --host 127.0.0.1 --ssh-user ${wetty_user}
[Install]
WantedBy=multi-user.target
SERVICE
sudo chmod 0755 /etc/systemd/system/wetty.service
echo "--> Enable Nginx and Wetty web terminal services"
sudo systemctl daemon-reload
sudo systemctl enable wetty
sudo systemctl start wetty
sudo systemctl enable nginx
sudo systemctl restart nginx