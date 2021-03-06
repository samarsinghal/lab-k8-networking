# NodePort

## Pre-requisites

Finish the [Services](services.md) and [ClusterIP](clusterip.md) labs.

## NodePort

To expose a Service to an external IP address, you have to create a ServiceType other than ClusterIP. When you send a request to the name of the service, `kube-proxy` looks up the name in the cluster `DNS server` and routes the request to the in-cluster IP address of the service. 

To allow external traffic into a kubernetes cluster, you need a `NodePort` ServiceType. When kubernetes creates a NodePort service, `kube-proxy` allocates a port in the range **30000-32767** and opens this port on the `eth0` interface of every node (the `NodePort`). Connections to this port are then forwarded to the service’s cluster IP. A gateway router typically sits in front of the cluster and forwards packets to the node.

Add a property `type: NodePort` in the specification in the file `helloworld-service-nodeport.yaml`,

```execute
cat helloworld-service-nodeport.yaml
```

  apiVersion: v1
  kind: Service
  metadata:
    name: helloworld
    labels:
      app: helloworld
  spec:
    ports:
    - port: 8080
      targetPort: 8080
      nodePort: 30007
    selector:
      app: helloworld
    type: NodePort



To apply changes to the configuration from file,

```execute
kubectl apply -f helloworld-service-nodeport.yaml
```
service/helloworld configured

Describe the Service

```execute
kubectl describe svc helloworld 
```

Kubernetes added a NodePort, in the example with port value `30007`.

You can now connect to the service from outside the cluster via the public IP address of any worker node in the cluster and traffic will be forwarded to the service. Service discovery with the selector and labels is used to deliver the request to one of the pod's IP addresses. With this piece in place we now have a complete pipeline for load balancing external client requests to all the nodes in the cluster.

To connect to the service, we need the Public IP address of one of the worker nodes and the NodePort of the Service. You can use a bash processor called [`jq`](https://stedolan.github.io/jq/) to parse JSON from command line.

```execute
PUBLIC_IP=$(kubectl get nodes -o wide -o json | jq -r '.items[0].status.addresses | .[] | select( .type=="InternalIP" ) | .address ')
echo $PUBLIC_IP
```

```execute
NODE_PORT=$(kubectl get svc helloworld --output json | jq -r '.spec.ports[0].nodePort' )
echo $NODE_PORT
```

Test the deployment,

```execute
curl -L -X POST "http://$PUBLIC_IP:$NODE_PORT/api/messages" -H 'Content-Type: application/json' -d '{ "sender": "world1" }'
```

Output:
{"id":"f142f74f-c679-4738-96e3-6518e607efa2","sender":"world1","message":"Hello world1 (direct)","host":null}

The client connects to your application via a public IP address of a worker node and the NodePort. Each node proxies the port, `kube-proxy` receives the request, and forwards it to the service at the cluster IP. At this point the request matches the netfilter or `iptables` rules and gets redirected to the server pod. 

However, we still require some level of load balancing. a `LoadBalancer` service is the standard way to expose a service. Go to LoadBalancer to learn more about the ServiceType LoadBalancer.
