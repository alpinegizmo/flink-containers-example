##|-----------------------------------------------------------------|
##| Minimal makefile for building and running dockerized flink jobs |
##|-----------------------------------------------------------------|
##| Variables                                                       |
##|-----------------------------------------------------------------|
##

JAR = target/streaming-job-*.jar

FLINK_VERSION  = 1.10.0
HADOOP_VERSION = NONE
SCALA_VERSION  = 2.12
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

image:
	./docker/flink/build.sh --job-artifacts $(JAR) \
		--from-archive ~/Downloads/flink-$(FLINK_VERSION)-bin-scala_$(SCALA_VERSION).tgz \
		--image-name streaming-job:latest

image-from-release:
	./docker/flink/build.sh --job-artifacts $(JAR) \
		--from-release \
		--flink-version $(FLINK_VERSION) \
		--hadoop-version $(HADOOP_VERSION) \
		--scala-version $(SCALA_VERSION) \
		--image-name streaming-job:latest

run:        	## run the image with docker-compose
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker/docker-compose-up.sh

status: 	## check the status of the running components
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker-compose -f docker/docker-compose.yml ps

stop: 		## stop all components of the job
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker-compose -f docker/docker-compose.yml down -v

jm-logs: 		## shows jobmanager logs
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker-compose -f docker/docker-compose.yml logs -f job-cluster

tm-logs: 		## shows jobmanager logs
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker-compose -f docker/docker-compose.yml logs -f taskmanager

k8s:            ## run the image with kubernetes
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker stack deploy --orchestrator=kubernetes -c docker/docker-compose.yml streaming-job
