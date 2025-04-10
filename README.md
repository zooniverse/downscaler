# downscaler
A Kubernetes job and Ruby script to scale down Panoptes deployments. Scaling up is managed by [KEDA](https://keda.sh), which automatically increase the number of available pods based on the size of Sidekiq Redis queues. This works great for processing jobs that run in less than the standard timeout, around 25 seconds. But scaling down in the same way is dangerous for much longer-running jobs like data exports, as the k8s downscaling operation doesn't differentiate between active and idle Sidekiq processes. So this utility runs as a cron job in Kubernetes and checks for idle Sidekiq dumpworker processes, periodically killing pods and scaling the deployment down.
