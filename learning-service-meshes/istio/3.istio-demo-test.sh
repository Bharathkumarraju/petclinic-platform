root@controlplane ~ ➜ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/bookinfo/platform/kube/bookinfo.yaml
service/details created
serviceaccount/bookinfo-details created
deployment.apps/details-v1 created
service/ratings created
serviceaccount/bookinfo-ratings created
deployment.apps/ratings-v1 created
service/reviews created
serviceaccount/bookinfo-reviews created
deployment.apps/reviews-v1 created
deployment.apps/reviews-v2 created
deployment.apps/reviews-v3 created
service/productpage created
serviceaccount/bookinfo-productpage created
deployment.apps/productpage-v1 created
root@controlplane ~ ➜


root@controlplane ~ ✘ curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.26.3 sh -
 % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   102  100   102    0     0    479      0 --:--:-- --:--:-- --:--:--   481
100  5124  100  5124    0     0  14087      0 --:--:-- --:--:-- --:--:-- 14087

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

-----------------------------------------------------------------------------:

root@controlplane ~/istio-1.26.3 ➜ ll
total 48
drwxr-x---  6 root root  4096 Jul 25 11:38 ./
drwx------  9 root root  4096 Aug 26 17:26 ../
drwxr-x---  2 root root  4096 Jul 25 11:38 bin/
-rw-r--r--  1 root root 11357 Jul 25 11:38 LICENSE
drwxr-xr-x  4 root root  4096 Jul 25 11:38 manifests/
-rw-r-----  1 root root   983 Jul 25 11:38 manifest.yaml
-rw-r--r--  1 root root  6927 Jul 25 11:38 README.md
drwxr-xr-x 27 root root  4096 Jul 25 11:38 samples/
drwxr-xr-x  3 root root  4096 Jul 25 11:38 tools/

root@controlplane ~/istio-1.26.3 ➜ export PATH=$PWD/bin:$PATH

root@controlplane ~/istio-1.26.3 ➜ istioctl version
Istio is not present in the cluster: no running Istio pods in namespace "istio-system"
client version: 1.26.3
root@controlplane ~/istio-1.26.3 ➜


root@controlplane ~/istio-1.26.3 ➜ istioctl install --set profile=demo -y
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

root@controlplane ~/istio-1.26.3 ➜

root@controlplane ~/istio-1.26.3 ➜ kubectl get pods -n istio-system
NAME                                   READY   STATUS    RESTARTS   AGE
istio-egressgateway-fbdbf94c6-nqzj5    1/1     Running   0          24s
istio-ingressgateway-7f9cb54c46-nff5v  1/1     Running   0          24s
istiod-6699bd67b9-64dt9                1/1     Running   0          34s

root@controlplane ~/istio-1.26.3 ➜ 

root@controlplane ~/istio-1.26.3 ➜ istioctl analyze -n default
Info [IST0102] (Namespace default) The namespace is not enabled for Istio injection. Run 'kubectl label namespace default istio-injection=enabled' to enable it, or 'kubectl label namespace default istio-injection=disabled' to explicitly mark it as not needing injection.

root@controlplane ~/istio-1.26.3 ➜ kubectl label namespace default istio-injection=enabled
namespace/default labeled

root@controlplane ~/istio-1.26.3 ➜ istioctl analyze -n default
Warning [IST0103] (Pod default/details-v1-65599dcf88-k44bb) The pod default/details-v1-65599dcf88-k44bb is missing the Istio proxy. This can often be resolved by restarting or redeploying the workload.
Warning [IST0103] (Pod default/productpage-v1-9487c9c5b-9cqhs) The pod default/productpage-v1-9487c9c5b-9cqhs is missing the Istio proxy. This can often be resolved by restarting or redeploying the workload.
Warning [IST0103] (Pod default/ratings-v1-59b99c644-fhsp8) The pod default/ratings-v1-59b99c644-fhsp8 is missing the Istio proxy. This can often be resolved by restarting or redeploying the workload.
Warning [IST0103] (Pod default/reviews-v1-5985998544-k4lph) The pod default/reviews-v1-5985998544-k4lph is missing the Istio proxy. This can often be resolved by restarting or redeploying the workload.
Warning [IST0103] (Pod default/reviews-v2-86d6cc668-qntwq) The pod default/reviews-v2-86d6cc668-qntwq is missing the Istio proxy. This can often be resolved by restarting or redeploying the workload.
Warning [IST0103] (Pod default/reviews-v3-dbb5fb5dd-ffg9v) The pod default/reviews-v3-dbb5fb5dd-ffg9v is missing the Istio proxy. This can often be resolved by restarting or redeploying the workload.

root@controlplane ~/istio-1.26.3 ➜ █



root@controlplane ~/istio-1.26.3 ➜ kubectl get deployments.apps
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
details-v1      1/1     1            1           3m36s
productpage-v1  1/1     1            1           3m35s
ratings-v1      1/1     1            1           3m36s
reviews-v1      1/1     1            1           3m36s
reviews-v2      1/1     1            1           3m36s
reviews-v3      1/1     1            1           3m36s

root@controlplane ~/istio-1.26.3 ➜ kubectl rollout restart deployment details-v1
deployment.apps/details-v1 restarted

root@controlplane ~/istio-1.26.3 ➜ kubectl rollout restart deployment productpage-v1
deployment.apps/productpage-v1 restarted

root@controlplane ~/istio-1.26.3 ➜ kubectl rollout restart deployment ratings-v1
deployment.apps/ratings-v1 restarted

root@controlplane ~/istio-1.26.3 ➜ kubectl rollout restart deployment reviews-v1
deployment.apps/reviews-v1 restarted

root@controlplane ~/istio-1.26.3 ➜ kubectl rollout restart deployment reviews-v2
deployment.apps/reviews-v2 restarted

root@controlplane ~/istio-1.26.3 ➜ kubectl rollout restart deployment reviews-v3
deployment.apps/reviews-v3 restarted
root@controlplane ~/istio-1.26.3 ➜

root@controlplane ~/istio-1.26.3 ➜ istioctl analyze -n default
No validation issues found when analyzing namespace default.

