# MIT license

FROM ubuntu:22.04

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8 
ENV LC_ALL=en_US.UTF-8 

# install packages
RUN apt update && apt upgrade -y
RUN DEBIAN_FRONTEND="noninteractive" apt install -y \
      sudo \
      gawk \
      cmake \
      g++ \
      git \
      vim \
      tar \
      ssh \
      locales \
      libpcre2-dev \
      libssl-dev \
      zlib1g-dev

# update locale
RUN sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen
RUN locale-gen
RUN update-locale LANG=$LANG LANGUAGE=$LANGUAGE LC_ALL=$LC_ALL

# generate RSA1 RSA DSA ECDSA keys
RUN ssh-keygen -A

# permit root ssh login
RUN sed -i "s+#PermitRootLogin prohibit-password+PermitRootLogin prohibit-password+g" /etc/ssh/sshd_config
#COPY --chown=root:root id_rsa.pub /root/.ssh/authorized_keys

WORKDIR /root

# install libyang
RUN git clone --branch devel https://github.com/CESNET/libyang.git
RUN mkdir -p /root/libyang/build
RUN cd /root/libyang/build  ; cmake ..
RUN cd /root/libyang/build/ ; make
RUN cd /root/libyang/build/ ; make install

# install sysrepo
RUN git clone --branch devel https://github.com/sysrepo/sysrepo.git
RUN mkdir -p /root/sysrepo/build
RUN cd /root/sysrepo/build/ ; cmake ..
RUN cd /root/sysrepo/build/ ; make
RUN cd /root/sysrepo/build/ ; make install

# install libssh (required bu libnetconf2)
RUN git clone http://git.libssh.org/projects/libssh.git
RUN mkdir -p /root/libssh/build
RUN cd /root/libssh/build ; cmake -DCMAKE_INSTALL_PREFIX=/usr ..
RUN cd /root/libssh/build ; make
RUN cd /root/libssh/build ; make install

# install libnetconf2
RUN git clone --branch devel https://github.com/CESNET/libnetconf2.git
RUN mkdir -p /root/libnetconf2/build
RUN cd /root/libnetconf2/build ; cmake ..
RUN cd /root/libnetconf2/build ; make
RUN cd /root/libnetconf2/build ; make install

# install netopeer2
RUN git clone --branch devel https://github.com/CESNET/netopeer2.git
RUN mkdir -p /root/netopeer2/build
RUN cd /root/netopeer2/build ; cmake ..
RUN cd /root/netopeer2/build ; make
RUN cd /root/netopeer2/build ; ldconfig
RUN cd /root/netopeer2/build ; make install

ENTRYPOINT service ssh start > /dev/null 2>&1; \
           echo "NETCONF Stack Compiled"; \
           /bin/bash