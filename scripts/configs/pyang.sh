export PYBINDPLUGIN=`/usr/bin/env python -c \
	'import pyangbind; import os; print "%s/plugin" % os.path.dirname(pyangbind.__file__)'`

sleep 5

sudo pyang --plugindir $PYBINDPLUGIN --format pybind -p /tmp/public/release/models -o /tmp/public/release/models/bgp/binding.py /tmp/public/release/models/bgp/openconfig-bgp.yang
