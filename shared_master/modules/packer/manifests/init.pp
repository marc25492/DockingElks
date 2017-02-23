#parameterised for future change/updates
class packer($packer_archive	= 'packer_0.12.1_linux_amd64.zip'){

	Exec {
		path	=>	['/usr/bin', '/usr/sbin', '/bin'],
		returns =>	[0, 2, 14, 100],
	}

#INSTALL PACKER START
	#INSTALL DEPENDENCIES
	#ensure folder exits
	file { '/opt/packer/' : 
		ensure	=> directory,
		before	=> Package['unzip']
	}
	
	package { 'unzip' : 
		ensure 	=> present,
		require	=> File['/opt/packer/'],
		before	=> File["/opt/packer/${packer_archive}"],
	}

	#INSTALL DEPENDENCIES END

#FOLDER START	
	# EXTRACT ARCHIVE
	file { "/opt/packer/${packer_archive}" : 
		ensure  => present,
		source  => "puppet:///modules/packer/${packer_archive}",
		require => Package['unzip'],
		before	=> Exec['extract_packer'],
	}

	exec { 'extract_packer' :
		cwd	=> '/opt/packer/',
		command	=> "sudo unzip ${packer_archive}",
		require	=> File["/opt/packer/${packer_archive}"],
		before	=> File['/opt/packer/setpath.sh'],
	}
	# EXTRACT END
#FOLDER END

#INSTALL BEGIN
	#Add path to /etc/environment
	
	#Load sed shell script to append PATH in /etc/environment
	file { '/opt/packer/setpath.sh' : 
		ensure 	=> present,
		source  => 'puppet:///modules/packer/setpath.sh',
		require	=> Exec['extract_packer'],
		before	=> Exec['shell_perm'],
	}

	#update shell script permissions
	exec { 'shell_perm' : 
		cwd		=> '/opt/packer',
		command	=> 'sudo chmod a+x /opt/packer/setpath.sh',
		require	=> File['/opt/packer/setpath.sh'],
		before	=> Exec['path_app'],
	}

	exec { 'path_app' : 
		cwd		=> '/opt/packer',
		command	=> "sudo bash -c '/opt/packer/setpath.sh'",
		require	=> Exec['shell_perm'],
		before	=> Exec['load_path'],
	}
	
	#load the new variables so the path can be read without reset.
	exec { 'load_path' : 
		command => "sudo bash -c \"source /etc/environment\"",
		require	=> Exec['path_app'],
	}
	
	#INTALL END
#INSTALL END END
}
