from __future__ import absolute_import, print_function, unicode_literals
from cvprac.cvp_client import CvpClient
import salt
import urllib3


urllib3.disable_warnings()

def config():
    config = __salt__['config.get']('cvp')
    if not config:
        raise CommandExecutionError(
            'cvp execution module configuration could not be found'
        )
    return config

def config_dict():
    cvp_dict = {}
    cvp_dict['server'] = config().get('server')
    cvp_dict['username'] = config().get('username')
    cvp_dict['password'] = config().get('password')
    return cvp_dict

def connect_cvp():
    urllib3.disable_warnings()
    client = CvpClient()
    client.connect([config_dict()['server']], config_dict()['username'], config_dict()['password'])
    return client

def load_config(config_name, configlet):
    client = connect_cvp()
    add = client.api.add_configlet(config_name, configlet)
