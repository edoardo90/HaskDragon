# Aim 

Aim of this page is to give a basic explanation on how is possible to build this project using docker

### Credits

Most of what I've done is inspired to mgreenly work

https://github.com/mgreenly/dockerimages

### Creation of a Docker image to build 

In `deploy/docker-stack-builder` is present a Dockerfile from which is possible to create a docker image, based on debian, that contains a working installation of stack and ghc. This image can be used to build the project

From **project directory**

```bash
cd deploy/docker-stack-builder
docker build -t debian-stack-edo .
```



### Building HaskDragon source

Let us call **project directory** the one containing  **Application.hs**, the root of this repository

From **project directory**

```bash
./restore-docker-yaml   docker run \
   -v `pwd`:/project  \
   -v `pwd`/automation/docker-setup:/root/.stack \  
   debian-stack-edo stack build --system-ghc  | grep "Installing executable(s) in" -B 2 -A 2
```

We can break this command in parts:

- `restore-docker-yaml`  is  a bash script used to put in proejct directory the stack.yaml suitable for the docker builder. This file ask for resolver to be ghc-8.0.1, the same installed on the docker-builder. In that file are also added the build dependencies

-  `docker run -v $PWD:/project` is used to link project folder on guest to current directory, to easily access
  the binary file produced by stack

-  `-v  $PWD/automation/docker-setup:/root/.stack`   is used to cache stack files, this speed up the build process

-  `debian-stack-edo`  docker name produced with the above command

-  `stack build --system-ghc`  build using locally installed stack: on the guest system

-  ` | grep "Installing executable(s) in"  -A 1 `  print directory in which is installed the binary
