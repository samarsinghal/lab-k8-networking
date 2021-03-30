## Pre-requisites

Finish the [Services](services.md), [ClusterIP](clusterip.md), and [NodePort](nodeport.md) labs.

## LoadBalancer

In the previous labs, you created a service for the `helloworld` application with a default clusterIP and then added a NodePort to the Service, which proxies requests to the Service resource. But in a production environment, you still need a type of load balancer, whether client requests are internal or external coming in over the public network. 

The `LoadBalancer` service in Kubernetes configures an Open Systems Interconnection (OSI) model Layer 4 (L4) load balancer, which forwards and balances traffic from the internet to your backend application.

To use a load balancer for distributing client traffic to the nodes in a cluster, you need a public IP address that the clients can connect to, and you need IP addresses on the nodes themselves to which the load balancer can forward the requests. 

The portable public and private IP addresses are static floating IPs pointing to worker nodes. A `Keepalived` daemon constantly monitors the IP, and automatically moves the IP to another worker node if the worker node is removed.  

Because, the creation of the load balancer happens asynchronously with the creation of the Service, you might have to wait until both the Service and the load balancer have been created.


## Create a LoadBalancer

In the previous lab, you already created a `NodePort` Service. 

```execute
kubectl get svc 
```

NAME         TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
helloworld   NodePort   172.21.86.16   <none>        8080:30007/TCP   12m


Update the service for `helloworld` and change the type to `LoadBalancer`.

```execute
cat helloworld-service-loadbalancer.yaml
```

apiVersion: v1
kind: Service
metadata:
  name: helloworld
  labels:
    app: helloworld
spec:
  ports:
  - port: 80
    targetPort: 8080
    protocol: TCP
    nodePort: 30007
  selector:
    app: helloworld
  type: LoadBalancer



To apply changes to the configuration from file,

```execute
kubectl apply -f helloworld-service-loadbalancer.yaml
```

service/helloworld configured

The `TYPE` should be set to `LoadBalancer` now, and an `EXTERNAL-IP` should be assigned.

```execute
kubectl get svc helloworld
```

NAME         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)          AGE
helloworld   LoadBalancer   172.21.86.16   169.47.155.242   8080:32387/TCP   12m

To access the Service of the `helloworld` from the public internet, you can use the public IP address of the NLB and the assigned NodePort of the service in the format `<IP_address>:<NodePort>`.

```execute
PUBLIC_IP=$(kubectl get svc helloworld --output json | jq -r '.status.loadBalancer.ingress[0].hostname')
echo $PUBLIC_IP
```

Access the `helloworld` app in a browser or with Curl,

```execute
curl -L -X POST "http://$PUBLIC_IP/api/messages" -H 'Content-Type: application/json' -d '{ "sender": "world2" }'
```

{"id":"0ebdc166-32cd-4d0d-93b6-f278e4405c6f","sender":"world2","message":"Hello world2 (direct)","host":null}

Note:- Services of type `LoadBalancer` have some limitations. They cannot do TLS termination, do virtual hosts or path-based routing, so you can’t use a single load balancer to proxy to multiple services. These limitations led to the addition in Kubernetes v1.2 of a separate kubernetes resource called `Ingress`.

Cleanup delete loadbalancer service 

```execute
kubectl delete -f helloworld-service-loadbalancer.yaml
```


Next, go to ExternalName
