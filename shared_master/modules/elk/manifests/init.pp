class elk(
    $elasticsearch_archive ="elasticsearch-5.1.1.deb",
    $kibana_archive = "kibana-5.1.1-linux-x86_64.tar.gz",
    $kibana_home = "/opt/kibana-5.1.1-linux-x86_64",
    $logstash_archive = "logstash-5.1.1.tar.gz",
    $logstash_home = "/opt/logstash-5.1.1",
    $elasticsearch = "es.sh"
    )
    {
    
	require java

    Exec {
    	path => ["/usr/bin", "/bin", "/usr/sbin"]
    }

    #Install Elasticsearch first
	file {"/opt/${elasticsearch_archive}":
        ensure => "present",
        #source => "/tmp/shared/elk/files/${elasticsearch_archive}",
        source => "puppet:///modules/elk/${elasticsearch_archive}",
        owner => vagrant,
    	mode => 755,
    }

	exec{'get debian key':
        cwd => "/opt",
        command => "wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -",
    	require => File["/opt/${elasticsearch_archive}"],
    }

	package{'install elasticsearch':
        ensure => installed,
        provider => 'dpkg',
        source => "/opt/${elasticsearch_archive}",
    	require => Exec["get debian key"],
    }

	file {"/opt/${elasticsearch}":
        ensure => "present",
        #source => "/tmp/shared/elk/files/${elasticsearch_archive}",
        source => "puppet:///modules/elk/${elasticsearch}",
        owner => vagrant,
    	mode => 755,
    }

	exec{'update network host':
        command => "/opt/es.sh",
    	require => File["/opt/es.sh"],
    }

	exec{'restart elasticsearch':
        command => "sudo service elasticsearch restart",
    	require => Exec['update network host'],
    }

	exec{'update elasticsearch':
        command => "sudo update-rc.d elasticsearch defaults 95 10",
    	require => Exec['restart elasticsearch'],
    }

	exec{'start elasticsearch':
        command => "sudo service elasticsearch restart",
    	require => Exec['update elasticsearch'],
    }

    #Install Kibana
    file {"/opt/${kibana_archive}":
        ensure => "present",
        #source => "/tmp/shared/elk/files/${kibana_archive}",
        source => "puppet:///modules/elk/${kibana_archive}",
        owner => vagrant,
        mode => 755,
    	require => Exec['start elasticsearch'],
    }

    exec{'unpack kibana':
        cwd => "/opt",
        command => "tar zxvf ${kibana_archive}",
    	require => File["/opt/${kibana_archive}"],
    }

    file{"/opt/kibana.sh":
        ensure => "present",
        #source => "/tmp/shared/elk/files/kibana.sh",
        source => "puppet:///modules/elk/kibana.sh",
        owner => vagrant,
        mode => 755,
    	require => Exec['unpack kibana'],
    }

    exec{'update kibana':
        command => "/opt/kibana.sh",
        require => File["/opt/kibana.sh"],
    }

    exec{'start kibana':
        cwd => "${kibana_home}/bin",
        command => "sudo ./kibana &",
        require => Exec['update kibana'],
    }


	#Install Logstash
	file {"/opt/${logstash_archive}":
		ensure => "present",
		#source => "/tmp/shared/elk/files/${logstash_archive}",	
		source => "puppet:///modules/elk/${logstash_archive}",
		owner => vagrant,
		mode => 755,
		require => Exec['start kibana'],		
	}

	exec{'unpack logstash':
		cwd => "/opt",
		command => "tar zxvf ${logstash_archive}",
		require => File["/opt/${logstash_archive}"],
	}

	file {"${logstash_home}/logstash.conf":
		ensure => "present",
		#source => "/tmp/shared/elk/files/logstash.conf",
		source => "puppet:///modules/elk/logstash.conf",
		owner => vagrant,
		mode => 755,
		require => Exec['unpack logstash'],
	}

	exec{'configure logstash':
		cwd => "${logstash_home}",
		command => "sudo bin/logstash -f logstash.conf",
		require => File["${logstash_home}/logstash.conf"]
	}
}
