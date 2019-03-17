run:
	kubectl create -f minio-standalone-pvc.yaml
	kubectl create -f minio-standalone-deployment.yaml
	kubectl create -f minio-standalone-service.yaml
	kubectl create -f miniosetup-deployment.yaml
	kubectl create -f job-cluster-service.yaml
	FLINK_IMAGE_NAME=streaming-job FLINK_JOB=com.ververica.example.StreamingJob FLINK_JOB_PARALLELISM=1 envsubst < job-cluster-job.yaml.template | kubectl create -f -
	FLINK_IMAGE_NAME=streaming-job FLINK_JOB_PARALLELISM=1 envsubst < task-manager-deployment.yaml.template | kubectl create -f -

status:
	kubectl get services,deployments,pods,pvc,rc,rs

stop:
	- kubectl delete deployment minio
	- kubectl delete deployment miniosetup
	- kubectl delete pvc minio-pv-claim
	- kubectl delete svc minio-service
	- kubectl delete job flink-job-cluster
	- kubectl delete deploy flink-task-manager
	- kubectl delete service flink-job-cluster

bucket:
	- mc config host add myminio http://localhost:30090 minio minio123 --api s3v4
	- mc mb myminio/flink
