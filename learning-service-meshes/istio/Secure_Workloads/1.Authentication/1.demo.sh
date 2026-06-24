root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/helloworld/helloworld.yaml
service/helloworld created
deployment.apps/helloworld-v1 created
deployment.apps/helloworld-v2 created

root@controlplane ~ ➜  kubectl get pods
NAME                             READY   STATUS     RESTARTS   AGE
helloworld-v1-7459d7b54b-f7cxb   0/2     Init:0/1   0          2s
helloworld-v2-654d97458-r84kp    0/2     Init:0/1   0          2s

root@controlplane ~ ➜

kubectl create ns test 

kubectl run test --image=nginx -n test

kubectl exec -it test -n test -- curl helloworld.default.svc.cluster.local:5000/hello


peer_atuh_global_authentication.yaml  need to apply on istio-system namespace, so run the below command to apply the peer authentication policy.

apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT


We can overwrite the global peer authentication policy by creating a new peer authentication policy in the default namespace. 
The new policy will override the global policy for workloads in the default namespace.

peer_auth_default.yaml

apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: default
spec:
  mtls:
    mode: PERMISSIVE


root@controlplane ~ ➜  kubectl get pods --show-labels
NAME                             READY   STATUS    RESTARTS   AGE     LABELS
helloworld-v1-7459d7b54b-f7cxb   2/2     Running   0          7m47s   app=helloworld,pod-template-hash=7459d7b54b,security.istio.io/tlsMode=istio,service.istio.io/canonical-name=helloworld,service.istio.io/canonical-revision=v1,version=v1
helloworld-v2-654d97458-r84kp    2/2     Running   0          7m47s   app=helloworld,pod-template-hash=654d97458,security.istio.io/tlsMode=istio,service.istio.io/canonical-name=helloworld,service.istio.io/canonical-revision=v2,version=v2

root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/bookinfo/platform/kube/bookinfo.yaml
service/details created
serviceaccount/bookinfo-details created
deployment.apps/details-v1 created
service/ratings created
serviceaccount/bookinfo-ratings created
deployment.apps/ratings-v1 created
service/reviews created
serviceaccount/bookinfo-reviews created
deployment.apps/reviews-v1 created
deployment.apps/reviews-v2 created
deployment.apps/reviews-v3 created
service/productpage created
serviceaccount/bookinfo-productpage created
deployment.apps/productpage-v1 created

root@controlplane ~ ➜

We can also enable peer authrentication for a specific workload by creating a new peer authentication policy in the default namespace.

specific_workload_peer_auth.yaml

apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: default
spec:
  selector:
    matchLabels:
      app: helloworld
  mtls:
    mode: PERMISSIVE




root@controlplane ~ ➜  kubectl get svc
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
details       ClusterIP   10.101.7.195    <none>        9080/TCP   2m24s
helloworld    ClusterIP   10.108.92.244   <none>        5000/TCP   10m
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP    13m
productpage   ClusterIP   10.98.2.67      <none>        9080/TCP   2m24s
ratings       ClusterIP   10.96.129.32    <none>        9080/TCP   2m24s
reviews       ClusterIP   10.110.28.81    <none>        9080/TCP   2m24s

root@controlplane ~ ➜  kubectl exec -ti -n test test -- curl --head productpage.default.svc:9080
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 1683
server: envoy
date: Tue, 15 Apr 2025 18:18:37 GMT
x-envoy-upstream-service-time: 23

root@controlplane ~ ➜  kubectl exec -ti -n app test -- curl --head productpage.default.svc:9080
curl: (56) Recv failure: Connection reset by peer
command terminated with exit code 56

root@controlplane ~ ✗

root@controlplane ~ ✗ kubectl exec -ti -n app test -- curl --head helloworld.default.svc:5000/hello
HTTP/1.1 200 OK
server: istio-envoy
date: Tue, 15 Apr 2025 18:20:09 GMT
content-type: text/html; charset=utf-8
content-length: 60
x-envoy-upstream-service-time: 103
x-envoy-decorator-operation: helloworld.default.svc.cluster.local:5000/*

root@controlplane ~ ➜

