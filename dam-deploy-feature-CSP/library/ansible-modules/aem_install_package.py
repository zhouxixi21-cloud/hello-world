#!/usr/bin/python

import pyaem
import time
import urllib2
import json
import base64

def main():
    module = AnsibleModule(
        argument_spec=dict(
            host=dict(required=False, type='str', default='localhost'),
            port=dict(required=False, type='int', default=4502),
            group_name=dict(required=True),
            package_name=dict(required=True),
            package_version=dict(required=True),
            aem_username=dict(required=True),
            aem_password=dict(required=True),
            interval=dict(required=False, type='int', default=10),
            requires_restart=dict(required=False, type='bool', default=False)
        )
    )

    host = module.params['host']
    port = module.params['port']
    group_name = module.params['group_name']
    package_name = module.params['package_name']
    package_version = module.params['package_version']

    aem_username = module.params['aem_username']
    aem_password = module.params['aem_password']

    aem = pyaem.PyAem(aem_username, aem_password, host, port)
    result = aem.install_package_sync(group_name, package_name, package_version)

    requires_restart = module.params['requires_restart']
    interval = module.params['interval']

    if requires_restart and not result.is_failure():
        attempts = 0
        max_attempts = 10

        while attempts < max_attempts:
            attempts += 1

            # All AEM Ansible modules are currently using http://
            try:
                request = urllib2.Request("http://"+host+":"+str(port)+"/system/console/bundles.json")
                encodedBasicAuth = base64.b64encode('%s:%s' % (aem_username, aem_password))
                request.add_header("Authorization", "Basic %s" % encodedBasicAuth)

                response = urllib2.urlopen(request)

                if response.code == 401:
                    print(json.dumps({'failed': True, 'msg': response.message}))

                    return

                elif response.code == 200:
                    bundles = json.load(response)

                    bundle_status = bundles['s']

                    existing = bundle_status[0]
                    active = bundle_status[1]
                    fragment = bundle_status[2]

                    if existing == active + fragment:

                        print(json.dumps({'msg': 'Package installed and all bundles active. '}))

                        return
            except (urllib2.URLError, urllib2.HTTPError):
                pass

            time.sleep(interval)

    if result.is_failure():
        print(json.dumps({'failed': True, 'msg': result.message}))
    else:
        print(json.dumps({'msg': result.message}))


from ansible.module_utils.basic import *

main()
