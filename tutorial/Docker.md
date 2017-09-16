# Aim

Aim of this page is to give a basic explanation on how is possible to build this project using docker

### Credits

Most of what I've done in the Docker builder part is inspired to mgreenly work

https://github.com/mgreenly/dockerimages

### Convention

Let us call **project directory** the one containing  **Application.hs**, the root of this repository.

### Creation of a Docker image to build

In `deploy/docker-stack-builder` is present a Dockerfile from which is possible to create a docker image, based on debian, that contains a working installation of stack and ghc. This image can be used to build the project.

From *project directory*

```bash
cd deploy/docker-stack-builder
```

Here we can inspect the Dockerfile

```yaml
FROM debian:latest  # starting from debian official image

# create project directory, 
# install stack and haskell-platform, used to compile a project with system-ghc
RUN DEBIAN_FRONTEND=noninteractive \
    && mkdir /project \
    && apt-get update  \
    && apt-get install -my wget gnupg  \
    && cd /tmp \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 575159689BEFB442 \
    && echo 'deb http://download.fpcomplete.com/debian jessie main' | tee /etc/apt/sources.list.d/fpco.list \
    && apt-get -q -y update \
    && apt-get \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        -q -y install \
        libncursesw5-dev \
        stack \
        git \
        haskell-platform

WORKDIR /project
```

We can create a docker image doing ```bash docker build -t debian-stack-edo . ```

With *debian-stack-edo* we can build our source (I called like this after my name, but off course any name is good provided to be consistent) . 

The command  ```docker images``` should output *debian-stack-edo* among others, if no errors occurred.



### Building HaskDragon source

From *project directory*

```bash
./restore-docker-yaml  

docker run
   -v `pwd`:/project  
   -v `pwd`/automation/docker-setup:/root/.stack
   debian-stack-edo stack build --system-ghc
```


We can break this command in parts:

- `restore-docker-yaml`  is  a bash script used to put in proejct directory the stack.yaml suitable for the docker builder. This file ask for resolver to be ghc-8.0.1, the same installed on the docker-builder. In that file are also added the build dependencies

   It is, basically, nothing more then

   ```bash
   rm stack*.yaml
   cp automation/deploy/stack-originals/stack-dock.yaml stack.yaml
   ```

   ​

-  `docker run -v $PWD:/project` is used to link project folder on guest to current directory, to easily access
  the binary file produced by stack

-  `-v  $PWD/automation/docker-setup:/root/.stack`   is used to cache stack files, this speed up the build process

-  `debian-stack-edo`  docker name produced with the above command

-  `stack build --system-ghc`  build using locally installed stack: on the guest system

   ​


possible output: [...]
Installing executable(s) in
/project/.stack-work/install/x86_64-linux/ghc-8.0.1/8.0.1/bin

[…]

from which we can infer that

*projectDir*/.stack-work/install/x86_64-linux/ghc-8.0.1/8.0.1/bin  
is where the exe **haskdragon-exe** is stored

### Creation of docker image running the App

The haskdragon-exe binary file can be executed by any debian-like linux distribution, provided that some libraries are installed, like libgmp10. (For instance this can run without problems on Ubuntu Server 16)

To create a docker image and running the app the *haskdragon-exe* file should be copied in *automation/deploy*

From *projectDir*

```cp .stack-work/install/x86_64-linux/ghc-8.0.1/8.0.1/bin/haskdragon-exe  automation/deploy
   cd automation/deploy         
```

The Dockerfile should be straight-forward

```yaml
# Use an official Debian runtime as a parent image
FROM debian:latest

# Set the working directory to /app
WORKDIR /app

# Copy the binary haskdragon-exe into the container at /app
ADD ./haskdragon-exe /app

# install the minimum libraries the bin will need to run
RUN DEBIAN_FRONTEND=noninteractive                    \
    apt-get -q -y update                              \
    && apt-get                                        \
      -o Dpkg::Options::="--force-confdef"            \
      -o Dpkg::Options::="--force-confold"            \
      -q -y install                                   \
      libgmp10                                        \
    && apt-get install --reinstall libffi6            \
    && apt-get clean                                  \
    && rm -rf /var/lib/apt/lists/*

# Make ports 3000 available to the world outside this container
EXPOSE 3000


# Run haskdragon-exe when the container launches
CMD ./haskdragon-exe
```

We can create a docker image able to run our web-server app doing:

```docker build -t haskdragon .```

Then it is possible to tag it

```bash
docker tag haskdragon edoardo90/haskdragon:latest
```

and eventually to push it on a Docker repository

```bash
docker push edoardo90/haskdragon:latest
```

As in the previous paragraph *edoardo90* is my repository on Docker Cloud.

It is possible to try this image running ```docker run -d -p 3000:3000 edoardo90/haskdragon:latest```, 

this will launch the image in detached mode.

If everythig worked it should be possible to run ``` curl localhost:3000``` and see the home page responding correctly.



### Deploying 

To understand how to create and deploy  a docker application I read [Docker getting started](https://docs.docker.com/get-started/) guide, which I will give as granted in this paragraph.

In *project directory* is located build-digitaloc-dock.sh, it is used to build the project and to deploy it on DigitalOcean ([https://www.digitalocean.com/](https://www.digitalocean.com/)).

I used Digital Ocean but the same approach can be used to any remote machine we control.

The first lines reproduce what we have described in previous paragraphs: build the project, move the bin,  create a docker image to hold it and run it, tag and push the image

```
cp .stack-work/install/x86_64-linux/ghc-8.0.1/8.0.1/bin/haskdragon-exe automation/deploy
docker build -t haskdragon automation/deploy
docker tag haskdragon edoardo90/haskdragon:latest
docker push edoardo90/haskdragon:latest
```

The second part is to push *docker-compose.yml* on DigitalOcean machine, via ssh


```
scp automation/docker-stack-builder/docker-compose.yml root@$DIGITALOCEAN_MACHINE:~
ssh root@$DIGITALOCEAN_MACHINE mkdir -p ./data
```

Fort the first deploy is also needed a command to add the machine to the *swarm*

```ssh root@$DIGITALOCEAN_MACHINE docker swarm init --advertise-addr 10.12.0.5```

the  *—advertis-add* option is not mandatory but I needed it

The last step is to launch the *stack deploy* command on the remote machine to have it creating services according to the docker-compose yaml

```
ssh root@ssh root@$DIGITALOCEAN_MACHINE "docker stack deploy -c docker-compose.yml hsdragonSwarm" "docker stack deploy -c docker-compose.yml hsdragonSwarm"
```

