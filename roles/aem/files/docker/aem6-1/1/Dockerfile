FROM aem-base:1

LABEL   maintainer="max.barrass@gmail.com" \
        app.version="aem 6.1" \
        os.version="centos 7" \
        java.version="oracle 8" \
        container.description="aem instance, will run as author unless specified otherwise"

ARG AEM_QUICKSTART_URL
ARG AEM_PORT=4502

WORKDIR /aem

COPY "start.sh" "license.properties" ./

COPY dist/install.first/*.config ./install/

ADD $AEM_QUICKSTART_URL ./cq-quickstart-6.jar

EXPOSE $AEM_PORT

VOLUME ["/aem/crx-quickstart"]

ENTRYPOINT ["/aem/start.sh"]