# DockingElks

1) Clone git repository: https://github.com/JosephHardy/DockingElks

2) The following binary files should be added to the shared_master/binaries directory:

- apache-tomcat-7.0.73.tar.gz
- daq-2.0.6.tar.gz
- elasticsearch-5.1.1.deb
- haproxy-1.7.1.tar.gz
- java.tar.gz
- jenkins_2.1_all.deb
- jira.bin
- kibana_5.1.1-linux-x86_64.tar.gz
- logstash-5.1.1.tar.gz
- maven.tar.gz
- nexus-3.0.2-02-unix.tar.gz
- packer_0.12.1_linux_amd64.zip
- snort-2.9.9.0.tar.gz

3) Git bash within the DockingElks directory and run the command 'vagrant up' 

4) To configure the monitoring for ELK stack, add the following file to the shared_agent folder and run the filebeat.sh file in the "/tmp/shared" folder on the agent
- filebeat-5.1.1-linux-x86_64.tar.gz 

### Machines can all be loaded at once with `vargant up`. Not advised as they take up 12GB Ram between them and really slow down the computer

Can also launch individual machines by putting the name of the machine after the 'vagrant up' command. The machines are as follows:
``` 
- elkAgent: includes java and elk stack. IP: 192.168.1.100
- snortAgent: includes snort. IP: 192.168.1.101
- jiraAgent: includes java, maven, jenkins and jira. IP: 192.168.1.104
- packerAgent: includes java, maven, nexus and packer. IP: 192.168.1.105
- master: IP: 192.168.1.120
``` 
### Users:

Add any installation files to the binaries folder in shared_master. Bootstrap should copy it to the correct folder on the machine. If not add it to the list at the bottom of bootstrap_master in the same format

Any files needed by the installation process, access in this format

```
#Install Kibana
file { "/opt/${kibana_archive}":
    ensure => "present",
    source => "puppet:///modules/elk/${kibana_archive}",
    owner => vagrant,
    mode => 755,
    require => Exec['start elasticsearch'],
}
```

### Nagios Installation

Nagios can be installed on the master by running `sudo /tmp/shared/Nagios/nagios.sh`.
Upon running this you will be prompted to create a password for the user "nagiosadmin", which you will need to view the web interface on http://192.168.1.120/nagios. 
By default the master instance and the Elk agent are monitored.



### Auto deployment from jenkins to tomcat

Tutorial which outlines steps: https://www.jdev.it/deploying-your-war-file-from-jenkins-to-tomcat/




