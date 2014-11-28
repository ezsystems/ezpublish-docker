FROM million12/varnish

RUN yum --assumeyes install \
    supervisor

ADD run.sh /run.sh
ADD etcd_functions /etcd_functions
ADD supervisord-base.conf-part /supervisord-base.conf-part
ADD supervisord-etcd.conf-part /supervisord-etcd.conf-part
ADD varnish4.vcl /varnish_config_fallback/varnish4.vcl

# The current stuff is yet not implemented:
# - etcd support
# - Configuration of http cache in ezpublish.yml according to https://doc.ez.no/display/EZP/Using+Varnish ( requires to be done after setup wizard )
# - Setting varnis cache size and other varnish parameters not yet supported ( ref comment in dockerfiles/varnish/supervisord-base.conf-part )

CMD /run.sh
