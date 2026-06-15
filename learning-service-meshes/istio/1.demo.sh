bharathkumardasaraju@abspot$ istioctl version
Istio is not present in the cluster: no running Istio pods in namespace "istio-system"
client version: 1.30.1
bharathkumardasaraju@abspot$ aws eks update-kubeconfig --region eu-central-1 --name petclinic-istio
Updated context arn:aws:eks:eu-central-1:172586632398:cluster/petclinic-istio in /Users/bharathkumardasaraju/.kube/config
bharathkumardasaraju@abspot$
bharathkumardasaraju@abspot$
bharathkumardasaraju@abspot$
bharathkumardasaraju@abspot$ istioctl version
client version: 1.30.1
control plane version: 1.30.1
data plane version: 1.30.1 (8 proxies)
bharathkumardasaraju@abspot$ kubectl get all -n istio-system
NAME                          READY   STATUS    RESTARTS   AGE
pod/istio-cni-node-297rq      1/1     Running   0          30h
pod/istio-cni-node-f9mjq      1/1     Running   0          30h
pod/istio-cni-node-hpbfv      1/1     Running   0          30h
pod/istio-cni-node-jkmhj      1/1     Running   0          30h
pod/istio-cni-node-rwkft      1/1     Running   0          30h
pod/istio-cni-node-ws4m9      1/1     Running   0          30h
pod/istio-cni-node-x86cj      1/1     Running   0          30h
pod/istio-cni-node-xs5jg      1/1     Running   0          30h
pod/istiod-64f6fb765f-48hcp   1/1     Running   0          30h
pod/ztunnel-245hd             1/1     Running   0          30h
pod/ztunnel-57pm8             1/1     Running   0          30h
pod/ztunnel-6v6j8             1/1     Running   0          30h
pod/ztunnel-8kdfl             1/1     Running   0          30h
pod/ztunnel-978cp             1/1     Running   0          30h
pod/ztunnel-g88zg             1/1     Running   0          30h
pod/ztunnel-jvm8f             1/1     Running   0          30h
pod/ztunnel-lpbnt             1/1     Running   0          30h

NAME             TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                                 AGE
service/istiod   ClusterIP   172.20.3.39   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP   30h

NAME                            DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/istio-cni-node   8         8         8       8            8           kubernetes.io/os=linux   30h
daemonset.apps/ztunnel          8         8         8       8            8           kubernetes.io/os=linux   30h

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istiod   1/1     1            1           30h

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/istiod-64f6fb765f   1         1         1       30h

NAME                                         REFERENCE           TARGETS              MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/istiod   Deployment/istiod   cpu: <unknown>/80%   1         5         1          30h
bharathkumardasaraju@abspot$

