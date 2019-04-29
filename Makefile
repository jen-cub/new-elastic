RELEASE 	?= p4-es
NAMESPACE	?= default

CHART ?= stable/elasticsearch

.DEFAULT_GOAL := deploy

.PHONY: clean deploy

all: deploy

clean:
	helm delete $(RELEASE) --purge
	kubectl delete pvc -l release=$(RELEASE),component=data -n $(NAMESPACE)
	kubectl delete pvc -l release=$(RELEASE),component=master -n $(NAMESPACE)
	kubectl delete statefulset $(RELEASE)-es-elasticsearch-data -n $(NAMESPACE)

port:
	@echo "Visit http://127.0.0.1:9200 to use Elasticsearch"
	kubectl port-forward --namespace $(NAMESPACE) $(shell kubectl get service --namespace $(NAMESPACE) -l "app=elasticsearch,component=client,release=$(RELEASE)" -o name) 9200:9200

status:
	helm status $(RELEASE)

deploy:
	helm upgrade --install --force $(RELEASE) $(CHART) \
		-f values.yaml \
		--namespace $(NAMESPACE)
