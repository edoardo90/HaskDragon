FROM debian:latest

#
# create project dir,
# install stack and haskell-platform, used to compile a project with system-ghc
#
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
