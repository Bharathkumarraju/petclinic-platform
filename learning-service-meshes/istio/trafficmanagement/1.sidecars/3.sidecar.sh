$ vim sidecar.yaml

By default the mode is permissive, 
which means that the sidecar will accept both mTLS and non-mTLS traffic.

apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: app
spec:
  mtls:
    mode: STRICT