bharathkumardasaraju@abspot$ kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.1/standard-install.yaml
customresourcedefinition.apiextensions.k8s.io/backendtlspolicies.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/grpcroutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/listenersets.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/referencegrants.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/tlsroutes.gateway.networking.k8s.io created
validatingadmissionpolicy.admissionregistration.k8s.io/safe-upgrades.gateway.networking.k8s.io created
validatingadmissionpolicybinding.admissionregistration.k8s.io/safe-upgrades.gateway.networking.k8s.io created
bharathkumardasaraju@abspot$ istioctl waypoint apply -n petclinic-istio
✅ waypoint petclinic-istio/waypoint applied
bharathkumardasaraju@abspot$ kubectl get pods -n petclinic-istio
NAME                                 READY   STATUS    RESTARTS   AGE
admin-server-7449c676f9-rlr5m        1/1     Running   0          32h
api-gateway-79db9467-tbjjt           1/1     Running   0          32h
config-server-7f87f4579-7dh4z        1/1     Running   0          32h
customers-service-6868798c4b-cq2l7   1/1     Running   0          32h
discovery-server-7f5dc9676d-n8tv8    1/1     Running   0          32h
genai-service-7fbbdddfc-fzr7g        1/1     Running   0          32h
vets-service-788c8c548b-76ftb        1/1     Running   0          32h
visits-service-6fcb9c5-bj4lr         1/1     Running   0          32h
waypoint-7954749956-45qbt            1/1     Running   0          107s
bharathkumardasaraju@abspot$ kubectl logs -f waypoint-7954749956-45qbt -n petclinic-istio
2026/06/14 21:59:40 INFO GOMEMLIMIT is already set, skipping package=github.com/KimMachineGun/automemlimit/memlimit GOMEMLIMIT=1073741824
2026-06-14T21:59:40.874075Z	info	FLAG: --concurrency="0"
2026-06-14T21:59:40.874106Z	info	FLAG: --domain="petclinic-istio.svc.cluster.local"
2026-06-14T21:59:40.874111Z	info	FLAG: --help="false"
2026-06-14T21:59:40.874113Z	info	FLAG: --log_as_json="false"
2026-06-14T21:59:40.874115Z	info	FLAG: --log_caller=""
2026-06-14T21:59:40.874117Z	info	FLAG: --log_output_level="default:info"
2026-06-14T21:59:40.874119Z	info	FLAG: --log_stacktrace_level="default:none"
2026-06-14T21:59:40.874128Z	info	FLAG: --log_target="[stdout]"
2026-06-14T21:59:40.874131Z	info	FLAG: --meshConfig="./etc/istio/config/mesh"
2026-06-14T21:59:40.874134Z	info	FLAG: --outlierLogPath=""
2026-06-14T21:59:40.874136Z	info	FLAG: --profiling="true"
2026-06-14T21:59:40.874138Z	info	FLAG: --proxyComponentLogLevel="misc:error"
2026-06-14T21:59:40.874140Z	info	FLAG: --proxyLogLevel="warning"
2026-06-14T21:59:40.874142Z	info	FLAG: --serviceCluster="waypoint.petclinic-istio"
2026-06-14T21:59:40.874144Z	info	FLAG: --stsPort="0"
2026-06-14T21:59:40.874146Z	info	FLAG: --templateFile=""
2026-06-14T21:59:40.874148Z	info	FLAG: --tokenManagerPlugin=""
2026-06-14T21:59:40.874153Z	info	FLAG: --vklog="0"
2026-06-14T21:59:40.874156Z	info	Version 1.30.1-10229c76f2854420eeac94906ffff949b9aab746-Clean
2026-06-14T21:59:40.874335Z	info	Proxy role	ips=[10.0.1.110] type=waypoint id=waypoint-7954749956-45qbt.petclinic-istio domain=petclinic-istio.svc.cluster.local
2026-06-14T21:59:40.874372Z	info	Apply proxy config from env {"proxyMetadata":{"ISTIO_META_ENABLE_HBONE":"true"},"image":{"imageType":"distroless"}}

2026-06-14T21:59:40.875929Z	info	cpu limit detected as 2, setting concurrency
2026-06-14T21:59:40.876185Z	info	Effective config: binaryPath: /usr/local/bin/envoy
concurrency: 2
configPath: ./etc/istio/proxy
controlPlaneAuthPolicy: MUTUAL_TLS
discoveryAddress: istiod.istio-system.svc:15012
drainDuration: 45s
image:
  imageType: distroless
proxyAdminPort: 15000
proxyMetadata:
  ISTIO_META_ENABLE_HBONE: "true"
serviceCluster: istio-proxy
statNameLength: 189
statusPort: 15020
terminationDrainDuration: 5s

2026-06-14T21:59:40.876202Z	info	JWT policy is third-party-jwt
2026-06-14T21:59:40.876205Z	info	using credential fetcher of JWT type in cluster.local trust domain
2026-06-14T21:59:40.978435Z	info	Starting default Istio SDS Server
2026-06-14T21:59:40.978651Z	info	CA Endpoint istiod.istio-system.svc:15012, provider Citadel
2026-06-14T21:59:40.978423Z	info	Opening status port 15020
2026-06-14T21:59:40.978768Z	info	Using CA istiod.istio-system.svc:15012 cert with certs: var/run/secrets/istio/root-cert.pem
2026-06-14T21:59:40.979567Z	info	xdsproxy	Initializing with upstream address "istiod.istio-system.svc:15012" and cluster "Kubernetes"
2026-06-14T21:59:40.981351Z	info	Pilot SAN: [istiod.istio-system.svc]
2026-06-14T21:59:40.983414Z	info	Starting proxy agent
2026-06-14T21:59:40.983465Z	info	Envoy command: [-c etc/istio/proxy/envoy-rev.json --drain-time-s 45 --drain-strategy immediate --local-address-ip-version v4 --file-flush-interval-msec 1000 --disable-hot-restart --allow-unknown-static-fields -l warning --component-log-level misc:error --skip-deprecated-logs --concurrency 2]
2026-06-14T21:59:40.996847Z	info	sds	Starting SDS grpc server
2026-06-14T21:59:40.997308Z	info	sds	Starting SDS server for workload certificates, will listen on "var/run/secrets/workload-spiffe-uds/socket"
2026-06-14T21:59:41.120455Z	info	xdsproxy	connected to delta upstream XDS server: istiod.istio-system.svc:15012	id=1
2026-06-14T21:59:41.150814Z	info	ads	ADS: new connection for node:1
2026-06-14T21:59:41.151767Z	info	ads	ADS: new connection for node:2
2026-06-14T21:59:41.381805Z	info	cache	generated new workload certificate	resourceName=default latency=402.05132ms ttl=23h59m59.618199731s
2026-06-14T21:59:41.381858Z	info	cache	Root cert has changed, start rotating root cert
2026-06-14T21:59:41.381912Z	info	cache	returned workload trust anchor from cache	ttl=23h59m59.618089212s
2026-06-14T21:59:41.381942Z	info	cache	returned workload certificate from cache	ttl=23h59m59.618058509s
2026-06-14T21:59:41.382146Z	info	cache	returned workload trust anchor from cache	ttl=23h59m59.617857647s
2026-06-14T21:59:41.382566Z	info	cache	returned workload trust anchor from cache	ttl=23h59m59.617435624s
2026-06-14T21:59:41.633199Z	info	Readiness succeeded in 763.368645ms
2026-06-14T21:59:41.633539Z	info	Envoy proxy is ready
^C
bharathkumardasaraju@abspot$


bharathkumardasaraju@abspot$ kubectl get deployments -n petclinic-istio
NAME                READY   UP-TO-DATE   AVAILABLE   AGE
admin-server        1/1     1            1           40h
api-gateway         1/1     1            1           40h
config-server       1/1     1            1           40h
customers-service   1/1     1            1           40h
discovery-server    1/1     1            1           40h
genai-service       1/1     1            1           40h
vets-service        1/1     1            1           40h
visits-service      1/1     1            1           40h
waypoint            1/1     1            1           7m
bharathkumardasaraju@abspot$


bharathkumardasaraju@abspot$ kubectl get gatewayclasses.gateway.networking.k8s.io -A
NAME             CONTROLLER                    ACCEPTED   AGE
istio            istio.io/gateway-controller   True       18m
istio-remote     istio.io/unmanaged-gateway    True       18m
istio-waypoint   istio.io/mesh-controller      True       18m
bharathkumardasaraju@abspot$
