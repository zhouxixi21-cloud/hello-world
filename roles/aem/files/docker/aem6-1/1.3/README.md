AEM Docker Image
======

One image that can be used for both Author and Publish nodes


Target disk structure for a clean Container
------
- /
- /aem
- /aem/cq-quickstart-6.jar
- /aem/start.sh
- /aem/install/*

Target disk structure for a Container after first run using the "start.sh"
------
- /
- /aem
- /aem/cq-quickstart-6.jar
- /aem/start.sh
- /aem/install/*
- /aem/crx-quickstart/*


Start Up Override
------

Target command line for AEM startup is:

```
 java $CQ_JVM_OPTS -jar $CQ_JARFILE $CQ_START_OPT
```

you can provide following variable for complete override of all script defaults and variables
* CQ_JVM_OPTS_OVD
* CQ_START_OPTS_OVD
