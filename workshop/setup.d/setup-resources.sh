#!/bin/bash

envsubst < k8-networking/helloworld-ingress.yaml.in > k8-networking/helloworld-ingress.yaml

envsubst < k8-networking/helloworld-ingress-subdomain.yaml.in > k8-networking/helloworld-ingress-subdomain.yaml

envsubst < k8-networking/helloworld-ingressroute.yaml.in > k8-networking/helloworld-ingressroute.yaml
