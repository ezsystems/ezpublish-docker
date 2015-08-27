FROM million12/varnish

RUN yum --assumeyes install \
    supervisor

ADD run.sh /run.sh
ADD supervisord-base.conf-part /supervisord-base.conf-part
ADD varnish4.vcl /varnish_config_fallback/varnish4.vcl

# The current stuff is yet not implemented:
# - Setting varnis cache size and other varnish parameters not yet supported ( ref comment in dockerfiles/internal/varnish/supervisord-base.conf-part )

CMD /run.sh
