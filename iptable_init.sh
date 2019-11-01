#!/bin/sh

iptables -t nat -N ENVOY_INBOUND
iptables -t nat -N ENVOY_IN_REDIRECT

iptables -t nat -N ENVOY_OUTPUT
iptables -t nat -N ENVOY_REDIRECT

if [ -z "${DISABLE_INBOUNT_IPTABLE}"]; then 
# Jump to the ENVOY_INBOUND chain from PREROUTING chain for all tcp traffic.
iptables -t nat -A PREROUTING -p tcp -j ENVOY_INBOUND

# Use this chain also for redirecting inbound traffic to the common Envoy port
iptables -t nat -A ENVOY_IN_REDIRECT -p tcp -j REDIRECT --to-port ${PROXY_PORT}

# Avoid infinite loops. Don't redirect admin traffic directly back to Envoy
iptables -t nat -A ENVOY_INBOUND -p tcp --dport ${PROXY_MANAGE_PORT} -j RETURN

# Redirect remaining outbound traffic to Envoy
iptables -t nat -A ENVOY_INBOUND -p tcp -j ENVOY_IN_REDIRECT
fi

if [ -z "${DISABLE_OUTBOUNT_IPTABLE}"]; then 
# Create a new chain for redirecting outbound traffic to the Envoy port.
iptables -t nat -A ENVOY_REDIRECT -p tcp -j REDIRECT --to-port ${PROXY_PORT}

# Jump to the ENVOY_OUTPUT chain from OUTPUT chain for all tcp traffic.
iptables -t nat -A OUTPUT -p tcp -j ENVOY_OUTPUT

# Avoid infinite loops. Don't redirect Envoy traffic directly back to
# Envoy for non-loopback traffic.
iptables -t nat -A ENVOY_OUTPUT -p tcp --dport ${PROXY_MANAGE_PORT} -j RETURN
iptables -t nat -A ENVOY_OUTPUT -m owner --uid-owner ${PROXY_UID} -j RETURN
iptables -t nat -A ENVOY_OUTPUT -m owner --gid-owner ${PROXY_UID} -j RETURN

# Redirect remaining outbound traffic to Envoy
iptables -t nat -A ENVOY_OUTPUT -j ENVOY_REDIRECT

# Skip redirection for Envoy-aware applications and
# container-to-container traffic both of which explicitly use
# localhost.
iptables -t nat -A ENVOY_OUTPUT -d 127.0.0.1/32 -j RETURN
fi
iptables -L -t nat 
