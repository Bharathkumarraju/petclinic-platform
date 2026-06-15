IstioOperator is a custom resource definition (CRD) that allows you to customize the installation and configuration of Istio. It provides a way to manage the lifecycle of Istio components and their configurations in a declarative manner.

Customizing istio using Operator API

$ vim default.yaml

apiVersion: install.istio.io/v1alpha1
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
...

$ vim default.yaml

$ istioctl upgrade -f default.yaml

apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  components:
    base:
      enabled: true
    cni:
      enabled: false
    egressGateways:
    - enabled: true
      name: istio-egressgateway
    ingressGateways:
    - enabled: true
      name: istio-ingressgateway
    istiodRemote:
      enabled: false
    pilot:
      enabled: true


customize using helm values files:

$ helm show values istio/base > istio_base.yaml
$ helm upgrade install istio-base istio/base -n istio_system -f istio_base.yaml

$ helm show values istio/istiod > istiod.yaml
$ helm upgrade --install istiod istio/istiod -n istio-system -f istiod.yaml

$ helm show values istio/gateway > istio_gateway.yaml


helm uninstall:

istioctl uninstall --set profile=demo purge

helm uninstall istio-ingress -n istio-ingress

