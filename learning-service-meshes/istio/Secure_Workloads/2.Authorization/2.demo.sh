# Allow Authorization 

apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: payments-allow-pol
  namespace: payments
spec:
  action: ALLOW
  rules:
  - from:
    - source:
        namespaces: ["app"]
    to:
    - operation:
        methods: ["POST"]

# Deny Authorization 

apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: payments-deny-pol
  namespace: payments
spec:
  action: DENY
  rules:
  - from:
    - source:
        namespaces: ["app"]
    to:
    - operation:
        methods: ["GET"]
        paths: ["/credit-cards-info"]

# Complex authorization 

apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: payments-allow-pol
  namespace: payments
spec:
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/identity/sa/app"]
    - source:
        namespace: ["app"]
    to:
    - operation:
        methods: ["GET"]
        paths: ["/data"]
    - operation:
        methods: ["POST"]
        paths: ["/purchases"]
    when:
    - key: request.auth.claims[iss]
      values: ["https://accounts.google.com"]

