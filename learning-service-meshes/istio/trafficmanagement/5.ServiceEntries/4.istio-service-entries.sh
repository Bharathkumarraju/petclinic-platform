root@controlplane ~/istio-1.18.2 ➜  istioctl profile dump demo -o yaml > demo.yaml
root@controlplane ~/istio-1.18.2 ➜  vim demo.yaml
root@controlplane ~/istio-1.18.2 ➜  istioctl validate -f demo.yaml
"demo.yaml" is valid

root@controlplane ~/istio-1.18.2 ➜  istioctl install -f demo.yaml -y
✔ Istio core installed
✔ Istiod installed
✔ Egress gateways installed
✔ Ingress gateways installed
✔ Installation complete
Making this installation the default for injection and validation.

root@controlplane ~/istio-1.18.2 ➜ 


apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: wikipedia-egress
spec:
  hosts:
  - www.wikipedia.org
  ports:
  - number: 80
    name: http
    protocol: HTTP
  - number: 443
    name: https
    protocol: HTTPS
  resolution: DNS




-----------------------------

apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: istio-egressgateway
spec:
  selector:
    istio: egressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - www.wikipedia.org
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: egressgateway-for-wikipedia
  namespace: default
spec:
  host: istio-egressgateway.istio-system.svc.cluster.local
  subsets:
  - name: wikipedia
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: wikipedia-egress-gateway
spec:
  hosts:
  - www.wikipedia.org
  gateways:
  - istio-egressgateway
  - mesh
  http:
  - match:
    - gateways:
      - mesh
      port: 80
    route:
    - destination:
        host: istio-egressgateway.istio-system.svc.cluster.local
        subset: wikipedia
        port:
          number: 80
      weight: 100
  - match:
    - gateways:
      - istio-egressgateway
      port: 80
    route:
    - destination:
        host: www.wikipedia.org
        port:
          number: 80
      weight: 100
      