#!/usr/bin/python

import pyaem


def main():
    module = AnsibleModule(
        argument_spec=dict(
            host=dict(required=True),
            port=dict(required=True),
            stack=dict(required=True),
            agent_id=dict(required=True),
            agent_name=dict(required=True),
            agent_type=dict(required=True),
            dest_group=dict(required=True),
            dest_username=dict(required=True),
            dest_password=dict(required=True),
            run_mode=dict(required=True)
        )
    )

    host = module.params['host']
    port = module.params['port']
    stack = module.params['stack']
    agent_id = module.params['agent_id']
    agent_name = module.params['agent_name']
    agent_type = module.params['agent_type']
    dest_username = module.params['dest_username']
    dest_password = module.params['dest_password']
    dest_group = module.params['dest_group']
    run_mode = module.params['run_mode']

    # determine ports based on group
    if dest_group == 'author':
        dest_port = 4502
    elif dest_group == 'publisher':
        dest_port = 4503
    else:
        dest_port = 8080

    agent_title = '{0} agent to {1} {2}'.format(agent_type, dest_group, agent_id)
    if stack == 'local':
        dest_url = 'http://localhost:{0}'.format(dest_port)
    elif stack == 'docker':
        if dest_port == 4502:
            dest_url = 'http://192.168.78.1:{0}'.format(dest_port)
        elif dest_port == 4503:
            dest_url = 'http://192.168.78.2:{0}'.format(dest_port)
        elif dest_port == 8080:
            dest_url = 'http://192.168.78.3:{0}'.format(dest_port)
    else:
        dest_domain = re.search(r'.aws-sensis.com.au', host).group()
        dest_url = 'http://sitesmart-{0}-{1}-{2}.in.{3}:{4}'.format(stack, dest_group, agent_id, dest_domain, dest_port)

    aem_username = os.getenv('crx_username')
    aem_password = os.getenv('crx_password')

    aem = pyaem.PyAem(aem_username, aem_password, host, port)

    params = {
        'jcr:content/jcr:title': agent_title,
        'jcr:content/jcr:description': agent_title,
        'jcr:content/logLevel': 'info',
        'jcr:content/retryDelay': '60000'
    }
    result = aem.create_agent(agent_name, agent_type, dest_username, dest_password, dest_url, run_mode, **params)

    if result.is_failure():
        print json.dumps({'failed': True, 'msg': result.message})
    else:
        print json.dumps({'msg': result.message})


from ansible.module_utils.basic import *

main()
