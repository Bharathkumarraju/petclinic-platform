root@controlplane ~ ➜  vim peer_auth.yaml

root@controlplane ~ ➜  cat peer_auth.yaml 
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: default
spec:
  mtls:
    mode: STRICT

root@controlplane ~ ➜  kubectl apply -f peer_auth.yaml 
peerauthentication.security.istio.io/default created

root@controlplane ~ ➜  kubectl get peerauthentications.security.istio.io  -A
NAMESPACE   NAME      MODE     AGE
default     default   STRICT   14s

root@controlplane ~ ➜  

root@controlplane ~ ✖ kubectl exec -it test -n test -- bash
root@test:/# curl --head productpage.default.svc
^C
root@test:/# curl --head productpage.default.svc:9080
curl: (56) Recv failure: Connection reset by peer
root@test:/# 

root@controlplane ~ ✖ kubectl label namespace test istio-injection=enabled
namespace/test labeled

root@controlplane ~ ➜ 

root@controlplane ~ ✖ kubectl get ns --show-labels
NAME              STATUS   AGE     LABELS
default           Active   52m     istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   10m     kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   52m     kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   52m     kubernetes.io/metadata.name=kube-public
kube-system       Active   52m     kubernetes.io/metadata.name=kube-system
test              Active   7m22s   istio-injection=enabled,kubernetes.io/metadata.name=test

root@controlplane ~ ➜  



root@controlplane ~ ➜  kubectl delete pods test -n test
pod "test" deleted

root@controlplane ~ ➜  kubectl run test --image nginx -n test
pod/test created

root@controlplane ~ ➜  kubectl exec -it test -n test -- bash
root@test:/# curl --head productpage.default.svc
^C
root@test:/# exit
exit
command terminated with exit code 130

root@controlplane ~ ✖ kubectl get pods -n test
NAME   READY   STATUS    RESTARTS   AGE
test   2/2     Running   0          34s

root@controlplane ~ ➜  kubectl exec -it test -n test -- bash
root@test:/# curl --head productpage.default.svc
^C
root@test:/# curl --head productpage.default.svc:9080
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 1683
server: envoy
date: Mon, 22 Jun 2026 05:05:33 GMT
x-envoy-upstream-service-time: 9

root@test:/# exit
exit

root@controlplane ~ ➜  



root@controlplane ~ ➜  vi sidecar_default_namespace.yaml

root@controlplane ~ ➜  k apply -f sidecar_default_namespace.yaml
sidecar.networking.istio.io/default created

root@controlplane ~ ➜  cat sidecar_default_namespace.yaml 
apiVersion: networking.istio.io/v1
kind: Sidecar
metadata:
  name: default
  namespace: test
spec:
  egress:
  - hosts:
    - "./*"
    - "istio-system/*"

root@controlplane ~ ➜  


root@controlplane ~ ✖ vim sidecar_default_namespace.yaml 

root@controlplane ~ ➜  k apply -f sidecar_default_namespace.yaml
sidecar.networking.istio.io/default configured

root@controlplane ~ ➜  kubectl exec -ti -n test test -- /bin/bash
root@test:/# curl --head productpage.default.svc.cluster.local:9080
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 1683
server: envoy
date: Mon, 22 Jun 2026 05:07:48 GMT
x-envoy-upstream-service-time: 6

root@test:/# exit
exit

root@controlplane ~ ➜  cat sidecar_default_namespace.yaml 
apiVersion: networking.istio.io/v1
kind: Sidecar
metadata:
  name: default
  namespace: test
spec:
  egress:
  - hosts:
    - "./*"
    - "default/*"
    - "istio-system/*"

root@controlplane ~ ➜  



root@controlplane ~ ✖ k apply -f sidecar_default_namespace.yaml
sidecar.networking.istio.io/default configured

root@controlplane ~ ➜  kubectl exec -ti -n test test -- /bin/bash
root@test:/# curl --head productpage.default.svc.cluster.local:9080
curl: (52) Empty reply from server
root@test:/# kubectl run nginx --image=nginx -n test^C
root@test:/# exit
exit
command terminated with exit code 130

root@controlplane ~ ✖ kubectl run nginx --image=nginx -n test
pod/nginx created

root@controlplane ~ ➜  kubectl exec -ti -n test nginx -- /bin/bash
root@nginx:/# curl --head productpage.default.svc.cluster.local:9080
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 1683
server: envoy
date: Mon, 22 Jun 2026 05:10:17 GMT
x-envoy-upstream-service-time: 10

root@nginx:/# exit  
exit

root@controlplane ~ ➜  cat sidecar_default_namespace
cat: sidecar_default_namespace: No such file or directory

root@controlplane ~ ✖ cat sidecar_default_namespace.yaml 
apiVersion: networking.istio.io/v1
kind: Sidecar
metadata:
  name: default
  namespace: test
spec:
  workloadSelector:
    labels:
      run: test
  egress:
  - hosts:
    - "./*"
    - "istio-system/*"

root@controlplane ~ ➜  

