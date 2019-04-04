import subprocess
import os
import sys
import signal
import time

def set_uid():
  uid=get_env("PROXY_UID")
  try:    
    os.setuid(int(uid))
  except BaseException as e:
    sys.stderr.write("Failed to setuid: %s\n" % str(e))
    sys.stdout.flush()
    sys.exit(1)

def sigterm_handler(signo, stack_frame):
  sys.stdout.write("shuting down proxy...\n")
  sys.stdout.write(subprocess.check_output(["sh", "iptable_clean.sh"]))
  sys.stdout.flush()
  sys.exit(0)

def get_env(key):
  value = os.getenv(key)
  if not value:
    sys.stderr.write("missing env %s" % key)
    sys.stdout.flush()
    sys.exit(1)
  return value
    
if len(sys.argv) < 2:
  sys.stderr.write("python run.py [envoy config path]\n")
  sys.stdout.flush()
  sys.exit(1)

config_path = sys.argv[1]

for key in ('PROXY_UID', 'PROXY_PORT', 'PROXY_MANAGE_PORT', 'CONTROL_PLANE_PORT', 'INBOUND_PORTS_INCLUDE'):
  sys.stdout.write ("%s=%s\n" % (key, os.getenv(key)))

uid = os.getenv("PROXY_UID")
proxy_manage_port = get_env("PROXY_MANAGE_PORT")
control_plane_port = get_env("CONTROL_PLANE_PORT")
control_plane_service = get_env("CONTROL_PLANE_SERVICE")
zipkin_service = get_env("ZIPKIN_SERVICE")
zipkin_port = get_env("ZIPKIN_PORT")
cluster_name = get_env("SERVICE_CLUSTER")
node_id = get_env("NODE_ID")

with open(config_path, 'r') as config_file:
  config_data = config_file.read()
  config_data = config_data.replace("$MANAGE_PORT", proxy_manage_port)
  config_data = config_data.replace("$CONTROL_PLANE_PORT", control_plane_port)
  config_data = config_data.replace("$CONTROL_PLANE_SERVICE", control_plane_service)
  config_data = config_data.replace("$ZIPKIN_SERVICE", zipkin_service)
  config_data = config_data.replace("$ZIPKIN_PORT", zipkin_port)
  config_data = config_data.replace("$MY_NODE_ID", node_id)
  config_data = config_data.replace("$MY_CLUSTER", cluster_name)
  sys.stdout.write (config_data)

with open(config_path, 'w') as config_file:
  config_file.write(config_data)

cmd = [ "/usr/local/bin/envoy", "-c", config_path ]

if uid :
	#check PROXY_PORT exists
	get_env("PROXY_PORT")
	signal.signal(signal.SIGTERM, sigterm_handler)
	sys.stdout.write (subprocess.check_output(["sh", "iptable_init.sh"]))
	proxy_env={'PROXY_UID': uid}
	p = subprocess.Popen( cmd , preexec_fn=set_uid, env=proxy_env, stdout=subprocess.PIPE, stdin=subprocess.PIPE)
else:
	p = subprocess.Popen( cmd , stdout=subprocess.PIPE, stdin=subprocess.PIPE)

sys.stdout.write ("running %s\n" % cmd)
sys.stdout.flush()

while True:
  line = p.stdout.readline()
  if line: 
    sys.stdout.write(line + "\n")
    sys.stdout.flush()
  time.sleep(1)
