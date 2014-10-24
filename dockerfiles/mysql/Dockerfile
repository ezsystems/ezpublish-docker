FROM tutum/mysql:latest

RUN apt-get update -y
RUN apt-get install -y --force-yes \
    curl \
    python

ADD etcd_functions /etcd_functions
ADD register_ip_and_run.sh /register_ip_and_run.sh

CMD /register_ip_and_run.sh
