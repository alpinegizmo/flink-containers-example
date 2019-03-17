#!/usr/bin/env bash
DIR=$(dirname $0)

CORE_SERVICES="job-cluster minio-service taskmanager miniosetup zoo1"

docker-compose -f $DIR/docker-compose.yml up -d $CORE_SERVICES