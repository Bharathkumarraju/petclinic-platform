root@controlplane ~/demo ➜  kubectl get pods -n istio-system
NAME                            READY   STATUS    RESTARTS   AGE
istio-cni-node-vdt82            1/1     Running   0          2m49s
istiod-6b854648cc-nnfk4         1/1     Running   0          2m57s
ztunnel-qgtj5                   1/1     Running   0          2m45s
root@controlplane ~/demo ➜


root@controlplane ~/demo ➜  kubectl get ns
NAME              STATUS   AGE
default           Active   8m27s
hello             Active   4m
httpbin           Active   3m57s
istio-system      Active   3m8s
kube-node-lease   Active   8m27s
kube-public       Active   8m27s
kube-system       Active   8m27s
test              Active   4m3s

root@controlplane ~/demo ➜  kubectl get ns --show-labels
NAME              STATUS   AGE     LABELS
default           Active   8m31s   kubernetes.io/metadata.name=default
hello             Active   4m4s    kubernetes.io/metadata.name=hello
httpbin           Active   4m1s    kubernetes.io/metadata.name=httpbin
istio-system      Active   3m12s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   8m31s   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   8m31s   kubernetes.io/metadata.name=kube-public
kube-system       Active   8m31s   kubernetes.io/metadata.name=kube-system
test              Active   4m7s    istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=test
root@controlplane ~/demo ➜


root@controlplane ~/demo ➜  kubectl get pod -n test
NAME   READY   STATUS    RESTARTS   AGE
curl   1/1     Running   0          2m40s

root@controlplane ~/demo ➜


root@controlplane ~/demo ➜  kubectl apply -f helloworld.yaml -n hello
service/helloworld created
deployment.apps/helloworld-v1 created
deployment.apps/helloworld-v2 created

root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/httpbin/httpbin.yaml
serviceaccount/httpbin created
service/httpbin created
deployment.apps/httpbin created
root@controlplane ~ ➜

root@controlplane ~/demo ➜

root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/helloworld/helloworld.yaml -n hello 
service/helloworld created
deployment.apps/helloworld-v1 created
deployment.apps/helloworld-v2 created

root@controlplane ~ ➜

--- hello-dr.yaml

apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: hello-world-dr
  namespace: hello
spec:
  host: helloworld
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2


--- hello-vs.yaml

apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: hello-world-vs
  namespace: hello
spec:
  hosts:
  - helloworld
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: helloworld.default.svc.cluster.local
        port:
          number: 5000
        subset: v1
      weight: 95
    - destination:
        host: helloworld.default.svc.cluster.local
        port:
          number: 5000
        subset: v2
      weight: 5


---

root@controlplane ~/demo ➜  kubectl get destinationrules.networking.istio.io -A
NAMESPACE   NAME             HOST         AGE
hello       hello-world-dr   helloworld   22s

root@controlplane ~/demo ➜  kubectl get vs -A
NAMESPACE   NAME             GATEWAYS   HOSTS           AGE
hello       hello-world-vs              ["helloworld"]  13s

root@controlplane ~/demo ➜  kubectl get pods -n test
NAME   READY   STATUS    RESTARTS   AGE
curl   1/1     Running   0          5m5s

root@controlplane ~/demo ➜  kubectl exec curl -n test -- curl helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    59  100     59    0     0    517      0 --:--:-- --:--:-- --:--:--   522
Hello version: v2, instance: helloworld-v2-654d97458-bj962

root@controlplane ~/demo ➜  kubectl exec curl -n test -- curl helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    59  100     59    0     0    593      0 --:--:-- --:--:-- --:--:--   595
Hello version: v2, instance: helloworld-v2-654d97458-bj962

root@controlplane ~/demo ➜  kubectl exec curl -n test -- curl helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    59  100     59    0     0    585      0 --:--:-- --:--:-- --:--:--   590
Hello version: v2, instance: helloworld-v2-654d97458-bj962

root@controlplane ~/demo ➜  kubectl exec curl -n test -- curl helloworld.hello.svc.cluster.local:5000/hello


label the namespace hello 

root@controlplane ~/demo ➜  kubectl get ns hello --show-labels
NAME    STATUS   AGE     LABELS
hello   Active   8m35s   kubernetes.io/metadata.name=hello

root@controlplane ~/demo ➜  kubectl label namespace hello istio.io/dataplane-mode=ambient istio.io/use-waypoint=waypoint
namespace/hello labeled

root@controlplane ~/demo ➜  kubectl get crd
NAME                                       CREATED AT
authorizationpolicies.security.istio.io    2025-08-31T05:29:11Z
destinationrules.networking.istio.io       2025-08-31T05:29:10Z
envoyfilters.networking.istio.io           2025-08-31T05:29:10Z
gatewayclasses.gateway.networking.k8s.io   2025-08-31T05:29:40Z
gateways.gateway.networking.k8s.io         2025-08-31T05:29:40Z
gateways.networking.istio.io               2025-08-31T05:29:10Z
grpcroutes.gateway.networking.k8s.io       2025-08-31T05:29:40Z
httproutes.gateway.networking.k8s.io       2025-08-31T05:29:40Z
peerauthentications.security.istio.io      2025-08-31T05:29:11Z
proxyconfigs.networking.istio.io           2025-08-31T05:29:10Z
referencegrants.gateway.networking.k8s.io  2025-08-31T05:29:40Z
requestauthentications.security.istio.io   2025-08-31T05:29:11Z
serviceentries.networking.istio.io         2025-08-31T05:29:10Z
sidecars.networking.istio.io               2025-08-31T05:29:10Z
telemetries.telemetry.istio.io             2025-08-31T05:29:11Z
virtualservices.networking.istio.io        2025-08-31T05:29:11Z
wasmplugins.extensions.istio.io            2025-08-31T05:29:10Z
workloadentries.networking.istio.io        2025-08-31T05:29:11Z
workloadgroups.networking.istio.io         2025-08-31T05:29:11Z

root@controlplane ~/demo ➜


root@controlplane ~/demo ➜  istioctl waypoint apply -n hello
✅waypoint hello/waypoint applied

root@controlplane ~/demo ➜  kubectl get pods -n hello
NAME                             READY   STATUS             RESTARTS   AGE
helloworld-v1-7459d7b54b-pkhgf   1/1     Running            0          4m23s
helloworld-v2-654d97458-bj962    1/1     Running            0          4m23s
waypoint-795d979b85-tr7q9        0/1     ContainerCreating  0          4s

root@controlplane ~/demo ➜




root@controlplane ~/demo ➜  kubectl get pods -n istio-system
NAME                            READY   STATUS    RESTARTS   AGE
istio-cni-node-vdt82            1/1     Running   0          2m49s
istiod-6b854648cc-nnfk4         1/1     Running   0          2m57s
ztunnel-qgtj5                   1/1     Running   0          2m45s
root@controlplane ~/demo ➜

Ztunnel is going to route L4 traffic.
Waypoint is going to route L7 traffic.


root@controlplane ~/demo ➜  kubectl delete -f hello-vs.yaml
virtualservice.networking.istio.io "hello-world-vs" deleted

root@controlplane ~/demo ➜  kubectl delete -f hello-dr.yaml
destinationrule.networking.istio.io "hello-world-dr" deleted

root@controlplane ~/demo ➜



root@controlplane ~/demo ➜  vim hello-httproute-split-traffic.yaml

apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello-http-split-traffic
  namespace: hello
spec:
  parentRefs:
  - group: ""
    kind: Service
    name: helloworld
    port: 5000
  rules:
  - backendRefs:
    - name: helloworld-v1
      port: 5000
      weight: 95
    - name: helloworld-v2
      port: 5000
      weight: 5


root@controlplane ~/demo ➜  kubectl get deployments.apps -n hello
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
helloworld-v1   1/1     1            1           7m45s
helloworld-v2   1/1     1            1           7m45s
waypoint        1/1     1            1           3m26s

root@controlplane ~/demo ➜


root@controlplane ~/demo ➜  kubectl get svc -n hello
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)               AGE
helloworld   ClusterIP   10.109.201.209   <none>        5000/TCP              8m2s
waypoint     ClusterIP   10.108.208.214   <none>        15021/TCP,15008/TCP   3m43s

root@controlplane ~/demo ➜

need to create two services for helloworld-v1 and helloworld-v2 to use HTTPRoute to split traffic between them.

apiVersion: v1
kind: Service
metadata:
  name: helloworld
  labels:
    app: helloworld
    service: helloworld
spec:
  ports:
  - port: 5000
    name: http
  selector:
    app: helloworld

---
# Separate service for v1
apiVersion: v1
kind: Service
metadata:
  name: helloworld-v1
  namespace: hello
  labels:
    app: helloworld
    version: v1
spec:
  ports:
  - port: 5000
    name: http
  selector:
    app: helloworld
    version: v1
---
# Separate service for v2
apiVersion: v1
kind: Service
metadata:
  name: helloworld-v2
  namespace: hello
  labels:
    app: helloworld
    version: v2
spec:
  ports:
  - port: 5000
    name: http
  selector:
    app: helloworld
    version: v2
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-v1
  labels:
    app: helloworld
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: helloworld
      version: v1
  template:
    metadata:
      labels:
        app: helloworld
        version: v1
    spec:
      containers:
      - name: helloworld
        image: docker.io/istio/examples-helloworld-v1:1.0
        resources: {}

root@controlplane ~/demo ➜


root@controlplane ~/demo ➜  kubectl apply -f hello-httproute-split-traffic.yaml
httproute.gateway.networking.k8s.io/hello-http-split-traffic created

root@controlplane ~/demo ➜  vim helloworld.yaml

root@controlplane ~/demo ➜  kubectl apply -f helloworld.yaml -n hello
service/helloworld unchanged
service/helloworld-v1 created
service/helloworld-v2 created
deployment.apps/helloworld-v1 unchanged
deployment.apps/helloworld-v2 unchanged

root@controlplane ~/demo ➜  kubectl get svc -n hello
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)               AGE
helloworld      ClusterIP   10.109.201.209   <none>        5000/TCP              9m26s
helloworld-v1   ClusterIP   10.106.112.114   <none>        5000/TCP              2s
helloworld-v2   ClusterIP   10.106.42.104    <none>        5000/TCP              2s
waypoint        ClusterIP   10.108.208.214   <none>        15021/TCP,15008/TCP   5m7s

root@controlplane ~/demo ➜


httpbin:
------------------------------------------------------------------------------------------->

root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/httpbin/httpbin.yaml
serviceaccount/httpbin created
service/httpbin created
deployment.apps/httpbin created
root@controlplane ~ ➜


root@controlplane ~/demo ➜  ll
total 28
drwxr-xr-x  2 root root 4096 Aug 31 05:42 ./
drwx------ 10 root root 4096 Aug 31 05:42 ../
-rw-r--r--  1 root root  231 Aug 31 05:34 hello-dr.yaml
-rw-r--r--  1 root root  353 Aug 31 05:40 hello-httproute-split-traffic.yaml
-rw-r--r--  1 root root  482 Aug 31 05:34 hello-vs.yaml
-rw-r--r--  1 root root 1801 Aug 31 05:42 helloworld.yaml
-rw-r--r--  1 root root 1526 Aug 31 05:28 httpbin.yaml

root@controlplane ~/demo ➜  kubectl label namespace httpbin istio.io/dataplane-mode=ambient istio.io/use-waypoint=waypoint
namespace/httpbin labeled

root@controlplane ~/demo ➜  kubectl get pods -n hello
NAME                             READY   STATUS    RESTARTS   AGE
helloworld-v1-7459d7b54b-pkhgf   1/1     Running   0          11m
helloworld-v2-654d97458-bj962    1/1     Running   0          11m
waypoint-795d979b85-tr7q9        1/1     Running   0          6m44s

root@controlplane ~/demo ➜ 

root@controlplane ~/demo ✗  istioctl waypoint apply -n httpbin
✅waypoint httpbin/waypoint applied

(reverse-i-search)`get pods: kubectl get pods -n istio-system

root@controlplane ~/demo ✗  kubectl get pods -n httpbin
NAME                        READY   STATUS    RESTARTS   AGE
waypoint-86d5d94866-2n5d8   1/1     Running   0          9s

root@controlplane ~/demo ➜

apply httpbin.yaml in httpbin namespace.


root@controlplane ~/demo ➜  kubectl get svc -n httpbin
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)               AGE
httpbin    ClusterIP   10.109.106.235   <none>        8000/TCP              9s
waypoint   ClusterIP   10.111.106.152   <none>        15021/TCP,15008/TCP   38s

root@controlplane ~/demo ➜  kubectl exec curl -n test -- curl httpbin.httpbin.svc.cluster.local:8000/get
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   420  100     420    0     0  30077      0 --:--:-- --:--:-- --:--:-- 32307
{
  "args": {}, 
  "headers": {
    "Accept": [
      "*/*"
    ], 
    "Host": [
      "httpbin.httpbin.svc.cluster.local:8000"
    ], 
    "User-Agent": [
      "curl/8.15.0"
    ], 
    "X-Forwarded-Proto": [
      "http"
    ], 
    "X-Request-Id": [
      "9d1b0c49-7ec9-4963-b89f-1fedb4068a1f"
    ]
  }, 
  "method": "GET", 
  "origin": "10.50.0.11:55395", 
  "url": "http://httpbin.httpbin.svc.cluster.local:8000/get"
}

root@controlplane ~/demo ➜


httpbin delay virtualservice.yaml

apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: httpbin-vs-delay
  namespace: httpbin
spec:
  hosts:
  - httpbin.httpbin.svc.cluster.local
  http:
  - fault:
      delay:
        percentage:
          value: 100.0
        fixedDelay: 3s
    route:
    - destination:
        host: httpbin.httpbin.svc.cluster.local
        port:
          number: 8000

httpbon abort virtualservice.yaml

apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: httpbin-vs-abort
  namespace: httpbin
spec:
  hosts:
  - httpbin.httpbin.svc.cluster.local
  http:
  - fault:
      abort:
        percentage:
          value: 100.0
        httpStatus: 500
    route:
    - destination:
        host: httpbin.httpbin.svc.cluster.local
        port:
          number: 8000



root@controlplane ~/demo ➜  kubectl exec curl -n test -- curl --head http://httpbin.httpbin.svc.cluster.local:8000/get
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0    18    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 500 Internal Server Error
content-length: 18
content-type: text/plain
date: Sun, 31 Aug 2025 05:49:39 GMT
server: istio-envoy
x-envoy-decorator-operation: httpbin.httpbin.svc.cluster.local:8000/*

root@controlplane ~/demo ➜  kubectl exec curl -n test -- curl --head http://httpbin.httpbin.svc.cluster.local:8000/get
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0HTTP/1.1 500 Internal Server Error
content-length: 18
content-type: text/plain
date: Sun, 31 Aug 2025 05:49:41 GMT
server: istio-envoy
x-envoy-decorator-operation: httpbin.httpbin.svc.cluster.local:8000/*

  0    18    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0

root@controlplane ~/demo ➜  vim httpbin-vs-

