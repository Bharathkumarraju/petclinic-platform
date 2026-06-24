# test 

root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/httpbin/httpbin.yaml
serviceaccount/httpbin created
service/httpbin created
deployment.apps/httpbin created

root@controlplane ~ ➜  kubectl run test --image=nginx
pod/test created

root@controlplane ~ ➜

apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: httpbin-vs
spec:
  hosts:
  - httpbin
  http:
  - timeout: 2s
    route:
    - destination:
        host: httpbin
        port:
          number: 8000


root@controlplane ~ ➜  kubectl exec -ti test -- curl http://httpbin:8000/get
{
  "args": {}, 
  "headers": {
    "Accept": [
      "*/*"
    ], 
    "Host": [
      "httpbin:8000"
    ], 
    "User-Agent": [
      "curl/7.88.1"
    ], 
    "X-Envoy-Attempt-Count": [
      "1"
    ], 
    "X-Forwarded-Client-Cert": [
      "By=spiffe://cluster.local/ns/default/sa/httpbin;Hash=2c75fde58ee794250a36e7cd0b8edebaa62745abb7ab33fe349319d733d77bb5;Subject=\"\";URI=spiffe://cluster.local/ns/default/sa/default"
    ], 
    "X-Forwarded-Proto": [
      "http"
    ], 
    "X-Request-Id": [
      "e9b856f5-2868-9a61-b6a7-6f953666faa4"
    ]
  }, 
  "method": "GET", 
  "origin": "127.0.0.6:47543", 
  "url": "http://httpbin:8000/get"
}

root@controlplane ~ ➜


kubectl exec -ti test -- curl http://httpbin:8000/delay/1
kubectl exec -ti test -- curl http://httpbin:8000/delay/2

retries:

apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: httpbin-vs
spec:
  hosts:
  - httpbin
  http:
  - route:
    - destination:
        host: httpbin
        port:
          number: 8000
    retries:
      attempts: 3
      perTryTimeout: 1s
      retryOn: 5xx


apply the virtual service with retries:

root@controlplane ~ ➜  kubectl exec -ti test -- curl --head http://httpbin:8000/get
HTTP/1.1 200 OK
access-control-allow-credentials: true
access-control-allow-origin: *
content-type: application/json; charset=utf-8
date: Tue, 15 Apr 2025 17:21:01 GMT
x-envoy-upstream-service-time: 1
server: envoy
transfer-encoding: chunked

root@controlplane ~ ➜  kubectl exec -ti test -- curl http://httpbin:8000/status/500

root@controlplane ~ ➜  kubectl exec -ti test -- curl --head http://httpbin:8000/status/500
HTTP/1.1 500 Internal Server Error
access-control-allow-credentials: true
access-control-allow-origin: *
content-type: text/plain; charset=utf-8
date: Tue, 15 Apr 2025 17:21:28 GMT
x-envoy-upstream-service-time: 97
server: envoy
transfer-encoding: chunked

root@controlplane ~ ➜


kubectl logs -f httpbin-5f7d9b6c7b-2x8k9 -c istio-proxy
[2025-04-15T17:21:28.123Z] "GET /status/500 HTTP/1.1" 500 UH 0 97 0 - "-" "curl/7.88.1" "e9b856f5-2868-9a61-b6a7-6f953666faa4" "httpbin.default.svc.cluster.local" "

3 more 500 responses were sent to the client due to retries, but the final response was still a 500 error.




