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
            state=dict(required=False, type='str', default='absent', choices=['absent']),
            dangling=dict(required=False, type='bool', default=False)
        ),
        supports_check_mode=True
    )

    module_args = module.params

    client_base_url = module_args['docker_url']
    client_version = module_args['docker_api_version']

    state = module_args['state']
    dangling = module_args['dangling']

    client = docker.DockerClient(base_url=client_base_url, version=client_version)

    module_output = {
        'invocation': module_args,
        'images': []
    }

    images = []

    try:
        if dangling:
            images_filter = dict(dangling=dangling)
            images = client.images.list(filters=images_filter)
        else:
            images = client.images.list()

    except docker.errors.APIError:
        module_output['result'] = False

    for image in images:
        task_output = dict()
        task_output['id'] = image.id

        module_output['images'].append(task_output)

        try:
            if state == 'absent' and not module.check_mode:
                client.images.remove(image.id)

        except docker.errors.APIError:
            pass

    module_output['result'] = True

    print(json.dumps(module_output))


if __name__ == '__main__':
    main()
