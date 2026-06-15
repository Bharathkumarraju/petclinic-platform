root@controlplane ~ ➜  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/bookinfo/platform/kube/bookinfo.yaml
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

root@controlplane ~ ➜  istioctl install --set profile=demo -y
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
✔ Egress gateways installed 🛫                                                                                                                                                
✔ Ingress gateways installed 🛬                                                                                                                                              
✔ Installation complete                                                                                                                                                      

root@controlplane ~ ➜  


root@controlplane ~ ✖ k label namespace default istio-injection=enabled
namespace/default labeled

root@controlplane ~ ➜  k get ns default --show-labels
NAME      STATUS   AGE   LABELS
default   Active   34m   istio-injection=enabled,kubernetes.io/metadata.name=default

root@controlplane ~ ➜  k get pods
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-54ffb59669-58rmj       1/1     Running   0          6m39s
productpage-v1-6c58956fd9-r8rwp   1/1     Running   0          6m38s
ratings-v1-7d7546bf89-hdm9b       1/1     Running   0          6m38s
reviews-v1-6c7fd84f89-mxgkq       1/1     Running   0          6m38s
reviews-v2-57bb9fdcdf-rzxdw       1/1     Running   0          6m38s
reviews-v3-548fc5d9c7-lmh2n       1/1     Running   0          6m38s

root@controlplane ~ ➜  


root@controlplane ~ ➜  k run redis-no-proxy --image redis -n db
pod/redis-no-proxy created

root@controlplane ~ ➜  kubectl run redis -n db --image=redis --dry-run=client -o yaml > pod.yaml

root@controlplane ~ ➜  istioctl kube-inject -f pod.yaml | kubectl apply -f  - 
pod/redis created

root@controlplane ~ ➜  kubectl get ns db --show-labels
NAME   STATUS   AGE     LABELS
db     Active   2m46s   kubernetes.io/metadata.name=db

root@controlplane ~ ➜  k get pods -n db
NAME             READY   STATUS    RESTARTS   AGE
redis            2/2     Running   0          28s
redis-no-proxy   1/1     Running   0          106s

root@controlplane ~ ➜  
