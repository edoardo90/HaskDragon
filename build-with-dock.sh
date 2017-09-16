echo "./restore-docker-yaml"
./restore-docker-yaml

echo "docker run
      -v /Users/edoardo/Documents/programming/skillbill/HaskDragon:/project
      -v /Users/edoardo/Documents/programming/skillbill/HaskDragon/automation/docker-setup:/root/.stack
      debian-stack-edo stack build --system-ghc"
docker run    -v $HASKDRAGON_HOME:/project  -v $HASKDRAGON_HOME/automation/docker-setup:/root/.stack \
 debian-stack-edo stack build --system-ghc

echo "cp .stack-work/install/x86_64-linux/ghc-8.0.1/8.0.1/bin/haskdragon-exe automation/deploy"
cp .stack-work/install/x86_64-linux/ghc-8.0.1/8.0.1/bin/haskdragon-exe automation/deploy


echo "docker build -t haskdragon automation/deploy"
docker build -t haskdragon automation/deploy

echo "docker tag haskdragon edoardo90/haskdragon:latest"
docker tag haskdragon edoardo90/haskdragon:latest

echo "docker push edoardo90/haskdragon:latest"
docker push edoardo90/haskdragon:latest

echo "docker-machine scp automation/docker-stack-builder/docker-compose.yml myvm1:~"
docker-machine scp automation/docker-stack-builder/docker-compose.yml myvm1:~

echo 'docker-machine ssh myvm1 "mkdir -p ./data && docker stack deploy -c docker-compose.yml hsdragonSwarm"'
docker-machine ssh myvm1 "mkdir -p ./data && docker stack deploy -c docker-compose.yml hsdragonSwarm"
