apiVersion: networking.istio.io/v1
kind: IstioOperator
spec:
  components:
    base:
      enabled: true
    cni:
      enabled: false
    egressGateways:
    - enabled: false
      name: istio-egressgateway
    ingressGateways:
    - enabled: true
      name: istio-ingressgateway
    istiodRemote:
      enabled: false
    pilot:
      enabled: true
  hub: docker.io/istio
  meshConfig:
    outboundTrafficPolicy:
      mode: REGISTRY_ONLY
  defaultConfig:
    proxyMetadata: {}

---

apiVersion: networking.istio.io/v1
kind: ServiceEntry
metadata:
  name: postgres-db
  namespace: frontend
spec:
  hosts:
  - db.example.com
  ports:
  - number: 5432
    name: db
    protocol: TCP
  resolution: DNS

