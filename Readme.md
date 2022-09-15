# IT and IOT lab at Home Infrastructure


### Summary

This repository is infrastructure in code for the micro servers and other IOT devices running at my home and Proxy Server on Linode. I've mostly used Ansible and few parts uses terraform (currently not in main branch).

## Objective
The inital objective was just to maintain nextcloud and DNS service and nodes infrastructure as code but later I decided to share publically to give a starting point if anyone wants to setup raspberry pi or any other type server based infrastructure at home.

## What's in this repo ?
This repository contains Vagrantfile to setup ubuntu vm's in VirtualBox running on a Windows 10 in a Mini PC :man_facepalming: , and ansible playbook to deploy services into Docker Swarm setup at Home lab. A windows based machine for server stuff might not be a good choice but for set of specific needs Its working and I found a decent quite and tiny box.

In addition to Window Mini PC, I also have 4 Single board computer nodes out of which 1 is x86 rockpix and rockpi 4B and rockpro64 which are arm64 based. The fourth one is raspberry pi zero which I use for audio alert in-case a server or a critical goes down.

### Why Mini PC?
Mini PC was added recently and suited my budget as I wanted to spend as little as possible and get a decent one but price would go up as you wish for more. So I picked up Beelink Mini PC that has 8GB RAM and 256GB SSD. Linux one's were hard to find and I didnt wanted to jump into spending time re-installing linux on the mini pc. Beside just learning to use Ansible and Hashicorp Vagrant I also wanted to learn Docker Swarm based infrastructure.

Running Nextcloud is just fine as it is going on Single board computers I mentioned above. So I have two instances of nextcloud in which second one is backup of the main instance.

## Prerequisite 
* SSH Keys setup -- First step is to create ssh key which will be shared all the nodes that whill give the ansible user access with Sudo privilages. Use add user playbook to add ansibe user with sudo privileges.
* Knowledge of Ansible -- After the ssh keys are setup we will be using the ssh to connect to server nodes to perform instalation of services and configuring them from your computer.

### Services 
Here is a list of services running at my Home

| # 	| Services 	| Type 	| State 	| Node 	| Instances 	| Use 	| Extra 	|
|---	|---	|:---:	|:---:	|---	|---	|---	|---	|
| 1 	| Nextcloud 	| HTTPS 	| Active 	| Rockpi/Rockpi X 	| 2 	| Storage, Music Player and Document Editor 	|  	|
| 2 	| Cloudflared 	| DNS 	| Active 	| Proxy/Oracle1 	| 2 	| Network wide DNS over HTTPS 	|  	|
| 3 	| Pihole 	| DNS 	| Active 	| Pi Zero/Rockpi X 	| 2 	| Netwrok wide Ad blocking 	| Uses cloudflared as Upstream DNS Server 	|
| 4 	| Grafana 	| HTTPS 	| Active 	| Rockpi 	| 1 	| Service Monitoring 	|  	|
| 5 	| Prometheus 	| HTTP 	| Active 	| Rockpi 	| 1 	| Event monitoring and alerting 	|  	|
| 6 	| Node Exporter 	| HTTP 	| Active 	| ALL nodes 	| 5 	| Exporter for server & OS level metrics with configurable metric collectors 	|  	|
| 7 	| Mariadb 	| TCP 	| Active 	| Rockpix 	| 1 	| Database used by Nextcloud service 	|  	|
| 8 	| Influxdb 	| TCP 	| Down 	| Rockpi 	| 1 	| Database 	|  	|
| 9 	| Beep 	| Audio 	| Active 	| Pi Zero 	| 1 	| Alerts with an audio beep if a critical service is goes down. 	|  	|
| 10 	| Uptime Kuma 	| HTTPS 	| Active 	| Rockpi X 	| 1 	| Monitor services and nodes 	| sends notification when state changes via telegram 	|
| 11 	| Syncthing 	| SSH 	| Active 	| Rockpi / Rockpi X 	| 2 	| Keeps redundant data backup stored using Nextcloud. 	|  	|
| 12 	| Dashy 	| HTTPS 	| Down 	| - 	| 0 	| Dashboard for services 	|  	|
| 13 	| Traefik 	| HTTPS 	| Active 	| Rockpi X 	| 1 	| Reverse Proxy for services running at home. 	|  	|
| 14 	| Haproxy 	| HTTPS/TCP 	| Active 	| Proxy 	| 1 	| Internet facing reverse proxy to access website and nextcloud over internet. 	|  	|
| 15 	| DNSMasq 	| DNS 	| Active 	| Rockpi 	| 1 	| DNS Service in case all instances of pihole is down. 	| Uses cloudflared as Upstream DNS Server 	|
| 16 	| Keepalived 	| ALL 	| Active 	| Rockpi/Rockpi X 	| 2 	| Virtual IP on rockpi and rockpix gives access to duplicate instances of DNS 	|  	|
| 17 	| Redis 	| TCP 	| Active 	| Rockpi 	| 1 	| Used by Nextcloud 	|  	|


## Usage

### For docker swarm nodes only.

```bash
ansible-playbook playooks/install.yml
```
If you want to run on the remote services.

```bash
$ ansible-playbook -i remote/hosts --vault-password-file ~/paswd remote/playbooks/install.yml --tags "remote" --skip-tags "haproxy"
```
In the above command line, I am running the playbook on remote hosts but skipping the tasks with haproxy tag.

If you want to run on the baremetal nodes locally.

```bash
$ ansible-playbook -i remote/hosts --vault-password-file ~/paswd remote/playbooks/install.yml --tags "local"
```

## How to
If you want to use this repo as starting point, you would have to setup ssh keys, update the hosts file to match nodes at your premises. The ansbile playbook has variables declared in the config.yml that lives in private repository on github.com vault. 

Secondly, this repository also contains playbook/repo-pass.yml which I have encrypted with ansible vault contains password variable and password to the vault github repo. When running install.yml playbook I pass ansible vault password that decrypts repo-pass.yml using `--ask-vault-pass` and sets the password to clone the vault github repo. Ansible first clones the vault github repo and extract the variables stored in config.

What you would need is to list all the variables and either store locally your own config.yaml in the `{{playbook_dir}}/vault` or create a vault git repo and update it in install.yaml playbook.


## Nextcloud Setup (Since 2020)

I have two instances of Nextcloud running locally. The primary instance of nextcloud runs on the node facing the internet through a remote proxy on linode.
The second instance of nextcloud is the backup in case the primary instance is down.

Both instance have common mysql database which is accessed by both the intances. This was earlier setup as 3 node mariadb galera cluster, but having to spend time
managing galera cluster in case it goes out if sync was too much time consuming and
and requiring efforts. So for the time being single node mariadb instance is fine as I am taking database backup regularly.


The data is being kept redundent on both of these nodes. Both the local nodes are connected to 1TB storage and both the nodes are kept in sync. For keeping the data in sync I am using Syncthing.


This was the original setup of Nextcloud however with the passing of time it has reduced to single redis and single instance of mariadb.

<img src="https://instagram.flhr1-2.fna.fbcdn.net/v/t51.2885-15/133745031_2771479043107089_4878090111319432882_n.jpg?stp=dst-jpg_e35&_nc_ht=instagram.flhr1-2.fna.fbcdn.net&_nc_cat=109&_nc_ohc=dPfe4i7QxRUAX8uxzDT&edm=ALQROFkBAAAA&ccb=7-5&ig_cache_key=MjQ3NDk1MDk1MzA0OTUwNDg4OQ%3D%3D.2-ccb7-5&oh=00_AT-rnpjs__h0M8MOoUnv0SFGJeAqdtHoYWihqAUamy32xg&oe=63251FC1&_nc_sid=30a2ef"  style="float: left; margin-right: 10px;" />


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. 

As I would expect the first place for you to start would be to change the `hosts` file. i.e. changing IP's or adding new hosts to the list I have defined. The nodes IP under `[local]` are the single board computers I have locally.


## License
[MIT](https://github.com/sanfx/docker-swarm-infrastructure/blob/main/LICENSE)