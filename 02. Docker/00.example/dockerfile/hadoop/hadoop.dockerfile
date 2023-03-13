FROM centos:centos7
RUN yum update -y
RUN yum install -y java-1.8.0-openjdk-devel.x86_64 \
    wget \
    tar \
    ssh \
    pdsh

WORKDIR /usr/local
RUN wget -O hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz
RUN tar xvf hadoop.tar.gz \
    rm -f hadoop.tar.gz
RUN mv hadoop-3.3.3 hadoop
RUN sed -i ''

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64 \
    HADOOP_HOME=/usr/local/hadoop \
    PATH=$PATH:$HADOOP_HOME/bin:$JAVA_HOME/bin