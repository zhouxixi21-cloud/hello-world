FROM        aem-solr-cloud:6.3.0

MAINTAINER  Yaw Ly

ARG ZOOKEEPER_HOST=0.0.0.0:9983

CMD ["-f","-q","-cloud", "-m", "2g", "-s", "/opt/solr/server/aemsolr", "-z", "10.72.36.65:9984"]
