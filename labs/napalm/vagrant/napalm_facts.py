import json

from napalm import get_network_driver
driver = get_network_driver('eos')
dev = driver(hostname='leaf1a', username='vagrant',
             password='vagrant')

dev.open()
facts = dev.get_facts()
dev.close()
print(json.dumps(facts, sort_keys=True, indent=4))


