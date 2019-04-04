FROM envoyproxy/envoy:36f39c746eb7d03b762099b206403935b11972d8 
RUN apt-get update
RUN apt-get install apt-utils -y
RUN apt-get install iptables -y
RUN apt-get install python -y
RUN apt-get install curl -y
RUN apt-get install sudo -y
RUN apt-get install net-tools -y
RUN touch /var/log/access.log
RUN groupadd envoy-proxy -g 1337
RUN useradd envoy-proxy -u 1337 -g 1337
RUN chown envoy-proxy /var/log/access.log
COPY dynamic-envoy.yaml /etc/envoy/envoy.yaml
COPY run.py .
COPY iptable_init.sh .
COPY iptable_clean.sh .
CMD ["python", "run.py", "/etc/envoy/envoy.yaml"]

