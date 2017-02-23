echo "Installing puppet .. "
sudo apt-get update -y
sudo apt-get install -y openssh-server openssh-client

echo "Disabling the firewall .. "
sudo ufw disable
sudo apt-get install -y puppet

fqdn=$(facter fqdn)
ip=$(facter ipaddress_eth1)

echo "Configuring the Agent's IP Address .. "
sed -i "1s/^/$ip $fqdn puppet\n/" /etc/hosts
sed -i "1s/^/127.0.0.1 $fqdn puppet\n/" /etc/hosts
sed -i "1s/^/$masterIP $masterDN puppetmaster\n/" /etc/hosts

echo "Configuring the the default server to master fqdn .. "
sed -i "2s/^/server=$masterDN\n/" /etc/puppet/puppet.conf

echo "Testing and enabling the service .. "
sudo puppet agent --test --server=$masterDN
sudo puppet agent --enable
sudo puppet agent --test --server=$masterDN