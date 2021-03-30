# Ingress

## Pre-requisites

Finish the [Services](services.md), [ClusterIP](clusterip.md), [NodePort](nodeport.md) and [LoadBalancer](loadbalancer.md) labs. 


## Ingress

Kubernetes ingress is a collection of routing rules that govern how external users access services running in a Kubernetes cluster.

In a typical Kubernetes application, you have pods running inside a cluster and a load balancer running outside. The load balancer takes connections from the internet and routes the traffic to an edge proxy that sits inside your cluster. This edge proxy is then responsible for routing traffic into your pods. The edge proxy is commonly called an ingress controller because it is commonly configured using ingress resources in Kubernetes, however the edge proxy can also be configured with custom resource definitons (CRDs) or annotations.

To expose an app with Ingress, create a Kubernetes service of type `LoadBalancer` and register this Service with Ingress by defining an Ingress resource. The Ingress resource is a Kubernetes resource that defines the rules for how to route incoming requests for apps. The Ingress resource also specifies the path to your app services. The Ingress API also supports TLS termination, virtual hosts, and path-based routing.

### Ingress Controllers and Ingress Resources

Kubernetes supports a high level abstraction called Ingress, which allows simple host or URL based HTTP routing. An ingress is a core concept of Kubernetes, but is always implemented by a third party proxy. These implementations are known as ingress controllers. An ingress controller is responsible for reading the Ingress Resource information and processing that data accordingly. Different ingress controllers have extended the specification in different ways to support additional use cases.

* [`NGINX` Ingress controller](https://docs.nginx.com/nginx-controller/).

* [`HAProxy` Ingress controller](https://github.com/haproxytech/kubernetes-ingress).

* [`Contour` Ingress controller] (https://github.com/projectcontour/contour).

Note that an ingress controller typically doesn’t eliminate the need for an external load balancer — the ingress controller simply adds an additional layer of routing and control behind the load balancer.


## Create an Ingress Resource for the HelloWorld App

Instead of using `<external-ip>:<nodeport>` to access the HelloWorld app, we want to access our HelloWorld aplication via the URL `<Ingress-subdomain>:<nodeport>/<path>`. 

Lets first create helloworld-service

```execute
kubectl apply -f helloworld-service.yaml
```


Make sure, the values for the `hosts`, `secretName` and `host` are set correctly to match the values of the Ingress Subdomain and Secret of your cluster. 

```execute
cat helloworld-ingress.yaml 
```

The above resource will create an access path to the helloworld at `http://helloworld.tanzudemo.frankcarta.com`. 

Create the Ingress for helloworld

```execute
kubectl create -f helloworld-ingress.yaml
```

Try to access the `helloworld` API and the proxy using the Ingress Subdomain with the path to the service,

```execute
curl -L -X POST "http://helloworld-$SESSION_NAMESPACE.tanzudemo.frankcarta.com/api/messages" -H 'Content-Type: application/json' -d '{ "sender": "world1" }'
```

{"id":"c806432d-0f84-45bb-a654-0b6be0146044","sender":"world3","message":"Hello world1 (direct)","host":null}

If you instead want to use subdomain paths instead of URI paths,

```execute
cat helloworld-ingress-subdomain.yaml
```

Delete the previous Ingress resource and create the Ingress resource using subdomain paths.

```execute
kubectl get ingress
kubectl delete ingress helloworld-ingress 
kubectl create -f helloworld-ingress-subdomain.yaml
```

Try to access the application using the subdomain,

```execute
curl -L -X POST "http://hello.helloworld-$SESSION_NAMESPACE.tanzudemo.frankcarta.com/api/messages" -H 'Content-Type: application/json' -d '{ "sender": "world4" }'
```

{"id":"ea9c00e9-190a-4d83-ab8a-cf6e81c1bb10","sender":"world4","message":"Hello world4 (direct)","host":null}


kubernetes Ingress controllers is responsible for getting traffic from the outside world down to your pods.

The kubernetes default ingress controller definition take care of the 90% use case for deploying HTTP middleware

•Traffic consolidation
•TLS management
•Abstract configuration
•Path based routing

### Real-world ingress

We’ve just covered the basic patterns for routing external traffic to your Kubernetes cluster. However, we’ve only discussed how to route traffic to your cluster. Typically, though, your Kubernetes services will impose additional requirements on your ingress. Examples of this include:

* content-based routing, e.g., routing based on HTTP method, request headers, or other properties of the specific request
resilience, e.g., rate limiting, timeouts
* support for multiple protocols, e.g., WebSockets or gRPC
* authentication

Unless you’re running a very simple cloud application, you’ll likely need support for some or all of these capabilities. And, importantly, many of these requirements may need to be managed at the service level, which means you want to manage these concerns inside Kubernetes.


## Next

Next, go to Contour
