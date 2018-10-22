import netaddr

Loopback1 = "10.1.1.255"
Loopback2 = "10.1.1.555"

netaddr.IPNetwork(Loopback1)

svi = "10.1.2.0"

netaddr.IPNetwork(svi)
