Automatic sidecar injection --> istio-injection=enabled

kubectl delete -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/bookinfo/platform/kube/bookinfo.yaml
kubectl get pods


$ wget https://raw.githubusercontent.com/istio/istio/release-1.25/samples/bookinfo/platform/kube/bookinfo.yaml

Manual sidecar injection:
$ istioctl kube-inject -f bookinfo.yaml | kubectl apply -f -
$ kubectl get pods
NAME                             READY   STATUS    RESTARTS   AGE
details-v1-7c5d957895-pss97      2/2     Running   0          8s
productpage-v1-f47f868c8-wtkx2   2/2     Running   0          7s
ratings-v1-85cf8d8647-tl6cr      2/2     Running   0          8s
reviews-v1-5fc87d67c-h8925       2/2     Running   0          7s
reviews-v2-f6d449f65-p4zwc       2/2     Running   0          7s
reviews-v3-76f75877b9-gn88k      2/2     Running   0          7s
$


install istio using Helm:
--------------------------------->

$ helm repo add istio https://istio-release.storage.googleapis.com/charts
$ helm repo update

$ helm install istio-base istio/base --namespace istio-system --version 1.26.3 --create-namespace
$ helm install istiod istio/istiod --namespace istio-system --version 1.26.23-wait
$ helm install istio-ingress istio/gateway --namespace istio-ingress --version 1.26.3 --create-namespace

$ helm ls -A
NAME          NAMESPACE     REVISION    UPDATED                                     STATUS      CHART           APP VERSION
istio-base    istio-system  1           2025-03-30 22:11:23.842761778 +0000 UTC     deployed    base-1.26.3     1.26.3
istio-ingress istio-ingress 1           2025-03-30 22:15:35.833414871 +0000 UTC     deployed    gateway-1.26.3  1.26.3
istiod        istio-system  1           2025-03-30 22:13:31.896435162 +0000 UTC     deployed    istiod-1.26.3   1.26.3



bharathkumardasaraju@abspot$ istioctl version
client version: 1.30.1
control plane version: 1.30.1
data plane version: 1.30.1 (8 proxies)
bharathkumardasaraju@abspot$ istioctl analyze -n petclinic-istio
Warning [IST0150] (Service petclinic-istio/tracing-server) Port name for ExternalName service is invalid. Proxy may prevent tcp named ports and unmatched traffic for ports serving TCP protocol from being forwarded correctly
bharathkumardasaraju@abspot$

bharathkumardasaraju@abspot$ kubectl get namespaces
NAME               STATUS   AGE
default            Active   8d
external-secrets   Active   42h
istio-system       Active   31h
kube-node-lease    Active   8d
kube-public        Active   8d
kube-system        Active   8d
monitoring         Active   35h
petclinic-istio    Active   7d15h
tracing            Active   35h
bharathkumardasaraju@abspot$

