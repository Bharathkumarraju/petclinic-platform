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


apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: httpbin
  namespace: default
spec:
  hosts:
  - httpbin
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: httpbin.default.svc.cluster.local
        port:
          number: 8000


---


apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: httpbin
  namespace: default
spec:
  hosts:
  - httpbin
  http:
  - match:
    - uri:
        prefix: /hello
    rewrite:
      uri: /
    route:
    - destination:
        host: httpbin.default.svc.cluster.local
        port:
          number: 8000
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: httpbin.default.svc.cluster.local
        port:
          number: 8000

