echo "./restore-docker-yaml"
./restore-docker-yaml

docker run   \
  -v $HASKDRAGON_HOME:/project  \
  -v $HASKDRAGON_HOME/automation/docker-setup:/root/.stack \
  debian-stack-edo stack build --system-ghc

echo "cp .stack-work/install/x86_64-linux/ghc-8.0.1/8.0.1/bin/haskdragon-exe automation/deploy"
cp .stack-work/install/x86_64-linux/ghc-8.0.1/8.0.1/bin/haskdragon-exe automation/deploy


echo "docker build -t haskdragon automation/deploy"
docker build -t haskdragon automation/deploy

echo "docker tag haskdragon edoardo90/haskdragon:latest"
docker tag haskdragon edoardo90/haskdragon:latest

echo "docker push edoardo90/haskdragon:latest"
docker push edoardo90/haskdragon:latest

# ssh-add
# just first time  ssh root@$DIGITALOCEAN_MACHINE docker swarm init --advertise-addr 10.12.0.5

echo "scp automation/docker-stack-builder/docker-compose.yml root@$DIGITALOCEAN_MACHINE:~"
scp automation/docker-stack-builder/docker-compose.yml root@$DIGITALOCEAN_MACHINE:~

echo "ssh root@$DIGITALOCEAN_MACHINE mkdir -p ./data"
ssh root@$DIGITALOCEAN_MACHINE mkdir -p ./data

echo 'ssh root@ssh root@$DIGITALOCEAN_MACHINE "docker stack deploy -c docker-compose.yml hsdragonSwarm" "docker stack deploy -c docker-compose.yml hsdragonSwarm"'
ssh root@ssh root@$DIGITALOCEAN_MACHINE "docker stack deploy -c docker-compose.yml hsdragonSwarm" "docker stack deploy -c docker-compose.yml hsdragonSwarm"
