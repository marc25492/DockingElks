class packer (
		$packer_zipfile = "packer_0.12.1_linux_amd64.zip" )
		{

        Exec {
                path => ["/usr/bin", "/bin/", "/usr/sbin", "/opt/packer"]
        }

        exec { 'copy zip file' :
                cwd => '/opt/packer',
                command => 'sudo cp -r /opt/binaries/packer-binary/${packer_zipfile} .',
        }

        exec { 'extract zip file' :
                cwd => '/opt/packer/packer-binary/',
                command => 'sudo unzip /opt/packer/packer-binary/${packer_zipfile}',
                require => Exec['copy zip file']
        }
		
		exec { 'copy bash script':
				command => 'sudo cp /tmp/shared/editbashrc.sh /opt/packer',
				require => Exec['extract zip file']
		}

        file { 'editbashrc.sh' :
                ensure => 'file',
                path => '/opt/packer/editbashrc.sh',
                owner => 'root',
                mode => '755'
				require => Exec['copy bash script']
        }
		
		exec { 'change permissions' :
				cwd => '/opt/packer/',
				command => 'sudo chmod u+x /opt/packer/editbashrc.sh',
				require => File['editbashrc.sh']
		}

        exec { 'run bash script' :
				cwd => '/opt/packer',
                user    => 'root',
				command => './editbashrc.sh',
                refreshonly => true,
                require => Exec['change permissions']
        }

        exec { 'reboot VM' :
                command => 'sudo reboot',
                require => Exec['run bash script']
        }

}

