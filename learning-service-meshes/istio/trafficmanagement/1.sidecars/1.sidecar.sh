1. All Inbound and outbound traffic is intercepted and managed by the Envoy sidecar proxy. 
   This allows for features like load balancing, traffic routing, and security policies to be applied to the traffic.
2. 


$ vim sidecar.yaml

apiVersion: networking.istio.io/v1
kind: Sidecar
metadata:
  name: default
  namespace: payments
spec:
  egress:
  - hosts:
    - "./*"
    - "app/*"
    - "istio-system/*"
