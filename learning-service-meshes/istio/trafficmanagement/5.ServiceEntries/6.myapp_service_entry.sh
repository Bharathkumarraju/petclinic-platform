root@controlplane ~ ➜  curl myapp.com
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>

root@controlplane ~ ➜  cat /etc/hosts
10.0.0.6 docker-registry-mirror.kodekloud.com
127.0.0.1 controlplane controlplane
192.168.121.2 myapp.com

root@controlplane ~ ➜

ServiceEntry for myapp.com:
------------------------------------------------->
apiVersion: networking.istio.io/v1
kind: ServiceEntry
metadata:
  name: myapp-service-entry
spec:
  hosts:
  - myapp.com
  location: MESH_EXTERNAL
  ports:
  - number: 80
    name: http
    protocol: HTTP
  resolution: STATIC
  endpoints:
  - address: 192.168.121.2

VirtualService for myapp.com:
------------------------------------------------->
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: myapp-vs
spec:
  hosts:
  - myapp.com
  http:
  - route:
    - destination:
        host: myapp.com
        port:
          number: 80



