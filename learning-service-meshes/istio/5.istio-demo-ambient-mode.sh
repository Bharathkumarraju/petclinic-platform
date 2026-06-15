istio ambient mode demo 

root@controlplane ~ ➜ istioctl version
Istio is not present in the cluster: no running Istio pods in namespace "istio-system"
client version: 1.26.3

root@controlplane ~ ➜ istioctl install --set profile=ambient -y
✔ Istio core installed ⛵
✔ Istiod installed 🧠
✔ CNI installed 🪢
✔ Ztunnel installed 🔒
✔ Installation complete
The ambient profile has been installed successfully, enjoy Istio without sidecars!

root@controlplane ~ ➜ █


root@controlplane ~ ➜ kubectl get pods -n istio-system
NAME                          READY   STATUS    RESTARTS   AGE
istio-cni-node-rc84w          1/1     Running   0          19s
istiod-6b854648cc-z54lj       1/1     Running   0          27s
ztunnel-kbc9c                 1/1     Running   0          13s

root@controlplane ~ ➜ kubectl get ds -n istio-system
NAME             DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
istio-cni-node   1         1         1       1            1           kubernetes.io/os=linux   31s
ztunnel          1         1         1       1            1           kubernetes.io/os=linux   25s

root@controlplane ~ ➜ 



root@controlplane ~ ➜ kubectl get ns --show-labels
NAME              STATUS   AGE     LABELS
default           Active   3m7s    kubernetes.io/metadata.name=default
istio-system      Active   73s     kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   3m7s    kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   3m7s    kubernetes.io/metadata.name=kube-public
kube-system       Active   3m7s    kubernetes.io/metadata.name=kube-system
root@controlplane ~ ➜

root@controlplane ~ ➜ istioctl analyze -n default
Info [IST0102] (Namespace default) The namespace is not enabled for Istio injection. Run 'kubectl label namespace default istio-injection=enabled' to enable it, or 'kubectl label namespace default istio-injection=disabled' to explicitly mark it as not needing injection.
root@controlplane ~ ➜


root@controlplane ~ ➜ kubectl label namespace default istio.io/dataplane-mode=ambient
namespace/default labeled
root@controlplane ~ ➜

root@controlplane ~ ➜ kubectl get ns --show-labels
NAME              STATUS   AGE     LABELS
default           Active   4m28s   istio.io/dataplane-mode=ambient,kubernetes.io/metadata.name=default
istio-system      Active   2m34s   kubernetes.io/metadata.name=istio-system
kube-node-lease   Active   4m28s   kubernetes.io/metadata.name=kube-node-lease
kube-public       Active   4m28s   kubernetes.io/metadata.name=kube-public
kube-system       Active   4m28s   kubernetes.io/metadata.name=kube-system
root@controlplane ~ ➜ 


root@controlplane ~ ➜ kubectl get crd
NAME                                              CREATED AT
authorizationpolicies.security.istio.io           2025-08-30T19:37:58Z
destinationrules.networking.istio.io              2025-08-30T19:37:58Z
envoyfilters.networking.istio.io                  2025-08-30T19:37:58Z
gateways.networking.istio.io                      2025-08-30T19:37:58Z
peerauthentications.security.istio.io             2025-08-30T19:37:58Z
proxyconfigs.networking.istio.io                  2025-08-30T19:37:58Z
requestauthentications.security.istio.io          2025-08-30T19:37:58Z
serviceentries.networking.istio.io                2025-08-30T19:37:58Z
sidecars.networking.istio.io                      2025-08-30T19:37:58Z
telemetries.telemetry.istio.io                    2025-08-30T19:37:58Z
virtualservices.networking.istio.io               2025-08-30T19:37:58Z
wasmplugins.extensions.istio.io                   2025-08-30T19:37:57Z
workloadentries.networking.istio.io               2025-08-30T19:37:58Z
workloadgroups.networking.istio.io                2025-08-30T19:37:58Z
root@controlplane ~ ➜

root@controlplane ~ ➜ kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/grpcroutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/referencegrants.gateway.networking.k8s.io created
root@controlplane ~ ➜ █



kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml


root@controlplane ~ ➜ istioctl waypoint apply -n default
✔ waypoint default/waypoint applied

root@controlplane ~ ➜ kubectl get pods
NAME                        READY   STATUS              RESTARTS   AGE
test                        1/1     Running             0          2m34s
waypoint-7cb5d4bd6-crnmp    0/1     ContainerCreating   0          3s

root@controlplane ~ ➜ kubectl get pods
NAME                        READY   STATUS              RESTARTS   AGE
test                        1/1     Running             0          2m38s
waypoint-7cb5d4bd6-crnmp    1/1     Running             0          7s

root@controlplane ~ ➜ █


root@controlplane ~ ➜ kubectl get deployments.apps
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
waypoint    1/1     1            1           99s

root@controlplane ~ ➜ istioctl waypoint delete --all -n default
waypoint default/waypoint deleted

root@controlplane ~ ➜ kubectl get pods
NAME                        READY   STATUS        RESTARTS   AGE
test                        1/1     Running       0          4m22s
waypoint-7cb5d4bd6-crnmp    1/1     Terminating   0          111s

root@controlplane ~ ➜ █