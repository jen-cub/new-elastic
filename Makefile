RELEASE-CLIENT 	?= just-es-client
RELEASE-DATA 	?= just-es-data
RELEASE-MASTER 	?= just-es
NAMESPACE	?= default

CHART_NAME ?= elastic/elasticsearch
CHART_VERSION ?= 7.10.2

DEV_CLUSTER ?= testrc
DEV_PROJECT ?= jendevops1
DEV_ZONE ?= australia-southeast1-c

.DEFAULT_TARGET := status

.PHONY: clean deploy

all: deploy

lint:
ifdef YAMLLINT
	@find . -type f -name '*.yml' | xargs $(YAMLLINT)
	@find . -type f -name '*.yaml' | xargs $(YAMLLINT)
else
	$(warning "WARNING :: yamllint is not installed: https://github.com/adrienverge/yamllint")
endif


init:
	helm3 repo add elastic https://helm.elastic.co
	helm3 repo update

port:
	@echo "Visit http://127.0.0.1:9200 to use Elasticsearch"
	kubectl port-forward --namespace $(NAMESPACE) service/elasticsearch-client 9200:9200

status:
	helm status $(RELEASE)

dev: lint init dev-client dev-data dev-master

dev-client:
	gcloud config set project $(DEV_PROJECT)
	gcloud container clusters get-credentials $(DEV_CLUSTER) --zone $(DEV_ZONE) --project $(DEV_PROJECT)
	helm3 upgrade --install --wait $(RELEASE-CLIENT) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
		-f values-client.yaml \
		-f env/dev/values.yaml \
		$(CHART_NAME)
	$(MAKE) history

dev-data:
	gcloud config set project $(DEV_PROJECT)
	gcloud container clusters get-credentials $(DEV_CLUSTER) --zone $(DEV_ZONE) --project $(DEV_PROJECT)
	helm3 upgrade --install --wait $(RELEASE-DATA) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
		-f values-data.yaml \
		-f env/dev/values.yaml \
		$(CHART_NAME)
	$(MAKE) history

dev-master:
	gcloud config set project $(DEV_PROJECT)
	gcloud container clusters get-credentials $(DEV_CLUSTER) --zone $(DEV_ZONE) --project $(DEV_PROJECT)
	helm3 upgrade --install --wait $(RELEASE) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
		-f values-master.yaml \
		-f env/dev/values.yaml \
		$(CHART_NAME)
	$(MAKE) history







prod: lint init
ifndef CI
	$(error Please commit and push, this is intended to be run in a CI environment)
endif
	gcloud config set project $(PROD_PROJECT)
	gcloud container clusters get-credentials $(PROD_PROJECT) --zone $(PROD_ZONE) --project $(PROD_PROJECT)
	-kubectl label namespace $(NAMESPACE)
	helm upgrade --install --force --wait $(RELEASE) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
		-f env/prod/values.yaml \
		$(CHART_NAME)
	$(MAKE) history


history:
	helm3 history $(RELEASE) -n $(NAMESPACE) --max=5


destroy:
	helm delete $(RELEASE) --purge
	kubectl delete pvc -l release=$(RELEASE),component=data -n $(NAMESPACE)
	kubectl delete pvc -l release=$(RELEASE),component=master -n $(NAMESPACE)
	kubectl delete statefulset $(RELEASE)-es-elasticsearch-data -n $(NAMESPACE)


deploy:
	helm upgrade --install --force $(RELEASE) $(CHART) \
		-f values.yaml \
		--namespace $(NAMESPACE)
