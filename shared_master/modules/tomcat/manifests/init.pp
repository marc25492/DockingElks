class tomcat {

require java

	#Plucks the tomcat tar file from the tomcat/files directory and pops it into /opt
	file {'/opt/apache-tomcat-7.0.73.tar.gz':
		ensure => "present",
		source => "puppet:///modules/tomcat/apache-tomcat-7.0.73.tar.gz",
		owner => 'root',
		group => 'root',
	}

	Exec {
		path => ["/usr/bin","/bin/","/usr/sbin"]
	}


	#exec {'Add Tomcat Group':
		#command => 'groupadd tomcat',
	#}

	#exec {'Add new Tomcat User':
		# command => 'useradd -s /bin/false -g tomcat -d /opt/apache-tomcat-8.5.8 tomcat',
	#}

	#exec {'Copy Tomcat':
		# command => 'cp /tmp/shared/apache-tomcat-7.0.73.tar.gz /opt/apache-tomcat-7.0.73.tar.gz',
		# before => Exec['Extract Tomcat'],
	#}


	#Extracts Tomcat tar files
		exec {'Extract Tomcat':
		cwd => '/opt',
		command => 'tar -xzvf apache-tomcat-7.0.73.tar.gz',
		require => File['/opt/apache-tomcat-7.0.73.tar.gz'],
	}

	#exec {'User Permissions':
		# cwd => '/opt',
		# command => 'chgrp -R tomcat /opt/apache-tomcat-7.0.73',
	#}

	#Allow the tomcat file to be accessible
	exec {'Change Permissions':
		cwd => '/opt',
		command => 'chmod -R g+rx apache-tomcat-7.0.73',
		require => Exec['Extract Tomcat'],
	}

	#Update the Java Home
	exec {'Update Java Home':
		command => 'echo "export JAVA_HOME=/opt/jdk1.8.0_45" >> /etc/profile',
	}

	#Allow the executable file to be executable
	exec {'Allow execution':
		cwd => '/opt/apache-tomcat-7.0.73/bin/',
		command => 'chmod a+x startup.sh',
		require => Exec['Change Permissions'],
	}


	#file_line { 'Port Config':
		#  path  => '/opt/apache-tomcat-7.0.73/conf/server.xml',
		#  line  => '    <Connector port="8082" protocol="HTTP/1.1"',
		#  match => '    <Connector port="8080" protocol="HTTP/1.1"',
		#  before => Exec['Start'],
	#}


	#Change the config file to edit the Port which tomcat listens on
	exec {'Change Port':
		#command => "echo sed -i 's|<Connector port=\"8080\"|<Connector port=\"8082\"|g' /opt/apache-tomcat-7.0.73/conf/server.xml"
		command => "sed -i 's:8080:8082:g' /opt/apache-tomcat-7.0.73/conf/server.xml",
		require => Exec['Allow execution'],
	}
 
	# Copy a shell script to /opt
	file {"/opt/tomcatscript.sh":
		ensure => "present",
		source => "puppet:///modules/tomcat/tomcatscript.sh",
		owner => vagrant,
		mode => 755,
		#notify => Exec['run_script'],
		require => Exec['Change Port'],
	}
 
	#Run a script which sets up the defult manager users in Tomcat (GUI, Status, Script and jmx)
	exec {'run_script':
		command => '/opt/tomcatscript.sh',
		require => File["/opt/tomcatscript.sh"],
	}

	# Need to Restart Tomcat (incase we are re-running) to allow the config changes to occur
	exec {'Stop':
		cwd => '/opt/apache-tomcat-7.0.73/bin/',
		command => 'sudo ./shutdown.sh',
		require => Exec['Change Port'],
	}

	# Starts Tomcat
	exec {'Start':
		cwd => '/opt/apache-tomcat-7.0.73/bin/',
		command => 'sudo ./startup.sh',
		require => Exec['Stop'],
	}	


}
