#!/bin/sh

source /qvm.config

### SETUP SSH
### #########

QVM_SSH_HOME="/target/root/.ssh"
QVM_SSH_KEY="id_dsa_$QVM_HOST".pub
QVM_SSH_CFG=/etc/ssh/sshd_config

echo making ssh dir
mkdir -p /target/root/.ssh

echo copying ssh public key
cp "/$QVM_SSH_KEY" "$QVM_SSH_HOME/$QVM_SSH_KEY"

echo authorizing ssh public key
cat "/$QVM_SSH_KEY" >>"$QVM_SSH_HOME"/authorized_keys

echo allowing root only acces to key
chmod 600 -R "$QVM_SSH_HOME"

echo setting up ssh
perl -pi -e "s/Port 22/Port $QVM_SSH_PORT/" $QVM_SSH_CFG
perl -pi -e 's/PermitRootLogin yes/PermitRootLogin yes/' $QVM_SSH_CFG
perl -pi -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/' $QVM_SSH_CFG
perl -pi -e 's/#AuthorizedKeysFile     %h/.ssh/authorized_keys/AuthorizedKeysFile     %h/.ssh/authorized_keys/' $QVM_SSH_CFG


### ALL HAIL GEEKS
### ##############

echo geekrulez>/target/root/geekrulez
