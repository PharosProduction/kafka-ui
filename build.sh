#!/usr/bin/env bash

ORGANIZATION="dmytronasyrov"
DOCKER_REPO="kafka-ui"
DATE="21-11-23"
VERSION="1"

VCS_URL="https://github.com/PharosProduction/kafka-ui"
VCS_BRANCH="kafka/master"
VCS_REF="40charsSHA-1hashOfCommit"

docker buildx stop
docker buildx create --use --name serverbuilder --node serverbuilder0 --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=1073741824

################################################################################

BASE_IMAGE="dmytronasyrov/maven:14-10-23-1"

docker rmi BASE_IMAGE

docker buildx build \
  --build-arg builder_image=BASE_IMAGE \
  --build-arg build_date=$DATE \
  --build-arg vcs_url=$VCS_URL \
  --build-arg vcs_branch=$VCS_BRANCH \
  --build-arg vcs_ref=$VCS_REF \
  --platform linux/amd64 \
  -f Dockerfile \
  --progress plain \
  --push \
  -t $ORGANIZATION/$DOCKER_REPO:$DATE-$VERSION \
  .

################################################################################

docker buildx stop
