# ClusterIP

## Add a Service to `helloworld`

Now we have a basic understanding of service discovery and the different ServiceTypes on Kubernetes, it is time to expose the Deployment of `helloworld` using a new Service specification. 

Let's look at the definition for the `helloworld-service.yaml`,

```execute
cat helloworld-service.yaml
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
      targetPort: http-server
    selector:
      app: helloworld

The `spec` defines a few important attributes for service discovery: `labels`, `selector` and `port`. The set of Pods that a Service targets, is determined by the **selector and labels**. When a Service has no selector, the corresponding `Endpoints` object is not created automatically.

The Service maps the incoming `port` to the container's `targetPort`. By default the `targetPort` is set to the same value as the incoming `port` field.

Create the Service object with the default type,

```execute
kubectl create -f helloworld-service.yaml
```

service/helloworld created

Describe the Service,

```execute
kubectl describe svc helloworld
```

Name:              helloworld
Namespace:         my-apps
Labels:            app=helloworld
Annotations:       <none>
Selector:          app=helloworld
Type:              ClusterIP
IP:                172.21.86.16
Port:              <unset>  8080/TCP
TargetPort:        http-server/TCP
Endpoints:         172.30.172.228:8080,172.30.234.176:8080,172.30.234.177:8080
Session Affinity:  None
Events:            <none>

Lets test service 

```execute
CLUSTER_IP=$(kubectl get svc -o wide -o json | jq -r '.items[0].spec.clusterIP')
echo $CLUSTER_IP
```

```execute
curl -L -X POST "http://$CLUSTER_IP:8080/api/messages" -H 'Content-Type: application/json' -d '{ "sender": "world1" }'
```

{"id":"5e2efa73-ed9f-4e83-884b-4a717aa5c584","sender":"world1","message":"Hello world1 (direct)","host":null}

You see that Kubernetes by default creates a Service of type `ClusterIP`. The service is now available and discoverable, but only within the cluster, using the `Endpoints` and `port` mapping found via the `selector` and `labels`.

Go to NodePort to learn more about ServiceType NodePort.
