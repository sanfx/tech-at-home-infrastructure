# Docker Swarm Infrastructure for Home Lab

This repository contains Vagrantfile to setup Docker Swarm cluster in VirtualBox running on a Windows 10 in a Mini PC :man_facepalming: , and ansible playbook to deploy services into Docker Swarm setup at Home lab. A windows based machine for server stuff might not be a good choice but for set of specific needs Its working and I found a decent quite and tiny box.


### Why Mini PC?
Mini PC suited my budget as I wanted to spend as little as possible and get a decent one but price would go up as you wish for more. So I picked up Beelink Mini PC that has 8GB RAM and 256GB SSD. Linux one's were hard to find and I didnt wanted to jump into spending time re-installing linux on the mini pc. Beside just learning to use Ansible and Hashicorp Vagrant I also wanted to move the nextcloud to this stack.(the part which I still haven't started yet).


## Pre-requisite 
First step is to create ssh key which will be shared all the nodes that whill give the ansible user access with Sudo privilages. Use add user playbook to add ansibe user with sudo privileges.


## Usage

```bash
ansible-playbook playooks/install.yml
```

## How to
If you want to use this repo as starting poing, you would have to change few things for the ansible part. The ansbile playbook has variables declared in the config.yml that lives in private repository on github.com vault. Secondly, this repository contains playbook/repo-pass.yml which I have encrypted with ansible vault contains password variable and password to the vault github repo. When running install.yml playbook I pass ansible vault password that decrypts repo-pass.yml using `--ask-vault-pass` and sets the password to clone the vault github repo. Ansible first clones the vault github repot and extract the variables stored in config.

What you would need is to list all the variables and either store locally your own config.yaml in the `{{playbook_dir}}/vault` or create a vault git repo and update it in install.yaml playbook.


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.


## License
[MIT](https://github.com/sanfx/docker-swarm-infrastructure/blob/main/LICENSE)