FROM ubuntu:latest
LABEL maintainer="busungg" desc="open ssh image"
ARG passwd=root
RUN apt-get update && \
    apt-get install -y openssh-server
RUN echo root:${passwd} | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    mkdir /var/run/sshd
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 22
ENTRYPOINT ["/bin/bash", "/entrypoint.sh" ]