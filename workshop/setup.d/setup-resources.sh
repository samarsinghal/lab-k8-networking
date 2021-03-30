#!/bin/bash

envsubst < k8-networking/helloworld-ingress.yaml.in > k8-networking/helloworld-ingress.yaml

# envsubst < frontend-v3/ingress.yaml.in > frontend-v3/ingress.yaml
# envsubst < frontend-v4/ingress.yaml.in > frontend-v4/ingress.yaml
# envsubst < frontend-v5/ingress.yaml.in > frontend-v5/ingress.yaml
