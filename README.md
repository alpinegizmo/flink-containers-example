## Prerequisites

You'll need docker and kubernetes to run this example. 
It has been tested with Docker Desktop for Mac, Version 2.0.0.3 (31259), with Kubernetes enabled, using the docker-for-desktop context.

This example depends on FLINK-10817, added in Flink 1.8.0. 
The Makefile and pom.xml will need to be updated when Flink 1.8.0 is released.

## Build a docker image

To begin, you'll need to build a docker image by doing these two steps:

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

## Run with docker stack

Docker Desktop and Docker Enterprise include compose-on-kubernetes, making it possible to run the docker compose script as a docker stack, using kubernetes as the orchestrator.

    FLINK_JOB=com.ververica.example.StreamingJob FLINK_JOB_ARGUMENTS='' \
    docker stack deploy --orchestrator=kubernetes -c docker/docker-compose.yml streaming-job
    
To stop everything, use

    kubectl delete stack streaming-job

Once again the flink dashboard will be at http://localhost:8081 and 
the minio filesystem browser will be available at http://localhost:9000.

## Run with kubectl

	cd kubernetes
	make run
	
The flink dashboard will be at http://localhost:30081, and the minio browser will be at http://localhost:30090.

To bring it all down, use

    make stop
