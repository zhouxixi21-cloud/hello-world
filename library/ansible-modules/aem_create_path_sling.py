#!/usr/bin/python

import pyaem


# this Ansible module is a workaround since we haven't figured out a way to handle existing path
# the endpoint that's used on this module returns 500 on both real error and when the path already exists
# already discussed with Max and Yuval, no clear solution yet
# TODO: fix the above, duh!
def main():
    module = AnsibleModule(
        argument_spec=dict(
            host=dict(required=True),
            port=dict(required=True),
            path_name=dict(required=True),
            path_base=dict(required=True),
            path_type=dict(required=True)
        )
    )

    host = module.params['host']
    port = module.params['port']
    path_name = module.params['path_name']
    path_base = module.params['path_base']
    path_type = module.params['path_type']

    aem_username = os.getenv('crx_username')
    aem_password = os.getenv('crx_password')

    aem = pyaem.PyAem(aem_username, aem_password, host, port)
    params = {':name': path_name, 'jcr:primaryType': path_type, 'jcr:mixinTypes': 'rep:AccessControllable'}

    try:
        result = aem.create_path(path_base, **params)

        if result.is_failure():
            print json.dumps({'failed': True, 'msg': result.message})
        else:
            print json.dumps({'msg': result.message})
    except pyaem.PyAemException, e:
        print json.dumps({
                             'msg': 'Allow error due to inability to differentiate existing path from real error when response code is 500' +
                                    e.response['body']})


from ansible.module_utils.basic import *

main()
