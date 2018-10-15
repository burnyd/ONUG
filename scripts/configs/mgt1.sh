#!/usr/bin/env bash


sleep 5

#Check for ping connectivity to google before proceeding.

ping -q -c5 google.com > /dev/null

if [ $? -eq 0 ]
then
	echo "connectivity is there"
else    echo "connectivity is not there"
        exit 1
fi



echo "Add dns names to etc hosts"

sudo echo 10.0.0.99 leaf1a  >> /etc/hosts
sudo echo 10.0.0.100 leaf1b  >> /etc/hosts
sudo echo 10.0.0.101 spine1  >> /etc/hosts
sudo echo 10.0.0.102 spine2  >> /etc/hosts
sudo echo 10.0.0.103 leaf2a  >> /etc/hosts
sudo echo 10.0.0.104 leaf2b  >> /etc/hosts
sudo echo 127.0.0.1 salt >> /etc/hosts

echo "updating apt-get"
sudo apt-get update
echo "installing Packages"
sudo apt-get install -y git python-pip python-dev default-jre libffi-dev libssl-dev python-dev python-cffi libxslt1-dev -y

echo "Adding salt directories"
sudo mkdir -p /srv/salt/
sudo mkdir -p /srv/salt/pillar/
sudo mkdir -p /srv/salt/states/
sudo mkdir -p /srv/salt/states/vlans/
sudo mkdir -p /srv/salt/states/bgp/
sudo mkdir -p /srv/salt/templates/
sudo mkdir -p /srv/salt/_grains/
sudo mkdir -p /srv/salt/reactor

echo "fixing the default ubuntu pyOpenSSL issue"
pip install --upgrade pyOpenSSL

echo "Installing Saltstack"
sudo wget -O bootstrap-salt.sh https://bootstrap.saltstack.com/develop
sudo sh bootstrap-salt.sh -M

echo "upgrading pip"
sudo pip install -U pip setuptools
sudo pip install --upgrade pip

echo "Install napalm EOS libraries"
sudo pip install napalm
sudo pip install napalm-logs
sudo pip install napalm-base

echo "Move salt files to their directories"
cp /vagrant/scripts/salt/master /etc/salt/master
cp -R /vagrant/scripts/salt/pillar/* /srv/salt/pillar/
cp -R /vagrant/scripts/salt/reactor/* /srv/salt/reactor
cp -R /vagrant/scripts/salt/states/vlans/ /srv/salt/states/vlans/
cp -R /vagrant/scripts/salt/states/bgp/ /srv/salt/states/bgp/
cp -R /vagrant/scripts/salt/templates/* /srv/salt/templates/
cp /vagrant/scripts/salt/_grains/bgp-as.py /srv/salt/_grains/

echo "installing salt api via apt"
apt-get install salt-api -y

echo "upgrading cherrypy for api server"
pip install --upgrade cherrypy

echo "restarting the master service"
service salt-master restart

sleep 5

echo "getting salt keys"
salt-call --local tls.create_self_signed_cert

echo "adding api user"
useradd saltdev
echo "saltdev:saltdev" | chpasswd
usermod -aG sudo saltdev


echo "setting permissions for salt folders for api user"
chown -R saltdev /etc/salt /var/cache/salt /var/log/salt /var/run/salt


echo "restarting salt-master and starting api-server"
service salt-master restart && service salt-api start

cp /vagrant/scripts/salt/BGP_NEIGHBOR_STATE_CHANGE.yml /usr/local/lib/python2.7/dist-packages/napalm_logs/config/eos/

echo "Run napalm logs"
napalm-logs --publisher zmq --disable-security --port 5514 &

echo "Run the python web server"
cd /vagrant/scripts/salt
sudo python -m SimpleHTTPServer 8088 &

echo "Installing docker and docker-compose"
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
#####
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update && sudo apt-get install docker-ce docker-compose -y

sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

echo "Installing docker-netbox"
git clone -b master https://github.com/ninech/netbox-docker.git
cd netbox-docker
sudo docker-compose pull
sudo docker-compose up -d

echo "Install pynetbox"
pip install pynetbox


echo "Installing OC tools"
pip install pyangbind

git clone https://github.com/robshakir/pyangbind /tmp/pyangbind/
git clone https://github.com/openconfig/public/ /tmp/public/

echo "Starting salt proxy minions"
salt-proxy --proxyid leaf[1:4] -d
salt-proxy --proxyid spine[1:2] -d
