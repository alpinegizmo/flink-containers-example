run:
#	kubectl create -f zoo1-deployment.yaml
#	kubectl create -f zoo1-service.yaml
	kubectl create -f minio-standalone-pvc.yaml
	kubectl create -f minio-standalone-deployment.yaml
	kubectl create -f minio-standalone-service.yaml
	kubectl create -f miniosetup-job.yaml
	kubectl create -f job-cluster-service.yaml
	FLINK_IMAGE_NAME=streaming-job FLINK_JOB=com.ververica.example.StreamingJob FLINK_JOB_PARALLELISM=1 envsubst < job-cluster-job.yaml.template | kubectl create -f -
	FLINK_IMAGE_NAME=streaming-job FLINK_JOB_PARALLELISM=1 envsubst < task-manager-deployment.yaml.template | kubectl create -f -

status:
	kubectl get services,deployments,pods,pvc,rc,rs

stop:
#	- kubectl delete deployment zoo1
#	- kubectl delete service zoo1
	- kubectl delete deployment minio
	- kubectl delete job miniosetup
	- kubectl delete pvc minio-pv-claim
	- kubectl delete svc minio-service
	- kubectl delete job flink-job-cluster
	- kubectl delete deploy flink-task-manager
	- kubectl delete service flink-job-cluster
