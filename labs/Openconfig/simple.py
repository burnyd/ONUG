#!/usr/bin/python

from binding import openconfig_bgp
import json
ocbgp = openconfig_bgp()

ocbgp.bgp.global_.config.as_ = 1 #Configures the rw bgp - > global - > config passes in the oc-inet:as-number

ocbgp.bgp.global_.config.router_id = "1.1.1.1" #Passes in the rw bgp - > global - > config - > router-id passes in the oc-yang:dotted-quad

struct =  json.dumps(ocbgp.get(filter=True), indent=4)

print struct

with open('simple.json', 'w') as f:
  f.write(struct)
