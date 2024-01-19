## Setup new machine remotely

Edit `hosts` file and run:

```sh
ansible-playbook -i hosts setup.yml -K --tags all
```

## Setup new machine locally

```sh
ansible-playbook setup.yml -K --tags all
```

## Dev env

Provision an Ubuntu VM using `docker`
```sh
./docker-build
./docker-run
```

Reset the VM by `./docker-reset`


Test the VM by ssh:

```sh
ssh ubutu@localhost -p 2222
```
