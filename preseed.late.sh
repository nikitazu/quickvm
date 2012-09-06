#!/bin/sh

echo making ssh dir
mkdir -p /target/root/.ssh

echo copying ssh public key
cp /id_dsa.pub /target/root/.ssh/id_dsa.pub

echo authorizing ssh public key
cat /target/root/.ssh/id_dsa.pub>>/target/root/.ssh/authorized_keys

echo allowing root only acces to key
chmod 600 -R /target/root/.ssh

echo setting up ssh
sshc=/etc/ssh/sshd_config

perl -pi -e 's/Port 22/Port 19865/' $sshc
perl -pi -e 's/PermitRootLogin yes/PermitRootLogin yes/' $sshc
perl -pi -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/' $sshc
perl -pi -e 's/#AuthorizedKeysFile     %h/.ssh/authorized_keys/AuthorizedKeysFile     %h/.ssh/authorized_keys/' $sshc


echo geekrulez>/target/root/geekrulez

