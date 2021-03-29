## Contour

Contour is an Ingress controller for Kubernetes that works by deploying the Envoy proxy as a reverse proxy and load balancer. Contour supports dynamic configuration updates out of the box while maintaining a lightweight profile.

Contour also introduces a new ingress API (HTTPProxy) which is implemented via a Custom Resource Definition (CRD). Its goal is to expand upon the functionality of the Ingress API to allow for a richer user experience as well as solve shortcomings in the original design.

For this workshop we deployed contour ingress controller on the cluster 

What are the problems with Ingress?

* A default backend capable of servicing requests that don't match any rule.

* The ingress spec permits the definition of a virtual host to span more than one ingress object.

    The ingress objects can only use services in the same namespace, but what if you want to have /finance managed in the finance namespace
    and /ads in the ads namespace? You do this by putting part of the vhost definition in the finance namespace and part of the vhost definition in the ads namespace. They both refer to the same virtual host, so the ingress controller stitches them all together for you.

    However, this means that if someone has RBAC permission to add an ingress object in their namespace, they can inject a route onto the ingress you defined in your namespace. 

* Ingress makes shared tenancy difficult

    There are no safeguards to prevent anyone with RBAC permission to create or edit ingress objects from accidentally, or maliciously, injecting conflicting or invalid configuration onto the vhost for another tenant.

* Ingress spec only permits _one_ service per route
    
    Now a kubernetes service can match multiple pods if they share the same label, they’ll all get mixed into the same endpoint document, but at best you’re going to get a weighted distribution across the deployments that make up the service.
    
    If you want to send 1% of your traffic to the new version of your application, you’ll need to have 99 pods running the old version of your app to make the ratios work out.


```execute
cat helloworld-ingress.yaml 
```

    apiVersion: extensions/v1beta1
    kind: Ingress
    metadata:
    name: helloworld-ingress
    annotations:
        kubernetes.io/ingress.class: contour
    spec:
    rules:
    - host: helloworld.tanzudemo.frankcarta.com
        http:
        paths:
        - path: /
            pathType: ImplementationSpecific
            backend:
            serviceName: helloworld

### Ingress to IngressRoute

* Every Ingressroute document has one hostname. 

    This means all the properties of a virtual host, its name, its tls parameters, the secret that holds the tls certificate are in one namespace alone.

* Load balancing strategies can be specified per backend service

    apiVersion: contour.heptio.com/v1beta1
    kind: IngressRoute
    metadata:
    name: blog
    namespace: marketing
    spec:
    virtualhost:
    fqdn: blog.heptio.com
    tls:
    secretName: blog-secret
    routes:
    - match: /blog
    services:
    - name: blog-svc
    port: 80
    strategy: WeightedLeastRequest

* Enabling websocket support per route is as simple as adding the enableWebsockets: true key to your route

    apiVersion: contour.heptio.com/v1beta1
    kind: IngressRoute
    metadata:
        name: chat
        namespace: default
    spec:
        virtualhost:
            fqdn: chat.example.com
        routes:
        - match: /
            services:
            - name: chat-app
              port: 80
        - match: /websocket
            enableWebsockets: true
            services:
            - name: chat-app
              port: 80

Multiple service backends/Weighted services - The kubernetes ingress document limits routes to a single backend service. Using ingressroute we have the ability to say instead of a single service, allow a list of services.

    apiVersion: contour.heptio.com/v1beta1
    kind: IngressRoute
    metadata:
        name: blog
        namespace: marketing
    spec:
        virtualhost:
            fqdn: blog.heptio.com
        tls:
            secretName: blog-secret
        routes:
        - match: /
            services:
            - name: service1
              port: 8080
              weight: 90
            - name: service2
              port: 8080
              weight: 10

Delegation to helping multi tenant clusters stay managable.

In this example we have a standard ingressroute root; its for google.com, and references google-com-secret in the google namespace.
However all the routes, / and /finance refer to ingressroute documents in other namespaces.

apiVersion: contour.heptio.com/v1beta1
kind: IngressRoute
metadata:
 name: google-com
 namespace: google
spec:
 virtualhost:
 fqdn: google.com
 tls:
 secret: google-com-secret
 routes:
 - match: /
 delegate:
 name: search
 namespace: google-search
 - match: /finance
 delegate:
 name: finance
 namespace: google-finance

apiVersion: contour.heptio.com/v1beta1
kind: IngressRoute
metadata:
 name: finance
 namespace: google-finance
spec:
 routes:
 - match: /finance
 services:
 name: finance-v1.0.1
 port: 8080

Here is the finance ingressroute document.
It does not have a virtual host stanza, which means it is not a root. It is a delegate and can only be referenced by other ingressroute documents that delegate to it
explicitly. And contour is only going to reference routes that start with the prefix that was delegated too
D

The Kubernetes Ingress object has a number of limitations which over the years have been papered over with annotations. Contour, the Ingress controller my
team at Heptio are building, recently introduced a new Ingress object which addresses the existing limitations and unlocks the ability for teams and operators to have
more control over ingress deployments in multi team and multi tenant scenarios. In this short talk I'll explain the limitations of the current ingress object and how our new
Ingress object addresses those shortcomings while making it possible for multiple teams to collaborate and delegate responsibility using various routing patterns and
strategies that our new Ingress object makes possible.


### Migrating from IngressRoute to HTTPProxy

As a name, IngressRoute was lengthy. Abbreviating it introduced confusion with another Kubernetes object–also in beta. The name HTTPProxy reflects the desire to clarify Contour's role in the crowded Kubernetes networking space.


#### Manual Migration guide :-
https://projectcontour.io/guides/ingressroute-to-httpproxy/


#### ir2proxy 

ir2proxy is a tool to convert Contour's IngressRoute resources to HTTPProxy resources.

https://github.com/projectcontour/ir2proxy




Speaking of namespaces, the ingress spec permits the definition of a virtual host to span more than one ingress object.
I can see the argument for this; ingress objects can only use services in the same namespace, but what if you want to have /finance managed in the finance namespace
and /ads in the ads namespace? You do this by putting part of the vhost definition in the finance namespace and part of the vhost definition in the ads namespace. They
both refer to the same virtual host, so the ingress controller stitches them all together for you.
However, this means that if someone has RBAC permission to add an ingress object in their namespace, they can inject a route onto the ingress you defined in your
namespace. 