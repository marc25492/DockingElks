class nexus (
	$nexus_archive = "nexus-3.0.2-02-unix.tar.gz",
	$nexus_home = "/opt/nexus-3.0.2-02",
	$nexus_folder = "nexus-3.0.2-02"
	)
	{
	
	require java
	require maven
	
	Exec {
		path => ["/usr/bin", "/bin", "/usr/sbin"]
	}

	file {"/opt/${nexus_archive}":
		ensure => "present",
		source => "puppet:///modules/nexus/${nexus_archive}",
		owner => vagrant,
		mode => 755,
	}

	exec {'extract nexus':
		cwd => "/opt",
		command => "tar zxvf ${nexus_archive}",
		require => File["/opt/${nexus_archive}"],
	}

	exec { 'update nexus':
		cwd => "/usr/bin",
		command => "sudo ln -s ${nexus_home} nexus",
		require => Exec["extract nexus"],
	}

	exec { 'run nexus':
		cwd => "${nexus_home}/bin",
		command => "sudo ./nexus run &",
		require => Exec['update nexus'],
	}
}
