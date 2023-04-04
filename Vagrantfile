CPUS_WORKER = 2
MEMORY_WORKER = "1024"
CPUS_MANAGER = 2
MEMORY_MANAGER = "1024"
MANAGER_IP = "192.168.0.100"
WORKER_IP = "192.168.0.101"

ANSIBLE_PATH = File.expand_path("./ansible")

Vagrant.configure("2") do |config|
    config.vm.box = "bento/ubuntu-22.10"
    config.ssh.insert_key = false

    config.vm.synced_folder ".assets", "/assets"

    config.vm.provision "docker-install", type: "ansible" do |ansible|
      ansible.playbook = "#{ANSIBLE_PATH}/docker-install.yml"
      ansible.become = true
    end

    config.vm.define "manager" do |manager|
      manager.vm.network :private_network, ip: MANAGER_IP
      manager.vm.hostname = "manager"

      manager.vm.provider "virtualbox" do |vb|
        vb.memory = MEMORY_MANAGER
        vb.cpus = CPUS_MANAGER

        vb.customize ["modifyvm", :id, "--memory", MEMORY_MANAGER]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end

      manager.vm.network :forwarded_port, guest: 80, host: 80

      manager.vm.provision "setup-manager", type: "ansible" do |ansible|
        ansible.playbook = "#{ANSIBLE_PATH}/setup_manager.yml"
        ansible.become = true
      end
    end

    config.vm.define "worker" do |worker|
      worker.vm.provider "virtualbox" do |vb|
        vb.memory = MEMORY_WORKER
        vb.cpus = CPUS_WORKER

        vb.customize ["modifyvm", :id, "--memory", MEMORY_WORKER]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end
      
      worker.vm.network :private_network, ip: WORKER_IP
      worker.vm.hostname = "worker"

      worker.vm.provision "setup-worker", type: "ansible" do |ansible|
        ansible.playbook = "#{ANSIBLE_PATH}/setup_worker.yml"
        ansible.become = true
      end
    end
end