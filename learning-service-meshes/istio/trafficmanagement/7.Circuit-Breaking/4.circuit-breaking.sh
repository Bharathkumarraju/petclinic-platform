apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo-server
  template:
    metadata:
      labels:
        app: echo-server
    spec:
      containers:
      - name: echo
        image: ealen/echo-server
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: echo-server
  labels:
    app: echo-server
spec:
  ports:
  - port: 80
    name: http
  selector:
    app: echo-server


# -------------------------------------

root@controlplane ~ ➜  kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
echo-server-64fb4c5655-vzdh6   2/2     Running   0          33s

root@controlplane ~ ➜  kubectl get svc
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
echo-server   ClusterIP   10.104.144.230   <none>        80/TCP     6s
kubernetes    ClusterIP   10.96.0.1        <none>        443/TCP    26m

root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/httpbin/sample-client/fortio-deploy.yaml
service/fortio created
deployment.apps/fortio-deploy created

root@controlplane ~ ➜



root@controlplane ~ ➜  kubectl exec fortio-deploy-689bd5969b-l8z2v -c fortio -- /usr/bin/fortio curl -quiet http://echo-server | grep -o '"HOSTNAME":"[^"]*"'
HTTP/1.1 200 OK
content-type: application/json; charset=utf-8
content-length: 1103
etag: W/"44f-kZQpLjcWmsipxF9nvINv1V82nmI"
date: Tue, 15 Apr 2025 15:35:04 GMT
x-envoy-upstream-service-time: 10
server: envoy

"HOSTNAME":"echo-server-64fb4c5655-vzdh6"

root@controlplane ~ ➜

--------------------------------------------------------------------------------->

apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: echo-vs
spec:
  hosts:
  - echo-server
  http:
  - route:
    - destination:
        host: echo-server
        port:
          number: 80
---
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: echo-dr
spec:
  host: echo-server
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 1
      http:
        http1MaxPendingRequests: 1
        maxRequestsPerConnection: 1
    outlierDetection:
      consecutive5xxErrors: 1
      interval: 5s
      baseEjectionTime: 30s
      maxEjectionPercent: 100


--------------------------------------------------------------------------------->

root@controlplane ~ ✖ kubectl exec fortio-deploy-689bd5969b-l8z2v -c fortio -- /usr/bin/fortio load -c 2 -qps 0 -n 20 -loglevel Warning http://echo-server



root@controlplane ~ ✖ kubectl exec fortio-deploy-689bd5969b-l8z2v -c fortio -- /usr/bin/fortio load -c 20 -qps 0 -n 80 -loglevel Warning http://echo-server


apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: echo-dr
spec:
  host: echo-server
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 10
      http:
        http1MaxPendingRequests: 1
        maxRequestsPerConnection: 10
    outlierDetection:
      consecutive5xxErrors: 1
      interval: 5s
      baseEjectionTime: 30s
      maxEjectionPercent: 100


root@controlplane ~ ➔ kubectl exec fortio-deploy-689bd5969b-l8z2v -c istio-proxy -- pilot-agent request GET stats | grep echo-server | grep pending
cluster.outbound|80||echo-server.default.svc.cluster.local;.circuit_breakers.default.remaining_pending: 1
cluster.outbound|80||echo-server.default.svc.cluster.local;.circuit_breakers.default.rq_pending_open: 0
cluster.outbound|80||echo-server.default.svc.cluster.local;.circuit_breakers.high.rq_pending_open: 0
cluster.outbound|80||echo-server.default.svc.cluster.local;.upstream_rq_pending_active: 0
cluster.outbound|80||echo-server.default.svc.cluster.local;.upstream_rq_pending_failure_eject: 0
cluster.outbound|80||echo-server.default.svc.cluster.local;.upstream_rq_pending_overflow: 139
cluster.outbound|80||echo-server.default.svc.cluster.local;.upstream_rq_pending_total: 36
root@controlplane ~ ➔

