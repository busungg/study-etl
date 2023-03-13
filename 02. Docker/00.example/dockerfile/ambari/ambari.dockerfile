FROM centos:centos7
LABEL maintainer="busungg" desc="open ssh image"
ARG passwd=root
RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y openssh-server
RUN yum install -y nano
RUN yum install -y java-1.8.0-openjdk-devel.x86_64 \
    #maven \
    bzip2 \
    wget \
    git \
    rpm-build \
    nodejs \
    npm 
RUN npm install -g bower

#root config
RUN echo root:${passwd} | chpasswd

# config open ssh
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

#maven
WORKDIR /opt
RUN wget https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.3.9/apache-maven-3.3.9-bin.tar.gz
RUN tar xzf apache-maven-3.3.9-bin.tar.gz && \
    rm -f apache-maven-3.3.9-bin.tar.gz
RUN mv apache-maven-3.3.9 maven
RUN alternatives --install /usr/bin/mvn mvn /opt/maven/bin/mvn 1
RUN update-alternatives --set mvn /opt/maven/bin/mvn

# config env
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk \
    _JAVA_OPTIONS="-Xmx2048m -XX:MaxPermSize=512m -Djava.awt.headless=true" \
    #MAVEN_HOME=/usr/share/maven \
    MAVEN_HOME=/opt/maven \
    PATH=$PATH:$JAVA_HOME:$MAVEN_HOME/bin

# install ambari
WORKDIR /opt
RUN wget http://archive.apache.org/dist/ambari/ambari-2.7.5/apache-ambari-2.7.5-src.tar.gz && \
    tar xfvz apache-ambari-2.7.5-src.tar.gz && \
    rm -f apache-ambari-2.7.5-src.tar.gz
WORKDIR /opt/apache-ambari-2.7.5-src
RUN mvn versions:set -DnewVersion=2.7.5.0.0
WORKDIR /opt/apache-ambari-2.7.5-src/ambari-metrics
RUN mvn versions:set -DnewVersion=2.7.5.0.0
WORKDIR /opt/apache-ambari-2.7.5-src
#RUN mvn -e -Drat.skip=true -B clean install rpm:rpm -DnewVersion=2.7.5.0.0 -DbuildNumber=5895e4ed6b30a2da8a90fee2403b6cab91d19972 -DskipTests -Dpython.ver="python >= 2.6"

#RUN yum install ambari-server*.rpm
    # Install the rpm package from ambari-server/target/rpm/ambari-server/RPMS/noarch/

#RUN ambari-server setup

# init
COPY init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 22 443 8080 8440
ENTRYPOINT ["/bin/bash", "/init.sh" ]

# ambari metrics pom.xml에서 legacy module 삭제
# https://dydwnsekd.tistory.com/38

# ambari 2.7.6에서 오류발생
# [INFO] Ambari Metrics Collector ........................... FAILURE [04:29 min]
#[ERROR] Failed to execute goal on project ambari-metrics-timelineservice: Could not resolve dependencies for project org.apache.ambari:ambari-metrics-timelineservice:jar:2.7.5.0.0: Could not find artifact org.apache.zookeeper:zookeeper:jar:3.4.5.1.3.0.0-107 in apache-hadoop (https://repo.hortonworks.com/content/groups/public/) -> [Help 1]
#org.apache.maven.lifecycle.LifecycleExecutionException: Failed to execute goal on project ambari-metrics-timelineservice: Could not resolve dependencies for project org.apache.ambari:ambari-metrics-timelineservice:jar:2.7.5.0.0: Could not find artifact org.apache.zookeeper:zookeeper:jar:3.4.5.1.3.0.0-107 in apache-hadoop (https://repo.hortonworks.com/content/groups/public/)
#at org.apache.maven.lifecycle.internal.LifecycleDependencyResolver.getDependencies(LifecycleDependencyResolver.java:221)
#at org.apache.maven.lifecycle.internal.LifecycleDependencyResolver.resolveProjectDependencies(LifecycleDependencyResolver.java:127)


# https://repo.hortonworks.com/content/groups/public/

# https://repository.apache.org/content/repositories/snapshots/org/apache/zookeeper/zookeeper/3.4.5.1.3.0.0-107/zookeeper-3.4.5.1.3.0.0-107.jar
# https://repo.maven.apache.org/maven2/org/apache/zookeeper/zookeeper/3.4.5.1.3.0.0-107/zookeeper-3.4.5.1.3.0.0-107.jar
# org.apache.zookeeper:zookeeperjar:3.4.5.1.3.0.0-107 in apache-hadoop (https://repo.hortonworks.com/content/groups/public/) -> [Help 1]

