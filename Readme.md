# IT and IOT lab at Home Infrastructure


### Introduction 🖋️

This repository is infrastructure in code for the micro servers and other IOT devices running at my home and Proxy Server on Linode. I've mostly used Ansible and few parts uses terraform (currently not in main branch).

The inital objective was just to maintain nextcloud and DNS service and nodes infrastructure as code but later I decided to share publically to give a starting point if anyone wants to setup raspberry pi or any other type server based infrastructure at home.

This repository contains Vagrantfile to setup ubuntu vm's in VirtualBox running on a Windows 10 in a Mini PC :man_facepalming: , and ansible playbook to deploy services into Docker Swarm setup at Home lab. A windows based machine for server stuff might not be a good choice but for set of specific needs Its working and I found a decent quite and tiny box.

In addition to Window Mini PC, I also have 4 Single board computer nodes out of which 1 is x86 rockpix and rockpi 4B and rockpro64 which are arm64 based. The fourth one is raspberry pi zero which I use for audio alert in-case a server or a critical goes down.

### Why Mini PC?
Mini PC was added recently and suited my budget as I wanted to spend as little as possible and get a decent one but price would go up as you wish for more. So I picked up Beelink Mini PC that has 8GB RAM and 256GB SSD. Linux one's were hard to find and I didnt wanted to jump into spending time re-installing linux on the mini pc. Beside just learning to use Ansible and Hashicorp Vagrant I also wanted to learn Docker Swarm based infrastructure.

Running Nextcloud is just fine as it is going on Single board computers I mentioned above. So I have two instances of nextcloud in which second one is backup of the main instance.

## Table of contents 📋
See below the top level parts of this README:

+ [Requirements](#requirements)
+ [Structure](#structure)
+ [Setup PreRequisite](#prerequisite)
+ [Services](#services)
+ [Usage](#usage)

[![Back to top](https://img.shields.io/badge/Back%20to%20top-lightgrey?style=flat-square)](#it-and-iot-lab-at-home-infrastructure)

## Requirements 🧰
Only [Docker](https://docs.docker.com/get-docker/) and [Compose](https://docs.docker.com/compose/) are required to deploy the stack, the following versions are the minimal requirements:

| Tool          | Version |
|:-------------:|:-------:|
| Docker        | 20      |
| Compose       | 1.29    |
| Ansible       | 2.10.8  |

[![Back to top](https://img.shields.io/badge/Back%20to%20top-lightgrey?style=flat-square)](#it-and-iot-lab-at-home-infrastructure)

## Prerequisite 
* SSH Keys setup -- First step is to create ssh key which will be shared all the nodes that whill give the ansible user access with Sudo privilages. Use add user playbook to add ansibe user with sudo privileges.
* Knowledge of Ansible -- After the ssh keys are setup we will be using the ssh to connect to server nodes to perform instalation of services and configuring them from your computer.

[![Back to top](https://img.shields.io/badge/Back%20to%20top-lightgrey?style=flat-square)](#it-and-iot-lab-at-home-infrastructure)

## Structure 
The ansible playbooks containes roles and in the roles directory has role which are basically services that gets deployed on the host that falls in specific category. Now, I have 4 types of hosts.

1. Three Single board Computers located and referred to as `local` 
    A. Rockpi 4A (arm64)
    B. Rockpi X  (x86)
    C. Raspberry pi 0 (armv6)
2. Remote Instances located and referred to as `remote`
    A. Linode Nano G1 (x86)
    B. Oracle  (arm64)
3. Virtual Machines loacted locally and referred to as `vms` running on Beelink Mini PC used for testing or heavy duty apps. I use docker swarm on vms.


```bash
├── baremetal
│   ├── hosts
│   └── playbooks
│       ├── install.yml
│       └── roles
├── remote
│   ├── hosts
│   └── playbooks
│       ├── install.yml
│       └── roles
│
└── virtual_machines
    ├── bootstrap_ansible.sh
    ├── hosts
    └── playbooks
        ├── install.yml
        └── roles

```
See usage below how I run when I want to deploy to a specific target. Each of the target type contains hosts file that contains list of hosts and `playbooks/install.yml` runs all the roles deploying services and updating configurations on the targetted nodes.

[![Back to top](https://img.shields.io/badge/Back%20to%20top-lightgrey?style=flat-square)](#it-and-iot-lab-at-home-infrastructure)

## Usage

For docker swarm nodes only.
----------------------------
```bash
ansible-playbook playooks/install.yml
```

If you want to run on the remote services.
------------------------------------------
```bash
$ ansible-playbook -i remote/hosts --vault-password-file ~/paswd remote/playbooks/install.yml --tags "remote" --skip-tags "haproxy"
```
In the above command line, I am running the playbook on remote hosts but skipping the tasks with haproxy tag.

If you want to run on the nodes locally.
----------------------------------------
```bash
$ ansible-playbook -i local/hosts --vault-password-file ~/paswd local/playbooks/install.yml --tags "local"
```


[![Back to top](https://img.shields.io/badge/Back%20to%20top-lightgrey?style=flat-square)](#it-and-iot-lab-at-home-infrastructure)

### Services 

Here is a list of services you can deploy on your servers at home. I am running these services at my Home some single and some are multi instance and loadbalanced.

| # 	| Services 	| Type 	| State 	| Node 	| Instances 	| Use 	| Extra 	|
|---	|---	|:---:	|:---:	|---	|---	|---	|---	|
| 1 	| [Nextcloud][1]	| HTTPS 	| Active 	| Rockpi/Rockpi X 	| 2 	| Storage, Music Player and Document Editor 	|  	|
| 2 	| [Cloudflared][2] | DNS 	| Active 	| Proxy/Oracle1 	| 2 	| Network wide DNS over HTTPS 	|  	|
| 3 	| [Pihole][3] 	| DNS 	| Active 	| Pi Zero/Rockpi X 	| 2 	| Network wide Ad blocking 	| Uses cloudflared as Upstream DNS Server 	|
| 4 	| [Grafana][4] 	| HTTPS 	| Active 	| Rockpi 	| 1 	| Service Monitoring 	|  	|
| 5 	| [Prometheus][5] 	| HTTP 	| Active 	| Rockpi 	| 1 	| Event monitoring and alerting 	|  	|
| 6 	| [Node Exporter][6]| HTTP 	| Active 	| ALL nodes 	| 5 	| Exporter for server & OS level metrics with configurable metric collectors 	|  	|
| 7 	| [Mariadb][7] | TCP 	| Active 	| Rockpix 	| 1 	| Database used by Nextcloud service 	|  	|
| 8 	| [Influxdb][8] | TCP 	| Down 	| Rockpi 	| 1 	| Database 	|  	|
| 9 	| [Beep][9] | Audio | Active 	| Pi Zero 	| 1 	| Alerts with an audio beep if a critical service is goes down. 	|  	|
| 10 	| [Uptime Kuma][10] | HTTPS | Active | Rockpi X | 1 | Monitor services and nodes | sends notification when state changes via telegram 	|
| 11 	| [Syncthing][11]| SSH 	| Active 	| Rockpi / Rockpi X 	| 2 	| Keeps redundant data backup stored using Nextcloud. 	|  	|
| 12 	| [Dashy][12] | HTTPS 	| Down 	| - 	| 0 	| Dashboard for services 	|  	|
| 13 	| [Traefik][13] 	| HTTPS 	| Active 	| Rockpi X 	| 1 	| Reverse Proxy for services running at home. 	|  	|
| 14 	| [Haproxy][14] 	| HTTPS/TCP 	| Active 	| Proxy 	| 1 	| Internet facing reverse proxy to access website and nextcloud over internet. 	|  	|
| 15 	| [DNSMasq][15] | DNS | Active 	| Rockpi 	| 1 	| DNS Service in case all instances of pihole is down. 	| Uses cloudflared as Upstream DNS Server 	|
| 16 	| [Keepalived][16] 	| ALL 	| Active 	| Rockpi/Rockpi X 	| 2 	| Virtual IP on rockpi and rockpix gives access to duplicate instances of DNS 	|  	|
| 17 	| [Redis][17] 	| TCP 	| Active 	| Rockpi 	| 1 	| Used by Nextcloud 	|  	|
| 18    | [Authelia][18]  | HTTP  | Active    | Rockpi    | 1     | Used by Syncthing,Grafana,Uptime Kuma| Single Sign On |
| 19    | [CAdvisor][19]  | TCP   | Active    | Rockpi/RockpiX | 1| Used to get docker metrics |  |
| 20    | [Dockered][20]| TCP   | Active    | Rockpi/X/Pi 0    | 3     | Used to Monitor Containers          |  |


## How to
If you want to use this repo as starting point, you would have to setup ssh keys, update the hosts file to match nodes at your premises. The ansbile playbook has variables declared in the config.yml that lives in private repository on github.com vault. 

Secondly, this repository also contains playbook/repo-pass.yml which I have encrypted with ansible vault contains password variable and password to the vault github repo. When running install.yml playbook I pass ansible vault password that decrypts repo-pass.yml using `--ask-vault-pass` and sets the password to clone the vault github repo. Ansible first clones the vault github repo and extract the variables stored in config.

What you would need is to list all the variables and either store locally your own config.yaml in the `{{playbook_dir}}/vault` or create a vault git repo and update it in install.yaml playbook.

[![Back to top](https://img.shields.io/badge/Back%20to%20top-lightgrey?style=flat-square)](#it-and-iot-lab-at-home-infrastructure)
## Nextcloud Setup (Since 2020)

I have two instances of Nextcloud running locally. The primary instance of nextcloud runs on the node facing the internet through a remote proxy on linode.
The second instance of nextcloud is the backup in case the primary instance is down.

Both instance have common mysql database which is accessed by both the intances. This was earlier setup as 3 node mariadb galera cluster, but having to spend time
managing galera cluster in case it goes out if sync was too much time consuming and
and requiring efforts. So for the time being single node mariadb instance is fine as I am taking database backup regularly.


The data is being kept redundent on both of these nodes. Both the local nodes are connected to 1TB storage and both the nodes are kept in sync. For keeping the data in sync I am using Syncthing.

[![Back to top](https://img.shields.io/badge/Back%20to%20top-lightgrey?style=flat-square)](#it-and-iot-lab-at-home-infrastructure)

This was the original setup of Nextcloud however with the passing of time it has reduced to single redis and single instance of mariadb.

<img src="https://instagram.flhr1-2.fna.fbcdn.net/v/t51.2885-15/133745031_2771479043107089_4878090111319432882_n.jpg?stp=dst-jpg_e35&_nc_ht=instagram.flhr1-2.fna.fbcdn.net&_nc_cat=109&_nc_ohc=dPfe4i7QxRUAX8uxzDT&edm=ALQROFkBAAAA&ccb=7-5&ig_cache_key=MjQ3NDk1MDk1MzA0OTUwNDg4OQ%3D%3D.2-ccb7-5&oh=00_AT-rnpjs__h0M8MOoUnv0SFGJeAqdtHoYWihqAUamy32xg&oe=63251FC1&_nc_sid=30a2ef"  style="float: left; margin-right: 10px;" />


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change. 

As I would expect the first place for you to start would be to change the `hosts` file. i.e. changing IP's or adding new hosts to the list I have defined. The nodes IP under `[local]` are the single board computers I have locally.

[![Back to top](https://img.shields.io/badge/Back%20to%20top-lightgrey?style=flat-square)](#it-and-iot-lab-at-home-infrastructure)

## License
[MIT](https://github.com/sanfx/docker-swarm-infrastructure/blob/main/LICENSE)

[2]: https://developers.cloudflare.com/1.1.1.1/encryption/dns-over-https/dns-over-https-client/#cloudflared
[1]: https://nextcloud.com/
[3]: https://pi-hole.net/
[4]: https://grafana.com/
[5]: https://prometheus.io/docs/introduction/overview/
[6]: https://github.com/prometheus/node_exporter#node-exporter
[7]: https://mariadb.org/
[8]: https://www.influxdata.com/
[9]: https://github.com/sanfx/Beep
[10]: https://uptime.kuma.pet/
[11]: https://syncthing.net/
[12]: https://dashy.to/
[13]: https://traefik.io/traefik/
[14]: https://www.haproxy.com/
[15]: https://thekelleys.org.uk/dnsmasq/doc.html
[16]: https://keepalived.readthedocs.io/en/latest/introduction.html
[17]: https://redis.io/
[18]: https://homelabos.com/docs/software/authelia/
[19]: https://github.com/google/cadvisor
[20]: https://github.com/stefanprodan/dockerd-exporter
