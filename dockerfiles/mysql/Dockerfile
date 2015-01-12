FROM tutum/mysql:latest

RUN apt-get update -y && apt-get install -y --force-yes \
    python

ADD etcd_0.4.6_amd64.deb /etcd_0.4.6_amd64.deb
RUN dpkg -i /etcd_0.4.6_amd64.deb

ADD etcd_functions /etcd_functions
ADD register_ip_and_run.sh /register_ip_and_run.sh

CMD /register_ip_and_run.sh
