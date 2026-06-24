root@controlplane ~ ➜  kubectl get ns --show-labels
NAME              STATUS   AGE   LABELS
default           Active   43m   istio-injection=enabled,kubernetes.io/metadata.name=default
istio-system      Active   97s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   43m   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   43m   kubernetes.io/metadata.name=kube-public
kube-system       Active   43m   kubernetes.io/metadata.name=kube-system

root@controlplane ~ ➜  kubectl get pods -o wide
No resources found in default namespace.

root@controlplane ~ ➜  

root@controlplane ~ ➜    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/bookinfo/platform/kube/bookinfo.yaml
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

root@controlplane ~ ➜  kubectl get pods
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-54ffb59669-7sxt5       2/2     Running   0          38s
productpage-v1-6c58956fd9-6nqfw   2/2     Running   0          37s
ratings-v1-7d7546bf89-trm7s       2/2     Running   0          38s
reviews-v1-6c7fd84f89-wpv4g       2/2     Running   0          38s
reviews-v2-57bb9fdcdf-gqsxb       2/2     Running   0          38s
reviews-v3-548fc5d9c7-v2z4d       2/2     Running   0          38s

root@controlplane ~ ➜  
root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl run test --image nginx -n test
pod/test created
root@controlplane ~ ✖ kubectl get pods -n test
NAME   READY   STATUS    RESTARTS   AGE
test   1/1     Running   0          33s

root@controlplane ~ ➜  


root@controlplane ~ ✖ kubectl exec -ti -n test test -- /bin/bash 
root@test:/# curl --head productpage.default.svc.cluster.local:9080 
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 1683
server: istio-envoy
date: Mon, 22 Jun 2026 04:56:30 GMT
x-envoy-upstream-service-time: 14
x-envoy-decorator-operation: productpage.default.svc.cluster.local:9080/*

root@test:/# curl  productpage.default.svc.cluster.local:9080 
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
root@test:/# 

