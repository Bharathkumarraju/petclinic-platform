root@controlplane ~ ➜  kubectl get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   21m   istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   51s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   21m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   21m   kubernetes.io/metadata.name=kube-public
kube-system       Active   21m   kubernetes.io/metadata.name=kube-system

root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/helloworld/helloworld.yaml
service/helloworld created
deployment.apps/helloworld-v1 created
deployment.apps/helloworld-v2 created
root@controlplane ~ ➜

root@controlplane ~ ➜  kubectl run test --image=nginx
pod/test created

root@controlplane ~ ➜  kubectl get pods
NAME                             READY   STATUS           RESTARTS   AGE
helloworld-v1-7459d7b54b-lqtl6   2/2     Running          0          25s
helloworld-v2-654d97458-7vpz4    2/2     Running          0          25s
test                             0/2     PodInitializing  0          5s

root@controlplane ~ ➜  kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
helloworld   ClusterIP   10.111.16.180    <none>        5000/TCP   37s
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP    22m

root@controlplane ~ ➜  kubectl exec -ti test -- curl http://helloworld:5000/hello
Hello version: v2, instance: helloworld-v2-654d97458-7vpz4

root@controlplane ~ ➜  kubectl exec -ti test -- curl http://helloworld:5000/hello
Hello version: v1, instance: helloworld-v1-7459d7b54b-lqtl6

root@controlplane ~ ➜



apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: hello-world-vs
spec:
  hosts:
  - helloworld
  http:
  - fault:
      delay:
        percentage:
          value: 100.0
        fixedDelay: 5s
    route:
    - destination:
        host: helloworld
        port:
          number: 5000
---
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: hello-world-vs
spec:
  hosts:
  - helloworld
  http:
  - fault:
      abort:
        percentage:
          value: 100.0
        httpStatus: 500
    route:
    - destination:
        host: helloworld
        port:
          number: 5000



root@controlplane ~ ➜  kubectl exec -ti test -- curl --head http://helloworld:5000/hello
HTTP/1.1 404 Not Found
content-length: 18
content-type: text/plain
date: Tue, 15 Apr 2025 15:58:18 GMT
server: envoy

root@controlplane ~ ➜  vim vs.yaml
root@controlplane ~ ➜  kubectl apply -f vs.yaml
virtualservice.networking.istio.io/hello-world-vs configured

root@controlplane ~ ➜  kubectl exec -ti test -- curl --head http://helloworld:5000/hello
root@controlplane ~ ✖ kubectl exec -ti test -- /bin/sh -c 'for i in $(seq 1 10); do curl --head helloworld.default.svc:5000/hello; echo "---"; done'