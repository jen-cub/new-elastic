RELEASE 	?= p4-es
NAMESPACE	?= default

.DEFAULT_GOAL := deploy

.PHONY: clean deploy

all: clean deploy

clean:
	helm delete $(RELEASE) --purge
	kubectl delete pvc -l release=$(RELEASE),component=data -n $(NAMESPACE)
	kubectl delete pvc -l release=$(RELEASE),component=master -n $(NAMESPACE)
	kubectl delete statefulset $(RELEASE)-es-elasticsearch-data -n $(NAMESPACE)

port:
	@echo "Visit http://127.0.0.1:9200 to use Elasticsearch"
	kubectl port-forward --namespace $(NAMESPACE) $(shell kubectl get pods --namespace default -l "app=elasticsearch,component=client,release=$(RELEASE)" -o jsonpath="{.items[0].metadata.name}") 9200:9200

status:
	helm status $(RELEASE)

deploy:
	helm upgrade --install $(RELEASE) -f values.yaml incubator/elasticsearch --namespace $(NAMESPACE)
