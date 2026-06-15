root@controlplane ~ ➜  kubectl run test --image=nginx
pod/test created

root@controlplane ~ ➜  curl -sL https://istio.io/downloadIstioctl | ISTIO_VERSION=1.26.0 sh -

Downloading istioctl-1.26.0 from https://github.com/istio/istio/releases/download/1.26.0/istioctl-1.26.0-linux-amd64.tar.gz ...
istioctl-1.26.0-linux-amd64.tar.gz download complete!

Add the istioctl to your path with:
  export PATH=$HOME/.istioctl/bin:$PATH 

Begin the Istio pre-installation check by running:
         istioctl x precheck 

Need more information? Visit https://istio.io/docs/reference/commands/istioctl/ 

root@controlplane ~ ➜  sudo install -m 755 ~/.istioctl/bin/istioctl /usr/local/bin/istioctl

root@controlplane ~ ➜  istioctl version
Istio is not present in the cluster: no running Istio pods in namespace "istio-system"
client version: 1.26.0

root@controlplane ~ ➜  



root@controlplane ~ ✖ kubectl get all -n istio-system
No resources found in istio-system namespace.

root@controlplane ~ ➜  istioctl install --set profile=ambient -y
        |\          
        | \         
        |  \        
        |   \       
      /||    \      
     / ||     \     
    /  ||      \    
   /   ||       \   
  /    ||        \  
 /     ||         \ 
/______||__________\
____________________
  \__       _____/  
     \_____/        

WARNING: Istio 1.26.0 may be out of support (EOL) already: see https://istio.io/latest/docs/releases/supported-releases/ for supported releases
✔ Istio core installed ⛵️                                                                                                                                        
✔ Istiod installed 🧠                                                                                                                                            
✔ CNI installed 🪢                                                                                                                                               
✔ Ztunnel installed 🔒                                                                                                                                           
✔ Installation complete                                                                                                                                         
The ambient profile has been installed successfully, enjoy Istio without sidecars!

root@controlplane ~ ➜  kubectl get all -n istio-system
NAME                         READY   STATUS    RESTARTS   AGE
pod/istio-cni-node-h5hfv     1/1     Running   0          14s
pod/istiod-86b6b7ff7-j58x2   1/1     Running   0          20s
pod/ztunnel-rct9m            1/1     Running   0          8s

NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                 AGE
service/istiod   ClusterIP   10.109.83.206   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP   20s

NAME                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/istio-cni-node   1         1         1       1            1           kubernetes.io/os=linux   14s
daemonset.apps/ztunnel          1         1         1       1            1           kubernetes.io/os=linux   8s

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istiod   1/1     1            1           20s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/istiod-86b6b7ff7   1         1         1       20s

NAME                                         REFERENCE           TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/istiod   Deployment/istiod   cpu: <unknown>/80%   1         5         1          20s

root@controlplane ~ ➜  


Labels application namespace for ambient enrollment (istio.io/dataplane-mode=ambient) and restart app pods to trigger ambient CNI interception. Then verify control plane and app pods.

root@controlplane ~ ➜  kubectl label namespace default istio.io/dataplane-mode=ambient
namespace/default labeled

root@controlplane ~ ➜  



root@controlplane ~ ➜  kubectl exec test -- curl --head www.google.com
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 200 OK
Content-Type: text/html; charset=ISO-8859-1
Content-Security-Policy-Report-Only: object-src 'none';base-uri 'self';script-src 'nonce-RHrBr2ut6lr0MI1egasTeA' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
P3P: CP="This is not a P3P policy! See g.co/p3phelp for more info."
Date: Sun, 14 Jun 2026 22:14:18 GMT
Server: gws
X-XSS-Protection: 0
X-Frame-Options: SAMEORIGIN
Transfer-Encoding: chunked
Expires: Sun, 14 Jun 2026 22:14:18 GMT
Cache-Control: private
Set-Cookie: AEC=AaJma5tlcxfxgUpHpdzcT5IgtDm9WGtQOIlCIrDTXzGFkxCSEfS88jx-8g; expires=Fri, 11-Dec-2026 22:14:18 GMT; path=/; domain=.google.com; Secure; HttpOnly; SameSite=lax
Set-Cookie: NID=532=nGDjJhS-WiyxGVp6pQuv_AZs7OG5Iw0FfyXghO7DtEg_Y3TYlvJPiv-QHEsAV2eAZvTixA4ITQYO62Vx89u2W17AZJtL_BH5IZUCKTZ1nib_rkqzo-EsVAzya869HK9CSjZbvkRlbESt8iNKSqcZ65G8t1bGo7Tge854bsg95k9jRhRsPM39dY4; expires=Mon, 14-Dec-2026 22:14:18 GMT; path=/; domain=.google.com; HttpOnly


root@controlplane ~ ➜  



root@controlplane ~ ➜  kubectl logs -f -n istio-system -l app=ztunnel --all-containers=true
2026-06-14T22:12:19.298640Z     info    readiness       Task 'workload proxy manager' complete (16.467375ms), marking server ready
2026-06-14T22:12:20.041433Z     info    xds::client:xds{id=1}   received response       type_url="type.googleapis.com/istio.security.Authorization" size=0 removes=0
2026-06-14T22:12:20.141853Z     info    xds::client:xds{id=1}   received response       type_url="type.googleapis.com/istio.workload.Address" size=1 removes=0
2026-06-14T22:12:22.210455Z     info    xds::client:xds{id=1}   received response       type_url="type.googleapis.com/istio.security.Authorization" size=0 removes=0
2026-06-14T22:13:12.931769Z     info    inpod::statemanager     pod received, starting proxy    uid="21d69c2c-7981-4c8f-8123-0eacfa2585fb" name="test" namespace="default"
2026-06-14T22:13:12.932227Z     info    dns::server     starting local DNS server       address=localhost:15053 component="dns"
2026-06-14T22:13:12.932490Z     info    proxy::inbound  listener established    address=[::]:15008 component="inbound" transparent=true
2026-06-14T22:13:12.932563Z     info    proxy::inbound_passthrough      listener established    address=[::]:15006 component="inbound plaintext" transparent=true
2026-06-14T22:13:12.932575Z     info    proxy::outbound listener established    address=[::]:15001 component="outbound" transparent=true
2026-06-14T22:13:13.042122Z     info    xds::client:xds{id=1}   received response       type_url="type.googleapis.com/istio.workload.Address" size=1 removes=0



2026-06-14T22:14:18.415546Z     info    access  connection complete     src.addr=10.50.0.4:47734 src.workload="test" src.namespace="default" dst.addr=142.251.151.119:80 direction="outbound" bytes_sent=79 bytes_recv=1027 duration="14ms"






root@controlplane ~ ➜  kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/grpcroutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/referencegrants.gateway.networking.k8s.io created

root@controlplane ~ ➜  kubectl get crd gateways.gateway.networking.k8s.io
NAME                                 CREATED AT
gateways.gateway.networking.k8s.io   2026-06-14T22:15:11Z

root@controlplane ~ ➜  


root@controlplane ~ ➜  kubectl get gatewayclasses.gateway.networking.k8s.io -A
NAME             CONTROLLER                    ACCEPTED   AGE
istio            istio.io/gateway-controller   True       38s
istio-remote     istio.io/unmanaged-gateway    True       38s
istio-waypoint   istio.io/mesh-controller      True       38s

root@controlplane ~ ➜  



root@controlplane ~ ➜  istioctl waypoint apply -n default
✅ waypoint default/waypoint applied

root@controlplane ~ ➜  kubectl get all -n default
NAME                          READY   STATUS    RESTARTS   AGE
pod/test                      1/1     Running   0          8m4s
pod/waypoint-66b59898-mh2p4   1/1     Running   0          8s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)               AGE
service/kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP               54m
service/waypoint     ClusterIP   10.96.183.133   <none>        15021/TCP,15008/TCP   8s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/waypoint   1/1     1            1           8s

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/waypoint-66b59898   1         1         1       8s

root@controlplane ~ ➜  



root@controlplane ~ ➜  istioctl waypoint delete --all -n default
waypoint default/waypoint deleted

root@controlplane ~ ➜  kubectl get all -n default
NAME                          READY   STATUS    RESTARTS   AGE
pod/test                      1/1     Running   0          8m53s
pod/waypoint-66b59898-mh2p4   0/1     Error     0          57s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   55m

root@controlplane ~ ➜  kubectl get all -n default
NAME       READY   STATUS    RESTARTS   AGE
pod/test   1/1     Running   0          8m57s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   55m

root@controlplane ~ ➜  

