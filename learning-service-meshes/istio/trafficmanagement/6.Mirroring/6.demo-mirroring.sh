root@test:/# curl -s http://echo-server | grep -o '"HOSTNAME":"[^"]*"' | sed 's/"HOSTNAME":"\(.*\)"/HOSTNAME: \1/'
HOSTNAME: echo-server-v2-5698db4f99-lm5ss
root@test:/# curl -s http://echo-server | grep -o '"HOSTNAME":"[^"]*"' | sed 's/"HOSTNAME":"\(.*\)"/HOSTNAME: \1/'
HOSTNAME: echo-server-v2-5698db4f99-lm5ss
root@test:/# curl -s http://echo-server | grep -o '"HOSTNAME":"[^"]*"' | sed 's/"HOSTNAME":"\(.*\)"/HOSTNAME: \1/'
HOSTNAME: echo-server-v1-59ff75d58-t4dq6
root@test:/# curl -s http://echo-server | grep -o '"HOSTNAME":"[^"]*"' | sed 's/"HOSTNAME":"\(.*\)"/HOSTNAME: \1/'
HOSTNAME: echo-server-v1-59ff75d58-t4dq6
root@test:/#


apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: echo-server
spec:
  host: echo-server
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: echo-server
spec:
  hosts:
  - echo-server
  http:
  - route:
    - destination:
        host: echo-server
        subset: v1
      weight: 100
    mirror:
      host: echo-server
      subset: v2
    mirrorPercentage:
      value: 100.0
      