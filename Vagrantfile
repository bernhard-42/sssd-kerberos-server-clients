Vagrant.configure("2") do |config|
  domain = ""
  ipprefix = ""
  serversuffix = -1

  File.open("./config.sh", "r") do |f|
    f.each_line do |line|
      parts = line.split
      if parts[0] == "export"
        kv = parts[1].split("=")
        if kv[0] == "DOMAIN"
          domain = kv[1]
        elsif kv[0] == "IP_PREFIX"
          ipprefix = kv[1]
        elsif kv[0] == "SERVER_SUFFIX"
          serversuffix = Integer(kv[1])
        end
      end
    end
  end
  puts "Parsed config: domain=#{domain}, server=#{ipprefix}.#{serversuffix}"

  ipsuffix = [serversuffix        , serversuffix + 1   , serversuffix + 2       ]
  name     = ["authx"             , "c73"              , "u1604"                ]
  memory   = [1024                , 1024               , 1024                   ]
  cpus     = [1                   , 1                  , 1                      ]
  tag      = ["server"            , "client"           , "client"               ]
  image    = ["bento/ubuntu-16.04", "bento/centos-7.3" , "bento/ubuntu-16.04"   ]


  hostfile =  "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4\n"
  hostfile += "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6\n"
  (0..name.length-1).each do |i|
    hostfile += "#{ipprefix}.#{ipsuffix[i]}  #{name[i]}.#{domain}  #{name[i]}\n"
  end


  (0..name.length-1).each do |i|
    config.vm.define name[i] do |box|
      box.vm.box = image[i]
      box.vm.hostname = name[i]
      box.vm.box_check_update = false
      box.vm.network "private_network", ip: "#{ipprefix}.#{ipsuffix[i]}"
      box.vm.provider "virtualbox" do |vb|
        vb.gui = true
        vb.memory = memory[i]
        vb.cpus = cpus[i]
        vb.customize ["storageattach", :id, "--storagectl", "IDE Controller", "--port", "0", "--device", "1",
                      "--type", "dvddrive", "--medium", "emptydrive"]
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
        ./#{tag[i]}.sh
        if [ $(hostname) == "authx" ]; then
          cp /etc/ssl/certs/cacert.pem /vagrant
        fi
      SHELL
    end
  end
end
