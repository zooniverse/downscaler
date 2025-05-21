# downscaler
Manage Panoptes Sidekiq process scaling smartly and safely with KEDA

Scaling is managed by [KEDA](https://keda.sh), which automatically increase the number of available pods based on the size of Sidekiq Redis queues. These KEDA objects are managed by this repo from the `panoptes-[env]-scalers' YAML files. For now, changes are not automatically applied and should be made by an admin.

KEDA's downscaling works great for processing jobs that run in less than the standard timeout, around 25 seconds. But this behavior is dangerous for much longer-running dumpworker jobs like data exports, as the HPA downscaling operation doesn't differentiate between active and idle Sidekiq processes when deciding which process to end. So this repo contains a script runs as a cron job in Kubernetes and checks for idle Sidekiq dumpworker processes, periodically killing pods and scaling the deployment down.
