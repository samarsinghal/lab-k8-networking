This rounds out this workshop on k8 networking

An abstract way to expose an application running on a set of Pods as a network service.
With Kubernetes you don't need to modify your application to use an unfamiliar service discovery mechanism. Kubernetes gives Pods their own IP addresses and a single DNS name for a set of Pods, and can load-balance across them.

## Next steps 

Next step is to explore other means to expose/limit access to an application Via Network Policy, Calico, and Istio. With Istio, you can manage network traffic, load balance across microservices, enforce access policies, verify service identity, and more.

We will also look at different use cases to explore the functional overlap and distinction across different networking techniques - Ingress Vs Gateway Vs Istio Service Mesh