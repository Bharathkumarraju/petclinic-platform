
root@controlplane ~ ➜  kubectl get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   45m   istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   72s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   45m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   45m   kubernetes.io/metadata.name=kube-public
kube-system       Active   45m   kubernetes.io/metadata.name=kube-system

root@controlplane ~ ➜  


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


root@controlplane ~ ➜  k get pods 
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-54ffb59669-ptrmh       2/2     Running   0          32s
productpage-v1-6c58956fd9-9hqvj   2/2     Running   0          31s
ratings-v1-7d7546bf89-48vnz       2/2     Running   0          32s
reviews-v1-6c7fd84f89-qdm2n       2/2     Running   0          32s
reviews-v2-57bb9fdcdf-46ml7       2/2     Running   0          32s
reviews-v3-548fc5d9c7-hvsxn       2/2     Running   0          32s

root@controlplane ~ ➜  


root@controlplane ~ ➜  cat vs.yaml 
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: book-info-vs
  namespace: istio-system
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

root@controlplane ~ ➜  k apply -f vs.yaml 
virtualservice.networking.istio.io/book-info-vs created

root@controlplane ~ ➜  k get pods -n istio-system 
NAME                                    READY   STATUS    RESTARTS   AGE
istio-egressgateway-675cdb9f4b-jtz6l    1/1     Running   0          3m58s
istio-ingressgateway-6cd9bc7f5b-dnt24   1/1     Running   0          3m58s
istiod-7f898458c5-7h6z4                 1/1     Running   0          4m7s

root@controlplane ~ ➜  

root@controlplane ~ ➜  k get vs -n istio-system -o wide
NAME           GATEWAYS   HOSTS             AGE
book-info-vs              ["productpage"]   37s

root@controlplane ~ ➜  


root@controlplane ~ ➜  k get pods -n istio-system --show-labels
NAME                                    READY   STATUS    RESTARTS   AGE     LABELS
istio-egressgateway-675cdb9f4b-jtz6l    1/1     Running   0          4m57s   app.kubernetes.io/instance=istio,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=istio-egressgateway,app.kubernetes.io/part-of=istio,app.kubernetes.io/version=1.26.0,app=istio-egressgateway,chart=gateways,helm.sh/chart=istio-egress-1.26.0,heritage=Tiller,install.operator.istio.io/owning-resource=unknown,istio.io/dataplane-mode=none,istio.io/rev=default,istio=egressgateway,operator.istio.io/component=EgressGateways,pod-template-hash=675cdb9f4b,release=istio,service.istio.io/canonical-name=istio-egressgateway,service.istio.io/canonical-revision=latest,sidecar.istio.io/inject=false
istio-ingressgateway-6cd9bc7f5b-dnt24   1/1     Running   0          4m57s   app.kubernetes.io/instance=istio,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=istio-ingressgateway,app.kubernetes.io/part-of=istio,app.kubernetes.io/version=1.26.0,app=istio-ingressgateway,chart=gateways,helm.sh/chart=istio-ingress-1.26.0,heritage=Tiller,install.operator.istio.io/owning-resource=unknown,istio.io/dataplane-mode=none,istio.io/rev=default,istio=ingressgateway,operator.istio.io/component=IngressGateways,pod-template-hash=6cd9bc7f5b,release=istio,service.istio.io/canonical-name=istio-ingressgateway,service.istio.io/canonical-revision=latest,sidecar.istio.io/inject=false
istiod-7f898458c5-7h6z4                 1/1     Running   0          5m6s    app.kubernetes.io/instance=istio,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=istiod,app.kubernetes.io/part-of=istio,app.kubernetes.io/version=1.26.0,app=istiod,helm.sh/chart=istiod-1.26.0,install.operator.istio.io/owning-resource=unknown,istio.io/dataplane-mode=none,istio.io/rev=default,istio=pilot,operator.istio.io/component=Pilot,pod-template-hash=7f898458c5,sidecar.istio.io/inject=false

root@controlplane ~ ➜  

root@controlplane ~ ➜  kubectl describe pod -n istio-system istio-ingress
Name:             istio-ingressgateway-6cd9bc7f5b-dnt24
Namespace:        istio-system
Priority:         0
Service Account:  istio-ingressgateway-service-account
Node:             controlplane/192.168.121.31
Start Time:       Mon, 22 Jun 2026 21:47:17 +0000
Labels:           app=istio-ingressgateway
                  app.kubernetes.io/instance=istio
                  app.kubernetes.io/managed-by=Helm
                  app.kubernetes.io/name=istio-ingressgateway
                  app.kubernetes.io/part-of=istio
                  app.kubernetes.io/version=1.26.0
                  chart=gateways
                  helm.sh/chart=istio-ingress-1.26.0
                  heritage=Tiller
                  install.operator.istio.io/owning-resource=unknown
                  istio=ingressgateway
                  istio.io/dataplane-mode=none
                  istio.io/rev=default
                  operator.istio.io/component=IngressGateways
                  pod-template-hash=6cd9bc7f5b
                  release=istio
                  service.istio.io/canonical-name=istio-ingressgateway
                  service.istio.io/canonical-revision=latest
                  sidecar.istio.io/inject=false

root@controlplane ~ ➜


root@controlplane ~ ➜  vim gw.yaml

root@controlplane ~ ➜  k apply -f gw.yaml
gateway.networking.istio.io/istio-gateway created

root@controlplane ~ ➜  kubectl get gateways -A -o wide
NAMESPACE      NAME            AGE
istio-system   istio-gateway   7s

root@controlplane ~ ➜  cat gw.yaml 
apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: istio-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "book.info.com"

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl get svc -n istio-system
NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                                                      AGE
istio-egressgateway    ClusterIP   10.101.106.37   <none>        80/TCP,443/TCP                                                               7m25s
istio-ingressgateway   NodePort    10.104.12.246   <none>        15021:32384/TCP,80:32679/TCP,443:30556/TCP,31400:31136/TCP,15443:30949/TCP   7m25s
istiod                 ClusterIP   10.101.183.68   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP                                        7m34s

root@controlplane ~ ➜  curl --head --header "Host: book.info.com" http://10.104.12.246
HTTP/1.1 404 Not Found
date: Mon, 22 Jun 2026 21:55:19 GMT
server: istio-envoy
transfer-encoding: chunked

root@controlplane ~ ➜  


root@controlplane ~ ➜  cat vs.yaml 
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: book-info-vs
  namespace: istio-system
spec:
  hosts:
  - productpage
  - book.info.com # Added
  gateways: # Added
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

root@controlplane ~ ➜  



root@controlplane ~ ➜  k apply -f vs.yaml 
virtualservice.networking.istio.io/book-info-vs configured

root@controlplane ~ ➜  curl --head --header "Host: book.info.com" http://10.104.12.246
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 1683
server: istio-envoy
date: Mon, 22 Jun 2026 21:56:46 GMT
x-envoy-upstream-service-time: 24


root@controlplane ~ ➜  curl --header "Host: book.info.com" http://10.104.12.246
<!DOCTYPE html>
<html>
  <head>
    <title>Simple Bookstore App</title>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="static/bootstrap/css/bootstrap.min.css">

<!-- Optional theme -->
<link rel="stylesheet" href="static/bootstrap/css/bootstrap-theme.min.css">

  </head>
  <body>
    
    
<p>
    <h3>Hello! This is a simple bookstore application consisting of three services as shown below</h3>
</p>

<table class="table table-condensed table-bordered table-hover"><tr><th>name</th><td>http://details:9080</td></tr><tr><th>endpoint</th><td>details</td></tr><tr><th>children</th><td><table class="table table-condensed table-bordered table-hover"><tr><th>name</th><th>endpoint</th><th>children</th></tr><tr><td>http://details:9080</td><td>details</td><td></td></tr><tr><td>http://reviews:9080</td><td>reviews</td><td><table class="table table-condensed table-bordered table-hover"><tr><th>name</th><th>endpoint</th><th>children</th></tr><tr><td>http://ratings:9080</td><td>ratings</td><td></td></tr></table></td></tr></table></td></tr></table>

<p>
    <h4>Click on one of the links below to auto generate a request to the backend as a real user or a tester
    </h4>
</p>
<p><a href="/productpage?u=normal">Normal user</a></p>
<p><a href="/productpage?u=test">Test user</a></p>


    
<!-- Latest compiled and minified JavaScript -->
<script src="static/jquery.min.js"></script>

<!-- Latest compiled and minified JavaScript -->
<script src="static/bootstrap/js/bootstrap.min.js"></script>

  </body>
</html>

root@controlplane ~ ➜  




