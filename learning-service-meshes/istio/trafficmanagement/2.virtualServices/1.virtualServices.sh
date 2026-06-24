# virtualServices

Virtual services enables fine-grained control of traffic behavior with 
rich routing rules, 
retries,
failovers, and fault injection.

 Virtual services let you configure how requests for a service are routed within an Istio service mesh.


Virtual services enables fine-grained routing using headers, URI, Query parameters, and other properties of a request.

Virtual services directs traffic to different versions of a service, which is useful for canary releases, A/B testing, and staged rollouts.



root@controlplane ~ ➜  kubectl get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   15m   istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   12m   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   15m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   15m   kubernetes.io/metadata.name=kube-public
kube-system       Active   15m   kubernetes.io/metadata.name=kube-system

root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/httpbin/httpbin.yaml
serviceaccount/httpbin created
service/httpbin created
deployment.apps/httpbin created

root@controlplane ~ ➜

httpbin is a simple HTTP request and response service. 
It is used in Istio examples to demonstrate traffic management features.


https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/httpbin/httpbin.yaml


