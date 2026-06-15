root@controlplane ~ ➜ touch demo.yaml

root@controlplane ~ ➜ vim demo.yaml

root@controlplane ~ ➜ cat demo.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: demo

root@controlplane ~ ➜ istioctl validate -f demo.yaml
"demo.yaml" is valid

root@controlplane ~ ➜ #istioctl install --set profile=demo

root@controlplane ~ ➜ istioctl install -f demo.yaml -y
       / \
      /   \
     /     \
    /       \
   /         \
  /           \
 /             \
|\_____________|
|      |       |
 \     |      /
  \____|_____/

✔ Istio core installed ⛵
✔ Istiod installed 🧠
✔ Egress gateways installed 🛫
✔ Ingress gateways installed 🛬
✔ Installation complete

root@controlplane ~ ➜ █


root@controlplane ~ ➜ cat demo.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: demo
  components:
    egressGateways:
    - enabled: false
      k8s:
        resources:
          requests:
            cpu: 10m
            memory: 40Mi
      name: istio-egressgateway
    - enabled: true
      k8s:
        resources:
          requests:
            cpu: 20m
            memory: 40Mi
          limits:
            cpu: 40m
            memory: 80Mi
      name: istio-egress-gateway
    ingressGateways:
    - enabled: false
      k8s:
        resources:
          requests:
            cpu: 10m
            memory: 40Mi
      service:
        ports:
        - name: status-port
          port: 15021
          targetPort: 15021
        - name: http2
          port: 80
          targetPort: 8080
        - name: https
          port: 443
          targetPort: 8443
        - name: tcp
          port: 31400
          targetPort: 31400
        - name: tls
          port: 15443
          targetPort: 15443
      name: istio-ingressgateway
    - enabled: true
      k8s:
        resources:
          requests:
            cpu: 20m
            memory: 40Mi
          limits:
            cpu: 40m
            memory: 80Mi
      service:
        ports:
        - name: status-port
          port: 15021
          targetPort: 15021
        - name: http2
          port: 80
          targetPort: 8080
        - name: https
          port: 443
          targetPort: 8443
        - name: tcp
          port: 31400
          targetPort: 31400
        - name: tls
          port: 15443
          targetPort: 15443
      name: istio-ingress-gateway

root@controlplane ~ ➜ █


root@controlplane ~ ➜ vim demo.yaml

root@controlplane ~ ➜ istioctl validate -f demo.yaml
"demo.yaml" is valid

root@controlplane ~ ➜ istioctl upgrade -f demo.yaml
This will install the Istio 1.26.3 profile "demo" into the cluster. Proceed? (y/N) y
✔ Istio core installed ⛵
✔ Istiod installed 🧠
✔ Egress gateways installed 🛫
✔ Ingress gateways installed 🛬
- Pruning removed resources
  Removed apps/v1, Kind=Deployment/istio-ingressgateway.istio-system.
  Removed apps/v1, Kind=Deployment/istio-egressgateway.istio-system.
  Removed /v1, Kind=Service/istio-ingressgateway.istio-system.
  Removed /v1, Kind=Service/istio-egressgateway.istio-system.
  Removed /v1, Kind=ServiceAccount/istio-ingressgateway-service-account.istio-system.
  Removed /v1, Kind=ServiceAccount/istio-egressgateway-service-account.istio-system.
  Removed rbac.authorization.k8s.io/v1, Kind=RoleBinding/istio-ingressgateway-sds.istio-system.
  Removed rbac.authorization.k8s.io/v1, Kind=RoleBinding/istio-egressgateway-sds.istio-system.
  Removed rbac.authorization.k8s.io/v1, Kind=Role/istio-ingressgateway-sds.istio-system.
  Removed rbac.authorization.k8s.io/v1, Kind=Role/istio-egressgateway-sds.istio-system.
  Removed policy/v1, Kind=PodDisruptionBudget/istio-ingressgateway.istio-system.
  Removed policy/v1, Kind=PodDisruptionBudget/istio-egressgateway.istio-system.
✔ Installation complete

root@controlplane ~ ➜ █

root@controlplane ~ ➜ kubectl get pods -n istio-system
NAME                                          READY   STATUS        RESTARTS   AGE
istio-egress-gateway-7949ccd449-r6wcn         1/1     Running       0          24s
istio-egressgateway-fbdbf94c6-j64m7           0/1     Terminating   0          4m51s
istio-ingress-gateway-64bf9dfb9-rn5jk         1/1     Running       0          24s
istio-ingressgateway-7f9cb54c46-lzfcv         1/1     Terminating   0          4m50s
istiod-6699bd67b9-swz6j                       1/1     Running       0          4m55s

root@controlplane ~ ➜ █



https://istio.io/latest/docs/reference/config/istio.operator.v1alpha1/

