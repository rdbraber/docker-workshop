# Docker workshop

This workshop is a beginners guide in using Docker. Lots of information can be found at the original [Docker](https://www.docker.com) website. A good way to learn Docker is to use the [get started guide](https://docs.docker.com/learn/).

For this workshop servers have been created for each participant. But you can also create your own workshop environment with the help of Vagrant and git. Since there's is lots to find about how to use [Vagrant](https://www.vagrantup.com) in combination with [Oracle's Virtualbox](https://www.virtualbox.org), this won't be covered in this workshop.

A quick getting started for this workshop, if you want to build your own environment:

- Make sure Virtualbox, Vagrant and git are installed on your computer
- Use the command `git clone https://github.com/rdbraber/docker-workshop.git` to clone the repository containing the scripts to create the virtual machine
- go to the directory docker-workshop
- start virtual machine with the `vagrant up` command and wait for the virtual machine to be started and for the configuration
- use the command `vagrant ssh` to login to the virtual machine

For you copy and paste people:

~~~
git clone https://github.com/rdbraber/docker-workshop.git
cd docker-workshop
vagrant up && vagrant ssh
~~~

All commands are done with the root account, but of course you could perform the commands with a regular user account with the proper sudo rights.

## Check if Docker is running and the version of Docker

To check if Docker is really installed and running we use the `systemctl` command:

~~~
systemctl status docker
~~~

The command above will show you that the service is running and that we should be able to use it.

To see the current version of Docker run the `docker --version` command:

~~~
docker --version
~~~

