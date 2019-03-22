##|-----------------------------------------------------------------|
##| Minimal makefile for building and running dockerized flink jobs |
##|-----------------------------------------------------------------|
##| Variables                                                       |
##|-----------------------------------------------------------------|
##

JAR = target/streaming-job-*.jar

FLINK_VERSION  = 1.8.0
HADOOP_VERSION = NONE
SCALA_VERSION  = 2.11
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
		--from-url "https://dist.apache.org/repos/dist/dev/flink/flink-1.8.0-rc2/flink-1.8.0-bin-scala_$(SCALA_VERSION).tgz" \
		--image-name streaming-job:latest

image-from-archive:
	./docker/flink/build.sh --job-jar $(JAR) \
		--from-archive ~/Downloads/flink-1.8.0-bin-scala_2.11.tgz \
		--image-name streaming-job:latest

image-from-release:
	./docker/flink/build.sh --job-jar $(JAR) \
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

logs: 		## shows jobmanager logs
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker-compose -f docker/docker-compose.yml logs -f job-cluster

k8s:            ## run the image with kubernetes
	FLINK_JOB=$(JOB) FLINK_JOB_ARGUMENTS=$(ARGS) docker stack deploy --orchestrator=kubernetes -c docker/docker-compose.yml streaming-job
