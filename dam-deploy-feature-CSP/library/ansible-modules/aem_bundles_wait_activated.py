#!/usr/bin/python

import time
import urllib2
import json
import base64

def main():
    module = AnsibleModule(
        argument_spec=dict(
            host=dict(required=False, type='str', default='localhost'),
            port=dict(required=False, type='int', default=4502),
            aem_username=dict(required=True),
            aem_password=dict(required=True),
            interval_wait=dict(required=False, type='int', default=10)
        )
    )

    host = module.params['host']
    port = module.params['port']

    aem_username = module.params['aem_username']
    aem_password = module.params['aem_password']

    interval_wait = module.params['interval_wait']

    attempts = 0
    max_attempts = 100

    while attempts < max_attempts:
        attempts += 1

        # All AEM Ansible modules are currently using http://
        request = urllib2.Request("http://"+host+":"+str(port)+"/system/console/bundles.json")

        encodedBasicAuth = base64.b64encode('%s:%s' % (aem_username, aem_password))
        request.add_header("Authorization", "Basic %s" % encodedBasicAuth)

        try:

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

                    print(json.dumps({'msg': 'Verified all bundles activated. '}))

                    return
        except urllib2.URLError:
            pass

        time.sleep(interval_wait)


    print(json.dumps({'failed': True, 'msg': 'Stopped verifying before all bundles were activated. '}))

from ansible.module_utils.basic import *

main()
