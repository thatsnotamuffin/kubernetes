#!/bin/bash

if [ ! "$1" ]; then
    echo "A pod name must be provided."
    exit 1
fi

if [ ! "$2" ]; then
    echo "A shell must be provided."
    exit 1
fi

kubectl exec -it "$1" -- "$2"
