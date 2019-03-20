run:
	kubectl create -f zoo1-deployment.yaml
	kubectl create -f zoo1-service.yaml
	kubectl create -f minio-standalone-pvc.yaml
	kubectl create -f minio-standalone-deployment.yaml
	kubectl create -f minio-standalone-service.yaml
	kubectl create -f miniosetup-job.yaml
	kubectl create -f job-cluster-service.yaml
	FLINK_IMAGE_NAME=streaming-job envsubst < job-cluster-job.yaml.template | kubectl create -f -
	FLINK_IMAGE_NAME=streaming-job FLINK_NUM_OF_TASKMANAGERS=1 envsubst < task-manager-deployment.yaml.template | kubectl create -f -

status:
	kubectl get all

stop:
	- kubectl delete deployment zoo1
	- kubectl delete service zoo1
	- kubectl delete deployment minio
	- kubectl delete job miniosetup
	- kubectl delete pvc minio-pv-claim
	- kubectl delete svc minio-service
	- kubectl delete job flink-job-cluster
	- kubectl delete deploy flink-task-manager
	- kubectl delete service flink-job-cluster
