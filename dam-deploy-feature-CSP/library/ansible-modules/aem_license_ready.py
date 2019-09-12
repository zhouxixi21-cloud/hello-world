#!/usr/bin/python

import urllib2


def main():
    module = AnsibleModule(
        argument_spec=dict(
            url=dict(required=True)
        )
    )

    url = module.params['url']

    try:
        f = urllib2.urlopen('{0}/system/granite/license/index.html'.format(url.rstrip('/')))
        if f.getcode() == 200:
            print json.dumps({'msg': 'AEM license page is ready'})
        else:
            print json.dumps({'failed': True,
                              'msg': 'Unexpected status code {0} when checking AEM license page'.format(f.getcode())})
    except Exception, e:
        print json.dumps({'failed': True, 'msg': 'Unexpected exception when checking AEM license page: {0}'.format(e)})


from ansible.module_utils.basic import *

main()
