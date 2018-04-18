RELEASE 	:= p4-es
NAMESPACE	:= default

.DEFAULT_GOAL := deploy

.PHONY: clean deploy

all: clean deploy

clean:
	helm delete $(RELEASE) --purge
	kubectl delete pvc -l release=$(RELEASE),component=data -n $(NAMESPACE)
	kubectl delete pvc -l release=$(RELEASE),component=master -n $(NAMESPACE)
	kubectl delete statefulset $(RELEASE)-es-elasticsearch-data -n $(NAMESPACE)

status:
	helm status $(RELEASE)

deploy:
	helm upgrade --install $(RELEASE) -f values.yaml incubator/elasticsearch --namespace $(NAMESPACE)
