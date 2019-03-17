##|-----------------------------------------------------------------|
##| Minimal makefile for building and running dockerized flink jobs |
##|-----------------------------------------------------------------|
##| Variables                                                       |
##|-----------------------------------------------------------------|
##

JAR = target/streaming-job-*.jar

FLINK_VERSION  = 1.8.0      ## set the flink version for the image
HADOOP_VERSION = NONE       ## set the hadoop version for the image (set to NONE for a Hadoop-free Flink build)
SCALA_VERSION  = 2.11       ## set the scala version for the image
JOB            = com.ververica.example.StreamingJob
ARGS           = ''

##
##|-----------------------------------------------------------------|
##| Commands                                                        |
##|-----------------------------------------------------------------|
##

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

.PHONY: jar
jar:
	mvn clean package

image: 		## build a flink image for job mode
	./docker/flink/build.sh --job-jar $(JAR) \
		--from-archive ~/Downloads/flink-1.8.0-bin-scala_2.11.tgz \
		--hadoop-version $(HADOOP_VERSION) \
		--scala-version $(SCALA_VERSION) \
		--image-name streaming-job:latest

run:            ## run the image with docker-compose
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker/docker-compose-up.sh

k8s:            ## run the image with kubernetes
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker stack deploy --orchestrator=kubernetes -c docker/docker-compose.yml streaming-job

status: 	## check the status of the running components
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker-compose -f docker/docker-compose.yml ps

stop: 		## stop all components of the job
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker-compose -f docker/docker-compose.yml down -v

logs: 		## shows jobmanager logs
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker-compose -f docker/docker-compose.yml logs -f job-cluster
