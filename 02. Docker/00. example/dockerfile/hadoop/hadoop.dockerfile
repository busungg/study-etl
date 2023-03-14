FROM centos:centos7
RUN yum update -y
RUN yum install -y java-1.8.0-openjdk-devel.x86_64 \
    wget \
    tar \
    ssh \
    pdsh \
    nano

WORKDIR /usr/local
RUN wget -O hadoop.tar.gz https://dlcdn.apache.org/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz
RUN tar xvf hadoop.tar.gz && \
    rm -f hadoop.tar.gz
RUN mv hadoop-3.3.3 hadoop
WORKDIR /usr/local/hadoop
RUN echo 'JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64' >> ./etc/hadoop/hadoop-env

ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.362.b08-1.el7_9.x86_64 \
    HADOOP_HOME=/usr/local/hadoop \
    PATH=$PATH:$HADOOP_HOME/bin:$JAVA_HOME/bin

# systemctl 용
RUN mv /usr/bin/systemctl /usr/bin/systemctl.old
RUN curl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py > /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl

#ftp server 구축
RUN yum install -y vsftpd
WORKDIR /etc/vsftpd/
RUN echo 'anonymous_enable=YES' >> vsftpd.conf
#RUN systemctl start vsftpd
#RUN yum install -y firewalld
#RUN systemctl enable firewalld
#RUN systemctl start firewalld
#RUN firewall-cmd --permanent --add-port=20/tcp
#RUN firewall-cmd --permanent --add-port=21/tcp
#RUN firewall-cmd --reload

# 20 FTP 파일 전송 프로토콜 - 데이터 포트 - 30000
# 21 FTP 제어 포트 (연결 시 인증과 컨트롤을 위한 포트) - 30001
# docker create -it -p 20:30000 -p 21:30001 --name hadoop hadoop