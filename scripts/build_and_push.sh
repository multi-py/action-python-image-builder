#!/usr/bin/env bash
set -e

if [[ -z $PYTHON_VERSION ]]; then
  echo "Must set a python version to build."
  exit 1
fi

# Version- the python version itself (3.7, 3.8, 3.9.7, etc)
# Build Target - the upstream container to use during the building stage
# Publish Target - the upstream container to use for the final stage

# Package Version -
# Package -

# REPO/image:py3.7-0.2.1
# REPO/image:py3.7-slim-0.2.1
# REPO/image:py3.7-alpine-0.2.1

if [[ $TARGET_BASE = "full" ]]; then
  TARGET_BASE=""
fi

# Set image PUBLISH_TARGET version- ie, 3.9-slim.
if [[ ! -z $TARGET_BASE ]]; then
  PUBLISH_TARGET=$PYTHON_VERSION-$TARGET_BASE
else
  PUBLISH_TARGET=$PYTHON_VERSION
fi

# Set build environment
if [[ $PUBLISH_TARGET =~ "alpine" ]]; then
  # Alpine is the odd one out- everything else is ubuntu.
  # So the build environment has to also be alpine.
  BUILD_TARGET=$PUBLISH_TARGET
else
  # Every other image should use the full container for builds.
  BUILD_TARGET=$PYTHON_VERSION
fi


# Image Push location
REGISTRY=${REGISTRY:-"ghcr.io"}
IMAGE_REPOSITORY=${IMAGE_NAME:-$GITHUB_REPOSITORY}
IMAGE_LOCATION=$REGISTRY/$IMAGE_REPOSITORY

TAG="$IMAGE_LOCATION:py${PUBLISH_TARGET}-${PACKAGE_VERSION}"

TAGS="  -t $TAG"
if [[ ! -z $PACKAGE_LATEST_VERSION ]] && [[ $PACKAGE_LATEST_VERSION = $PACKAGE_VERSION ]]; then
  TAGS+="\n  -t $IMAGE_LOCATION:py${PUBLISH_TARGET}-LATEST"
fi


echo Building and pushing $TAG
echo Python Version: $PYTHON_VERSION
echo Publish Target: $PUBLISH_TARGET
echo Build Target: $BUILD_TARGET

echo "Setting buildx builder."
# Create or Reuse buildx builder
docker buildx use $BUILDX_NAME

echo "Beginning build."
# Display docker command for debugging
echo docker buildx build \
  --platform $PLATFORM \
  $TAGS \
  --build-arg "python_version=$PYTHON_VERSION" \
  --build-arg "publish_target=$PUBLISH_TARGET" \
  --build-arg "build_target=$BUILD_TARGET" \
  --build-arg "packages=$PACKAGE" \
  --build-arg "package_version=$PACKAGE_VERSION" \
  --build-arg "maintainer=$MAINTAINER" \
  -f ${DOCKERFILE_LOCATION:-./dockerfile} \
  --push \
  ${DOCKER_BUILD_PATH:-.}


docker buildx build \
  --platform $PLATFORM \
  $TAGS \
  --build-arg "python_version=$PYTHON_VERSION" \
  --build-arg "publish_target=$PUBLISH_TARGET" \
  --build-arg "build_target=$BUILD_TARGET" \
  --build-arg "packages=$PACKAGE" \
  --build-arg "package_version=$PACKAGE_VERSION" \
  --build-arg "maintainer=$MAINTAINER" \
  -f ${DOCKERFILE_LOCATION:-./dockerfile} \
  --push \
  ${DOCKER_BUILD_PATH:-.}
