Istio Ambient – Traffic Management

Observe the reasons behind the initial failure of a 95/5 Layer 7 split in Ambient.

Enable a Waypoint and transition to the Gateway API (HTTPRoute) for proper Layer 7 traffic-splitting.
and Layer 7 fault injection (delay and abort) on httpbin.



root@controlplane ~ ➜  k get pods -n istio-system
NAME                     READY   STATUS    RESTARTS   AGE
istio-cni-node-sv9qf     1/1     Running   0          98s
istiod-86b6b7ff7-tvdpb   1/1     Running   0          103s
ztunnel-px6xg            1/1     Running   0          94s

root@controlplane ~ ➜  


root@controlplane ~ ➜  k get ns
NAME              STATUS   AGE
default           Active   46m
hello             Active   109s
httpbin           Active   109s
istio-system      Active   2m2s
kube-node-lease   Active   46m
kube-public       Active   46m
kube-system       Active   46m
test              Active   109s

root@controlplane ~ ➜  k get all -n test
NAME       READY   STATUS    RESTARTS   AGE
pod/curl   1/1     Running   0          117s

root@controlplane ~ ➜  


root@controlplane ~ ➜  ls -rlth
total 12K
drwx------ 3 root root 4.0K Jan 22  2025 snap
-rw-r--r-- 1 root root 1.5K Jun 23 15:32 httpbin.yaml
-rw-r--r-- 1 root root 1.3K Jun 23 15:32 helloworld.yaml

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

root@controlplane ~ ➜  cat httpbin.yaml 
# Copyright Istio Authors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

##################################################################################################
# httpbin service
##################################################################################################
apiVersion: v1
kind: ServiceAccount
metadata:
  name: httpbin
---
apiVersion: v1
kind: Service
metadata:
  name: httpbin
  labels:
    app: httpbin
    service: httpbin
spec:
  ports:
  - name: http
    port: 8000
    targetPort: 8080
  selector:
    app: httpbin
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
      version: v1
  template:
    metadata:
      labels:
        app: httpbin
        version: v1
    spec:
      serviceAccountName: httpbin
      containers:
      - image: docker.io/mccutchen/go-httpbin:v2.15.0
        imagePullPolicy: IfNotPresent
        name: httpbin
        ports:
        - containerPort: 8080

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl apply -f helloworld.yaml -n hello
service/helloworld created
deployment.apps/helloworld-v1 created
deployment.apps/helloworld-v2 created

root@controlplane ~ ➜  kubectl get pods -n hello 
kubectl get svc -n hello
NAME                             READY   STATUS              RESTARTS   AGE
helloworld-v1-5dd8856698-w5vqw   0/1     ContainerCreating   0          6s
helloworld-v2-56df4c568b-cggvc   0/1     ContainerCreating   0          6s
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
helloworld   ClusterIP   10.105.92.21   <none>        5000/TCP   6s

root@controlplane ~ ➜  



Create a DestinationRule named hello-world-dr in the hello namespace.

This rule should target the helloworld service and include subsets for both v1 and v2, 
corresponding to the version labels on the pods: version: v1 and version: v2.


root@controlplane ~ ➜  vim hello-dr.yaml

root@controlplane ~ ➜  k apply -f hello-dr.yaml -n hello
destinationrule.networking.istio.io/hello-world-dr created

root@controlplane ~ ➜  cat hello-dr.yaml 
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

root@controlplane ~ ➜  



Create a VirtualService named hello-world-vs in the hello namespace 
to attempt a 95/5 traffic split between v1 and v2.

This VirtualService should route 95% of traffic to the v1 subset and 5% to the v2 subset.

root@controlplane ~ ➜  vim hello-vs.yaml

root@controlplane ~ ➜  cat hello-vs.yaml 
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: hello-world-vs
  namespace: hello
spec:
  hosts:
  - helloworld
  http:
  - route:
    - destination:
        host: helloworld.hello.svc.cluster.local
        port:
          number: 5000
        subset: v1
      weight: 95
    - destination:
        host: helloworld.hello.svc.cluster.local
        port:
          number: 5000
        subset: v2
      weight: 5

root@controlplane ~ ➜  k apply -f hello-vs.yaml -n hello
virtualservice.networking.istio.io/hello-world-vs created

root@controlplane ~ ➜  k get vs -n hello
NAME             GATEWAYS   HOSTS            AGE
hello-world-vs              ["helloworld"]   9s

root@controlplane ~ ➜  k get dr -n hello
NAME             HOST         AGE
hello-world-dr   helloworld   107s

root@controlplane ~ ➜  

root@controlplane ~ ➜  for i in {1..10}; do kubectl exec curl -n test -- curl -s helloworld.hello.svc.cluster.local:5000/hello; done
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v2, instance: helloworld-v2-56df4c568b-cggvc
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v2, instance: helloworld-v2-56df4c568b-cggvc
Hello version: v2, instance: helloworld-v2-56df4c568b-cggvc
Hello version: v2, instance: helloworld-v2-56df4c568b-cggvc
Hello version: v2, instance: helloworld-v2-56df4c568b-cggvc
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw

root@controlplane ~ ➜  



Doesnot seem correct right? 95% of all traffic should be going to v1 but instead itss alternating 50/50. Why is that?
Inspect the hello namespace by running:

kubectl get ns --show-labels

Is there something missing? Unfortunately, 
in order to use split traffic capabilities we need to use the Waypoint Proxy.

This demonstrates a key limitation of Ambient mode without Waypoint proxies - 
advanced Layer 7 features like weighted routing require a Waypoint to be enabled.




root@controlplane ~ ➜  k get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   54m   kubernetes.io/metadata.name=default
hello             Active   10m   kubernetes.io/metadata.name=hello
httpbin           Active   10m   kubernetes.io/metadata.name=httpbin
istio-system      Active   10m   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   54m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   54m   kubernetes.io/metadata.name=kube-public
kube-system       Active   54m   kubernetes.io/metadata.name=kube-system
test              Active   10m   istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=test

root@controlplane ~ ➜  kubectl label ns hello  istio.io/dataplane-mode=ambient istio.io/use-waypoint=waypoint --overwrite
namespace/hello labeled

root@controlplane ~ ➜  k get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   55m   kubernetes.io/metadata.name=default
hello             Active   10m   istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=hello
httpbin           Active   10m   kubernetes.io/metadata.name=httpbin
istio-system      Active   11m   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   55m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   55m   kubernetes.io/metadata.name=kube-public
kube-system       Active   55m   kubernetes.io/metadata.name=kube-system
test              Active   10m   istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=test

root@controlplane ~ ➜  istioctl waypoint apply -n hello 
✅ waypoint hello/waypoint applied

root@controlplane ~ ➜  k get all -n hello
NAME                                 READY   STATUS    RESTARTS   AGE
pod/helloworld-v1-5dd8856698-w5vqw   1/1     Running   0          8m12s
pod/helloworld-v2-56df4c568b-cggvc   1/1     Running   0          8m12s
pod/waypoint-b8d5bf7c5-kc59w         1/1     Running   0          9s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)               AGE
service/helloworld   ClusterIP   10.105.92.21   <none>        5000/TCP              8m12s
service/waypoint     ClusterIP   10.96.21.34    <none>        15021/TCP,15008/TCP   9s

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloworld-v1   1/1     1            1           8m12s
deployment.apps/helloworld-v2   1/1     1            1           8m12s
deployment.apps/waypoint        1/1     1            1           9s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/helloworld-v1-5dd8856698   1         1         1       8m12s
replicaset.apps/helloworld-v2-56df4c568b   1         1         1       8m12s
replicaset.apps/waypoint-b8d5bf7c5         1         1         1       9s

root@controlplane ~ ➜  



root@controlplane ~ ➜  kubectl delete virtualservice hello-world-vs -n hello --ignore-not-found
virtualservice.networking.istio.io "hello-world-vs" deleted
root@controlplane ~ ➜

root@controlplane ~ ➜  kubectl delete destinationrule hello-world-dr -n hello --ignore-not-found 
destinationrule.networking.istio.io "hello-world-dr" deleted
root@controlplane ~ ➜

root@controlplane ~ ➜  k get vs -n hello
No resources found in hello namespace.

root@controlplane ~ ➜  k get dr -n hello
No resources found in hello namespace.

root@controlplane ~ ➜  



Create an HTTPRoute named hello-http-split-traffic in the hello namespace 
to achieve the 95/5 traffic split using Gateway API.


The HTTPRoute should reference the main helloworld service as a parentRef 
and distribute traffic to separate helloworld-v1 and helloworld-v2 services with 95/5 weights.


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


root@controlplane ~ ➜  kubectl apply -n hello -f helloworld.yaml
service/helloworld unchanged
service/helloworld-v1 created
service/helloworld-v2 created
deployment.apps/helloworld-v1 unchanged
deployment.apps/helloworld-v2 unchanged

root@controlplane ~ ➜  kubectl get svc -n hello
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)               AGE
helloworld      ClusterIP   10.105.92.21     <none>        5000/TCP              12m
helloworld-v1   ClusterIP   10.110.226.213   <none>        5000/TCP              8s
helloworld-v2   ClusterIP   10.105.1.227     <none>        5000/TCP              8s
waypoint        ClusterIP   10.96.21.34      <none>        15021/TCP,15008/TCP   4m39s

root@controlplane ~ ➜  


root@controlplane ~ ➜  cat > hello-httproute-split-traffic.yaml <<'EOF'
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
EOF

root@controlplane ~ ➜  cat hello-httproute-split-traffic.yaml 
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

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl apply -f hello-httproute-split-traffic.yaml -n hello
httproute.gateway.networking.k8s.io/hello-http-split-traffic created

root@controlplane ~ ➜  k get httproutes.gateway.networking.k8s.io  -n hello
NAME                       HOSTNAMES   AGE
hello-http-split-traffic               11s
root@controlplane ~ ➜



root@controlplane ~ ➜  for i in {1..20}; do kubectl exec curl -n test -- curl -s helloworld.hello.svc.cluster.local:5000/hello; done
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v2, instance: helloworld-v2-56df4c568b-cggvc
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw
Hello version: v1, instance: helloworld-v1-5dd8856698-w5vqw

root@controlplane ~ ➜  

You should now see approximately 95% of responses from v1 and 5% from v2:

for i in {1..20}; do kubectl exec curl -n test -- curl -s helloworld.hello.svc.cluster.local:5000/hello; done

This demonstrates how Waypoint proxies enable Layer 7 capabilities in Ambient mode, 
allowing for precise traffic splitting using the Gateway API HTTPRoute resource.

The HTTPRoute provides a more modern, 
Kubernetes-native approach to traffic management compared to 
Istios VirtualService when using Ambient mode.

