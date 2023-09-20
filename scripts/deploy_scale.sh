#!/bin/bash

kubectl scale --replicas=$1 deployments/$2
