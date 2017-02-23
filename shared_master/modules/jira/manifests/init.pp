class jira(
	$jira_bin = "jira.bin"){
	
	Exec{
		path => [ "/usr/bin", "/bin", "/usr/sbin"],
	}
	
	require java
	
	#MAKE JIRA DIRECTORY
	file { '/opt/jira/' : 
	ensure	=> 'directory',
	before	=> File["/opt/jira/${jira_bin}"],
	}
	
	#COPY JIRA AND RESPONSE.VARFILE
	file { "/opt/jira/${jira_bin}" : 
	ensure	=> 'present',
	source	=> "puppet:///modules/jira/${jira_bin}",
	mode	=> 755,
	require	=> File['/opt/jira/'],
	before	=> File['/opt/jira/response.varfile'],
	}
	
	file { '/opt/jira/response.varfile' : 
	ensure	=> 'present',
	source	=> 'puppet:///modules/jira/response.varfile',
	mode	=> 755,
	require	=> File["/opt/jira/${jira_bin}"],
	before	=> Exec['install_jira'],
	}

	#INSTALL JIRA 
	exec {'install_jira' : 
	cwd		=> '/opt/jira/',
	command	=> "sudo ./${jira_bin} -q -varfile /opt/jira/response.varfile",
	require	=> File['/opt/jira/response.varfile'],
	}
}