root@controlplane ~ ➜  k get  pods -n istio-system
NAME                     READY   STATUS    RESTARTS   AGE
istio-cni-node-zhpjw     1/1     Running   0          43s
istiod-86b6b7ff7-q56t8   1/1     Running   0          47s
ztunnel-nmlzj            1/1     Running   0          39s

root@controlplane ~ ➜  



root@controlplane ~ ➜  k get  pods -n istio-system
NAME                     READY   STATUS    RESTARTS   AGE
istio-cni-node-zhpjw     1/1     Running   0          43s
istiod-86b6b7ff7-q56t8   1/1     Running   0          47s
ztunnel-nmlzj            1/1     Running   0          39s

root@controlplane ~ ➜  k get ns --show-labels
NAME              STATUS   AGE     LABELS
default           Active   4h2m    kubernetes.io/metadata.name=default
hello             Active   3m18s   kubernetes.io/metadata.name=hello
istio-system      Active   3m31s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   4h2m    kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   4h2m    kubernetes.io/metadata.name=kube-public
kube-system       Active   4h2m    kubernetes.io/metadata.name=kube-system
test              Active   3m18s   kubernetes.io/metadata.name=test

root@controlplane ~ ➜  

root@controlplane ~ ➜  kubectl run curl --image=curlimages/curl -n test --restart=Never --command -- sleep infinity
pod/curl created

root@controlplane ~ ➜  k get pods -n test
NAME   READY   STATUS    RESTARTS   AGE
curl   1/1     Running   0          7s

root@controlplane ~ ➜  

root@controlplane ~ ➜  kubectl label namespace hello istio.io/dataplane-mode=ambient --overwrite
namespace/hello labeled

root@controlplane ~ ➜  kubectl get ns hello --show-labels
NAME    STATUS   AGE    LABELS
hello   Active   4m2s   istio.io/dataplane-mode=ambient,kubernetes.io/metadata.name=hello

root@controlplane ~ ➜  


root@controlplane ~ ➜  cat helloworld.yaml 
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
        image: registry.istio.io/release/examples-helloworld-v1:1.0
        resources:
          requests:
            cpu: "100m"
        imagePullPolicy: IfNotPresent #Always
        ports:
        - containerPort: 5000
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloworld-v2
  labels:
    app: helloworld
    version: v2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: helloworld
      version: v2
  template:
    metadata:
      labels:
        app: helloworld
        version: v2
    spec:
      containers:
      - name: helloworld
        image: registry.istio.io/release/examples-helloworld-v2:1.0
        resources:
          requests:
            cpu: "100m"
        imagePullPolicy: IfNotPresent #Always
        ports:
        - containerPort: 5000

root@controlplane ~ ➜  

root@controlplane ~ ➜ 

root@controlplane ~ ➜  kubectl apply -f helloworld.yaml -n hello
service/helloworld created
deployment.apps/helloworld-v1 created
deployment.apps/helloworld-v2 created

root@controlplane ~ ➜  k get pods -n hello
NAME                             READY   STATUS              RESTARTS   AGE
helloworld-v1-5dd8856698-vn2t4   0/1     ContainerCreating   0          10s
helloworld-v2-56df4c568b-2psjp   1/1     Running             0          10s

root@controlplane ~ ➜  k get svc -n hello
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
helloworld   ClusterIP   10.104.229.6   <none>        5000/TCP   15s

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl apply -f peer-auth-global.yaml
peerauthentication.security.istio.io/default created

root@controlplane ~ ➜  k get peerauthentications.security.istio.io -A
NAMESPACE      NAME      MODE     AGE
istio-system   default   STRICT   7s

root@controlplane ~ ➜  cat peer-auth-global.yaml 
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT

root@controlplane ~ ➜  



root@controlplane ~ ✖ kubectl label namespace test istio.io/dataplane-mode=ambient --overwrite
namespace/test labeled

root@controlplane ~ ➜  k get ns test --show-labels
NAME   STATUS   AGE     LABELS
test   Active   7m15s   istio.io/dataplane-mode=ambient,kubernetes.io/metadata.name=test

root@controlplane ~ ➜  kubectl exec -n test curl -- curl --head helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
  0      0   0      0   0      0      0      0                              0HTTP/1.1 200 OK
Server: gunicorn
Date: Tue, 23 Jun 2026 23:49:32 GMT
Connection: keep-alive
Content-Type: text/html; charset=utf-8
Content-Length: 60

  0     60   0      0   0      0      0      0                              0

root@controlplane ~ ➜  



root@controlplane ~ ➜  cat hello-world-auth-policy.yaml 
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

root@controlplane ~ ➜  kubectl apply -f hello-world-auth-policy.yaml
authorizationpolicy.security.istio.io/hello-world-auth-policy created

root@controlplane ~ ➜  kubectl get authorizationpolicies -n hello
NAME                      ACTION   AGE
hello-world-auth-policy   ALLOW    2s

root@controlplane ~ ➜  kubectl exec -n test curl -- curl --head helloworld.hello.svc.cluster.local:5000/hello || true
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
  0      0   0      0   0      0      0      0                              0
curl: (56) Recv failure: Connection reset by peer
command terminated with exit code 56

root@controlplane ~ ➜  

You should see a Connection rest by peer.
Why is it not working? Both the test and hello namespace are labeled correctly right? 

HTTP Methods are Layer 7 so we need what? That’s right, 
we need a Waypoint Proxy in the hello namespace.




root@controlplane ~ ➜  istioctl waypoint apply -n hello
✅ waypoint hello/waypoint applied

root@controlplane ~ ➜  kubectl label namespace hello istio.io/use-waypoint=waypoint --overwrite
namespace/hello labeled

root@controlplane ~ ➜  k get ns hello --show-labels
NAME    STATUS   AGE     LABELS
hello   Active   9m34s   istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=hello

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl delete pods -l app=helloworld -n hello
pod "helloworld-v1-5dd8856698-vn2t4" deleted
pod "helloworld-v2-56df4c568b-2psjp" deleted

root@controlplane ~ ➜  kubectl get pods -n hello -o wide
NAME                             READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
helloworld-v1-5dd8856698-ws9mr   1/1     Running   0          4s    10.50.0.11   controlplane   <none>           <none>
helloworld-v2-56df4c568b-pxzcn   1/1     Running   0          4s    10.50.0.12   controlplane   <none>           <none>
waypoint-b8d5bf7c5-fk6hh         1/1     Running   0          39s   10.50.0.10   controlplane   <none>           <none>

root@controlplane ~ ➜  


root@controlplane ~ ➜  cat > hello-world-auth-policy-v2.yaml <<'EOF'
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
EOF

root@controlplane ~ ➜  cat hello-world-auth-policy-v2.yaml 
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

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl apply -f hello-world-auth-policy-v2.yaml
authorizationpolicy.security.istio.io/hello-world-auth-policy created

root@controlplane ~ ➜  kubectl get authorizationpolicies -n hello
NAME                      ACTION   AGE
hello-world-auth-policy   ALLOW    3s

root@controlplane ~ ➜  kubectl exec -n test curl -- curl --head helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed  Time    Time    Time   Current
                                 Dload  Upload  Total   Spent   Left   Speed
  0     60   0      0   0      0      0      0                              0
HTTP/1.1 200 OK
server: istio-envoy
date: Tue, 23 Jun 2026 23:53:39 GMT
content-type: text/html; charset=utf-8
content-length: 60
x-envoy-upstream-service-time: 77
x-envoy-decorator-operation: helloworld.hello.svc.cluster.local:5000/*


root@controlplane ~ ➜  



root@controlplane ~ ➜  k create ns web
namespace/web created

root@controlplane ~ ➜  kubectl label namespace web istio.io/dataplane-mode=ambient --overwrite
namespace/web labeled

root@controlplane ~ ➜  k get ns web --show-labels
NAME   STATUS   AGE   LABELS
web    Active   24s   istio.io/dataplane-mode=ambient,kubernetes.io/metadata.name=web

root@controlplane ~ ➜  k run app --image nginx -n web
pod/app created

root@controlplane ~ ➜  kubectl exec -n web app -- curl --head helloworld.hello.svc.cluster.local:5000/hello
error: Internal error occurred: unable to upgrade connection: container not found ("app")

root@controlplane ~ ✖ kubectl exec -n web app -- curl --head helloworld.hello.svc.cluster.local:5000/hello
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0    19    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 403 Forbidden
content-length: 19
content-type: text/plain
date: Tue, 23 Jun 2026 23:55:12 GMT
server: istio-envoy
x-envoy-decorator-operation: helloworld.hello.svc.cluster.local:5000/*


root@controlplane ~ ➜  


kubectl label namespace web istio.io/dataplane-mode=ambient --overwrite

kubectl run app -n web --image=nginx --restart=Never --command -- sleep infinity

root@controlplane ~ ➜  kubectl exec -n web app -- curl -sS --head helloworld.hello.svc.cluster.local:5000/hello || true
HTTP/1.1 403 Forbidden
content-length: 19
content-type: text/plain
date: Tue, 23 Jun 2026 23:55:58 GMT
server: istio-envoy
x-envoy-decorator-operation: helloworld.hello.svc.cluster.local:5000/*


root@controlplane ~ ➜  