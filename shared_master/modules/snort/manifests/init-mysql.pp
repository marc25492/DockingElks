#parameterised for future change/updates
class snort($snort_archive	= 'snort-2.9.9.0.tar.gz',
			$snort_folder	= 'snort-2.9.9.0',
			$snort_daq		= 'daq-2.0.6.tar.gz',
			$snort_daq_fol	= 'daq-2.0.6',
			$mysql_archive	= 'mysql-server_5.7.16-1ubuntu16.04_amd64.deb-bundle.tar'){

	Exec {
		path	=>	['/usr/bin', '/usr/sbin', '/bin'],
		returns =>	[0, 2, 14, 100],
	}

	package { 'libaio1' : 
		ensure => present,
	}

	package { 'libmecab2' : 
		ensure => present,
		require => Package['libaio1']
	}	

	exec { 'opt_dir' :
	command	=> 'mkdir -p /opt/mysql && mkdir mkdir -p /opt/mysql/tmp', 
	require => Package['libmecab2'],
	}

#INSTALL MYSQL
#FOLDER START	
	# EXTRACT ARCHIVE

	file {"/opt/mysql/${mysql_archive}" : 
		ensure  => present,
		source  => "puppet:///modules/mysql/${mysql_archive}",
		require => Exec["opt_dir"]
	}

	exec { "extract_mysql" :
		cwd	=> "/opt/mysql",
		command	=> "sudo tar xvf ${mysql_archive}",
		require	=> File["/opt/mysql/${mysql_archive}"],
	}
	# EXTRACT END

	# PRESEED ANSWERS
	exec { "set_ans" : 
		cwd		=> "/opt/mysql",
		command	=> "sudo bash -c 'debconf-set-selections <<< \"mysql-community-server  mysql-community-server/root-pass password root\"'",
		require	=> Exec['extract_mysql'],
	}

	exec { "set_ans2" :
		cwd		=> "/opt/mysql",
		command	=> "sudo bash -c 'debconf-set-selections <<< \"mysql-community-server  mysql-community-server/re-root-pass password root\"'",
		require	=> Exec['set_ans'],
	}
	# PRESEED END

#FOLDER END

#INSTALL BEGIN
	#INSTALL MYSQL
	exec { "install_sql" : 
		cwd			=> "/opt",
		environment =>  [ "DEBIAN_FRONTEND=noninteractive" ],
		command		=> "sudo bash -c 'DEBIAN_FRONTEND=noninteractive dpkg -R --install mysql/'",
		require		=> Exec['set_ans2'],
	}
	#INTALL END

	#ENSURING SQL STATEMENTS AND CONF FILES ARE LOADED
	#COPY POST CONFIGS
	file { "/opt/mysql/tmp/post_install.sql" : 
		ensure  => present,
		source  => "puppet:///modules/mysql/post_install.sql",
		require => Exec["install_sql"]
	}

	file { "/opt/mysql/tmp/mysqld.cnf" : 
		ensure  => present,
		source  => "puppet:///modules/mysql/mysqld.cnf",
		require => File["/opt/mysql/tmp/post_install.sql"]
	}
	#COPY POST CONFIGS END

	#COPY MYSQL MY.CNF FILE FOR REMOTE ACCESS
	exec { "sql_conf" : 
		cwd		=> "/opt/mysql/tmp",
		command	=> 'sudo cp ./mysqld.cnf /etc/mysql/mysql.conf.d/',
		require	=> File["/opt/mysql/tmp/mysqld.cnf"],
	}

	#EXECUTE SQL STATEMENT
	exec { "sql_stat" : 
		cwd		=> "/opt/mysql/tmp",
		command	=> 'mysql -sfu root --password=root < "post_install.sql"',
		require	=> Exec['sql_conf'],
	}

	#REMOVE TMP FOLDER
	exec { "rm_post" : 
		command => "rm -rf /opt/mysql/tmp",
		require	=> Exec['sql_stat'],
	}

	#RESTART MYSQL SERVICE
	exec { "sql_stop" : 
		command => "sudo /etc/init.d/mysql restart",
		require	=> Exec['rm_post'],
	}
#INSTALL MYSQL END

#INSTALL SNORT START
	#INSTALL DEPENDENCIES
	package { 'ethtool' : 
		ensure => present,
	}

	package { 'build-essential' : 
		ensure => present,
	}
	package { 'libpcap-dev' : 
		ensure => present,
	}
	package { 'libpcre3-dev' : 
		ensure => present,
	}
	package { 'libdumbnet-dev' : 
		ensure => present,
	}
	package { 'bison' : 
		ensure => present,
	}
	package { 'flex' : 
		ensure => present,
	}
	package { 'zlib1g-dev' : 
		ensure => present,
	}
	
	package { 'liblzma-dev' : 
		ensure => present,
	}
	
	package { 'openssl' : 
		ensure => present,
	}
	
	package { 'libssl-dev' : 
		ensure => present,
	}
	#INSTALL DEPENDENCIES END
	
#FOLDER START	
	# EXTRACT ARCHIVE
	file {'/opt/snort/${snort_archive}' : 
		ensure  => present,
		source  => "puppet:///modules/snort/${snort_archive}",
		require => Exec['install_dep'],
	}

	file {"/opt/snort/${snort_snort_daq}" : 
		ensure  => present,
		source  => "puppet:///modules/snort/${snort_daq}",
		require => File["/opt/snort/${snort_archive}"],
	}

	exec { 'extract_snort' :
		cwd	=> '/opt/snort',
		command	=> "sudo tar zxvf ${snort_archive}",
		require	=> File["/opt/snort/${snort_snort_daq}"],
	}

	exec { 'extract_snort_daq' :
		cwd	=> '/opt/snort',
		command	=> "sudo tar zxvf ${snort_daq}",
		require	=> Exec['extract_snort'],
	}

	# EXTRACT END
#FOLDER END

#INSTALL BEGIN
	#DISABLE LRO AND GRO ON ETHERNET ADAPTER
	exec { 'disable_eth_feature1' : 
	command	=> "echo 'post-up ethtool -K eth0 lro off' >> /etc/network/interfaces",
	require	=> Exec['extract_snort_daq'],
	}

	exec { 'disable_eth_feature2' : 
	command	=> "echo 'post-up ethtool -K eth0 gro off' >> /etc/network/interfaces",
	require	=> Exec['disable_eth_feature1'],
	}
	#NETORK CONFIG END

	#COMPILE SNORT DAQ AND INSTALL
	exec { 'install_daq' : 
		cwd		=> "/opt/snort/${snort_daq_fol}",
		command	=> "sudo bash -c './configure && make && make install'",
		require	=> Exec['disable_eth_feature2'],
	}

	#COMPILE SNORT AND INSTALL
	exec { 'install_snort' : 
		cwd		=> "/opt/snort/${snort_folder}",
		command	=> "sudo bash -c './configure --enable-sourcefire && make && make install'",
		require	=> Exec['install_daq'],
	}
	#INTALL END
#INSTALL END END

#CONFIGURING SNORT
	#RUN COMMAND TO UPDATE SHARED LIBS
	exec { 'update_lib' : 
		command	=> 'sudo ldconfig',
		require	=> Exec['update_snort'],
	}

	#CREATE SYMLINK FOR SNORT SERVICE
	exec { 'sym_snort' : 
		command	=> 'sudo ln -s /usr/local/bin/snort /usr/sbin/snort',
	}

	# CREATE SNORT USER AND GROUP
	exec { 'sym_snort' : 
		command	=> 'sudo useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort',
	}

	exec { 'sym_snort' : 
		command	=> 'sudo ln -s /usr/local/bin/snort /usr/sbin/snort',
	}
	# CREATE SNORT USER END

	#CREATE RESPECTIVE SNORT FOLDERS
	file { '/opt/snort/mkdir.sh' : 
		ensure => present,
		source => source  => 'puppet:///modules/snort/mkdir.sh',
	}

	exec { 'snort_mkdir' : 
		cwd		=> '/opt/snort'
		command	=> "sudo bash -c '/opt/snort/mkdir.sh'",
	}

	#CREATE FOLDERS END

	# ENSURING SNORT HAS LATEST COMMUNITY SIGNATURE DEFINITIONS
	exec { 'update_snort_download' : 
		cwd		=> "/opt/snort/${snort_folder}",
		command	=> 'sudo wget https://www.snort.org/rules/community',
		require	=> Exec['install_snort'],
	}

	exec { "update_snort" : 
		cwd		=> "/opt/snort/${snort_folder}",
		command	=> 'sudo tar -xvfz community.tar.gz -C /etc/snort/rules',
		require	=> Exec['update_snort_download'],
	}
	#UPDATE SNORT END

	#COPY CONFIG FILE FOR SNORT
	file {'/etc/snort/snort.conf' : 
		ensure  => present,
		source  => 'puppet:///modules/snort/snort.conf',
		require => Exec['install_dep'],
	}

	#UPDATE PERMISSIONS FOR SNORT USER
	exec { 'update_perm1' : 
		command	=> 'sudo chown -R snort:snort /etc/snort',
	}

	exec { "update_perm2" : 
		command	=> "sudo chown -R snort:snort /var/log/snort",
	}

	exec { "update_perm3" : 
		command	=> "sudo chown -R snort:snort /usr/local/lib/snort_dynamicrules",
	}

	#UPDATE PERMISSIONS END	


}
 
