#parameterised for future change/updates
class snort($snort_archive	= 'snort-2.9.9.0.tar.gz',
			$snort_folder	= 'snort-2.9.9.0',
			$snort_deb		= 'snort_2.9.9.0-1_amd64.deb',
			$snort_daq		= 'daq-2.0.6.tar.gz',
			$snort_daq_fol	= 'daq-2.0.6',
			$snort_daq_deb	= 'daq_2.0.6-1_amd64.deb',
			$filebeat_bin	= 'filebeat-5.1.1-amd64.deb'){

	Exec {
		path	=>	['/usr/bin', '/usr/sbin', '/bin'],
		returns =>	[0, 2, 14, 100],
	}

#INSTALL SNORT START
	#INSTALL DEPENDENCIES
	#ensure folder exits
	file { '/opt/snort/' : 
		ensure	=> directory,
		before	=> Package['ethtool']
	}
	
	package { 'ethtool' : 
		ensure 	=> present,
		require	=> File['/opt/snort'],
		before	=> Package['build-essential'],
	}

	package { 'build-essential' : 
		ensure 	=> present,
		require => Package['ethtool'],
		before	=> Package['libpcap-dev'],
	}

	package { 'libpcap-dev' : 
		ensure 	=> present,
		require => Package['build-essential'],
		before	=> Package['libpcre3-dev'],
	}

	package { 'libpcre3-dev' : 
		ensure 	=> present,
		require => Package['libpcap-dev'],
		before	=> Package['libdumbnet-dev'],
	}

	package { 'libdumbnet-dev' : 
		ensure 	=> present,
		require => Package['libpcre3-dev'],
		before	=> Package['bison'],
	}

	package { 'bison' : 
		ensure 	=> present,
		require => Package['libdumbnet-dev'],
		before	=> Package['flex'],
	}

	package { 'flex' : 
		ensure 	=> present,
		require => Package['bison'],
		before	=> Package['zlib1g-dev'],
	}

	package { 'zlib1g-dev' : 
		ensure  => present,
		require => Package['flex'],
		before	=> Package['liblzma-dev'],
	}

	package { 'liblzma-dev' : 
		ensure 	=> present,
		require => Package['zlib1g-dev'],
		before	=> Package['openssl'],
	}

	package { 'openssl' : 
		ensure 	=> present,
		require => Package['liblzma-dev'],
		before	=> Package['libssl-dev'],
	}

	package { 'libssl-dev' : 
		ensure  => present,
		require => Package['openssl'],
		before	=> File["/opt/snort/${snort_archive}"],
	}
	#INSTALL DEPENDENCIES END

#FOLDER START	
	# EXTRACT ARCHIVE
	file { "/opt/snort/${snort_archive}" : 
		ensure  => present,
		source  => "puppet:///modules/snort/${snort_archive}",
		require => Package['libssl-dev'],
		before	=> File["/opt/snort/${snort_daq}"]
	}

	file { "/opt/snort/${snort_daq}" : 
		ensure  => present,
		source  => "puppet:///modules/snort/${snort_daq}",
		require => File["/opt/snort/${snort_archive}"],
		before	=> Exec['extract_snort'],
	}

	exec { 'extract_snort' :
		cwd	=> '/opt/snort/',
		command	=> "sudo tar zxvf ${snort_archive}",
		require	=> File["/opt/snort/${snort_daq}"],
		before	=> Exec['extract_snort_daq'],
	}

	exec { 'extract_snort_daq' :
		cwd	=> '/opt/snort/',
		command	=> "sudo tar zxvf ${snort_daq}",
		require	=> Exec['extract_snort'],
		before	=> Exec['disable_eth_feature1'],
	}
	# EXTRACT END
#FOLDER END

#INSTALL BEGIN
	#DISABLE LRO AND GRO ON ETHERNET ADAPTER
	exec { 'disable_eth_feature1' : 
	command	=> "sudo bash -c \"echo 'post-up ethtool -K eth0 lro off' >> /etc/network/interfaces\"",
	require	=> Exec['extract_snort_daq'],
	before	=> Exec['disable_eth_feature2'],
	}

	exec { 'disable_eth_feature2' : 
	command	=> "sudo bash -c \"echo 'post-up ethtool -K eth0 gro off' >> /etc/network/interfaces\"",
	require	=> Exec['disable_eth_feature1'],
	before	=> Exec['install_daq'],
	}
	#NETORK CONFIG END

	#COMPILE SNORT DAQ AND INSTALL
	exec { 'install_daq' : 
		cwd		=> "/opt/snort/${snort_daq_fol}",
		command	=> "sudo bash -c '/opt/snort/${snort_daq_fol}/configure && make && sudo make install'",
		require	=> Exec['disable_eth_feature2'],
		before	=> Exec['install_snort'],
	}

	#COMPILE SNORT AND INSTALL
	exec { 'install_snort' : 
		cwd		=> "/opt/snort/${snort_folder}",
		command	=> "sudo bash -c '/opt/snort/${snort_folder}/configure --enable-sourcefire && make && sudo make install'",
		require	=> Exec['install_daq'],
		before	=> Exec['update_lib'],
	}
	
	#INTALL END
#INSTALL END END

#CONFIGURING SNORT
	#RUN COMMAND TO UPDATE SHARED LIBS
	exec { 'update_lib' : 
		command	=> 'sudo ldconfig -v',
		require	=> Exec['install_snort'],
		before	=> Exec['sym_snort'],
	}

	#CREATE SYMLINK FOR SNORT SERVICE
	exec { 'sym_snort' : 
		command	=> 'sudo ln -s /usr/local/bin/snort /usr/sbin/snort',
		require	=> Exec['update_lib'],
		before	=> Exec['grp_snort'],
	}

	# CREATE SNORT USER AND GROUP
	exec { 'grp_snort' : 
		command	=> 'sudo groupadd snort',
		require	=> Exec['sym_snort'],
		before	=> Exec['usr_snort'],
	}

	exec { 'usr_snort' : 
		command	=> 'sudo useradd snort -r -s /sbin/nologin -c SNORT_IDS -g snort',
		require	=> Exec['grp_snort'],
		before	=> File['/opt/snort/mkdir.sh'],
	}
	# CREATE SNORT USER END

	#CREATE RESPECTIVE SNORT FOLDERS
	file { '/opt/snort/mkdir.sh' : 
		ensure 	=> present,
		source  => 'puppet:///modules/snort/mkdir.sh',
		require	=> Exec['usr_snort'],
		before	=> Exec['mkdir_perm'],
	}

	#update shell script permissions
	exec { 'mkdir_perm' : 
		cwd		=> '/opt/snort',
		command	=> 'sudo chmod a+x /opt/snort/mkdir.sh',
		require	=> File['/opt/snort/mkdir.sh'],
		before	=> Exec['snort_mkdir'],
	}

	exec { 'snort_mkdir' : 
		cwd		=> '/opt/snort',
		command	=> "sudo bash -c '/opt/snort/mkdir.sh'",
		require	=> Exec['mkdir_perm'],
		before	=> Exec['update_snort_download'],
	}

	#CREATE FOLDERS END

	# ENSURING SNORT HAS LATEST COMMUNITY SIGNATURE DEFINITIONS
	exec { 'update_snort_download' : 
		cwd		=> "/opt/snort/${snort_folder}",
		command	=> 'sudo wget https://www.snort.org/rules/community',
		require	=> Exec['snort_mkdir'],
		before	=> Exec['update_snort'],
	}

	exec { "update_snort" : 
		cwd		=> "/opt/snort/${snort_folder}",
		command	=> 'sudo tar -xvfz community.tar.gz -C /etc/snort/rules',
		require	=> Exec['update_snort_download'],
		before	=> Exec['copy_1'],
	}
	#UPDATE SNORT END
	
	#COPY RESPECTIE CONF FILES FOR /etc/snort
	exec { 'copy_1' : 
		cwd		=> "/opt/snort/${snort_folder}/etc/",
		command	=> 'sudo cp *.conf* /etc/snort',
		require	=> Exec['update_snort'],
		before	=> Exec['copy_2'],
	}
	
	exec { 'copy_2' : 
		cwd		=> "/opt/snort/${snort_folder}/etc/",
		command	=> 'sudo cp *.map /etc/snort',
		require	=> Exec['copy_1'],
		before	=> Exec['copy_3'],
	}
	
	exec { 'copy_3' : 
		cwd		=> "/opt/snort/${snort_folder}/etc/",
		command	=> 'sudo cp *.dtd /etc/snort',
		require	=> Exec['copy_2'],
		before	=> Exec['copy_4'],
	}
	
	exec { 'copy_4' : 
		cwd		=> "/opt/snort/${snort_folder}/src/dynamic-preprocessors/build/usr/local/lib/snort_dynamicpreprocessor/",
		command	=> 'sudo cp * /usr/local/lib/snort_dynamicpreprocessor/',
		require	=> Exec['copy_3'],
		before	=> Exec['rem_conf'],
	}
	
	exec { 'rem_conf' : 
		cwd		=> '/etc/snort/',
		command	=> 'sudo rm -f snort.conf',
		require	=> Exec['copy_4'],
		before	=> File['/etc/snort/snort.conf'],
	}
	
	#COPY CONFIG FILE FOR SNORT
	file { '/etc/snort/snort.conf' : 
		ensure  => present,
		source  => 'puppet:///modules/snort/snort.conf',
		require => Exec['rem_conf'],
		before	=> Exec['update_perm1'],
	}

	#UPDATE PERMISSIONS FOR SNORT USER
	exec { 'update_perm1' : 
		command	=> 'sudo chown -R snort:snort /etc/snort',
		require	=> File['/etc/snort/snort.conf'],
		before	=> Exec['update_perm2'],
	}

	exec { "update_perm2" : 
		command	=> "sudo chown -R snort:snort /var/log/snort",
		require	=> Exec['update_perm1'],
		before	=> Exec['update_perm3'],
	}

	exec { "update_perm3" : 
		command	=> "sudo chown -R snort:snort /usr/local/lib/snort_dynamicrules",
		require	=> Exec['update_perm2'],
		before	=> File['/etc/init/snort.init'],
	}
	#UPDATE PERMISSIONS END	

	#CREATE SNORT SERVICE
	#COPY snort.init file
	file { '/etc/init/snort.init' : 
		ensure  => present,
		source  => 'puppet:///modules/snort/snort.init',
		require	=> Exec['update_perm3'],
		before	=> Exec['rename_config'],
	}

	#RENAME snort.init FILE
	exec { "rename_config" : 
		cwd		=> '/etc/init',
		command	=> 'sudo mv ./snort.init ./snort.conf',
		require	=> File['/etc/init/snort.init'],
		before	=> Exec['update_ex'],
	}

	#UPDATE snort.conf Permissions
	exec { "update_ex" : 
		command	=> 'sudo chmod a+x /etc/init/snort.conf',
		require	=> Exec['rename_config'],
		before	=> Exec['restart_snort'],
	}

	#RESTART snort SERVICE
	exec { 'restart_snort' : 
		command	=> 'sudo service snort start',
		require	=> Exec['update_ex'],
		before	=> File['/opt/filebeat'],
	}
#SNORT INSTALLATION AND CONFIG END

#FILEBEAT INSTALLATION AND CONFIG
	#MAKE FILEBEAT FOLDER /opt/filebeat
	file { '/opt/filebeat/' : 
		ensure	=> directory,
		require	=> Exec['restart_snort'],
		before	=> File["/opt/filebeat/${filebeat_bin}"],
	}

	#COPY DEB BINARY FOR FILEBEAT
	file { "/opt/filebeat/${filebeat_bin}" : 
		ensure  => present,
		source  => "puppet:///modules/snort/${filebeat_bin}",
		require	=> File['/opt/filebeat/'],
		before	=> Exec['install_beat'],
	}
	
	#INSTALL filebeat
	exec { 'install_beat' :
		cwd		=> '/opt/filebeat/',
		command	=> "sudo dpkg -i ${filebeat_bin}",
		require	=> File["/opt/filebeat/${filebeat_bin}"],
		before	=> Exec['rm_beat_conf'],
	}
	
	#REMOVE EXISTING FILEBEAT CONFIG
	exec { 'rm_beat_conf' : 
		cwd		=> '/etc/filebeat',
		command	=> 'sudo rm -f filebeat.yml',
		require	=> Exec['install_beat'],
		before	=> File['/etc/filebeat/filebeat.yml'],
	}
	
	#COPY NEW FILEBEAT CONFIG
	file { '/etc/filebeat/filebeat.yml' : 
		ensure  => present,
		source  => 'puppet:///modules/snort/filebeat.yml',
		require	=> Exec['rm_beat_conf'],
		before	=> Exec['beat_restart'],
	}
	
	#SET FILEBEAT TO START ON BOOT
	exec { 'beat_restart' : 
		cwd		=> '/etc/init.d/',
		command	=> 'sudo update-rc.d filebeat defaults',
		require	=> File['/etc/filebeat/filebeat.yml'],
		before	=> Exec['beat_start'],
	}
	
	#START FILEBEAT
	exec { 'beat_start' : 
		command	=> 'sudo service filebeat start',
		require	=> Exec['beat_restart'],
	}
	
}
