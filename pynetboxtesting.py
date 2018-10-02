import pynetbox

import pynetbox
nb = pynetbox.api(
    'http://localhost:32768',
    token='0123456789abcdef0123456789abcdef01234567'
)

def create_networks():
    for i in networks
    nb.ipam.prefixes.create([{u'prefix': u'10.1.1.44/30', u'vrf': None, u'family': 4}])



#prefix.available_prefixes.list()
#prefix = nb.ipam.prefixes.all()


#curl -H "Accept: application/json; indent=4" http://localhost:8000/api/ipam/ip-addresses/350/ | jq '.
#curl -H "Accept: application/json; indent=4" http://localhost/api/dcim/devices/29/


#import pynetbox
#print(nb.virtualization.virtual_machines.all())
#prefix = nb.ipam.prefixes.create([{u'prefix': u'10.1.1.44/30', u'vrf': None, u'family': 4}])
