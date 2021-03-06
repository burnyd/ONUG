#!/bin/bash
#Copy the salt custom grain for bgp
#salt '*' saltutil.sync_grains
#salt-run state.event pretty=true
#salt '*' saltutil.refresh_pillar
#salt '*' pillar.items
#/usr/lib/python2.7/dist-packages/salt/modules#
#salt 'lab*' slsutil.renderer salt://top.sls 'jinja'

ping -q -c5 google.com > /dev/null

if [ $? -eq 0 ]
then
	echo "connectivity is there"
else    echo "connectivity is not there"
        exit 1
fi

sudo echo 192.168.0.4 salt >> /etc/hosts
sudo echo 192.168.0.4 master >> /etc/hosts


echo "Firewall rules for salt"
sudo ufw allow 4505:4506/tcp
sudo ufw allow 5514/tcp
sudo ufw allow 5514/udp

echo "Checking connectivity exists"
ping -q -c5 google.com > /dev/null

if [ $? -eq 0 ]
then
	echo "connectivity is there"
else    echo "connectivity is not there"
        exit 1
fi

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

echo "upgrade pip"
sudo python -m pip install --upgrade pip==9.0.3
sudo pip install req

echo "upgrading setup"
pip install -U setuptools

echo "Install napalm EOS libraries"
sudo pip install napalm
sudo pip install napalm-logs
sudo pip install napalm-base
sudo pip install jtextfsm

echo "Installing Saltstack"
sudo wget -O bootstrap-salt.sh https://bootstrap.saltstack.com/
sudo sh bootstrap-salt.sh -M

echo "Use ansible to install salstack agent on all switches"
ansible-playbook playbook.yaml -i inventory

sleep 5

echo "Move salt files to their directories"
cp ../scripts/salt/master /etc/salt/master
cp -R ../scripts/salt/pillar/* /srv/salt/pillar/
cp -R ../scripts/salt/reactor/* /srv/salt/reactor
cp -R ../scripts/salt/states/vlans/ /srv/salt/states/vlans/
cp -R ../scripts/salt/states/bgp/ /srv/salt/states/bgp/
cp -R ../scripts/salt/templates/* /srv/salt/templates/
cp ../scripts/salt/_grains/bgp-as.py /srv/salt/_grains/

echo "installing salt api via apt"
apt-get update && apt-get install salt-api -y

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

cp /home/arista/ONUG/scripts/salt/BGP_NEIGHBOR_STATE_CHANGE.yml /usr/local/lib/python2.7/dist-packages/napalm_logs/config/eos/

echo "Run napalm logs"
napalm-logs --publisher zmq --disable-security --port 5514 &

echo "Start salt proxy minions"
salt-proxy --proxyid=leaf1 -d
salt-proxy --proxyid=leaf2 -d
salt-proxy --proxyid=leaf3 -d
salt-proxy --proxyid=leaf4 -d
salt-proxy --proxyid=spine1 -d
salt-proxy --proxyid=spine2 -d
