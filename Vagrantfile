# -*- mode: ruby -*-
# vi: set ft=ruby:

mainscript = "initscripts/mainkubeinstall.sh"
workerscript = "initscripts/workerkubeinstall.sh"

nodes = [
		{:hostname => "node1", :cpus => 4, :mem => 3072, :script => workerscript},
	
		{:hostname => "node2", :cpus => 4, :mem => 3072, :script => workerscript},

		{:hostname => "main", :cpus => 4, :mem => 3072, :script => mainscript}
	]


Vagrant.configure(2) do |config|
	nodes.each do |node|
		config.vm.define node[:hostname] do |wmachine|
			config.vm.box_download_insecure = true
			config.vm.box = "peru/ubuntu-18.04-server-amd64"
			config.vm.box_check_update = false
			wmachine.vm.hostname = node[:hostname]
			wmachine.vm.provider :libvirt do |domain|
				domain.memory = node[:mem]
				domain.cpus = node[:cpus]
			end
			wmachine.vm.provision :shell, path: node[:script]
		end
	end
end