root@controlplane ~ ➜  kubectl get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   95m   istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   77s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   95m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   95m   kubernetes.io/metadata.name=kube-public
kube-system       Active   95m   kubernetes.io/metadata.name=kube-system

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   95m   istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   77s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   95m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   95m   kubernetes.io/metadata.name=kube-public
kube-system       Active   95m   kubernetes.io/metadata.name=kube-system

root@controlplane ~ ➜ 

root@controlplane ~ ✖ kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/httpbin/httpbin.yaml
serviceaccount/httpbin created
service/httpbin created
deployment.apps/httpbin created

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl get all
NAME                           READY   STATUS    RESTARTS   AGE
pod/httpbin-686d6fc899-ndp2f   2/2     Running   0          25s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/httpbin      ClusterIP   10.103.40.150   <none>        8000/TCP   25s
service/kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP    96m

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/httpbin   1/1     1            1           25s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/httpbin-686d6fc899   1         1         1       25s

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl create ns test
namespace/test created

root@controlplane ~ ➜  kubectl run test --image nginx -n test
pod/test created

root@controlplane ~ ➜  kubectl exec -it test -n test -- bash
root@test:/# curl httpbin.default.svc:8000/ip
{
  "origin": "127.0.0.6:58851"
}
root@test:/# curl httpbin.default.svc:8000/user-agent
{
  "user-agent": "curl/8.14.1"
}
root@test:/# 


root@test:/# curl --head  httpbin.default.svc:8000           
HTTP/1.1 200 OK
access-control-allow-credentials: true
access-control-allow-origin: *
content-security-policy: default-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' camo.githubusercontent.com
content-type: text/html; charset=utf-8
date: Mon, 22 Jun 2026 08:21:01 GMT
x-envoy-upstream-service-time: 0
server: istio-envoy
x-envoy-decorator-operation: httpbin.default.svc.cluster.local:8000/*
transfer-encoding: chunked

root@test:/# 



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


root@controlplane ~ ➜  cat vs.yaml 
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

root@controlplane ~ ➜  kubectl apply -f vs.yaml 
virtualservice.networking.istio.io/httpbin created

root@controlplane ~ ➜  kubectl get vs -o wide
NAME      GATEWAYS   HOSTS         AGE
httpbin              ["httpbin"]   7s

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl exec -ti -n test test -- curl --head httpbin.default.svc.cluster.local:8000
HTTP/1.1 200 OK
access-control-allow-credentials: true
access-control-allow-origin: *
content-security-policy: default-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' camo.githubusercontent.com
content-type: text/html; charset=utf-8
date: Mon, 22 Jun 2026 08:26:21 GMT
x-envoy-upstream-service-time: 0
server: istio-envoy
x-envoy-decorator-operation: httpbin.default.svc.cluster.local:8000/*
transfer-encoding: chunked


root@controlplane ~ ➜  




root@controlplane ~ ➜  kubectl exec -ti -n test test -- curl --head httpbin.default.svc.cluster.local
HTTP/1.1 503 Service Unavailable
date: Mon, 22 Jun 2026 08:35:39 GMT
server: envoy
transfer-encoding: chunked


root@controlplane ~ ➜  k describe vs
Name:         httpbin
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  networking.istio.io/v1
Kind:         VirtualService
Metadata:
  Creation Timestamp:  2026-06-22T08:25:28Z
  Generation:          2
  Resource Version:    9442
  UID:                 265c6c85-b7fa-40eb-95d9-f02f70ea5bda
Spec:
  Hosts:
    httpbin
  Http:
    Match:
      Uri:
        Prefix:  /
    Route:
      Destination:
        Host:  httpbin.default.svc.cluster.local
        Port:
          Number:  9000
Events:            <none>

root@controlplane ~ ➜  k get vs httpbin -o yaml
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"networking.istio.io/v1","kind":"VirtualService","metadata":{"annotations":{},"name":"httpbin","namespace":"default"},"spec":{"hosts":["httpbin"],"http":[{"match":[{"uri":{"prefix":"/"}}],"route":[{"destination":{"host":"httpbin.default.svc.cluster.local","port":{"number":9000}}}]}]}}
  creationTimestamp: "2026-06-22T08:25:28Z"
  generation: 2
  name: httpbin
  namespace: default
  resourceVersion: "9442"
  uid: 265c6c85-b7fa-40eb-95d9-f02f70ea5bda
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
          number: 9000

root@controlplane ~ ➜  



