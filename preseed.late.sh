#!/bin/sh

source /qvm.config

### SETUP SSH
### #########

QVM_SSH_PUB="/target/root/.ssh/$QVM_SSH".pub

echo making ssh dir
mkdir -p /target/root/.ssh

echo copying ssh public key
cp "$QVM_SSH".pub "$QVM_SSH_PUB"

echo authorizing ssh public key
cat "$QVM_SSH_PUB">>/target/root/.ssh/authorized_keys

echo allowing root only acces to key
chmod 600 -R /target/root/.ssh

echo setting up ssh
SSHC=/etc/ssh/sshd_config

perl -pi -e "s/Port 22/Port $QVM_SSH_PORT/" $SSHC
perl -pi -e 's/PermitRootLogin yes/PermitRootLogin yes/' $SSHC
perl -pi -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/' $SSHC
perl -pi -e 's/#AuthorizedKeysFile     %h/.ssh/authorized_keys/AuthorizedKeysFile     %h/.ssh/authorized_keys/' $SSHC




### ALL HAIL GEEKS
### ##############

echo geekrulez>/target/root/geekrulez
