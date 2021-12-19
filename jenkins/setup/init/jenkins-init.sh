#!/bin/bash

# volume setup
vgchange -ay

DEVICE_FS=`blkid -o value -s TYPE ${DEVICE}`
if [ "`echo -n $DEVICE_FS`" == "" ] ; then
  # wait for the device to be attached
  DEVICENAME=`echo "${DEVICE}" | awk -F '/' '{print $3}'`
  DEVICEEXISTS=''
  while [[ -z $DEVICEEXISTS ]]; do
    echo "checking $DEVICENAME"
    DEVICEEXISTS=`lsblk |grep "$DEVICENAME" |wc -l`
    if [[ $DEVICEEXISTS != "1" ]]; then
      sleep 15
    fi
  done
  pvcreate ${DEVICE}
  vgcreate data ${DEVICE}
  lvcreate --name volume1 -l 100%FREE data
  mkfs.ext4 /dev/data/volume1
fi
mkdir -p /var/lib/jenkins
echo '/dev/data/volume1 /var/lib/jenkins ext4 defaults 0 0' >> /etc/fstab
mount /var/lib/jenkins

# jenkins & docker repository 
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
echo "deb http://pkg.jenkins.io/debian binary/" >> /etc/apt/sources.list
apt-get update
apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# install dependencies
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
apt-get install -y python3.8 openjdk-8-jre jq

# install jenkins
apt-get install -y jenkins unzip

# install pip
wget -q https://bootstrap.pypa.io/get-pip.py
python3.8 get-pip.py
pip3 install docker-compose
usermod -aG docker jenkins
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
chmod 666 /var/run/docker.sock

# install awscli
pip install awscli

#install helm and K8s
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
snap install kubectl --classic

# install terraform
wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
&& rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# install packer
cd /usr/local/bin
wget -q https://releases.hashicorp.com/packer/1.7.0/packer_1.7.0_linux_amd64.zip
unzip packer_1.7.0_linux_amd64.zip

# clean up
apt-get clean
rm packer_1.7.0_linux_amd64.zip
