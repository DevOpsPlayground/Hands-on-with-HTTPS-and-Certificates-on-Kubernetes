#### - Put the custom install bits into this file
#### - you'll see the output of these, if you hop on to the instance and check out /var/log/cloud-init-output.log
#### - No need for #!/bin/bash

echo "============== My Custom Install Script =============="
HOST=$(hostname)
echo "Prepping stuff on instance $${HOST} for user: ${username} "

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl tree

echo "Adding ${username} user to sudoers"
sudo tee /etc/sudoers.d/${username} > /dev/null <<"EOF"
${username} ALL=(ALL:ALL) ALL
EOF
sudo chmod 0440 /etc/sudoers.d/${username}
sudo usermod -a -G sudo ${username}

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl awscli

# wget https://dl.google.com/go/go1.14.linux-amd64.tar.gz
# sudo tar -xvf go1.14.linux-amd64.tar.gz
# sudo mv go /usr/local

# cat <<EOF >>/home/playground/.bashrc
# export PATH=$PATH:/usr/local/go/bin
# export AWS_REGION=eu-west-2
# EOF

#DOCKER
curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -a -G docker ${username}
sudo systemctl enable docker

echo "running VS code container"
sudo mkdir /home/playground/WorkDir
sudo chown -R playground /home/playground/WorkDir
cd /home/playground/WorkDir
sudo docker run -dit -p 8000:8080 \
  -v "$PWD:/home/coder/project" \
  -u "$(id -u):$(id -g)" \
  codercom/code-server:latest --auth none

