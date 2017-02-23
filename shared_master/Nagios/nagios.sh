# Update apt packages and install Apache2
sudo apt-get update
sudo apt-get install -y apache2
sudo bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password password your_password"'
sudo bash -c 'debconf-set-selections <<< "mysql-server mysql-server/root_password_again password your_password"'
sudo apt-get install -y mysql-server

sudo apt-get install -y php5 libapache2-mod-php5 php5-mcrypt
sudo sed -i '2s/DirectoryIndex/DirectoryIndex index.php/' /etc/apache2/mods-enabled/dir.conf
sudo sed -i '2s/index.pl index.php/index.pl/' /etc/apache2/mods-enabled/dir.conf

sudo service apache2 restart
sudo apt-get install php5-cli

sudo useradd nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios

sudo apt-get install -y wget build-essential libgd2-xpm-dev openssl libssl-dev xinetd apache2-utils unzip

cd /opt/
sudo wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz
sudo tar xzf nagios-4.1.1.tar.gz
cd nagios-4.1.1
sudo ./configure --with-command-group=nagcmd
sudo make all
sudo make install
sudo make install-init
sudo make install-config
sudo make install-commandmode

sudo cp /tmp/shared/Nagios/nagios.conf /etc/apache2/conf-available/nagios.conf

sudo sed -i '51s/#cfg_dir=/cfg_dir=/' /usr/local/nagios/etc/nagios.cfg

sudo mkdir /usr/local/nagios/etc/servers

sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

sudo a2enconf nagios
sudo a2enmod cgi
sudo service apache2 restart

cd /opt/
sudo wget http://www.nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz
sudo tar xzf nagios-plugins-2.1.1.tar.gz
cd nagios-plugins-2.1.1
sudo ./configure --with-nagios-user=nagios --with-nagios-group=nagios
sudo make
sudo make install

sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
sudo service nagios start

ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios

sudo cp /tmp/shared/Nagios/elkAgent.cfg /usr/local/nagios/etc/servers/elkAgent.cfg
