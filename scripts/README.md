# Scripts
Some of these scripts are used to "automate" slightly longer commands in the spirit of lazy. Most notably the `pod_exec.sh` - `pod_describe.sh` - `pod_log.sh` - `deploy_scale.sh` scripts.

#### Pod Exec
[pod_exec.sh](pod_exec.sh) Starts an interactive shell in a specified pod. Requires a pod name and shell

```bash
bash pod_exec.sh my-pod bash
```

#### Pod Describe
[pod_describe.sh](pod_describe.sh) This script runs a `kubectl describe pod` command on a provided pod. Only a pod name is required

```bash
bash pod_describe my-pod
```

#### Pod Log
[pod_log.sh](pod_log.sh) Grabs the logs of a pod. Only the pod name is required - NOTE: tailing the log is not supported as of the moment

```bash
bash pod_log.sh my-pod
```

#### Deploy Scale
[deploy_scale.sh](deploy_scale.sh) Scales a deployment to a provided number of replicas. The direction of the scaling isn't forced (scaling up or scaling down). The number of replicas to scale to and the deployment name are required

```bash
bash deploy-scale.sh 3 my-deploy
```

Currently these are used as aliases to shorten the need for typing and preserve delicate finger life.
```txt
alias kscale='/home/thatsnotamuffin/scripts/deploy_scale.sh'
alias kexec='/home/thatsnotamuffin/scripts/pod_exec.sh'
alias klog='/home/thatsnotamuffin/scripts/pod_log.sh'
alias kdpod='/home/thatsnotamuffin/scripts/pod_describe.sh'
```

### Deploy Resources Script
[deploy_resources.sh](deploy_resources.sh) - This script is used to update a deployment's memory and cpu resource limits and requests. The deployment name, container name, and namespace are required in order to use the script. The other arguments are not necessarily required. The script attempts to discover these "missing" values and apply them as their current value.

#### Example Usage
```bash
bash deployment_resources.sh -d my-deployment -n my-namespace -c my-container -rm 128Mi -rc 250m -lm 256Mi -lc 500m
```

#### Help Info
```txt
Usage: ./deployment_resources.sh [OPTIONS]
Deployment Name (-d) - Namespace (-n) - Container Name (-c) options are required
NOTE: If any option, outside of those required, isn't provided - this script will attempt to discover the current resource value and apply that value.

Example Usage: ./deployment_resources.sh -d my-deployment -n my-namespace -c my-container -rm 128M -rc 250m -lm 256M -lc 500m

Options:
  -h, --help                  Show this help message
  -d, --deployment-name       Name of the deployment to update
  -n, --namespace             Namespace where the Deployment exists
  -c, --container-name        Container Name to update
  -rm, --request-memory       Amount of memory to request
  -rc, --request-cpu          Number of CPU to request
  -lm, --limit-memory         Amount of memory to limit
  -lc, --limit-cpu            Number of CPU to limit
```

### HPA Resources Script
[hpa_resources.sh](hpa_resources.sh) - This script is currently used to update the minimum and maximum replica counts for a given HPA. While it's strongly advised to do this via some form of automation or via a yaml file, there may be times when an HPA needs to be edited from the command line. This script attempts to accomodate this in a friendly manner.

The HPA name and namespace are required in order to use this script. The other arguments are not necessarily required. The script attempts to discover these "missing" values and apply them as their current value.

#### Example Usage
```bash
bash hpa_resources.sh -n my-hpa -N my-namespace -m 3 -M 5
```

#### Help Info
```txt
Usage: ./hpa_resources.sh [OPTIONS]
HPA Name (-n) and Namespace (-N) are required
NOTE: If any option, outside of those required, isn't provided - this script will attempt to discover the current resource value and apply that value.

Example Usage: ./hpa_resources.sh -n my-hpa -N my-namespace -m 3 -M 5

Options:
  -h, --help              Show this help message
  -n, --hpa-name          Name of the HPA to edit
  -N, --namespace         Namespace where the HPA exists
  -m, --min-replicas      Edit the minimum amount of replicas
  -M, --max-replicas      Edit the maximum amount of replicas
```
