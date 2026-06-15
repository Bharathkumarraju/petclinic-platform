root@controlplane ~ ➜ which helm
/usr/sbin/helm

root@controlplane ~ ➜ helm repo add istio https://istio-release.storage.googleapis.com/charts
"istio" has been added to your repositories

root@controlplane ~ ➜ helm repo list
NAME 	URL
istio	https://istio-release.storage.googleapis.com/charts

root@controlplane ~ ➜ kubectl get crd
No resources found

root@controlplane ~ ➜ helm install istio-base istio/base --namespace istio-system --create-namespace --version 1.26.3 --set profile=demo
NAME: istio-base
LAST DEPLOYED: Tue Aug 26 22:25:58 2025
NAMESPACE: istio-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
Istio base successfully installed!

To learn more about the release, try:
  $ helm status istio-base -n istio-system
  $ helm get all istio-base -n istio-system

root@controlplane ~ ➜ kubectl get crd
NAME                                             CREATED AT
authorizationpolicies.security.istio.io          2025-08-26T22:26:00Z
destinationrules.networking.istio.io             2025-08-26T22:25:59Z
envoyfilters.networking.istio.io                 2025-08-26T22:26:00Z
gateways.networking.istio.io                     2025-08-26T22:25:59Z
peerauthentications.security.istio.io            2025-08-26T22:26:00Z
proxyconfigs.networking.istio.io                 2025-08-26T22:25:59Z
requestauthentications.security.istio.io         2025-08-26T22:26:00Z
serviceentries.networking.istio.io               2025-08-26T22:26:00Z
sidecars.networking.istio.io                     2025-08-26T22:26:00Z
telemetries.telemetry.istio.io                   2025-08-26T22:26:00Z
virtualservices.networking.istio.io              2025-08-26T22:26:00Z
wasmplugins.extensions.istio.io                  2025-08-26T22:25:59Z
workloadentries.networking.istio.io              2025-08-26T22:26:00Z
workloadgroups.networking.istio.io               2025-08-26T22:25:59Z

root@controlplane ~ ➜ █

root@controlplane ~ ➜ helm install istiod istio/istiod --namespace istio-system --version 1.26.3 --set profile=demo --set pilot.resources.requests.memory=128Mi --set pilot.resources.requests.cpu=250m
NAME: istiod
LAST DEPLOYED: Tue Aug 26 22:26:57 2025
NAMESPACE: istio-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
"istiod" successfully installed!

To learn more about the release, try:
  $ helm status istiod -n istio-system
  $ helm get all istiod -n istio-system

Next steps:
  * Deploy a Gateway: https://istio.io/latest/docs/setup/additional-setup/gateway/
  * Try out our tasks to get started on common configurations:
    * https://istio.io/latest/docs/tasks/traffic-management
    * https://istio.io/latest/docs/tasks/security
    * https://istio.io/latest/docs/tasks/policy-enforcement
  * Review the list of actively supported releases, CVE publications and our hardening guide:
    * https://istio.io/latest/docs/releases/supported-releases/
    * https://istio.io/latest/news/security/
    * https://istio.io/latest/docs/ops/best-practices/security/

For further documentation see https://istio.io website

root@controlplane ~ ➜ █



root@controlplane ~ ➜ helm install istio-ingress istio/gateway --namespace istio-system --version 1.26.3
NAME: istio-ingress
LAST DEPLOYED: Tue Aug 26 22:27:56 2025
NAMESPACE: istio-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
"istio-ingress" successfully installed!

To learn more about the release, try:
  $ helm status istio-ingress -n istio-system
  $ helm get all istio-ingress -n istio-system

Next steps:
  * Deploy an HTTP Gateway: https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/
  * Deploy an HTTPS Gateway: https://istio.io/latest/docs/tasks/traffic-management/ingress/secure-ingress/

root@controlplane ~ ➜ kubectl get pods -n istio-system
NAME                             READY   STATUS    RESTARTS   AGE
istio-ingress-6cc846956d-b57jn   1/1     Running   0          5s
istiod-7f65f9c48b-5wgpr          1/1     Running   0          64s

root@controlplane ~ ➜ 

root@controlplane ~ ➜ helm show values istio/istiod > istiod.yaml
root@controlplane ~ ➜ helm show values istio/gateway > gateway.yaml

root@controlplane ~ ➜ ll
total 76
drwx------  8 root root  4096 Aug 26 22:30 ./
drwxr-xr-x 21 root root  4096 Aug 26 22:23 ../
-rw-r--r--  1 root root   711 Aug 26 22:23 .bash_profile
-rw-r--r--  1 root root  3256 May 31 14:47 .bashrc
drwxr-xr-x  4 root root  4096 Aug 26 22:25 .cache/
drwxr-xr-x  3 root root  4096 Aug 26 22:25 .config/
-rw-r--r--  1 root root  6083 Aug 26 22:30 gateway.yaml
-rw-r--r--  1 root root 23152 Aug 26 22:30 istiod.yaml
drwxr-xr-x  3 root root  4096 Aug 26 22:23 .kube/
-rw-r--r--  1 root root   161 Jul  9  2019 .profile
drwx------  3 root root  4096 May 31 14:45 snap/
drwx------  2 root root  4096 May 31 14:45 .ssh/
-rw-r--r--  1 root root     0 May 31 14:46 .sudo_as_admin_successful
drwx------  2 root root  4096 Aug 26 22:24 .terminal_logs/

root@controlplane ~ ➜ vim istiod.yaml

root@controlplane ~ ➜ vim gateway.yaml

root@controlplane ~ ➜ helm upgrade --install istiod istio/istiod --namespace istio-system -f istiod.yaml 

root@controlplane ~ ➜ helm upgrade --install istio-ingress istio/gateway --namespace istio-system -f gateway.yaml

