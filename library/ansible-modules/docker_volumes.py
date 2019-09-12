#!/usr/bin/python

import docker

from ansible.module_utils.basic import *

DOCUMENTATION = '''
---
module: docker_containers
short_description: Stops and starts all containers on the Docker host
#
'''


def main():
    module = AnsibleModule(
        argument_spec=dict(
            docker_url=dict(required=False, type='str', default='unix://var/run/docker.sock'),
            docker_api_version=dict(required=False, type='str', default='1.24'),
            state=dict(required=False, type='str', default='absent', choices=['absent'])
        ),
        supports_check_mode=True
    )

    module_args = module.params

    client_base_url = module_args['docker_url']
    client_version = module_args['docker_api_version']

    state = module_args['state']

    client = docker.DockerClient(base_url=client_base_url, version=client_version)

    module_output = {
        'invocation': module_args,
        'volumes': []
    }

    try:
        volumes = client.volumes.list()

    except docker.errors.APIError:
        module_output['result'] = False

    for volume in volumes:
        task_output = dict()

        task_output['name'] = volume.name
        task_output['id'] = volume.id

        module_output['volumes'].append(task_output)

        try:
            if state == 'absent':
                if not module.check_mode:
                    volume.remove()

                task_output['result'] = True
                task_output['state'] = 'absent'

        except docker.errors.APIError:
            task_output['result'] = False
            task_output['state'] = 'present'

    module_output['result'] = True

    print(json.dumps(module_output))


if __name__ == '__main__':
    main()
