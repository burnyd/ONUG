import pynetbox
import netaddr

ip = netaddr.ip.IPNetwork('192.168.0.0/20')
subnets = list(ip.subnet(24))

nb = pynetbox.api(
    'http://localhost:32768',
    token='0123456789abcdef0123456789abcdef01234567'
)

testdict = {u'vrf': None, u'family': 4}

def create_networks():
    for i in subnets:
       print 'Add the %s networks to Netbox' % (i)
       testdict.update({'prefix': str(i) })       
       nb.ipam.prefixes.create(testdict)
       #[{u'prefix': u'10.1.1.44/30', u'vrf': None, u'family': 4}] This is an example of an API call to add the 10.1.1.44/30 network

create_networks()
