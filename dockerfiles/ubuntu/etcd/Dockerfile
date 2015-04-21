FROM ubuntu:trusty


RUN apt-get update -y && apt-get install -y \
    ruby-dev \
    gcc \
    make \
    curl \
    wget

RUN sudo gem install fpm

# Current version of Makefile do not work (21st of April 2015 ). Downloading a fixed version which is known to work instead
#RUN cd /tmp; curl -L https://raw.githubusercontent.com/solarkennedy/etcd-packages/master/Makefile  > Makefile
#RUN cd /tmp; sed -i "s@^VERSION=0.4.3@VERSION=0.4.6@" /tmp/Makefile
RUN cd /tmp; curl -L https://raw.githubusercontent.com/solarkennedy/etcd-packages/ccd02a7617e51f939274f1b870b74491907f95ee/Makefile > Makefile
RUN cd /tmp; make deb

RUN cd /tmp; sudo dpkg -i etcd_0.4.6_amd64.deb

RUN mkdir /var/lib/etcd /etc/etcd

ADD etcd_functions /etcd_functions
ADD etcd.conf /etc/etcd/etcd.conf
ADD run.sh /run.sh

CMD /run.sh
#CMd /bin/bash

EXPOSE 4001 7001
