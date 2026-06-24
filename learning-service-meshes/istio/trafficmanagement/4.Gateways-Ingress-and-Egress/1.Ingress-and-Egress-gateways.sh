Ingress and Egress gateways are used to manage inbound and outbound traffic for 
services running in a service mesh. 

apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: ingress-app-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingress
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "app.example.com"


---

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ingress-app-vs
  namespace: istio-system
spec:
  hosts:
  - app-svc
  - "app.example.com"
  gateways:
  - ingress-app-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: app-svc.frontend.svc.cluster.local
        port:
          number: 80
        subset: v1
      weight: 50
    - destination:
        host: app-svc.frontend.svc.cluster.local
        port:
          number: 80
        subset: v2
      weight: 50



# --------------------

apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: egress-app-gateway
  namespace: istio-system
spec:
  selector:
    istio: egress
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
  - port:
      number: 443
      name: https
      protocol: HTTP
    hosts:
    - "*"

---

apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: egress-app-vs
  namespace: frontend
spec:
  hosts:
  - api.example.com
  gateways:
  - egress-app-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: api.example.com
        port:
          number: 443

