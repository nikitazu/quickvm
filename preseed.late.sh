#!/bin/sh

. /qvm.config

### SETUP SSH
### #########

QVM_SSH_HOME="/target/root/.ssh"
QVM_SSH_KEY="id_dsa_$QVM_HOST".pub
QVM_SSH_CFG="/target/etc/ssh/sshd_config"

test -f /qvm.config && echo "qvm.config found and that is good">>/target/root/qvm.log
test -f "/$QVM_SSH_KEY" && echo "$QVM_SSH_KEY found and that is good">>/target/root/qvm.log

echo making ssh dir
mkdir -p /target/root/.ssh

echo copying ssh public key
cp "/$QVM_SSH_KEY" "$QVM_SSH_HOME/$QVM_SSH_KEY"

echo authorizing ssh public key
cat "/$QVM_SSH_KEY" >>"$QVM_SSH_HOME"/authorized_keys

echo allowing root only acces to key
chmod 600 -R "$QVM_SSH_HOME"

echo setting up ssh
cp "$QVM_SSH_CFG" "$QVM_SSH_CFG".backup
cp /sshd_config "$QVM_SSH_CFG"


### ALL HAIL GEEKS
### ##############

echo geekrulez>/target/root/geekrulez

