# Planet-4 Helm chart Elastic Search configuration

Cleaning up: remember to delete any unwanted storage:
```
helm delete my-release
kubectl delete pvc -l release=my-release,component=data
kubectl delete pvc -l release=my-release,component=master
```
