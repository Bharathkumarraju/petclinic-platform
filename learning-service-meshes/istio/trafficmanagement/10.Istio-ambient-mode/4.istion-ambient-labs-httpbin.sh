root@controlplane ~ ➜  k get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   67m   kubernetes.io/metadata.name=default
hello             Active   23m   istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=hello
httpbin           Active   23m   kubernetes.io/metadata.name=httpbin
istio-system      Active   23m   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   67m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   67m   kubernetes.io/metadata.name=kube-public
kube-system       Active   67m   kubernetes.io/metadata.name=kube-system
test              Active   23m   istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=test

root@controlplane ~ ➜  kubectl label namespace httpbin istio.io/dataplane-mode=ambient istio.io/use-waypoint=waypoint --overwrite
namespace/httpbin labeled

root@controlplane ~ ➜  k get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   68m   kubernetes.io/metadata.name=default
hello             Active   23m   istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=hello
httpbin           Active   23m   istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=httpbin
istio-system      Active   23m   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   68m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   68m   kubernetes.io/metadata.name=kube-public
kube-system       Active   68m   kubernetes.io/metadata.name=kube-system
test              Active   23m   istio.io/dataplane-mode=ambient,istio.io/use-waypoint=waypoint,kubernetes.io/metadata.name=test

root@controlplane ~ ➜  


root@controlplane ~ ➜  istioctl waypoint apply -n httpbin 
✅ waypoint httpbin/waypoint applied

root@controlplane ~ ➜  k get pods -n httpbin 
NAME                        READY   STATUS    RESTARTS   AGE
waypoint-867754678b-s2lcz   1/1     Running   0          10s

root@controlplane ~ ➜  

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

root@controlplane ~ ➜  k apply -f httpbin.yaml -n httpbin 
serviceaccount/httpbin created
service/httpbin created
deployment.apps/httpbin created

root@controlplane ~ ➜  k get all -n httpbin
NAME                            READY   STATUS    RESTARTS   AGE
pod/httpbin-686d6fc899-zfn4f    1/1     Running   0          7s
pod/waypoint-867754678b-s2lcz   1/1     Running   0          53s

NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)               AGE
service/httpbin    ClusterIP   10.109.240.193   <none>        8000/TCP              7s
service/waypoint   ClusterIP   10.98.186.77     <none>        15021/TCP,15008/TCP   53s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/httpbin    1/1     1            1           7s
deployment.apps/waypoint   1/1     1            1           53s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/httpbin-686d6fc899    1         1         1       7s
replicaset.apps/waypoint-867754678b   1         1         1       53s

root@controlplane ~ ➜  kubectl exec curl -n test -- curl -s httpbin.httpbin.svc.cluster.local:8000/get
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
      "curl/8.20.0"
    ],
    "X-Forwarded-Proto": [
      "http"
    ],
    "X-Request-Id": [
      "fe59a112-b88d-4f43-bd7a-33d441eb6e0c"
    ]
  },
  "method": "GET",
  "origin": "10.50.0.11:44993",
  "url": "http://httpbin.httpbin.svc.cluster.local:8000/get"
}

root@controlplane ~ ➜  


Create a VirtualService named httpbin-vs-delay in the httpbin namespace 
to inject a 3-second delay on all requests to /get endpoint.


This VirtualService should apply a fixed 3-second delay 
to 100% of requests matching the /get URI prefix.


root@controlplane ~ ➜  cat httpbin-vs-delay.yaml 
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: httpbin-vs-delay
  namespace: httpbin
spec:
  hosts:
  - httpbin.httpbin.svc.cluster.local
  http:
  - match:
    - uri:
        prefix: /get
    fault:
      delay:
        percentage:
          value: 100.0
        fixedDelay: 3s
    route:
    - destination:
        host: httpbin.httpbin.svc.cluster.local
        port:
          number: 8000

root@controlplane ~ ➜  kubectl apply -f httpbin-vs-delay.yaml
virtualservice.networking.istio.io/httpbin-vs-delay created

root@controlplane ~ ➜  kubectl get virtualservice -n httpbin 
NAME               GATEWAYS   HOSTS                                   AGE
httpbin-vs-delay              ["httpbin.httpbin.svc.cluster.local"]   6s

root@controlplane ~ ➜  kubectl exec curl -n test -- curl -s -o /dev/null -w '%{time_total}\n' http://httpbin.httpbin.svc.cluster.local:8000/get
3.008985

root@controlplane ~ ➜  kubectl exec curl -n test -- curl -s -o /dev/null -w '%{time_total}\n' http://httpbin.httpbin.svc.cluster.local:8000/get
3.004988

root@controlplane ~ ➜  



Create VirtualService httpbin-vs-abort (namespace httpbin) 
with explicit metadata and a 500 abort on /get:


root@controlplane ~ ➜  cat httpbin-vs-abort.yaml 
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: httpbin-vs-abort
  namespace: httpbin
spec:
  hosts:
  - httpbin.httpbin.svc.cluster.local
  http:
  - match:
    - uri:
        prefix: /get
    fault:
      abort:
        percentage:
          value: 100.0
        httpStatus: 500
    route:
    - destination:
        host: httpbin.httpbin.svc.cluster.local
        port:
          number: 8000

root@controlplane ~ ➜  kubectl apply -f httpbin-vs-abort.yaml
virtualservice.networking.istio.io/httpbin-vs-abort created

root@controlplane ~ ➜  kubectl get virtualservice -n httpbin
NAME               GATEWAYS   HOSTS                                   AGE
httpbin-vs-abort              ["httpbin.httpbin.svc.cluster.local"]   4s

root@controlplane ~ ➜  

root@controlplane ~ ➜  kubectl exec curl -n test -- curl -s -o /dev/null -w '%{http_code}\n' http://httpbin.httpbin.svc.cluster.local:8000/get
500

root@controlplane ~ ➜  kubectl exec curl -n test -- curl -s -o /dev/null -w '%{http_code}\n' http://httpbin.httpbin.svc.cluster.local:8000/get
500

root@controlplane ~ ➜  kubectl exec curl -n test -- curl -s -o /dev/null -w '%{http_code}\n' http://httpbin.httpbin.svc.cluster.local:8000/get
500

root@controlplane ~ ➜ 


root@controlplane ~ ➜  cat httpbin-vs-abort.yaml
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: httpbin-vs-abort
  namespace: httpbin
spec:
  hosts:
  - httpbin.httpbin.svc.cluster.local
  http:
  - match:
    - uri:
        prefix: /get
    fault:
      abort:
        percentage:
          value: 100.0
        httpStatus: 404 
    route:
    - destination:
        host: httpbin.httpbin.svc.cluster.local
        port:
          number: 8000

root@controlplane ~ ➜  

root@controlplane ~ ➜  kubectl exec curl -n test -- curl -s -o /dev/null -w '%{http_code}\n' http://httpbin.httpbin.svc.cluster.local:8000/get
404

root@controlplane ~ ➜  kubectl exec curl -n test -- curl -s -o /dev/null -w '%{http_code}\n' http://httpbin.httpbin.svc.cluster.local:8000/get
404

root@controlplane ~ ➜ 

