# -*- mode: ruby -*-
# vi: set ft=ruby :

use_proxy = false
use_proxy = ENV['use_proxy'].to_s == 'true' ? true : false  if ENV['use_proxy']
url_proxy = ENV['http_proxy'] || 'http://web-proxy.corp.hp.com:8080'
not_proxy = 'localhost,127.0.0.1,.hpicorp.net,15.0.0.0/8,16.0.0.0/8'

private_key = File.expand_path(File.join(Dir.home, '.ssh/id_rsa'))
public_key = File.expand_path(File.join(Dir.home, '.ssh/id_rsa.pub'))

extra_mappings = ENV['extra_mappings'] ? ENV['extra_mappings'].split('|') : Array.new
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # Proxy configuration:
  #
  if use_proxy
    puts 'INFO: Configuring proxy for the VM.'
    if Vagrant.has_plugin?('vagrant-proxyconf')
      config.proxy.http     = url_proxy
      config.proxy.https    = url_proxy
      config.proxy.no_proxy = not_proxy
      config.proxy.enabled  = { npm: false }
    else
      puts '.'
      puts 'ERROR: Could not find vagrant-proxyconf plugin.'
      puts 'INFO: This plugin is required to use this box inside HPinc network.'
      puts 'INFO: $ vagrant plugin install vagrant-proxyconf'
      puts 'ERROR: Bailing out.'
      puts '.'
      exit 1
    end
  end

  # VB Guest Additions configuration:
  #
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_reboot = true
  else
    puts '.'
    puts 'WARN: Could not find vagrant-vbguest plugin.'
    puts 'INFO: This plugin is highly recommended as it ensures that your VB guest additions are up-to-date.'
    puts 'INFO: $ vagrant plugin install vagrant-vbguest'
    puts '.'
  end

  config.vm.box = "ubuntu/xenial64"
  config.vm.define 'hadoop-vm'
  config.vm.hostname = 'hadoop-vm'

  config.vm.provision :shell, path: 'scripts/bootstrap.sh', privileged: false, name: 'bootstrap'

  config.vm.network "forwarded_port", guest: 50070, host: 50070, auto_correct: true, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8088, host: 8088, auto_correct: true, host_ip: "127.0.0.1"

  config.vm.network "private_network", ip: "192.168.30.20"

  config.vm.synced_folder Dir.home, '/home/vagrant/shared', create: true

  # Map extra folder into the Guest
  extra_mappings.each do |value|
    sync_folder = value.split ','
    host_dir = sync_folder[0].strip
    guest_dir = sync_folder[1].strip
    puts "INFO: Mapping #{host_dir} to #{guest_dir}"
    config.vm.synced_folder host_dir, guest_dir, create: true
  end

  config.vm.provision 'file', source: public_key, destination: '~/.ssh/authorized_keys'
  config.vm.provision 'file', source: private_key, destination: '~/.ssh/id_rsa'

  config.vm.provider "virtualbox" do |vb|
   # Display the VirtualBox gui when booting the machine
   vb.cpus = 2

   # Customize the amount of memory on the VM:
   vb.memory = "4608"
 end

end
