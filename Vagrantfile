# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box_check_update = false

  config.vm.define "kiosk" do |kiosk|
    kiosk.vm.box = "peru/ubuntu-18.04-desktop-amd64"
    kiosk.vm.hostname = "wam-dev-foyer-wm06.local"
    kiosk.vm.synced_folder "./", "/etc/puppetlabs", type: "virtualbox"
    kiosk.vm.network "forwarded_port", guest: 8085, host: 8085
    kiosk.vm.network "forwarded_port", guest: 80, host: 80
    kiosk.vm.provider "virtualbox" do |kioskvb|
      kioskvb.memory = "2048"
      kioskvb.cpus = 2
      kioskvb.gui = true
      kioskvb.customize ["modifyvm", :id, "--vram", "128"]
    end
  end

 if Vagrant.has_plugin?("vagrant-cachier")
   config.cache.scope = :box
 end

  config.vm.provision "shell", inline: "/bin/bash /etc/puppetlabs/shell/initial-setup.sh"
end