# test 

root@controlplane ~ ➜  kubectl get ns --show-labels
NAME              STATUS   AGE     LABELS
default           Active   38m     istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   2m29s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   38m     kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   38m     kubernetes.io/metadata.name=kube-public
kube-system       Active   38m     kubernetes.io/metadata.name=kube-system

root@controlplane ~ ➜  k apply -f https://raw.githubusercontent.com/istio/istio/master/samples/helloworld/helloworld.yaml
service/helloworld created
deployment.apps/helloworld-v1 created
deployment.apps/helloworld-v2 created

root@controlplane ~ ➜  k get pods
NAME                             READY   STATUS            RESTARTS   AGE
helloworld-v1-5dd8856698-cwbzr   0/2     PodInitializing   0          3s
helloworld-v2-56df4c568b-hvhb8   0/2     PodInitializing   0          3s

root@controlplane ~ ➜  k get all
NAME                                 READY   STATUS            RESTARTS   AGE
pod/helloworld-v1-5dd8856698-cwbzr   0/2     PodInitializing   0          9s
pod/helloworld-v2-56df4c568b-hvhb8   1/2     Running           0          9s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/helloworld   ClusterIP   10.108.24.189   <none>        5000/TCP   9s
service/kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP    39m

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helloworld-v1   0/1     1            0           9s
deployment.apps/helloworld-v2   0/1     1            0           9s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/helloworld-v1-5dd8856698   1         1         0       9s
replicaset.apps/helloworld-v2-56df4c568b   1         1         0       9s

root@controlplane ~ ➜  




root@controlplane ~ ➜  k create namespace test
namespace/test created

root@controlplane ~ ➜  k label namespaces test istio-injection=enabled
namespace/test labeled

root@controlplane ~ ➜  k run test --image nginx -n test
pod/test created

root@controlplane ~ ➜  k get pods -n test
NAME   READY   STATUS    RESTARTS   AGE
test   2/2     Running   0          10s

root@controlplane ~ ➜  


root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr

root@controlplane ~ ➜  k exec -it test -n test -- curl helloworld.default.svc:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8


root@controlplane ~ ➜  vim dr.yaml

root@controlplane ~ ➜  cat dr.yaml 
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: hello-world-ds
  namespace: default
spec:
  host: helloworld
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2

root@controlplane ~ ➜  k apply -f dr.yaml 
destinationrule.networking.istio.io/hello-world-ds created

root@controlplane ~ ➜  


root@controlplane ~ ➜  k get destinationrules.networking.istio.io 
NAME             HOST         AGE
hello-world-ds   helloworld   17s

root@controlplane ~ ➜  


root@controlplane ~ ➜  vim vs.yaml

root@controlplane ~ ➜  k apply -f vs.yaml
virtualservice.networking.istio.io/hello-world-vs created

root@controlplane ~ ➜  cat vs.yaml 
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: hello-world-vs
  namespace: default
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
      weight: 50
    - destination:
        host: helloworld.default.svc.cluster.local
        port:
          number: 5000
        subset: v2
      weight: 50

root@controlplane ~ ➜  


root@controlplane ~ ➜  k get vs -o wide
NAME             GATEWAYS   HOSTS            AGE
hello-world-vs              ["helloworld"]   26s

root@controlplane ~ ➜  


root@controlplane ~ ➜  k get vs -o wide
NAME             GATEWAYS   HOSTS            AGE
hello-world-vs              ["helloworld"]   26s

root@controlplane ~ ➜  kubectl exec -ti -n test test -- /bin/bash
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8
root@test:/#  curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# 



root@controlplane ~ ➜  cat vs.yaml 
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: hello-world-vs
  namespace: default
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
      weight: 90
    - destination:
        host: helloworld.default.svc.cluster.local
        port:
          number: 5000
        subset: v2
      weight: 10

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl exec -ti -n test test -- /bin/bash
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v2, instance: helloworld-v2-56df4c568b-hvhb8
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# curl helloworld.default.svc.cluster.local:5000/hello
Hello version: v1, instance: helloworld-v1-5dd8856698-cwbzr
root@test:/# exit   
exit

root@controlplane ~ ➜ 