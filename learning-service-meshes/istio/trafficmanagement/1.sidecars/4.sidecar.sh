sidecar policy example 

apiVersion: networking.istio.io/v1
kind: Sidecar
metadata:
  name: ratings
  namespace: bookinfo
spec:
  workloadSelector:
    labels:
      app: ratings
  ingress:
  - port:
      number: 9080
      protocol: HTTP
      name: ratings
    defaultEndpoint: unix:///var/run/someuds.sock
  egress:
  - port:
      number: 9080
      protocol: HTTP
      name: egresshttp
    hosts:
    - "bookinfo/*"
    - hosts:
    - "istio-system/*"




root@controlplane ~ ➜  kubectl get ns --show-labels
NAME              STATUS   AGE    LABELS
default           Active   4m2s   istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   91s    kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   4m2s   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   4m2s   kubernetes.io/metadata.name=kube-public
kube-system       Active   4m2s   kubernetes.io/metadata.name=kube-system

root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/bookinfo/platform/kube/bookinfo.yaml


apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: default
spec:
  mtls:
    mode: STRICT

