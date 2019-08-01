IMAGE_NAME=traffic-envoy-proxy
VERSION=1.11.0
DOCKER_REGISTRY=docker.io/luguoxiang

.PHONY: build.images push.images

all: build.images push.images

build.images: 
	docker build  -t ${DOCKER_REGISTRY}/$(IMAGE_NAME):$(VERSION) .  
	docker push ${DOCKER_REGISTRY}/$(IMAGE_NAME):$(VERSION)
