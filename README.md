# Docker workshop

This workshop is a beginners guide in using Docker. Lots of information can be found at the original [Docker](https://www.docker.com) website. A good way to learn Docker is to use the [get started guide](https://docs.docker.com/learn/).

You can create your own workshop environment with the help of Vagrant and git. Since there's is lots to find about how to use [Vagrant](https://www.vagrantup.com) in combination with [Oracle's Virtualbox](https://www.virtualbox.org), this won't be covered in this workshop.

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

## Check if Docker is running and which version of Docker is installed

To check if Docker is really installed and running we use the `systemctl` command:

~~~
systemctl status docker
~~~

The command above will show you that the service is running and that we should be able to use it.

To see the current version of Docker run the `docker --version` command:

~~~
docker --version
~~~

As part of the configuration of the virtual machine, some images have already been installed. Check with the `docker images` command which images are already available on your server:

~~~
docker images
~~~

Output should be something simular to:

~~~
[root@docker1 ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              latest              a8493f5f50ff        5 days ago          192MB
nginx               latest              5766334bdaa0        6 days ago          182MB
ubuntu              latest              0ef2e08ed3fa        6 weeks ago         130MB
~~~

## Starting our first container

To test if Docker is working as expected, we can use the `docker run` command. We are going to run the hello-world image.

~~~
docker run hello-world
~~~

Since the image is not currently available on our server, the first step is to download this image from the Docker Hub. After is has been downloaded it will be started and show the following output:

~~~
[root@docker1 ~]# docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
78445dd45222: Pull complete
Digest: sha256:c5515758d4c5e1e838e9cd307f6c6a0d620b5e07e6f927b07d05f6d12a1ac8d7
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://cloud.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/engine/userguide/
~~~

As shown in the text of the output, Docker is working as expected.

## Starting a container that contains an application

The hello-world image is only capable of showing the text as shown in the above output. Since this is not very useful, let's try to start another container. In this example we're going to start a webserver (nginx). The image for nginx is already available on our server, so the start of this container should be pretty quick.

First let's take a look at how this image is created. You can use the `docker history` command for that:

~~~
docker history nginx
~~~

This will show you the commands that were used to create the image:

~~~
[root@docker1 ~]# docker history nginx
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
5766334bdaa0        6 days ago          /bin/sh -c #(nop)  CMD ["nginx" "-g" "daem...   0B
<missing>           6 days ago          /bin/sh -c #(nop)  EXPOSE 443/tcp 80/tcp        0B
<missing>           6 days ago          /bin/sh -c ln -sf /dev/stdout /var/log/ngi...   0B
<missing>           6 days ago          /bin/sh -c echo "deb http://nginx.org/pack...   59.1MB
<missing>           6 days ago          /bin/sh -c set -e;  NGINX_GPGKEY=573BFD6B3...   4.9kB
<missing>           6 days ago          /bin/sh -c #(nop)  ENV NGINX_VERSION=1.11....   0B
<missing>           3 weeks ago         /bin/sh -c #(nop)  MAINTAINER NGINX Docker...   0B
<missing>           3 weeks ago         /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
<missing>           3 weeks ago         /bin/sh -c #(nop) ADD file:4eedf861fb567ff...   123MB
~~~

If you want to show the output without it being truncated, use the `--no-trunc` option:

~~~
[root@docker1 ~]# docker history --no-trunc nginx
IMAGE                                                                     CREATED             CREATED BY                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        SIZE                COMMENT
sha256:5766334bdaa0bc37f1f0c02cb94c351f9b076bcffa042d6ce811b0fd9bc31f3b   6 days ago          /bin/sh -c #(nop)  CMD ["nginx" "-g" "daemon off;"]                                                                                                                                                                                                                                                                                                                                                                                                                                                               0B
<missing>                                                                 6 days ago          /bin/sh -c #(nop)  EXPOSE 443/tcp 80/tcp                                                                                                                                                                                                                                                                                                                                                                                                                                                                          0B
<missing>                                                                 6 days ago          /bin/sh -c ln -sf /dev/stdout /var/log/nginx/access.log  && ln -sf /dev/stderr /var/log/nginx/error.log                                                                                                                                                                                                                                                                                                                                                                                                           0B
<missing>                                                                 6 days ago          /bin/sh -c echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list  && apt-get update  && apt-get install --no-install-recommends --no-install-suggests -y       ca-certificates       nginx=${NGINX_VERSION}       nginx-module-xslt       nginx-module-geoip       nginx-module-image-filter       nginx-module-perl       nginx-module-njs       gettext-base  && rm -rf /var/lib/apt/lists/*                                                                              59.1MB
<missing>                                                                 6 days ago          /bin/sh -c set -e;  NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62;  found='';  for server in   ha.pool.sks-keyservers.net   hkp://keyserver.ubuntu.com:80   hkp://p80.pool.sks-keyservers.net:80   pgp.mit.edu  ; do   echo "Fetching GPG key $NGINX_GPGKEY from $server";   apt-key adv --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break;  done;  test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1;  exit 0   4.9kB
<missing>                                                                 6 days ago          /bin/sh -c #(nop)  ENV NGINX_VERSION=1.11.13-1~jessie                                                                                                                                                                                                                                                                                                                                                                                                                                                             0B
<missing>                                                                 3 weeks ago         /bin/sh -c #(nop)  MAINTAINER NGINX Docker Maintainers "docker-maint@nginx.com"                                                                                                                                                                                                                                                                                                                                                                                                                                   0B
<missing>                                                                 3 weeks ago         /bin/sh -c #(nop)  CMD ["/bin/bash"]                                                                                                                                                                                                                                                                                                                                                                                                                                                                              0B
<missing>                                                                 3 weeks ago         /bin/sh -c #(nop) ADD file:4eedf861fb567fffb2694b65ebdd58d5e371a2c28c3863f363f333cb34e5eb7b in /                                                                                                                                                                                                                                                                                                                                                                                                                  123MB
~~~

You have to read this output from the bottom to the top to see, in which order the commands were used. A simple way to change the order of the output, is to use the `tac` command:

~~~
[root@docker1 ~]# docker history nginx | tac
<missing>           3 weeks ago         /bin/sh -c #(nop) ADD file:4eedf861fb567ff...   123MB
<missing>           3 weeks ago         /bin/sh -c #(nop)  CMD ["/bin/bash"]            0B
<missing>           3 weeks ago         /bin/sh -c #(nop)  MAINTAINER NGINX Docker...   0B
<missing>           6 days ago          /bin/sh -c #(nop)  ENV NGINX_VERSION=1.11....   0B
<missing>           6 days ago          /bin/sh -c set -e;  NGINX_GPGKEY=573BFD6B3...   4.9kB
<missing>           6 days ago          /bin/sh -c echo "deb http://nginx.org/pack...   59.1MB
<missing>           6 days ago          /bin/sh -c ln -sf /dev/stdout /var/log/ngi...   0B
<missing>           6 days ago          /bin/sh -c #(nop)  EXPOSE 443/tcp 80/tcp        0B
5766334bdaa0        6 days ago          /bin/sh -c #(nop)  CMD ["nginx" "-g" "daem...   0B
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
~~~

The second to last command (`EXPOSE 443/tcp 80/tcp`) shows us, that both port 80 and 443 are exposed if the container is started. If we want to start the container we have to map the port from the container to a port on our server. We are going to use port 8080 for that. Start the container with the `-p 8080:80` option. Also we would like to run the container in the background (detached) so we're also going the use the `-d` option:

~~~
docker run -d -p 8080:80 nginx
~~~

To see if the container is started, use the `docker ps` command:

~~~
docker ps
~~~

Output should look similar to the following:

~~~
[root@docker1 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                           NAMES
72704c70c651        nginx               "nginx -g 'daemon ..."   3 seconds ago       Up 3 seconds        443/tcp, 0.0.0.0:8080->80/tcp   musing_engelbart
~~~

If you take a look at the PORTS column you see that port 8080 on our server is mapped to port 80 of our running container. Port 443 of the container is not mapped to any port of our server and this would make our webserver unavailable via https. 

To check if our webserver is really functioning, use the `curl` command to see the web content:

~~~
[root@docker1 ~]# curl -s localhost:8080 |html2text
# Welcome to nginx!

If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.

For online documentation and support please refer to
[nginx.org](http://nginx.org/).
Commercial support is available at [nginx.com](http://nginx.com/).

_Thank you for using nginx._
~~~

To stop the current running container, use the `docker kill` command. First get the CONTAINER ID of the container with the `docker ps` command:

~~~
[root@docker1 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                           NAMES
72704c70c651        nginx               "nginx -g 'daemon ..."   11 minutes ago      Up 11 minutes       443/tcp, 0.0.0.0:8080->80/tcp   musing_engelbart
~~~

In the example above the CONTAINER ID is 72704c70c651. To stop this container use the command `docker kill <CONTAINER ID>`:

~~~
docker kill 72704c70c651
~~~

If you run the command `docker ps` again, it will no longer show the nginx container:

~~~
[root@docker1 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
~~~

If you want to show containers that are still there, but currently not running, use the `docker ps` with the `-a` option:

~~~
[root@docker1 ~]# docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                            PORTS               NAMES
72704c70c651        nginx               "nginx -g 'daemon ..."   15 minutes ago      Exited (137) About a minute ago                       musing_engelbart
573d9dc2b687        hello-world         "/hello"                 About an hour ago   Exited (0) About an hour ago                          sad_snyder
~~~

If you want to get rid of all containers that are stopped, you can use the `docker container prune` command:

~~~
[root@docker1 ~]# docker container prune
WARNING! This will remove all stopped containers.
Are you sure you want to continue? [y/N] y
Deleted Containers:
72704c70c651b33fdff9fefdce55b31896ea2a371650fc252ddfc98e20befd70
573d9dc2b68764604f874912c74a3d312b235715061fbd260aa21bf3a678097e

Total reclaimed space: 2B
~~~

If a container has written a lot of stuff on the filesystem, this could save some space on the harddrive.

It's also possible to let Docker handle the port forwarding with regards to portnumbers. Just start the container with the `-P` option:

~~~
docker run -d -P nginx
~~~

If you run the command above and take a look at the container again, you will see that Docker assigned random ports to both exposed ports from the image:

~~~
[root@docker1 ~]# docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                           NAMES
b536b88f3274        nginx               "nginx -g 'daemon ..."   3 seconds ago       Up 3 seconds        0.0.0.0:32769->80/tcp, 0.0.0.0:32768->443/tcp   jolly_galileo
~~~

The website should now be available at http://localhost:32769:

~~~
[root@docker1 ~]# curl -s http://localhost:32769 |html2text |tail -2
_Thank you for using nginx._
~~~

## Getting more information about a container

If you want to get more info about the container you can use the `docker inspect` command. This gives you all the information there is about the container:

~~~
[root@docker1 ~]# docker inspect b536b88f3274
[
    {
        "Id": "b536b88f327478168e5dc155f0014859296a3caa448cdd260bbb636af3bfd054",
        "Created": "2017-04-12T17:54:29.470487433Z",
        "Path": "nginx",
        "Args": [
            "-g",
            "daemon off;"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 29193,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2017-04-12T17:54:29.626689711Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:5766334bdaa0bc37f1f0c02cb94c351f9b076bcffa042d6ce811b0fd9bc31f3b",
        "ResolvConfPath": "/var/lib/docker/containers/b536b88f327478168e5dc155f0014859296a3caa448cdd260bbb636af3bfd054/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/b536b88f327478168e5dc155f0014859296a3caa448cdd260bbb636af3bfd054/hostname",
        "HostsPath": "/var/lib/docker/containers/b536b88f327478168e5dc155f0014859296a3caa448cdd260bbb636af3bfd054/hosts",
        "LogPath": "/var/lib/docker/containers/b536b88f327478168e5dc155f0014859296a3caa448cdd260bbb636af3bfd054/b536b88f327478168e5dc155f0014859296a3caa448cdd260bbb636af3bfd054-json.log",
        "Name": "/jolly_galileo",
        "RestartCount": 0,
        "Driver": "overlay",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "CapAdd": null,
            "CapDrop": null,
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": true,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": null,
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DiskQuota": 0,
            "KernelMemory": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": -1,
            "OomKillDisable": false,
            "PidsLimit": 0,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0
        },
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay/e0214ced91db1af11fc0a377641725478a58cb1919e5916fbbbf54233a71b2bb/root",
                "MergedDir": "/var/lib/docker/overlay/389f9d34c3b5c1e7ce7f193f747acc659db07415c41d15e738ce0f06a974a906/merged",
                "UpperDir": "/var/lib/docker/overlay/389f9d34c3b5c1e7ce7f193f747acc659db07415c41d15e738ce0f06a974a906/upper",
                "WorkDir": "/var/lib/docker/overlay/389f9d34c3b5c1e7ce7f193f747acc659db07415c41d15e738ce0f06a974a906/work"
            },
            "Name": "overlay"
        },
        "Mounts": [],
        "Config": {
            "Hostname": "b536b88f3274",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "443/tcp": {},
                "80/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.11.13-1~jessie"
            ],
            "Cmd": [
                "nginx",
                "-g",
                "daemon off;"
            ],
            "ArgsEscaped": true,
            "Image": "nginx",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {}
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "0990cb2ce8a0ad16083878e27e522c89fa05ac237014e3e010aa5a24e3e36b88",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {
                "443/tcp": [
                    {
                        "HostIp": "0.0.0.0",
                        "HostPort": "32768"
                    }
                ],
                "80/tcp": [
                    {
                        "HostIp": "0.0.0.0",
                        "HostPort": "32769"
                    }
                ]
            },
            "SandboxKey": "/var/run/docker/netns/0990cb2ce8a0",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "cc797527a6cd8b514652e6f24744b13e1bbb7b2a08b30a1635fe831ff1b1756f",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "f3281122e1297bc28d90b1254d16a93097a1c65542bac0869fad86e7fd399576",
                    "EndpointID": "cc797527a6cd8b514652e6f24744b13e1bbb7b2a08b30a1635fe831ff1b1756f",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02"
                }
            }
        }
    }
]
~~~

If you just want to know some specific information you can pick out any field from the JSON output. Some examples are:

~~~
[root@docker1 ~]# docker inspect --format='{{.Id}}' b536b88f3274
b536b88f327478168e5dc155f0014859296a3caa448cdd260bbb636af3bfd054

[root@docker1 ~]# docker inspect --format='{{.Name}}' b536b88f3274
/jolly_galileo

[root@docker1 ~]# docker inspect --format='{{.NetworkSettings.Ports}}' b536b88f3274
map[443/tcp:[{0.0.0.0 32768}] 80/tcp:[{0.0.0.0 32769}]]
~~~

## Show logging of a process which is running inside a container

An application might generate logging, but since there's only one process running inside the container most of the time logfiles are written to stout and sterr. This is also the case for out nginx image. See the link that was created during the creation of the image:

~~~
<missing>                                                                 6 days ago          /bin/sh -c ln -sf /dev/stdout /var/log/nginx/access.log  && ln -sf /dev/stderr /var/log/nginx/error.log
~~~

We can take a look at the logfiles with the `docker logs` command:

~~~
[root@docker1 ~]# docker logs b536b88f3274
172.17.0.1 - - [12/Apr/2017:17:56:53 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.29.0" "-"
172.17.0.1 - - [12/Apr/2017:17:57:04 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.29.0" "-"
172.17.0.1 - - [12/Apr/2017:17:57:06 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.29.0" "-"
~~~

