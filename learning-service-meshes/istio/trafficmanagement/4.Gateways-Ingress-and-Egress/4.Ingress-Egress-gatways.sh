root@controlplane ~ ➜  kubectl get ns --show-labels
NAME              STATUS   AGE     LABELS
default           Active   5m29s   istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   4m51s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   5m29s   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   5m29s   kubernetes.io/metadata.name=kube-public
kube-system       Active   5m29s   kubernetes.io/metadata.name=kube-system

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

root@controlplane ~ ➜  clear

apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: book-info-vs
spec:
  hosts:
  - productpage
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: productpage.default.svc.cluster.local
        port:
          number: 9080



apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: istio-gateway
spec:
  selector:
    istio: ingress
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "book.info.com"


---

root@controlplane ~ ➜  kubectl get gateways.networking.istio.io
NAME            AGE
istio-gateway   5s

root@controlplane ~ ➜  kubectl get vs
NAME           GATEWAYS   HOSTS             AGE
book-info-vs              ["productpage"]   2m53s

root@controlplane ~ ➜  kubectl get svc -n istio-system
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                      AGE
istio-egress   ClusterIP   10.98.33.91     <none>        15021/TCP,80/TCP,443/TCP                     9m2s
istio-ingress  NodePort    10.97.88.127    <none>        15021:31817/TCP,80:30992/TCP,443:30171/TCP   9m6s
istiod         ClusterIP   10.111.147.170  <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP        9m6s

root@controlplane ~ ➜  curl --head --header "Host: book.info.com" http://10.97.88.127
HTTP/1.1 404 Not Found
date: Fri, 11 Apr 2025 21:33:08 GMT
server: istio-envoy
transfer-encoding: chunked

root@controlplane ~ ➜

---


apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: book-info-vs
spec:
  hosts:
  - "book.info.com"
  - productpage
  gateways:
  - istio-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: productpage.default.svc.cluster.local
        port:
          number: 9080


