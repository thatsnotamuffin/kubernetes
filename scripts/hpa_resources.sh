#!/bin/bash

show_help=false
edit_replicas=false

show_usage() {
    printf "\n"
    echo "Usage: ./hpa_resources.sh [OPTIONS]"
    echo "HPA Name (-n) and Namespace (-N) are required"
    echo "NOTE: If any option, outside of those required, isn't provided - this script will attempt to discover the current resource value and apply that value."
    printf "\n"
    echo "Example Usage: ./hpa_resources.sh -n my-hpa -N my-namespace -m 3 -M 5"
    printf "\n"
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -n, --hpa-name          Name of the HPA to edit"
    echo "  -N, --namespace         Namespace where the HPA exists"
    echo "  -m, --min-replicas      Edit the minimum amount of replicas"
    echo "  -M, --max-replicas      Edit the maximum amount of replicas"
    printf "\n"
}

replica_update() {
    if [ -z "$hpa_name" ]; then
        echo "HPA Name is required. Aborting..."
        show_usage
        return 1
    fi

    if [ -z "$namespace" ]; then
        echo "Namespace is required. Aborting..."
        show_usage
        return 1
    fi

    if [ -z "$min_replicas" ]; then
        min_replicas=$(kubectl get hpa/$hpa_name -n $namespace -o=jsonpath='{.spec.minReplicas}' 2>/dev/null)
    fi

    if [ -z "$max_replicas" ]; then
        max_replicas=$(kubectl get hpa/$hpa_name -n $namespace -o=jsonpath='{.spec.minReplicas}' 2>/dev/null)
    fi

    kubectl patch hpa/$hpa_name -p \
        "{\"spec\":{\"minReplicas\":$min_replicas,\"maxReplicas\":$max_replicas}}" -n $namespace

    if [ $? -eq 0 ]; then
        echo "HPA patch successful."
        return 0
    else
        echo "Error patching HPA."
        return 1
    fi
}

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            show_help=true
            shift
            ;;
        -n|--hpa-name)
            hpa_name="$2"
            shift 2
            ;;
        -N|--namespace)
            namespace="$2"
            shift 2
            ;;
        -m|--min-replicas)
            min_replicas="$2"
            shift 2
            ;;
        -M|--max-replicas)
            max_replicas="$2"
            shift 2
            ;;
        *)
            echo "Invalid option: $1" >&2
            show_usage
            exit 1
            ;;
    esac
done

# Check if the help flag is set and display help if necessary
if [ "$show_help" = true ]; then
    show_usage
    exit 0
fi

replica_update

exit $?
