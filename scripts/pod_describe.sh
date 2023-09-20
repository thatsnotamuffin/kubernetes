#!/bin/bash

if [ ! "$1" ]; then
    echo "A pod name must be provided."
    exit 1
fi

kubectl describe pod "$1"
