Observability
Visualizing Metrics
with Prometheus and Grafana

Distributed Tracing
with Jaeger

Kiali
in Detail


istioctl dashboard kiali 
istioctl dashboard prometheus
istioctl dashboard grafana

istio metrics 

istio_agents_go_info

istio_requests_total

istio_requests_total{destination_service="productpage.default.svc.cluster.local"}


istio_requests_total{destination_service="reviews.default.svc.cluster.local",destination_version="v3"}

istiotraining@local istio-1.10.3 $ while sleep 0.01; do curl -sS "http://${INGRESS_HOST}:${INGRESS_PORT}/productpage" &> /dev/null ; done

istiotraining@local istio-1.10.3 $ kubectl get svc prometheus -n istio-system
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
prometheus   ClusterIP   10.98.236.105   <none>        9090/TCP   85m

istiotraining@local istio-1.10.3 $ kubectl get svc grafana -n istio-system
NAME      TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
grafana   ClusterIP   10.96.79.92   <none>        3000/TCP   85m

istiotraining@local istio-1.10.3 $ istioctl dashboard grafana



istioctl dashboard kiali 
istioctl dashboard prometheus
istioctl dashboard grafana
istioctl dashboard jaeger 


istiotraining@local istio-1.10.3 $ kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: details
spec:
  hosts:
  - details
  http:
  - fault:
      delay:
        percentage:
          value: 70.0
        fixedDelay: 7s
    route:
    - destination:
        host: details
        subset: v1
EOF

