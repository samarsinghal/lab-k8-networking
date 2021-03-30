## Contour

Contour is an Ingress controller for Kubernetes that works by deploying the Envoy proxy as a reverse proxy and load balancer. Contour supports dynamic configuration updates out of the box while maintaining a lightweight profile.

Contour also introduces a new ingress API (HTTPProxy) which is implemented via a Custom Resource Definition (CRD). Its goal is to expand upon the functionality of the Ingress API to allow for a richer user experience as well as solve shortcomings in the original design.

For this workshop we deployed contour ingress controller on the cluster 

```execute
cat helloworld-ingress.yaml 
```

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




### Ingress to IngressRoute

lets see IngressRoute resource definition file https://github.com/projectcontour/contour/blob/main/design/ingressroute-design.md

```execute-2
cat helloworld-ingressroute.yaml
```


* Every Ingressroute document has one hostname. 

    This means all the properties of a virtual host, its name, its tls parameters, the secret that holds the tls certificate are in one namespace alone.

* Load balancing strategies can be specified per backend service

* Enabling websocket support per route is as simple as adding the enableWebsockets: true key to your route

* Multiple service backends/Weighted services - The kubernetes ingress document limits routes to a single backend service. Using ingressroute we have the ability to say instead of a single service, allow a list of services.

* Delegation to helping multi tenant clusters stay managable.


### Migrating from IngressRoute to HTTPProxy

As a name, IngressRoute was lengthy. Abbreviating it introduced confusion with another Kubernetes object–also in beta. The name HTTPProxy reflects the desire to clarify Contour's role in the crowded Kubernetes networking space.


#### Manual Migration guide :-
https://projectcontour.io/guides/ingressroute-to-httpproxy/


#### ir2proxy 

ir2proxy is a tool to convert Contour's IngressRoute resources to HTTPProxy resources.

https://github.com/projectcontour/ir2proxy

