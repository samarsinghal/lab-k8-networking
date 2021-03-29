# Services

This tutorial will demonstrate different ways to control traffic on a Kubernetes cluster using Service types, Ingress, Network Policy and Calico. You will learn basic networking and security concepts on Kubernetes.

## Deploy the Helloworld App

In this workshop, we use a `helloworld` application. The source code and Kubernetes resource specifications are included in the repository. 



Now you can deploy the `helloworld` application in workshop namespace. To create deployment first change to the `~/k8-networking` sub directory.

```execute
clear
cd ~/k8-networking
```

```execute
kubectl create -f helloworld-deployment.yaml
```

output:

deployment.apps/helloworld created


The `helloworld` application is now deployed and a Kubernetes `Deployment` object was created. 

```execute
kubectl get pods
```

output
NAME                              READY   STATUS    RESTARTS   AGE
pod/helloworld-5f8b6b587b-qqqjs   1/1     Running   0          73s
pod/helloworld-5f8b6b587b-rwkf9   1/1     Running   0          73s
pod/helloworld-5f8b6b587b-tbpts   1/1     Running   0          73s

The deployment consists of a `Deployment` object, a `ReplicaSet` with 3 replicas of `Pods`. 


Because we did not create a Service for the `helloworld` containers running in pods, they cannot yet be readily accessed. 

When a Pod is deployed to a worker node, it is assigned a `private IP address` in the 172.30.0.0/16 range. Worker nodes and pods can securely communicate on the private network by using private IP addresses. However, Kubernetes creates and destroys Pods dynamically, which means that the location of the Pods changes dynamically. When a Pod is destroyed or a worker node needs to be re-created, a new private IP address is assigned.

With a `Service` object, you can use built-in Kubernetes `service discovery` to expose Pods. A Service defines a set of Pods and a policy to access those Pods. Kubernetes assigns a single DNS name for a set of Pods and can load balance across Pods. When you create a Service, a set of pods and `EndPoints` are created to manage access to the pods.

The Endpoints object in Kubernetes contains a list of IP and port addresses and are created automatically when a Service is created and configured with the pods matching the `selector` of the Service.

## ServiceTypes

Before we create the Service for the `helloworld` application, briefly review the types of services.

The default type is `ClusterIP`. To expose a Service onto an external IP address, you have to create a ServiceType other than ClusterIP.

Available Service types:

- **ClusterIP**: Exposes the Service on a cluster-internal IP. This is the default ServiceType.
- **NodePort**: Exposes the Service on each Node’s IP at a static port (the NodePort). A ClusterIP Service, to which the NodePort Service routes, is automatically created. You’ll be able to contact the NodePort Service, from outside the cluster, by requesting <NodeIP>:<NodePort>.
- **LoadBalancer**: Exposes the Service externally using a cloud provider’s load balancer. NodePort and ClusterIP Services, to which the external load balancer routes, are automatically created.
- **ExternalName**: Maps the Service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record.

You can also use `Ingress` in place of `Service` to expose HTTP/HTTPS Services. Ingress however is technically not a ServiceType, but it acts as the entry point for your cluster and lets you consolidate routing rules into a single resource. 


## Next

Next, go to [ClusterIP](clusterip.md) to learn more about ServiceType ClusterIP.