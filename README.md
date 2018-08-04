# hadoop-vm

Hadoop VM used for playing around ensuring an uniform development environment maintained under version control using [Vagrant](http://vagrantup.com) (version 1.8.x only, see notes below) with the [VirtualBox](https://www.virtualbox.org/) (version 5.0.x or up) back-end.

* If you didn't do, install recommended Vagrant plugins:
  * Run `vagrant plugin install vagrant-proxyconf` (should be version 1.5.2 or up).
  * Run `vagrant plugin install vagrant-vbguest` (should be version 0.13.0 or up).

> **Note:** `export use_proxy=true` if you want to use the devenv with proxy.

> **Note:** Make sure your development machine has BIOS setup to allow for virtualization.

## Features:
* Copy your `id_rsa` and `id_rsa.pub` keypair from ~/.ssh into the vagrant vm.
* Map your home dir into the vagrant vm.
* Install and configure hadoop.

## Commands:
* Use `vagrant up` to start or provision the Vagrant box for the first time.
* Use `vagrant provision` (if VM already running) or `vagrant up --provision` (bring it up and re-provision it) to update an existing VM.
* Use `vagrant box update` (while the VM is down) to update the underlying distribution.
* Use `vagrant destroy -f` to destroy the VM.
* Use `vagrant ssh` to log in the VM.
* Use `vagrant halt` to stop your VM.

> **Note:** When asked which network interface you want to use, choose `bridge0` on Linux & OSX.

> **Note:** Use `vagrant halt` instead of suspend to stop your Vagrant box. When resuming a suspended VM, date and time may not synchronize correctly.


## Super Powers:
Add this to your `~/.bash_profile` to be able to log in to the development environment from ANY directory by typing `devenv-login` in your shell:

```
devenv-login() {
  vagrant ssh $(vagrant global-status | awk '{if ($2 == "hadoop-vm") print $1}')
}
```

## Port Forwarding:
By default, this vagrant box exposes these ports:

| port: | purpose: |
| ---- | ---- |
| `50070` |  for hadoop |
| `8088`  |  for debugging |

If you need to add custom ports for your service, create a `Vagrantfile` at your home directory (`~/.vagrant.d/Vagrantfile`):

More info at: https://www.vagrantup.com/docs/vagrantfile/#load-order-and-merging

```
Vagrant.configure('2') do |config|
  # MongoDB
  config.vm.network :forwarded_port, guest: 27017, host: 27017, auto_correct: true
end
```

## Mapping Additional Folders

If you desire to map extra folder into the Guest VM you may do so with the use of the environment variable 
`extra_mappings`. Below is how you can use it.

In order to map a folder it is require to provide two directories, the first will be considered as a directory from the
Host Machine and the second the Guest directory into which it will be mapped. You need to use `,` as separator. Below is
an example:

```bash
export extra_mappings="c:\\development\\git,/development/git"
```

In the example above Vagrant will map the directory `c:\development\git` from the Host Machine into the 
`/development/git` directory in the Guest VM.

You can map multiple folders. Use pipe (`|`) as the separator. Below is an example:

```bash
export extra_mappings="c:\\development\\git,/development/git|d:\\development\\commons,/development/commons"
```

Not only you map the `c:\development\git` directory you will also map the `d:\development\commons` directory from the 
Host Machine into the `/development/commons` directory in the Guest VM

## Compatibility Matrix:

These are the known good combinations of OS, Vagrant and Virtual Box that we have tested. If you're successfully using a different combination, please update the table below:

| Operating System | Vagrant | Virtual Box |
| ---------------- | ------- | ----------- |
| Windows 10       | 1.9.2   | 5.1.8       |
| Windows 10       | 1.8.5   | 5.1.14      |
| Ubuntu 16.04     | 1.8.5   | 5.1.22      |
