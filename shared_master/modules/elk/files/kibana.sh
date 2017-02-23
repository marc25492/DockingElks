#!/bin/sh
sed -i "8i server.host: 192.168.1.100" /opt/kibana-5.1.1-linux-x86_64/config/kibana.yml
sed -i "22i elasticsearch.url: \"http://localhost:9200\"" /opt/kibana-5.1.1-linux-x86_64/config/kibana.yml
