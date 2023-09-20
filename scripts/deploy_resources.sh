#!/bin/bash

read -p "Deployment Name: " deployment_name
read -p "Container Name: " container_name
read -p "Request Memory: " request_memory
read -p "Request CPU: " request_cpu
read -p "Limit Memory: " limit_memory
read -p "Limit CPU: " limit_cpu

kubectl patch deployment/$deployment_name -p \
    "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"$container_name\",\"resources\":{\"requests\":{\"memory\":\"$request_memory\",\"cpu\":\"$request_cpu\"},\"limits\":{\"memory\":\"$limit_memory\",\"cpu\":\"$limit_cpu\"}}}]}}}}"
