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
            state=dict(required=False, type='str', default='started', choices=['started', 'stopped', 'absent']),
            keep_volumes=dict(required=False, type='bool', default=True),
            stop_timeout=dict(required=False, type='int', default=10)
        ),
        supports_check_mode=True
    )

    module_args = module.params

    client_base_url = module_args['docker_url']
    client_version = module_args['docker_api_version']

    state = module_args['state']

    stop_timeout = module_args['stop_timeout']
    keep_volumes = module_args['keep_volumes']

    client = docker.DockerClient(base_url=client_base_url, version=client_version)

    module_output = {
        'invocation': module_args,
        'containers': []
    }

    try:
        containers = client.containers.list(all=True)

    except docker.errors.APIError:
        module_output['result'] = False

    for container in sorted(containers):
        task_output = dict()

        task_output['name'] = container.name
        task_output['id'] = container.id

        try:
            if state == 'stopped' and container.status == 'running':
                if not module.check_mode:
                    container.stop(timeout=stop_timeout)

                task_output['result'] = True
                task_output['state'] = 'stopped'

                module_output['containers'].append(task_output)

            elif state == 'started' and container.status == 'exited':
                if not module.check_mode:
                    container.start()

                task_output['result'] = True
                task_output['state'] = 'started'

                module_output['containers'].append(task_output)

            elif state == 'absent' and container.status == 'exited':

                if not module.check_mode:
                    # Convoy issue where named containers are not deleted on docker rm -v commands.
                    # Therefore, passing in the v parameter does not guarantee that the volume will be removed.
                    container.remove(v=not keep_volumes)

                task_output['result'] = True
                task_output['state'] = 'absent'

                module_output['containers'].append(task_output)

        except docker.errors.APIError:
            task_output['result'] = False
            task_output['state'] = container.status

    module_output['result'] = True

    print(json.dumps(module_output))


if __name__ == '__main__':
    main()
