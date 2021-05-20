# contrail-local-repo-builder

## Config

```bash
$ cat contrail-local-repo-builder/config.env
DOCKER_USERNAME=<username for hub.juniper.net>
DOCKER_PASSWORD=<password for the user>
DOCKER_REGISTRY=<local docker server eg; localhost:2375>
DOCKER_REGISTRY_NAME=<local registry name or IP adresss eg; local-regisitry.local:5000>
```

## instruction

```shellsession
$ yum install -y git
$ git clone https://github.com/shun159/contrail-local-repo-builder
$ # put the config.env in `pwd`
$ cd contrail-local-repo-builder
# You may need to allow 5000/tcp incoming packet
$ firewall-cmd --zone=public --add-port=5000/cp --permanent
$ firewall-cmd --reload
$ ./run.sh
```

__Bug report, feature request and pull request are welcome!__

