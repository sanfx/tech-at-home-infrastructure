# IT and IOT lab at Home Infrastructure

This repository contains Vagrantfile to setup ubuntu vm's in VirtualBox running on a Windows 10 in a Mini PC :man_facepalming: , and ansible playbook to deploy services into Docker Swarm setup at Home lab. A windows based machine for server stuff might not be a good choice but for set of specific needs Its working and I found a decent quite and tiny box.

In addition to Window Mini PC, I also have 4 Single board computer nodes out of which 1 is x86 rockpix and rockpi 4B and rockpro64 which are arm64 based. The fourth one is raspberry pi zero which I use for audio alert in-case a server or a critical goes down.

### Why Mini PC?
Mini PC was added recently and suited my budget as I wanted to spend as little as possible and get a decent one but price would go up as you wish for more. So I picked up Beelink Mini PC that has 8GB RAM and 256GB SSD. Linux one's were hard to find and I didnt wanted to jump into spending time re-installing linux on the mini pc. Beside just learning to use Ansible and Hashicorp Vagrant I also wanted to learn Docker Swarm based infrastructure.

Running Nextcloud is just fine as it is going on Single board computers I mentioned above. So I have two instances of nextcloud in which second one is backup of the main instance.

## Pre-requisite 
First step is to create ssh key which will be shared all the nodes that whill give the ansible user access with Sudo privilages. Use add user playbook to add ansibe user with sudo privileges.


## Usage

### For docker swarm nodes only.

```bash
ansible-playbook playooks/install.yml
```

## How to
If you want to use this repo as starting poing, you would have to change few things for the ansible part. The ansbile playbook has variables declared in the config.yml that lives in private repository on github.com vault. Secondly, this repository contains playbook/repo-pass.yml which I have encrypted with ansible vault contains password variable and password to the vault github repo. When running install.yml playbook I pass ansible vault password that decrypts repo-pass.yml using `--ask-vault-pass` and sets the password to clone the vault github repo. Ansible first clones the vault github repot and extract the variables stored in config.

What you would need is to list all the variables and either store locally your own config.yaml in the `{{playbook_dir}}/vault` or create a vault git repo and update it in install.yaml playbook.


## Nextcloud Setup

I have two instances of Nextcloud running locally. The primary instance of nextcloud runs on the node facing the internet through a remote proxy on linode.
The second instance of nextcloud is the backup in case the primary instance is down.

Both instance have common mysql database which is accessed by both the intances. This was earlier setup as 3 node mariadb galera cluster, but having to spend time
managing galera cluster in case it goes out if sync was too much time consuming and
and requiring efforts. So for the time being single node mariadb instance is fine as I am taking database backup regularly.


The data is being kept redundent on both of these nodes. Both the local nodes are connected to 1TB storage and both the nodes are kept in sync. For keeping the data in sync I am using Syncthing.


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. 

As I would expect the first place for you to start would be to change the `hosts` file. i.e. changing IP's or adding new hosts to the list I have defined. The nodes IP under `[local]` are the single board computers I have locally.




## License
[MIT](https://github.com/sanfx/docker-swarm-infrastructure/blob/main/LICENSE)