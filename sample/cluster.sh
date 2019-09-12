#!/bin/bash
# this script sets up AEM cluster
# - once during initial stack creation
# - on daily startup for non-prod environment
set -o nounset
set -o errexit

if [[ $# -lt 1 ]] || [[ $# -gt 2 ]]; then
  echo "Usage: ./cluster.sh <stack>"
  exit 1
fi

stack=$1
version=1.0-SNAPSHOT

## 
if [[ $# -ne 2 ]]; then
     crx_password=${crx_password:-admin}
else
     crx_password=${crx_password:-$2}
fi

if [[ $stack == prod* ]] ; then
       aws_account="paws"
else
       aws_account="naws"
fi

author_node_1="sitesmart-$stack-author-01.in.${aws_account}-sensis.com.au"
author_node_2="sitesmart-$stack-author-02.in.${aws_account}-sensis.com.au"

logical_id_1=`ssh senuser@${author_node_1} facter sen_ec2_tag_aws_cloudformation_logical_id`
logical_id_2=`ssh senuser@${author_node_2} facter sen_ec2_tag_aws_cloudformation_logical_id`

if [[ ${logical_id_1} == "AuthorInstance01" ]]; then
          masternode=${author_node_1}
          slavenode=${author_node_2}
else
          masternode=${author_node_2}
          slavenode=${author_node_1}
fi

extra_var="crx_password=$crx_password stack=$stack cluster_master=${masternode} cluster_slave=${slavenode}"

# verify that the master is ready for use (already finished initialising its repository)
ansible-playbook --extra-var="$extra_var" -i ${masternode}, \
  components/aem-cluster/playbook.yml -vvvvv --tags "verify"

# verify that the slave is ready for use (already finished initialising its repository)
ansible-playbook --extra-var="$extra_var" -i ${slavenode}, \
  components/aem-cluster/playbook.yml -vvvvv --tags "verify"

# stop slave
ansible-playbook --extra-var="$extra_var" -i ${slavenode}, \
  components/aem-cluster/playbook.yml --tags "stop-aem"

# stop master
ansible-playbook --extra-var="$extra_var" -i ${masternode}, \
  components/aem-cluster/playbook.yml --tags "stop-aem"

# create cluster files in master
ansible-playbook --extra-var="$extra_var" -i ${masternode}, \
  components/aem-cluster/playbook.yml --tags "cluster"

# backup logs, rsync master repository to slave, create cluster files in slave, and restore logs
# executed on 3 separate calls to make sure that the tags are executed in sequence regardless of position in the playbook
ansible-playbook --extra-var="$extra_var" -i ${slavenode}, \
  components/aem-cluster/playbook.yml --tags "pre-cluster-slave"
ansible-playbook --extra-var="$extra_var" -i ${slavenode}, \
  components/aem-cluster/playbook.yml --tags "cluster"
ansible-playbook --extra-var="$extra_var" -i ${slavenode}, \
  components/aem-cluster/playbook.yml --tags "post-cluster-slave"

# start master
ansible-playbook --extra-var="$extra_var" -i ${masternode}, \
  components/aem-cluster/playbook.yml --tags "start-aem"

# verify that master is ready for use
ansible-playbook --extra-var="$extra_var" -i ${masternode}, \
  components/aem-cluster/playbook.yml --tags "verify"

# start slave
ansible-playbook --extra-var="$extra_var" -i ${slavenode}, \
  components/aem-cluster/playbook.yml -vvvvv --tags "start-aem"

# verify that slave is ready for use
ansible-playbook --extra-var="$extra_var" -i ${slavenode}, \
  components/aem-cluster/playbook.yml -vvvvv --tags "verify"
