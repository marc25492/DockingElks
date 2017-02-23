class haproxy {
	Exec {
		path => ["/usr/bin", "/bin", "/usr/sbin"]
	}

	exec { 'install build-essential' :
		command => 'sudo apt-get install -y build-essential',
	}

	exec { 'install libssl' :
                command => 'sudo apt-get install -y libssl-dev',
		require => Exec['install build-essential'],
        }

	exec { 'install libpcre' :
                command => 'sudo apt-get install -y libpcre++-dev',
		require => Exec['install libssl'],
        }

	exec { 'create user' :
		command => 'sudo useradd haproxy',
	}

#	exec { 'copy haproxy' :
#		cwd => '/tmp/shared',
#		command => 'sudo cp /tmp/shared/binaries/haproxy-1.7.1.tar.gz /opt',
#	}

	file { '/opt/haproxy-1.7.1.tar.gz' :
                ensure => present,
                source => 'puppet:///modules/haproxy/haproxy-1.7.1.tar.gz',
		require => Exec['install libpcre'],
        }
	
	exec { 'extract haproxy' :
                cwd => '/opt',
                command => 'sudo tar zxvf haproxy-1.7.1.tar.gz',
		require => File['/opt/haproxy-1.7.1.tar.gz'],
        }

	exec { 'compile haproxy' :
		cwd => '/opt/haproxy-1.7.1',
		command => 'sudo make TARGET=linux2628 CPU=native USE_STATIC_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1',
		require => Exec['extract haproxy'],
	}

	exec { 'install haproxy' :
		cwd => '/opt/haproxy-1.7.1',
		command => 'sudo make install',
		require => Exec['compile haproxy'],
	}

	file { '/etc/init.d/haproxy' :
		ensure => present,
		source => 'puppet:///modules/haproxy/haproxy',
		require => Exec['install haproxy'],
	}

	file{ '/etc/haproxy' :
		ensure  =>  directory,
		mode    =>  0755,
	}

	file { '/etc/haproxy/haproxy.cfg' :
                ensure => present,
                source => 'puppet:///modules/haproxy/haproxy.cfg',
                require => File['/etc/haproxy'],
        }
}
