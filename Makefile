# Makefile for besoked installation

#NOTE: override these at execution time
REPO ?= localhost/
IMAGE_NAME ?= webdav
IMAGE_TAG ?= $(strip $(shell find Dockerfile.webdav Gemfile Gemfile.lock config.ru -type f | xargs shasum | sort | shasum | cut -f1 -d" "))
IMAGE = $(REPO)$(IMAGE_NAME):$(IMAGE_TAG)

BUILD=build

$(shell mkdir -p $(BUILD))
MANIFEST_TMP=$(BUILD)/deployment.yml

#.INTERMEDIATE: $(MANIFEST_TMP)
.PHONY: image uninstall clean

all: $(BUILD)/$(IMAGE_TAG) install

image:
	docker build -f Dockerfile.webdav -t $(IMAGE) .

$(BUILD)/$(IMAGE_TAG): image
	touch $(BUILD)/$(IMAGE_TAG)

install: $(MANIFEST_TMP)
	cat $(MANIFEST_TMP)
	kubectl apply -f $(MANIFEST_TMP)

$(MANIFEST_TMP): manifest.rb kubernetes/deployment.yml $(BUILD)/$(IMAGE_TAG)
	ruby manifest.rb "$(REPO)" $(IMAGE_NAME) $(IMAGE_TAG) > $(MANIFEST_TMP)

uninstall:
	kubectl delete -f $(MANIFEST_TMP)

clean: uninstall
	rm -Rf $(BUILD)
