# Planet-4 Helm chart Elastic Search configuration

Ingredients:
-   a running Kubernetes cluster
-   helm tiller initialised
-   helm client [https://docs.helm.sh/using_helm/](https://docs.helm.sh/using_helm/)

Preparation:
```
ES-RELEASE=<my-release>
helm upgrade --install $ES-RELEASE -f values.yaml incubator/elasticsearch
```

Cooking:

Access the ES instance from within your cluster, at the following DNS name at port 9200:

`$ES-RELEASE-elasticsearch-client.default.svc.cluster.local`

From outside the cluster, run these commands in the same shell:
```
export POD_NAME=$(kubectl get pods --namespace default -l "app=elasticsearch,component=client,release=$ES-RELEASE" -o jsonpath="{.items[0].metadata.name}")
echo "Visit http://127.0.0.1:9200 to use Elasticsearch"
kubectl port-forward --namespace default $POD_NAME 9200:9200
```

Cleaning up: remember to delete any unwanted storage:
```
helm delete $ES-RELEASE
kubectl delete pvc -l release=$ES-RELEASE,component=data
kubectl delete pvc -l release=$ES-RELEASE,component=master
```
