#!/bin/bash

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

tmpscript=`mktemp -p /tmp`
cat <<EOT > $tmpscript
#!/bin/bash

cd /vagrant
ls -all
EOT
echo vagrant "$@" >> $tmpscript
chmod a+x $tmpscript

username=`whoami`
uid=`id -u`
gid=`id -g`
gname=`id -g --name`

#docker run -i -t --rm --volume $SCRIPTDIR:/vagrant --volume $tmpscript:/tmp/vagrant_execute.sh --volume $HOME/.ssh:/home/$username/.ssh ezpublishdocker_vagrantaws:latest bash -c "groupadd $gname --gid $gid; useradd $username --uid $uid --gid $gid; chown $username:$gname /home/$username;  mv /root/.vagrant.d /home/$username/; chown -R $username:$gname /home/$username/.vagrant.d; cd /vagrant; sudo -i -u $username bash"
docker run -i -t --rm --volume $SCRIPTDIR:/vagrant --volume $tmpscript:/tmp/vagrant_execute.sh --volume $HOME/.ssh:/home/$username/.ssh ezpublishdocker_vagrantaws:latest bash -c "groupadd $gname --gid $gid; useradd $username --uid $uid --gid $gid; chown $username:$gname /home/$username; mv /root/.vagrant.d /home/$username/; chown -R $username:$gname /home/$username/.vagrant.d; cd /vagrant; sudo -i -u $username /tmp/vagrant_execute.sh"

m $tmpscript
