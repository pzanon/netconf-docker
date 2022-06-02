FROM ubuntu:22.04

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8 
ENV LC_ALL=en_US.UTF-8 

# install packages
RUN apt-get update && apt-get upgrade -y
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y \
      sudo \
      gawk \
      wget \
      curl \
      git \
      vim \
      tar \
      ssh \
      ftp \
      locales \
      openjdk-17-jdk

# update locale
RUN sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen
RUN locale-gen
RUN update-locale LANG=$LANG LANGUAGE=$LANGUAGE LC_ALL=$LC_ALL

# generate RSA1 RSA DSA ECDSA keys
RUN ssh-keygen -A

# permit root ssh login
RUN sed -i "s+#PermitRootLogin prohibit-password+PermitRootLogin prohibit-password+g" /etc/ssh/sshd_config
COPY --chown=root:root id_rsa.pub /root/.ssh/authorized_keys

