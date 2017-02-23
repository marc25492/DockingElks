class jira {
	Exec {
		path => ["/usr/bin", "/bin", "/usr/sbin"]
	}
	
	exec { 'copy jira bin' :
		command => 'sudo cp /tmp/shared/jira.bin /opt'
	}
	
	exec { 'change permissions' :
		cwd => '/opt',
		command => 'sudo chmod 755 jira.bin',
	}
	
	exec { 'execute and user input' :
		cwd => '/opt',
		command => 'sudo printf "o\n2\n/opt/atlassian/jira\n/var/atlassian/application-data/jira\n2\n8081\n8006\ny\n" | sudo ./jira.bin',
	}

	exec { 'echo' :
		command => 'echo Jira has been installed',
	}	
}
