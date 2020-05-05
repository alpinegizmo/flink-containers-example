This is an example of how to run an Apache Flink application in a containerized environment, using either docker compose or kubernetes.

minio, an s3-compatible filesystem, is used for checkpointing.

zookeeper is used for high availability.

## Prerequisites

You'll need docker and kubernetes to run this example. 
It has been tested with Docker Desktop for Mac, Version 2.2.0.3 (42716), with Kubernetes enabled, using the docker-for-desktop context.

This example depends on FLINK-10817, added in Flink 1.8.0. 

## Build a docker image

To begin, you'll need to build a job-specific docker image by doing these two steps:

~~~ bash
make jar
make image
~~~

You will need the resulting image for any of the following approaches for running this job.

## Run with docker-compose

You can run this job using docker-compose via `make run`, which is equivalent to

    FLINK_JOB=com.ververica.example.StreamingJob \
    FLINK_JOB_ARGUMENTS='' \
    docker-compose -f docker/docker-compose.yml up -d \
    job-cluster minio-service taskmanager miniosetup zoo1
    
The flink dashboard is then available at http://localhost:8081 and 
you will find the minio filesystem browser at http://localhost:9000.

    make stop
    
will tear that all down.

## Run with kubectl

	cd kubernetes
	make run
	
The flink dashboard will be at http://localhost:30081, and the minio browser will be at http://localhost:30090.

To bring it all down, use

    make stop

## Is this production-ready?

No. At a minimum you should take care of these things:

* imagePullPolicy: Never
* minio and zookeeper should be run as clusters, rather than in single server mode
* use k8s namespaces

Plus the usual getting-your-flink-job-ready-for-production topics, such as:

* UIDs on the stateful operators
