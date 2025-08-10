#!/bin/bash

# This script builds the Flutter application with different configurations.
# It takes a single argument, which is the environment to build for.
# The following environments are supported:
#   - dev: Development
#   - staging: Staging
#   - prod: Production

# Set the environment
ENV=$1

# Set the entry point
ENTRY_POINT="lib/main.dart"

# Set the build flags
if [ "$ENV" == "dev" ]; then
  FLAGS="--dart-define=ENV=dev"
elif [ "$ENV" == "staging" ]; then
  FLAGS="--dart-define=ENV=staging"
elif [ "$ENV" == "prod" ]; then
  FLAGS="--dart-define=ENV=prod"
else
  echo "Invalid environment specified. Please use one of the following: dev, staging, prod"
  exit 1
fi

# Build the application
flutter build apk --release $FLAGS --target=$ENTRY_POINT
