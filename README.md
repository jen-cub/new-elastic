# Planet-4 Helm chart Elastic Search configuration

Currently using a deprecated chart in stable/elasticsearch

***
NOT INTENDED TO BE DEPLOYED BY HAND
***

This repository is intended to be used via [CircleCI](https://circleci.com/gh/greenpeace/planet4-traefik)

Commits to the develop branch affect the development cluster, commits to the master branch affect the production cluster.

---


## Dining:

To access Elasticsearch from within your cluster, use:

`$RELEASE-elasticsearch-client.$NAMESPACE.svc.cluster.local:9200`

To connect from outside the cluster:

```
make port &
curl http://localhost:9200/_cat/health
```

## Destroying:

```
make destroy
```
