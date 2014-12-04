#!/usr/bin/env bash

error_exit(){
    echo $1
    exit 1
}

[ -n "${bamboo_DOCKER_BUILDER}" ] || error_exit "bamboo_DOCKER_BUILDER required"
[ -n "${IMAGE_NAME}" ] || error_exit "IMAGE_NAME required"

docker --tlsverify \
  --tlscacert=/home/bamboo/.docker/ca.pem \
  --tlscert=/home/bamboo/.docker/cert.pem \
  --tlskey=/home/bamboo/.docker/key.pem \
  --host ${bamboo_DOCKER_BUILDER} \
  build --tag=${IMAGE_NAME} . || \
  error_exit "Failed to build image"

docker --tlsverify \
  --tlscacert=/home/bamboo/.docker/ca.pem \
  --tlscert=/home/bamboo/.docker/cert.pem \
  --tlskey=/home/bamboo/.docker/key.pem \
  --host ${bamboo_DOCKER_BUILDER} \
  push ${IMAGE_NAME} || \
  error_exit "Unable to push image to DockerHub"
