IMAGE_NAME=traffic-envoy-proxy
VERSION=0.1
DOCKER_REGISTRY=docker.io/luguoxiang

.PHONY: build.images push.images

all: build.images push.images

build.images: 
	if [ ! -z "$${http_proxy}" ] ; then \
		DOCKER_BUILD_ARGS="$${DOCKER_BUILD_ARGS} --build-arg http_proxy=http://$${http_proxy##*://}" ; \
	fi ; \
	if [ ! -z "$${https_proxy}" ] ; then \
		DOCKER_BUILD_ARGS="$${DOCKER_BUILD_ARGS} --build-arg https_proxy=http://$${https_proxy##*://}" ; \
	fi ; \
	if [ ! -z "$${NO_PROXY}" ] ; then \
		DOCKER_BUILD_ARGS="$${DOCKER_BUILD_ARGS} --build-arg NO_PROXY=$${NO_PROXY}" ; \
	fi ; \
	if [ "$${NOCACHE}" = "true" ] ; then \
		DOCKER_BUILD_ARGS="$${DOCKER_BUILD_ARGS} --no-cache" ; \
	fi ; \
        docker build  -t ${DOCKER_REGISTRY}/$(IMAGE_NAME):$(VERSION) .  

push.images:
	docker push ${DOCKER_REGISTRY}/$(IMAGE_NAME):$(VERSION)
