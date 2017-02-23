sed -i 's:</tomcat-users>::g' /opt/apache-tomcat-7.0.73/conf/tomcat-users.xml

sudo echo '<role rolename="manager-gui"/>' >> /opt/apache-tomcat-7.0.73/conf/tomcat-users.xml
sudo echo '<user username="tomcatgui" password="s3cret" roles="manager-gui"/>' >> /opt/apache-tomcat-7.0.73/conf/tomcat-users.xml

sudo echo '<role rolename="manager-script"/>' >> /opt/apache-tomcat-7.0.73/conf/tomcat-users.xml
sudo echo '<user username="tomcatscript" password="s3cret" roles="manager-script"/>' >> /opt/apache-tomcat-7.0.73/conf/tomcat-users.xml

sudo echo '<role rolename="manager-jmx"/>' >> /opt/apache-tomcat-7.0.73/conf/tomcat-users.xml
sudo echo '<user username="tomcatjmx" password="s3cret" roles="manager-jmx"/>' >> /opt/apache-tomcat-7.0.73/conf/tomcat-users.xml

sudo echo '<role rolename="manager-status"/>' >> /opt/apache-tomcat-7.0.73/conf/tomcat-users.xml
sudo echo '<user username="tomcatstatus" password="s3cret" roles="manager-status"/>' >> /opt/apache-tomcat-7.0.73/conf/tomcat-users.xml

sudo echo '</tomcat-users>' >> /opt/apache-tomcat-7.0.73/conf/tomcat-users.xml