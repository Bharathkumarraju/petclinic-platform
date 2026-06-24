root@controlplane ~ ➜  kubectl get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   25m   istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   22m   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   25m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   25m   kubernetes.io/metadata.name=kube-public
kube-system       Active   25m   kubernetes.io/metadata.name=kube-system

root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/helloworld/helloworld.yaml
service/helloworld created
deployment.apps/helloworld-v1 created
deployment.apps/helloworld-v2 created

root@controlplane ~ ➜


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
---
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
      

