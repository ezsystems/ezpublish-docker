FROM ezpublishdocker_sahibase

RUN apt-get install -y \
    firefox


#wget -nv -O sahi_20130429.zip "http://downloads.sourceforge.net/project/sahi/sahi-v44/sahi_20130429.zip?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fsahi%2Ffiles%2Fsahi-v44%2F&ts=1376728867&use_mirror=garr"
ADD sahi_20130429.zip /tmp/sahi.zip

wget https://github.com/ezsystems/ezpublish-community/blob/master/bin/.travis/sahi/browser_types.xml-dist
#ADD browser_types.xml-dist /tmp/browser_types.xml-dist

RUN adduser sahi

RUN unzip  /tmp/sahi.zip
RUN chmod +x /sahi/bin/sahi.sh /sahi/bin/dashboard.sh
RUN chown sahi:sahi -R /sahi
#RUN cp /tmp/browser_types.xml-dist /sahi/userdata/config/browser_types.xml

ADD run.sh /run.sh

ADD x_session.sh /x_session.sh

USER sahi
CMD ["/run.sh"]

EXPOSE 9999 5900