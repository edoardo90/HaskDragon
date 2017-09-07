install docker on alpine:

# 1) install alpine on vbox

https://wiki.alpinelinux.org/wiki/Install_Alpine_on_VirtualBox
https://www.youtube.com/watch?v=RQXpmzVS804

caveats:
  alpine-setup ->
	sys when asked for hard disk
	in VBOX select a second network adapter and set it to bridge

https://wiki.alpinelinux.org/wiki/Docker

# 2) install docker al alpine

https://wiki.alpinelinux.org/wiki/Docker

Run `apk add docker` to install Docker on Alpine Linux.

The Docker package is in the 'Community' repository, so if the apk add fails with unsatisfiable constraints, you need to edit the **/etc/apk/repositories** file to add (or uncomment) a line like:

http://dl-cdn.alpinelinux.org/alpine/edge/community

then run 

```
apk update
```

 to index the repository.


To start the Docker daemon at boot, run:

```
 rc-update add docker boot 
```


Then to start the Docker daemon manually, run:

```
service docker start
```