echo "Installing puppet master .. "
sudo apt-get update -y
sudo apt-get install -y openssh-server openssh-client

echo "Disabling the firewall .. "
sudo ufw disable
sudo apt-get install -y puppet puppetmaster

echo "Configuring the Master IP Address .. "
sed -i "1s/^/$masterIP $masterDN puppetmaster\n/" /etc/hosts
sed -i "1s/^/127.0.0.1 $masterDN puppetmaster\n/" /etc/hosts

echo "Creating and configuring the site.pp file .. "
sudo cp /tmp/shared/site.pp /etc/puppet/manifests/
# add the modules to be installed
# over binary files

echo "Signing all certificates .. "
sed -i "16s/^/autosign=true/" /etc/puppet/puppet.conf

sudo cp -r /tmp/shared/modules/elk /etc/puppet/modules
sudo cp -r /tmp/shared/modules/haproxy /etc/puppet/modules
sudo cp -r /tmp/shared/modules/java /etc/puppet/modules
sudo cp -r /tmp/shared/modules/jenkins /etc/puppet/modules
sudo cp -r /tmp/shared/modules/jira /etc/puppet/modules
sudo cp -r /tmp/shared/modules/maven /etc/puppet/modules
sudo cp -r /tmp/shared/modules/nexus /etc/puppet/modules
sudo cp -r /tmp/shared/modules/packer /etc/puppet/modules
sudo cp -r /tmp/shared/modules/snort /etc/puppet/modules
sudo cp -r /tmp/shared/modules/tomcat /etc/puppet/modules

sudo mkdir /opt/packer

sudo cp /tmp/shared/binaries/elasticsearch-5.1.1.deb /etc/puppet/modules/elk/files
sudo cp /tmp/shared/binaries/kibana-5.1.1-linux-x86_64.tar.gz /etc/puppet/modules/elk/files
sudo cp /tmp/shared/binaries/logstash-5.1.1.tar.gz /etc/puppet/modules/elk/files
sudo cp /tmp/shared/binaries/haproxy-1.7.1.tar.gz /etc/puppet/modules/haproxy/files
sudo cp /tmp/shared/binaries/java.tar.gz /etc/puppet/modules/java/files
sudo cp /tmp/shared/binaries/jenkins_2.1_all.deb /etc/puppet/modules/jenkins/files
sudo cp /tmp/shared/binaries/jira.bin /etc/puppet/modules/jira/files
sudo cp /tmp/shared/binaries/maven.tar.gz /etc/puppet/modules/maven/files
sudo cp /tmp/shared/binaries/nexus-3.0.2-02-unix.tar.gz /etc/puppet/modules/nexus/files
sudo cp /tmp/shared/binaries/packer_0.12.1_linux_amd64.zip /etc/puppet/modules/packer/files
sudo cp /tmp/shared/binaries/daq-2.0.6.tar.gz /etc/puppet/modules/snort/files
sudo cp /tmp/shared/binaries/snort-2.9.9.0.tar.gz /etc/puppet/modules/snort/files
sudo cp /tmp/shared/binaries/filebeat-5.1.1-amd64.deb /etc/puppet/modules/snort/files
sudo cp /tmp/shared/binaries/mysql-server_5.7.16-1ubuntu16.04_amd64.deb-bundle.tar /etc/puppet/modules/snort/files
sudo cp /tmp/shared/binaries/apache-tomcat-7.0.73.tar.gz /etc/puppet/modules/tomcat/files
sudo cp /tmp/shared/binaries/filebeat-5.1.1-amd64.deb /etc/puppet/modules/snort/files

