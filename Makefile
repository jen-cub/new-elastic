RELEASE 	?= p4-es
NAMESPACE	?= default

CHART_NAME ?= stable/elasticsearch
CHART_VERSION ?= 1.32.4

DEV_CLUSTER ?= p4-development
DEV_PROJECT ?= planet-4-151612
DEV_ZONE ?= us-central1-a

PROD_CLUSTER ?= planet4-production
PROD_PROJECT ?= planet4-production
PROD_ZONE ?= us-central1-a

.DEFAULT_TARGET := status

.PHONY: clean deploy

all: deploy

lint:
	@find . -type f -name '*.yml' | xargs yamllint
	@find . -type f -name '*.yaml' | xargs yamllint

init:
	helm init --client-only
	helm repo update

port:
	@echo "Visit http://127.0.0.1:9200 to use Elasticsearch"
	kubectl port-forward --namespace $(NAMESPACE) $(shell kubectl get service --namespace $(NAMESPACE) -l "app=elasticsearch,component=client,release=$(RELEASE)" -o name) 9200:9200

status:
	helm status $(RELEASE)

dev: lint init
ifndef CI
	$(error Please commit and push, this is intended to be run in a CI environment)
endif
	gcloud config set project $(DEV_PROJECT)
	gcloud container clusters get-credentials $(DEV_CLUSTER) --zone $(DEV_ZONE) --project $(DEV_PROJECT)
	helm upgrade --install --force --wait $(RELEASE) \
		--namespace=$(NAMESPACE) \
		--version $(CHART_VERSION) \
		-f values.yaml \
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
	helm history $(RELEASE) --max=5


destroy:
	helm delete $(RELEASE) --purge
	kubectl delete pvc -l release=$(RELEASE),component=data -n $(NAMESPACE)
	kubectl delete pvc -l release=$(RELEASE),component=master -n $(NAMESPACE)
	kubectl delete statefulset $(RELEASE)-es-elasticsearch-data -n $(NAMESPACE)


deploy:
	helm upgrade --install --force $(RELEASE) $(CHART) \
		-f values.yaml \
		--namespace $(NAMESPACE)
