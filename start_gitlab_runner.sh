#!/usr/bin/env bash

#
# Starts a container with GitLab Runner
# Doc:
# - https://docs.gitlab.com/runner/install/docker.html#run-gitlab-runner-in-a-container
# - https://docs.gitlab.com/ce/ci/docker/using_docker_images.html#register-docker-runner
#

set -e

#
# Input
#

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

export GITLAB_REGISTRATION_TOKEN=$1


#
# Const
#

export GITLAB_URL=https://gitlab.com/
export DOCKER_IMAGE_BUILDER=ruby:2.1
export GITLAB_RUNNER_TAG_LIST=swarm-manager
export GITLAB_RUNNER_CONCURRENCY=1
export RUNNER_NAME=`hostname`-mgr

DOCKER_IMAGE_GITLAB=gitlab/gitlab-runner:alpine
# DOCKER_IMAGE_GITLAB=gitlab/gitlab-runner:latest

CONTAINER_NAME=gitlab-runner-mgr


#
# Main
#

echo Pulling latest version of the runner ...
docker pull $DOCKER_IMAGE_GITLAB

echo Starting container ...
docker run -d --name $CONTAINER_NAME -v /var/run/docker.sock:/var/run/docker.sock $DOCKER_IMAGE_GITLAB

echo Registering the runner ...
# See: https://docs.gitlab.com/ce/ci/docker/using_docker_images.html#register-docker-runner
docker exec -it $CONTAINER_NAME gitlab-runner register \
    --non-interactive --name $RUNNER_NAME --url $GITLAB_URL --registration-token $GITLAB_REGISTRATION_TOKEN \
    --executor docker --docker-image $DOCKER_IMAGE_BUILDER --tag-list $GITLAB_RUNNER_TAG_LIST \
    --request-concurrency=$GITLAB_RUNNER_CONCURRENCY  # --docker-volumes-from $CONTAINER_NAME

echo Smoke Testing runner ...
docker exec $CONTAINER_NAME gitlab-runner --version
