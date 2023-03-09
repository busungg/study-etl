FROM ubuntu:latest
LABEL maintainer="busungg" desc="open ssh image"
ARG passwd=root
RUN apt-get update && \
    apt-get install -y openssh-server \
    maven \
    nano \
    vi

# config open ssh
RUN echo root:${passwd} | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    mkdir /var/run/sshd

# install ambari
RUN wget https://archive.apache.org/dist/ambari/ambari-2.7.6/apache-ambari-2.7.6-src.tar.gz && \
    tar xfvz apache-ambari-2.7.7-src.tar.gz && \
    cd apache-ambari-2.7.7-src && \
    mvn versions:set -DnewVersion=2.7.7.0.0 && \
    pushd ambari-metrics && \
    mvn versions:set -DnewVersion=2.7.7.0.0 && \
    popd && \
    mvn -B clean install jdeb:jdeb -DnewVersion=2.7.7.0.0 -DbuildNumber=388e072381e71c7755673b7743531c03a4d61be8 -DskipTests -Dpython.ver='python >= 2.6' && \
    apt-get install ./ambari-server*.deb && \
    ambari-server setup

    #echo 'export PATH=$PATH:' >> ~/.profile && \
    #echo 'export PATH=$PATH:' >> ~/.profile && \
    #echo 'export PATH=$PATH:' >> ~/.profile && \
    #echo 'export PATH=$PATH:' >> ~/.profile

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 22
ENTRYPOINT ["/bin/bash", "/entrypoint.sh" ]