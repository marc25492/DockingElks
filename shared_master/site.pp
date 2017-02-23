node default {
	include java
	include maven
}

node 'elkAgent.qac.local'{
	include elk
	}
	
node 'snortAgent.qac.local' {
	include snort
	}
	
node 'jiraAgent.qac.local' {
	include jira
	include jenkins
	include tomcat
}

node 'packerAgent.qac.local'{
	include packer
	include nexus
	}
		
node 'test.qac.local'{
	include jenkins
	include tomcat
	include haproxy
	}