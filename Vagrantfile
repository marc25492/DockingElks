# -*- mode: ruby -*-
# vi: set ft=ruby :

#add environment variables to set up numerous agents ( domain name & IP Address)
masterDN = "jayde-master.qac.local"
masterIP = "192.168.1.120" #104 
agentDN = "jayde-agent.qac.local"
agentIP = "192.168.1.121"

Vagrant.configure("2") do |config|
 
	config.vm.boot_timeout = 400
	config.vm.box = "chad-thompson/ubuntu-trusty64-gui"

	config.vm.define "master" do |master|
        master.vm.hostname = masterDN
        master.vm.synced_folder "shared_master", "/tmp/shared"
        master.vm.network :public_network, ip: masterIP
        master.vm.provision :shell, path: "bootstrap_master.sh", env: {"masterIP" => masterIP, "masterDN" => masterDN, "agentDN" => agentDN, "agentIP" => agentIP}
        
		master.vm.provider :virtualbox do |masterVM|
            masterVM.gui = true
            masterVM.name = "master"
            masterVM.memory = 4096
            masterVM.cpus = 2
        end
    end
	
	agent_nodes = [
		{ :name => "elkAgent", :hostname => 'elkAgent.qac.local',	:ip => '192.168.1.100',	:ram => 2048},
		{ :name => "snortAgent", :hostname => 'snortAgent.qac.local',	:ip => '192.168.1.101', 	:ram => 2048},
		{ :name => "jiraAgent", :hostname => 'jiraAgent.qac.local',	:ip => '192.168.1.104', 	:ram => 2048},
		{ :name => "packerAgent", :hostname => 'packerAgent.qac.local',	:ip => '192.168.1.105', 	:ram => 2048},
		{ :name => "testAgent", :hostname => 'test.qac.local',	:ip => '192.168.1.106', 	:ram => 4096},
	]
	
    agent_nodes.each do |agent|
		config.vm.define agent[:name] do |agentconfig|
			agentconfig.vm.hostname = agent[:hostname]
			agentconfig.vm.synced_folder "shared_agent", "/tmp/shared"
			agentconfig.vm.network :public_network, ip: agent[:ip]
			agentconfig.vm.provision :shell, path: "bootstrap_agent.sh", env: {"masterIP" => masterIP, "masterDN" => masterDN}
			
			agentconfig.vm.provider :virtualbox do |agentVM|
				agentVM.gui = true
				agentVM.name = agent[:name]
				agentVM.memory = agent[:ram]
				agentVM.cpus = 2
			end
		end
	end
   
end
