#!/bin/bash

# Performs any provisioning needed for a clean build.
#
# This script is meant to be used either directly
# as a `before_install` step such that the next step
# in the Travis build have the environment properly
# setup.
#
# The script is also handy for debugging - SSH into
# the machine and then call `./.travis/main.sh` to
# have all dependencies set.

set -o errexit

main() {
  setup_dependencies

  echo "INFO:
  Done! Finished setting up Travis-CI machine.
  "
}

# Takes care of updating any dependencies that the
# machine needs.
setup_dependencies() {
  echo "INFO:
  Setting up dependencies.
  "
  set -x

  # Docker GPG
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  # Docker test for 19.x
  sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   test"


  sudo apt update -y
  #sudo apt install --only-upgrade docker-ce -y

  local docker_version="5:19.03.1~3-0~ubuntu-$(lsb_release -cs)"

  sudo apt-cache madison docker-ce-cli docker-ce
  sudo apt install -y docker-ce=$docker_version docker-ce-cli=$docker_version containerd.io

  # Docker buildx
  mkdir -p ~/.docker/cli-plugins
  wget https://github.com/docker/buildx/releases/download/v0.3.0/buildx-v0.3.0.linux-amd64 -O ~/.docker/cli-plugins/docker-buildx
  chmod a+x ~/.docker/cli-plugins/docker-buildx

  docker buildx create --name mybuilder --use
  docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3
  docker buildx inspect --bootstrap

  docker info
  docker buildx version
}

main
