#!/usr/bin/env bash

error_exit(){
    echo $1
    exit 1
}

[ -n "${bamboo_DOCKERHUB_EMAIL}" ] || error_exit "bamboo_DOCKERHUB_EMAIL Required"
[ -n "${bamboo_DOCKERHUB_USERNAME}" ] || error_exit "bamboo_DOCKERHUB_USERNAME Required"
[ -n "${bamboo_DOCKERHUB_PASSWORD}" ] || error_exit "bamboo_DOCKERHUB_PASSWORD Required"
[ -n "${bamboo_DOCKER_BUILDER}" ] || error_exit "bamboo_DOCKER_BUILDER required"
[ -n "${IMAGE_NAME}" ] || error_exit "IMAGE_NAME required"

docker --host ${bamboo_DOCKER_BUILDER} login \
  --email ${bamboo_DOCKERHUB_EMAIL} \
  --username ${bamboo_DOCKERHUB_USERNAME} \
  --password ${bamboo_DOCKERHUB_PASSWORD} || \
  error_exit "Failed to login to DockerHub"

docker --host ${bamboo_DOCKER_BUILDER} build --tag=${IMAGE_NAME} . || \
  error_exit "Failed to build image"

docker --host ${bamboo_DOCKER_BUILDER} push ${IMAGE_NAME} || \
  error_exit "Unable to push image to DockerHub"
