ARG VERSION=1.12.0
FROM envoyproxy/envoy:v$VERSION
RUN apt-get update
RUN apt-get install apt-utils -y
RUN apt-get install iptables -y
RUN apt-get install python -y
RUN apt-get install curl -y
RUN apt-get install sudo -y
RUN apt-get install net-tools -y
RUN groupadd envoy-proxy -g 1337
RUN useradd envoy-proxy -u 1337 -g 1337
COPY dynamic-envoy.yaml /etc/envoy/envoy.yaml
COPY run.py .
COPY iptable_init.sh .
COPY iptable_clean.sh .
CMD ["python", "run.py", "/etc/envoy/envoy.yaml"]

