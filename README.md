# downscaler
Manage Panoptes Sidekiq process scaling smartly and safely with KEDA

Scaling is managed by [KEDA](https://keda.sh), which automatically increase the number of available pods based on the size of Sidekiq Redis queues. These KEDA objects are managed by this repo from the `panoptes-[env]-scalers' YAML files. For now, changes are not automatically applied and should be made by an admin.

KEDA's downscaling works great for processing jobs that run in less than the standard timeout, around 25 seconds. But this behavior is dangerous for much longer-running dumpworker jobs like data exports, as the HPA downscaling operation doesn't differentiate between active and idle Sidekiq processes when deciding which process to end. So this repo contains a script runs as a cron job in Kubernetes and checks for idle Sidekiq dumpworker processes, periodically killing pods and scaling the deployment down. Normal HPA downscaling operation is disabled via the KEDA scalers for dumpworker processes.

Tweakables:
* **MINIMUM_PODS** Env var, allows for a specified number of pods to remain running even when idle. For example, setting this to '1' could allow for a production dumpworker to always remain running to minimize the delay in job processing, while allowing it to be set to '0' in the staging template. This should match the minReplicaCount in the scaler template, it tells the script to not try to kill a pod that'll just get replaced by the HPA.
* **pollingInterval** The amount of time between checks to see if it should downscaling. This applies to the KEDA/k8s HPAs and is not a factor for downscaler-managed dumpworkers.
* **maxReplicaCount** increase this if you want to see more parallel processing.
* **Schedule** CronJob attribute, will dictate the interval between downscaling jobs.
