class java {

        Exec {
                path => ["/usr/bin","/bin","/usr/sbin"]
        }

		file {"/opt/java.tar.gz":
			ensure => "present",
			source => "puppet:///modules/java/java.tar.gz",
			owner => vagrant,
			mode => 755,
		}
		
        exec { 'extract java tar file' :
                cwd => '/opt',
                command => 'sudo tar zxvf java.tar.gz',
                require => File["/opt/java.tar.gz"],
        }

        exec { 'install java' :
                require => Exec['extract java tar file'],
                command => 'sudo update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_45/bin/java 100',
        }

        exec { 'install javac' :
                require => Exec['extract java tar file'],
                command => 'sudo update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_45/bin/javac 100',
        }
}

