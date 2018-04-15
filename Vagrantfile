Vagrant.configure("2") do |config|
  conf = YAML::load_file(File.join(__dir__, 'config-machines.yaml'))
  hosts = conf["hosts"]
  domain = conf["domain"]
  server = nil

  hostfile =  "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4\n"
  hostfile += "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6\n"
  hosts.each do |host|
    hostfile += "#{host["ip"]}  #{host["name"]}.#{conf["domain"]} #{host["name"]}\n"
    server = host if host["tag"] == "server"
  end

  hosts.each do |host|
    config.vm.define host["name"] do |box|
      box.vm.box = host["image"]
      box.vm.hostname = host["name"]
      box.vm.box_check_update = false
      box.vm.network "private_network", ip: host["ip"]
      box.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.memory = host["memory"]
        vb.cpus = host["cpus"]
        vb.customize ["storageattach", :id, 
                      "--storagectl", "IDE Controller", 
                      "--port", "0", 
                      "--device", "1",
                      "--type", "dvddrive", 
                      "--medium", "emptydrive"]
      end

      box.vm.provision "shell", inline: <<-SHELL
        echo "#{hostfile}" > /etc/hosts

        if [[ ! -f /vagrant/id_rsa ]]; then
          ssh-keygen -P '' -f /vagrant/id_rsa
        fi
        cp /vagrant/id_rsa* /home/vagrant/.ssh
        chmod 600 /home/vagrant/.ssh/id_rsa*
        chown vagrant:vagrant /home/vagrant/.ssh/id_rsa*
        cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
        
        cd /vagrant
        export VAGRANT=1
        ./create-#{host["tag"]}.sh #{domain} #{server["ip"]} #{server["name"]}
        if [ #{host["tag"]} == "server" ]; then 
          cp /etc/ssl/certs/cacert.pem /vagrant
        fi
      SHELL
    end
  end
end
