#!/usr/bin/env bash

error_exit() {
  echo $1
  exit 1
}

_container_ids() {
  docker ps -aq
}

_get_image_name() {
  docker inspect -f '{{.Config.Image}}' $1 | sed -e 's/:.*$//'
}

[ -n "${DOCKER_IMAGE}" ] || error_exit "DOCKER_IMAGE is required"
[ -n "${bamboo_HOST_PORT}" ] || error_exit "bamboo_HOST_PORT is required"
[ -n "${bamboo_CONTAINER_PORT}" ] || error_exit "bamboo_CONTAINER_PORT is required"
[ -n "${bamboo_APP_ENV}" ] || error_exit "bamboo_APP_ENV is required"
[ -n "${bamboo_DOCKER_HOST}" ] || error_exit "bamboo_DOCKER_HOST is required"
[ -n "${bamboo_DOCKERHUB_EMAIL}" ] || error_exit "bamboo_DOCKERHUB_EMAIL is required"
[ -n "${bamboo_DOCKERHUB_USERNAME}" ] || error_exit "bamboo_DOCKERHUB_USERNAME is required"
[ -n "${bamboo_DOCKERHUB_PASSWORD}" ] || error_exit "bamboo_DOCKERHUB_PASSWORD is required"

export DOCKER_HOST=${bamboo_DOCKER_HOST}

echo email ${bamboo_DOCKERHUB_EMAIL}
echo password ${bamboo_DOCKERHUB_PASSWORD}
echo username ${bamboo_DOCKERHUB_USERNAME}

docker login \
  --email ${bamboo_DOCKERHUB_EMAIL} \
  --username ${bamboo_DOCKERHUB_USERNAME} \
  --password ${bamboo_DOCKERHUB_PASSWORD} || \
  error_exit "Failed to login to DockerHub"

for container_id in $(_container_ids)
do
  filtered_image_name=$(echo ${DOCKER_IMAGE} | sed -e 's/:.*$//')
  if [ "${filtered_image_name}" == "$(_get_image_name $container_id)" ]; then
    echo "Stopping container ${container_id}"
    docker stop $container_id > /dev/null
    docker rm $container_id > /dev/null
  fi
done

docker run --detach \
  --publish ${bamboo_HOST_PORT}:${bamboo_CONTAINER_PORT} \
  --env "CATALINA_OPTS='-Dgrails.env=${bamboo_APP_ENV}'" \
  --env "JAVA_OPTS=-Xmx512m -XX:MaxPermSize=256m" \
  ${DOCKER_IMAGE} || error_exit "Failed to start container"
