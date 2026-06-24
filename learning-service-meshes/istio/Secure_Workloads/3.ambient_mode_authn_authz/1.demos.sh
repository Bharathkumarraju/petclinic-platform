root@controlplane ~ ➜  kubectl get pods -n istio-system
NAME                             READY   STATUS    RESTARTS   AGE
istio-cni-node-zr8pb             1/1     Running   0          57s
istiod-6b854648cc-ppq86          1/1     Running   0          65s
ztunnel-9wjg7                    1/1     Running   0          51s

root@controlplane ~ ➜



root@controlplane ~ ➜  kubectl run curl --image=curlimages/curl -n test --restart=Never --command -- sleep infinity
pod/curl created

root@controlplane ~ ➜  kubectl get pods -n test
NAME   READY   STATUS    RESTARTS   AGE
curl   1/1     Running   0          4s

root@controlplane ~ ➜



root@controlplane ~ ➜  cd demo/

root@controlplane ~/demo ➜  ll
total 12
drwxr-xr-x  2 root root 4096 Sep  1 05:33 ./
drwx------ 10 root root 4096 Sep  1 05:33 ../
-rw-r--r--  1 root root 1303 Sep  1 05:33 helloworld.yaml

root@controlplane ~/demo ➜  kubectl label namespace hello istio.io/dataplane-mode=ambient
namespace/hello labeled

root@controlplane ~/demo ➜



root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/helloworld/helloworld.yaml -n hello 
service/helloworld created
deployment.apps/helloworld-v1 created
deployment.apps/helloworld-v2 created

root@controlplane ~ ➜


root@controlplane ~/demo ➜  kubectl get pods -n hello
NAME                             READY   STATUS    RESTARTS   AGE
helloworld-v1-7459d7b54b-q72j5   1/1     Running   0          9s
helloworld-v2-654d97458-kxkxm    1/1     Running   0          9s

root@controlplane ~/demo ➜  kubectl get svc -n hello
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
helloworld   ClusterIP   10.100.96.89   <none>        5000/TCP   13s

root@controlplane ~/demo ➜  vim global-pa.yaml

apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT


root@controlplane ~/demo ➜  kubectl apply -f global-pa.yaml
peerauthentication.security.istio.io/default created

root@controlplane ~/demo ➜  kubectl get peerauthentications.security.istio.io -A
NAMESPACE      NAME      MODE     AGE
istio-system   default   STRICT   6s

root@controlplane ~/demo ➜  kubectl exec -n test curl -- curl --head http://helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
curl: (56) Recv failure: Connection reset by peer
command terminated with exit code 56

root@controlplane ~/demo ✗



root@controlplane ~/demo ✗ kubectl get ns --show-labels
NAME              STATUS   AGE     LABELS
default           Active   6m10s   kubernetes.io/metadata.name=default
hello             Active   4m39s   istio.io/dataplane-mode=ambient,kubernetes.io/metadata.name=hello
istio-system      Active   4m13s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   6m10s   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   6m10s   kubernetes.io/metadata.name=kube-public
kube-system       Active   6m10s   kubernetes.io/metadata.name=kube-system
test              Active   4m42s   kubernetes.io/metadata.name=test

root@controlplane ~/demo ➜  kubectl label namespace test istio.io/dataplane-mode=ambient
label namespace/test labeled
root@controlplane ~/demo ➜ 

root@controlplane ~/demo ➜  kubectl exec -n test curl -- curl --head http://helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0    59    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 200 OK
Server: gunicorn
Date: Mon, 01 Sep 2025 05:38:34 GMT
Connection: keep-alive
Content-Type: text/html; charset=utf-8
Content-Length: 59

root@controlplane ~/demo ➜



Authorization Policy for ambient mode:
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: hello-world-auth-policy
  namespace: hello
spec:
  action: ALLOW
  selector:
    matchLabels:
      app: helloworld
  rules:
  - from:
    - source:
        namespaces: ["test"]
    to:
    - operation:
        methods: ["GET", "HEAD"]


root@controlplane ~/demo ➜  vim hw-auth-policy.yaml

root@controlplane ~/demo ➜  kubectl apply -f hw-auth-policy.yaml
authorizationpolicy.security.istio.io/hello-world-auth-policy created

root@controlplane ~/demo ➜  kubectl get authorizationpolicies.security.istio.io -A
NAMESPACE   NAME                       ACTION   AGE
hello       hello-world-auth-policy   ALLOW    5s

root@controlplane ~/demo ➜  kubectl exec -n test curl -- curl --head http://helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
curl: (56) Recv failure: Connection reset by peer
command terminated with exit code 56

root@controlplane ~/demo ✗

So the catch is we need a waypoint proxy to be deployed in the hello namespace 
to allow the traffic from test namespace to reach the helloworld service. 

The waypoint proxy will handle the authentication and authorization for the ambient mode.


root@controlplane ~/demo ➜  istioctl waypoint apply -n hello
✅waypoint hello/waypoint applied

root@controlplane ~/demo ➜  kubectl get pods -n hello
NAME                             READY   STATUS    RESTARTS   AGE
helloworld-v1-7459d7b54b-q72j5   1/1     Running   0          5m35s
helloworld-v2-654d97458-kxkxm    1/1     Running   0          5m35s
waypoint-795d979b85-r7669        0/1     Running   0          5s

root@controlplane ~/demo ➜  kubectl get pods -n hello
NAME                             READY   STATUS    RESTARTS   AGE
helloworld-v1-7459d7b54b-q72j5   1/1     Running   0          5m40s
helloworld-v2-654d97458-kxkxm    1/1     Running   0          5m40s
waypoint-795d979b85-r7669        1/1     Running   0          10s

root@controlplane ~/demo ➜  kubectl get ns hello --show-labels
NAME    STATUS   AGE     LABELS
hello   Active   8m29s   istio.io/dataplane-mode=ambient,kubernetes.io/metadata.name=hello

root@controlplane ~/demo ➜ 

root@controlplane ~/demo ✗  kubectl label namespace hello istio.io/use-waypoint=waypoint
namespace/hello labeled

root@controlplane ~/demo ➜


root@controlplane ~/demo ➜  kubectl get ns --show-labels
NAME              STATUS   AGE     LABELS
default           Active   10m     kubernetes.io/metadata.name=default
hello             Active   8m53s   istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=hello
istio-system      Active   8m27s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   10m     kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   10m     kubernetes.io/metadata.name=kube-public
kube-system       Active   10m     kubernetes.io/metadata.name=kube-system
test              Active   8m56s   istio.io/dataplane-mode=ambient,kubernetes.io/metadata.name=test

root@controlplane ~/demo ➜


root@controlplane ~/demo ➜  kubectl exec -n test curl -- curl --head http://helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0HTTP/1.1 503 Service Unavailable
content-length: 95
content-type: text/plain
date: Mon, 01 Sep 2025 05:42:25 GMT
server: istio-envoy
x-envoy-decorator-operation: helloworld.hello.svc.cluster.local:5000/*

  0    95    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0

root@controlplane ~/demo ➜

So the problem is authorization policy.

So we need to update the authorization policy to use the source principal instead of the source namespace.
also targetref should be used instead of selector to target the helloworld service.

root@controlplane ~/demo ➜  cat hw-auth-policy-v2.yaml
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: hello-world-auth-policy
  namespace: hello
spec:
  targetRefs:
  - kind: Service
    group: ""
    name: helloworld
  action: ALLOW
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/test/sa/default
    to:
    - operation:
        methods: ["GET", "HEAD"]



root@controlplane ~/demo ➜  kubectl get authorizationpolicies.security.istio.io -A
NAMESPACE   NAME                       ACTION   AGE
hello       hello-world-auth-policy   ALLOW    4s

root@controlplane ~/demo ➜  kubectl exec -n test curl -- curl --head http://helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0    60    HTTP/1.1 200 OK 0      0      0 --:--:-- --:--:-- --:--:--     0
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0server: istio-envoy
date: Mon, 01 Sep 2025 05:46:38 GMT
content-type: text/html; charset=utf-8
content-length: 60
x-envoy-upstream-service-time: 104
x-envoy-decorator-operation: helloworld.hello.svc.cluster.local:5000/*

  0    60    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0

root@controlplane ~/demo ➜

