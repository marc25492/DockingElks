class jenkins (
        $jenkins_archive = "jenkins_2.1_all.deb",
	)
	{
        require java
		require maven

        Exec {
                path => ["/usr/bin","/bin","/usr/sbin"]
        }

        exec{'install daemon':
                command => 'sudo apt-get install -y daemon',
        }
		
		exec{'install jre-headless':
				command => 'sudo apt-get install -y default-jre-headless',
		}

        file { "/opt/${jenkins_archive}":
                ensure => present,
                owner => vagrant,
                mode => 755,
                #source => "/tmp/shared/jenkins/files/${jenkins_archive}",
                source => "puppet:///modules/jenkins/${jenkins_archive}",
        }

#        exec { 'copy jenkins' :
#                command => 'sudo cp /tmp/shared/jenkins_2.1_all.deb /opt',
#        }

        exec { 'add key' :
                cwd => '/opt',
                command => 'wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -',
        }

        package { 'jenkins':
                provider => dpkg,
                ensure => installed,
                source => "/opt/jenkins_2.1_all.deb",
                require => Exec['add key'],
        }

#        exec { 'install jre' :
#               command => 'sudo apt-get install -f',
#               require => Package['jenkins'],
#       }

        service { 'jenkins':
                enable => true,
                ensure => running,
                hasrestart => true,
                hasstatus => true,
                require => Package['jenkins'],
        }
}
