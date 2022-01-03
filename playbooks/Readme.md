## Playbooks

This section contains list of playbooks that gets run when user runs the install.yml playbook.


When we run `vagrant up` command it brings up 3 virtual machine, as per this setup. (you can change the configuration as you like.)
1 Swarm Manager and 2 workers. Each of those run a `SHELL` from within the Vagrantfile to update and install apt packages and ansible.
once the VM is up the it runs ansbile internally to install docker and other dependencies using the `provision.yml`. You can install entire
ansible based stack from within but that slows down the process. So I chose to run the stack listed below separately.

--: Primary and Mandatory Playbooks :--

1. **Docker**: Ensures ansible user is part of the docker group and installs docker python library.

2. **Swarm Managers**: Initiates Docker Swarm in the first node.

3. **Swarm Workers**: joines the worker nodes to the Swarm if they have not already joiend.

-- : Stacks to monitor cluster and other applications :--

4. **traefik**: I have used traefik as reverse proxy, this has become one of my absolute favourite. 
This stack is also responsible for creating default network from which all containers are discovered by traefik.

| Containers | Mode | Host|
|:-------:|:---:|:---:|
| traefik | Replicated | Manager|

5. **Cluster Monitor** - contains `tasks/main.yml` resposible for deploying cluster monitoring stack.

    The stack file is located in `templates/` and has below listed containers getting deployed by the stack.

| Containers | Mode | Host|
|:-------:|:---:|:---:|
| Grafana  | Replicated | Manager |
| CAdvisor | Global | all|
| dockerd-exporter| Global |all|
| Prometheus| Replicated | Manager |
| Alertmanager| Replicated | Manager|
| Unsee | Replicated | Manager |
| node-exporter | Global | all |

6. **DNS Stack** -  contains `tasks/main.yml` responsible for deploying DNSMasq, Pihole and internet facing DNS over HTTPS.

    The stack file is located in `templates/` and has below listed containers getting deployed by the stack.
    For DNSMasq I am using jpillora/webproc which displays the query and replies in the web ui and I also have consul mesh installed from previous setup. I put Pihole and Consul mesh together in the DNSMasq config.

| Containers | Mode | Host|
|:-------:|:---:|:---:|
| cloudflared DOH | Replicated | Manager|
| Pihole Ad Blocker | Replicated | Manger|
| DNSMASQ | Replicated | Workers|


7. **Web** - This stack runs dashy dashboard , I plan to add wordpress and other web browser based applications here.

| Containers | Mode | Host|
|:-------:|:---:|:---:|
| dashy | Replicated | Manager|