sudo cp /tmp/shared/filebeat-5.1.1-linux-x86_64.tar.gz /opt
cd /opt
sudo tar -zxvf filebeat-5.1.1-linux-x86_64.tar.gz

sudo cp /tmp/shared/filebeat.yml filebeat-5.1.1-linux-x86_64/
cd filebeat-5.1.1-linux-x86_64/

sudo ./filebeat -e -c filebeat.yml -d "publish"
