Canary Release Istio Upgrade

upgrade istio from 1.26.2 to 1.26.3 using canary release strategy

root@controlplane ~ ➜ istioctl proxy-status
NAME                                                      CLUSTER      CDS             LDS             EDS             RDS             ECDS        ISTIOD                      VERSION
details-v1-65599dcf88-rqvm8.default                       Kubernetes   SYNCED (5m1s)   SYNCED (5m1s)   SYNCED (4m32s)   SYNCED (5m1s)   IGNORED     istiod-57dcc6d8b-wkf2n      1.26.2
istio-egressgateway-5478b96959-h7gzm.istio-system         Kubernetes   SYNCED (5m8s)   SYNCED (5m8s)   SYNCED (4m32s)   IGNORED         IGNORED     istiod-57dcc6d8b-wkf2n      1.26.2
istio-ingressgateway-7dddb56f89-wjsp4.istio-system        Kubernetes   SYNCED (5m8s)   SYNCED (5m8s)   SYNCED (4m32s)   IGNORED         IGNORED     istiod-57dcc6d8b-wkf2n      1.26.2
productpage-v1-9487c9c5b-mvv6k.default                    Kubernetes   SYNCED (4m52s)  SYNCED (4m52s)  SYNCED (4m32s)   SYNCED (4m52s)  IGNORED     istiod-57dcc6d8b-wkf2n      1.26.2
ratings-v1-59b99c644-76r4h.default                        Kubernetes   SYNCED (4m56s)  SYNCED (4m56s)  SYNCED (4m32s)   SYNCED (4m56s)  IGNORED     istiod-57dcc6d8b-wkf2n      1.26.2
reviews-v1-5985998544-s5tvt.default                       Kubernetes   SYNCED (4m34s)  SYNCED (4m34s)  SYNCED (4m32s)   SYNCED (4m34s)  IGNORED     istiod-57dcc6d8b-wkf2n      1.26.2
reviews-v2-86d6cc668-pzz89.default                        Kubernetes   SYNCED (4m32s)  SYNCED (4m32s)  SYNCED (4m32s)   SYNCED (4m32s)  IGNORED     istiod-57dcc6d8b-wkf2n      1.26.2
reviews-v3-dbb5fb5dd-c52wl.default                        Kubernetes   SYNCED (4m34s)  SYNCED (4m34s)  SYNCED (4m32s)   SYNCED (4m34s)  IGNORED     istiod-57dcc6d8b-wkf2n      1.26.2

root@controlplane ~ ➜ █



root@controlplane ~ ➜ curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.26.3 sh -
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   101  100   101    0     0    551      0 --:--:-- --:--:-- --:--:--   554
100  5124  100  5124    0     0  16652      0 --:--:-- --:--:-- --:--:-- 16652

Downloading istio-1.26.3 from https://github.com/istio/istio/releases/download/1.26.3/istio-1.26.3-linux-amd64.tar.gz ...

Istio 1.26.3 download complete!

The Istio release archive has been downloaded to the istio-1.26.3 directory.

To configure the istioctl client tool for your workstation,
add the /root/istio-1.26.3/bin directory to your environment path variable with:
    export PATH="$PATH:/root/istio-1.26.3/bin"

Begin the Istio pre-installation check by running:
    istioctl x precheck

Try Istio in ambient mode
    https://istio.io/latest/docs/ambient/getting-started/
Try Istio in sidecar mode
    https://istio.io/latest/docs/setup/getting-started/
Install guides for ambient mode
    https://istio.io/latest/docs/ambient/install/
Install guides for sidecar mode
    https://istio.io/latest/docs/setup/install/

Need more information? Visit https://istio.io/latest/docs/

root@controlplane ~ ➜ █


root@controlplane ~ ➜ cd istio-1.26.3/

root@controlplane ~/istio-1.26.3 ➜ export PATH=$PWD/bin:$PATH

root@controlplane ~/istio-1.26.3 ➜ istioctl version
client version: 1.26.3
control plane version: 1.26.2
data plane version: 1.26.2 (8 proxies)

root@controlplane ~/istio-1.26.3 ➜ istioctl install --set profile=demo --revision=1-26-3
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

This will install the Istio 1.26.3 profile "demo" into the cluster. Proceed? (y/N) y
✔ Istio core installed ⛵
✔ Istiod installed 🧠
✔ Egress gateways installed 🛫
✔ Ingress gateways installed 🛬
✔ Installation complete

root@controlplane ~/istio-1.26.3 ➜ █


root@controlplane ~/istio-1.26.3 ➜ kubectl get pods -n istio-system
NAME                                            READY   STATUS    RESTARTS   AGE
istio-egressgateway-7bd9c6f56c-82vs2            1/1     Running   0          33s
istio-ingressgateway-7c7f65d5d9-tgjqg           1/1     Running   0          33s
istiod-1-26-3-774fb5c659-xgx82                  1/1     Running   0          44s
istiod-57dcc6d8b-wkf2n                          1/1     Running   0          8m44s

root@controlplane ~/istio-1.26.3 ➜ █



root@controlplane ~/istio-1.26.3 ➜ istioctl tag set latest --reivision 1-26-3
Error: unknown flag: --reivision

root@controlplane ~/istio-1.26.3 ✖ istioctl tag set latest --revision 1-26-3
Revision tag "latest" created, referencing control plane revision "1-26-3". To enable injection using this revision tag, use 'kubectl label namespace <NAMESPACE> istio.io/rev=latest'

root@controlplane ~/istio-1.26.3 ➜ kubectl edit ns default █

root@controlplane ~/istio-1.26.3 ➜ kubectl edit ns default
namespace/default edited

root@controlplane ~/istio-1.26.3 ➜ kubectl get ns default --show-labels
NAME      STATUS   AGE   LABELS
default   Active   21m   istio.io/rev=latest,kubernetes.io/metadata.name=default

root@controlplane ~/istio-1.26.3 ➜ istioctl analyze
✔ No validation issues found when analyzing namespace: default.

root@controlplane ~/istio-1.26.3 ➜ █



root@controlplane ~/istio-1.26.3 ➜ kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
details-v1-65599dcf88-rqvm8         2/2     Running   0          9m37s
productpage-v1-9487c9c5b-mvv6k      2/2     Running   0          9m36s
ratings-v1-59b99c644-76r4h          2/2     Running   0          9m37s
reviews-v1-5985998544-s5tvt         2/2     Running   0          9m36s
reviews-v2-86d6cc668-pzz89          2/2     Running   0          9m36s
reviews-v3-dbb5fb5dd-c52wl          2/2     Running   0          9m36s

root@controlplane ~/istio-1.26.3 ➜ istioctl proxy-status
NAME                                                      CLUSTER      CDS           LDS           EDS           RDS           ECDS
details-v1-65599dcf88-rqvm8.default                       Kubernetes   SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  IGNORED
        istiod-57dcc6d8b-wkf2n            1.26.2
istio-egressgateway-7bd9c6f56c-82vs2.istio-system         Kubernetes   SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  IGNORED       IGNORED
        istiod-1-26-3-774fb5c659-xgx82    1.26.3
istio-ingressgateway-7c7f65d5d9-tgjqg.istio-system        Kubernetes   SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  IGNORED       IGNORED
        istiod-1-26-3-774fb5c659-xgx82    1.26.3
productpage-v1-9487c9c5b-mvv6k.default                    Kubernetes   SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  IGNORED
        istiod-57dcc6d8b-wkf2n            1.26.2
ratings-v1-59b99c644-76r4h.default                        Kubernetes   SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  IGNORED
        istiod-57dcc6d8b-wkf2n            1.26.2
reviews-v1-5985998544-s5tvt.default                       Kubernetes   SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  SYNCED (91s)  IGNORED
        istiod-57dcc6d8b-wkf2n            1.26.2
reviews-v2-86d6cc668-pzz89.default                        Kubernetes   SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  IGNORED
        istiod-57dcc6d8b-wkf2n            1.26.2
reviews-v3-dbb5fb5dd-c52wl.default                        Kubernetes   SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  SYNCED (92s)  IGNORED
        istiod-57dcc6d8b-wkf2n            1.26.2

root@controlplane ~/istio-1.26.3 ➜ █





