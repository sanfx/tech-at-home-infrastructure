# Docker Swarm Infrastructure for Home Lab

This repository contains ansible playbook to deploy services into Docker Swarm setup at Home lab.

## Pre-requisite 
First step is to create ssh key which will be shared all the nodes that whill give the ansible user access with Sudo privilages. Use add user playbook to add ansibe user with sudo privileges.


## Usage

```bash
ansible-playbook playooks/install.yml
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)