FROM devops/oracle-jdk:8u73-b02

MAINTAINER Terence Leung <terence.leung@rxpservices.com>

LABEL   container.version="1.0" \
        os.version="centos 7" \
        java.version="oracle 8" \
        container.description=""

WORKDIR /toughday

ADD https://docs.adobe.com/content/docs/en/aem/6-2/develop/test/tough-day/_jcr_content/contentbody/download/file.res/toughday-6.1.jar ./toughday-6.1.jar

ENTRYPOINT ["java","-Xmx1024m","-jar","toughday-6.1.jar"]

CMD ["-Dhostname=192.168.28.2","-Dport=4502","-DuploadImage.count=10","uploadImage"]