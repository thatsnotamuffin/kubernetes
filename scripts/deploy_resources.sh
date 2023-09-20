#!/bin/bash

show_help=false

show_usage() {
    printf "\n"
    echo "Usage: ./deployment_resources.sh [OPTIONS]"
    echo "Deployment Name (-d) - Namespace (-n) - Container Name (-c) options are required"
    echo "NOTE: If any option, outside of those required, isn't provided - this script will attempt to discover the current resource value and apply that value."
    printf "\n"
    echo "Example Usage: ./deployment_resources.sh -d my-deployment -n my-namespace -c my-container -rm 128M -rc 250m -lm 256M -lc 500m"
    printf "\n"
    echo "Options:"
    echo "  -h, --help                  Show this help message"
    echo "  -d, --deployment-name       Name of the deployment to update"
    echo "  -n, --namespace             Namespace where the Deployment exists"
    echo "  -c, --container-name        Container Name to update"
    echo "  -rm, --request-memory       Amount of memory to request"
    echo "  -rc, --request-cpu          Number of CPU to request"
    echo "  -lm, --limit-memory         Amount of memory to limit"
    echo "  -lc, --limit-cpu            Number of CPU to limit"
    printf "\n"
}

deployment_update(){
    if [ -z "$deployment_name" ]; then
        echo "Deployment Name is required. Aborting..."
        show_usage
        return 1
    fi

    if [ -z "$namespace" ]; then
        echo "Namespace is required. Aborting..."
        show_usage
        return 1
    fi

    if [ -z "$container_name" ]; then
        echo "Container Name is required. Aborting..."
        show_usage
        return 1
    fi

    if [ -z "$request_memory" ]; then
        request_memory=$(kubectl get deploy/$deployment_name -o=jsonpath="{.spec.template.spec.containers[?(@.name==\"$container_name\")].resources.requests.memory}")
    fi

    if [ -z "$request_cpu" ]; then
        request_cpu=$(kubectl get deploy/$deployment_name -o=jsonpath="{.spec.template.spec.containers[?(@.name==\"$container_name\")].resources.requests.cpu}")
    fi

    if [ -z "$limit_memory" ]; then
        limit_memory=$(kubectl get deploy/$deployment_name -o=jsonpath="{.spec.template.spec.containers[?(@.name==\"$container_name\")].resources.limits.memory}")
    fi

    if [ -z "$limit_cpu" ]; then
        limit_cpu=$(kubectl get deploy/$deployment_name -o=jsonpath="{.spec.template.spec.containers[?(@.name==\"$container_name\")].resources.limits.cpu}")
    fi

    if [ -z "$request_memory" ] && [ -z "$request_cpu" ] && [ -z "$limit_memory" ] && [ -z "$limit_cpu" ]; then
        echo "Error: At least one of the following must be provided: Request Memory (-rm) - Request CPU (-rc) - Limit Memory (-lm) - Limit CPU (-lc)"
        exit 1
    fi

    kubectl patch deployment/$deployment_name -p \
        "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"$container_name\",\"resources\":{\"requests\":{\"memory\":\"$request_memory\",\"cpu\":\"$request_cpu\"},\"limits\":{\"memory\":\"$limit_memory\",\"cpu\":\"$limit_cpu\"}}}]}}}}" -n $namespace

    if [ $? -eq 0 ]; then
        echo "Deployment resource update successful."
        return 0
    else
        echo "Error updating deployment resources."
        return 1
    fi
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help=true
            shift
            ;;
        -d|--deployment-name)
            deployment_name="$2"
            shift 2
            ;;
        -n|--namespace)
            namespace="$2"
            shift 2
            ;;
        -c|--container-name)
            container_name="$2"
            shift 2
            ;;
        -rm|--request-memory)
            request_memory="$2"
            shift 2
            ;;
        -rc|--request-cpu)
            request_cpu="$2"
            shift 2
            ;;
        -lm|--limit-memory)
            limit_memory="$2"
            shift 2
            ;;
        -lc|--limit-cpu)
            limit_cpu="$2"
            shift 2
            ;;
         *)
            echo "Invalid option: $1" >&2
            show_usage
            exit 1
            ;;
    esac
done

if [ "$show_help" = true ]; then
    show_usage
    exit 0
fi

deployment_update

exit $?
