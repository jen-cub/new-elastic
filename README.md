# Planet-4 Helm chart Elastic Search configuration

Ingredients:
-   a running Kubernetes cluster
-   helm tiller initialised
-   helm client [https://docs.helm.sh/using_helm/](https://docs.helm.sh/using_helm/)

Preparation:
```
RELEASE=<my-release> make
```

Cooking:

To access the ES instance from within your cluster, use:

`$RELEASE-elasticsearch-client.default.svc.cluster.local:9200`

To connect from outside the cluster:
```
make port &
```

Cleaning up:
```
make clean
```
