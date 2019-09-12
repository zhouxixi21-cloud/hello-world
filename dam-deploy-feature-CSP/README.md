WKCD Deploy
=======

Repository for deploying components to target Services using Ansible

Getting Started
========

1. clone repo
2. run dependencies install

```
mvn clean install -Pdependencies
```

Directory Layout
=======
```
production                # inventory file for production servers
staging                   # inventory file for staging environment

group_vars/
   group1                 # here we assign variables to particular groups
   group2                 # ""
host_vars/
   hostname1              # if systems need specific variables, put them here
   hostname2              # ""

library/                  # if any custom modules, put them here (optional)
filter_plugins/           # if any custom filter plugins, put them here (optional)

site.yml                  # master playbook
webservers.yml            # playbook for webserver tier
dbservers.yml             # playbook for dbserver tier

roles/
    common/               # this hierarchy represents a "role"
        tasks/            #
            main.yml      #  <-- tasks file can include smaller files if warranted
        handlers/         #
            main.yml      #  <-- handlers file
        templates/        #  <-- files for use with the template resource
            ntp.conf.j2   #  <------- templates end in .j2
        files/            #
            bar.txt       #  <-- files for use with the copy resource
            foo.sh        #  <-- script files for use with the script resource
        vars/             #
            main.yml      #  <-- variables associated with this role
        defaults/         #
            main.yml      #  <-- default lower priority variables for this role
        meta/             #
            main.yml      #  <-- role dependencies

    webtier/              # same kind of structure as "common" was above, done for the webtier role
    monitoring/           # ""
    fooapp/               # ""
```

Filename Convention
==================
```
"service-" =  this playbook is used for deploying services
"security-" =  the security playbooks
"operation-" = this playbook is used for services operation
site.xml = this is the main site playbook
localdev = the localdev playbook for setting dev environment
```

Ansible Roles
=======

Using localdev

Docker is configured to use the devops hosted repository. In cases where you do not have access to the network, you can override this setting by passing the following,

```
--extra-vars='docker_repository=0.0.0.0:5000'
```

Dependent images must be built locally as a result. You can pre-build images locally using the site build with the following,

```
--tags='docker-images-build'
```

Host Registry on a host

```
ansible-playbook -i inventory/localdev docker-host-registry.yml
```

Build all of the images

```
ansible-playbook -i inventory/localdev service-buildhost.yml
```


Host devops images on a host

```
ansible-playbook -i inventory/localdev site-wkcd-devops.yml
```

Update a Host (already done though devops buildlocaldev)

```
ansible-playbook -i inventory/localdev localdev.yml
```


Debug
=======

add base images to local registry

```
docker tag docker.io/java:8-jdk privateregistry:5000/docker.io/java:8-jdk && docker push privateregistry:5000/docker.io/java
docker tag docker.io/debian:jessie privateregistry:5000/docker.io/debian:jessie && docker push privateregistry:5000/docker.io/debian
docker tag docker.io/ubuntu:14.04 privateregistry:5000/docker.io/ubuntu:14.04 && docker push privateregistry:5000/docker.io/ubuntu
docker tag docker.io/centos:centos7 privateregistry:5000/docker.io/centos:centos7 && docker push privateregistry:5000/docker.io/centos
docker tag docker.io/alpine:latest privateregistry:5000/docker.io/alpine:latest && docker push privateregistry:5000/docker.io/alpine
```

remove all of the build images

```
docker rmi privateregistry:5000/devops/jenkins devops/jenkins devops/jenkins-base privateregistry:5000/devops/jenkins-base privateregistry:5000/devops/jenkins-data devops/jenkins-data devops/gitlab privateregistry:5000/devops/gitlab privateregistry:5000/devops/gitlab-data devops/gitlab-data aem privateregistry:5000/aem privateregistry:5000/aem-data aem-data aem-dispatcher privateregistry:5000/aem-dispatcher aem-dispatcher-data privateregistry:5000/aem-dispatcher-data privateregistry:5000/aem-base aem-base aem-apache privateregistry:5000/aem-apache
```