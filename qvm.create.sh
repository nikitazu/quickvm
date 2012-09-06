#!/bin/sh


### INIT, SANITY CHECKS
### ###################


EXPECTED_ARGS=6 # do i really need this?
E_BADARGS=65    # and this?
E_VM_EXISTS=66

if [ $# -ne $EXPECTED_ARGS ]; then
  echo error: wrong arguments
  echo usage: qvm.create vmhost vmdescr vmdsize vmid vmmac vmserver
  exit $E_BADARGS
fi


### SETUP
### #####


# here we do things
QVM_ROOT="`pwd`/test"

# vm name and hostname
QVM_HOST="$1"
QVM_DESCRIPTION="$2"

# here we do things with this vm
QVM_DIR="$QVM_ROOT/$QVM_HOST".d

# ssh key
QVM_SSH="$QVM_DIR/id_dsa_$QVM_HOST"

# size of vm disk to create in gigabytes
QVM_DISK_SIZE="$3"

# debian autoinstaller scripts
QVM_PRESEED="$QVM_DIR/preseed.cfg"
QVM_PRESEED_LATE="$QVM_DIR/preseed.late.sh"
QVM_CFG="$QVM_DIR/qvm.config"

# temporary desicion, id is needed to create sane
# ports for services, ip addressed etc..
QVM_ID="$4"
QVM_MAC="52:54:00:00:00:$5"
QVM_VNC_PORT="590$QVM_ID"
QVM_SSH_PORT="1986$QVM_ID"

# remote server with linux, kvm and ssh
QVM_SERVER="$6"

# vm will be stored here (path on remote server)
QVM_SERVER_DIR="/mnt/data/kvm/$QVM_HOST"

# vm disk
QVM_DISK="$QVM_SERVER_DIR/$QVM_HOST".qcow2

# remove command
QVMS="ssh $QVM_SERVER"

# check remote server and vm for being allready there
ssh $QVM_SERVER test -d $QVM_SERVER_DIR && \
	echo "STOP!!! DIRECTORY FOR $QVM_HOST ALLREADY EXISTS ON $QVM_SERVER" && \
		exit $E_VM_EXISTS


### PREPAIR LOCAL FILES
### ###################


echo making vm dir in $QVM_DIR
rm -rf $QVM_DIR
mkdir $QVM_DIR

echo making vm ssh keys $QVM_SSH
echo TODO: copy ssh private key to client machine
ssh-keygen -t dsa -N $QVM_HOST -C $QVM_HOST -f $QVM_SSH

echo making preseed $QVM_PRESEED
cp preseed.cfg "$QVM_PRESEED"
cp preseed.late.sh "$QVM_PRESEED_LATE"

echo making config
if [ -f "$QVM_CFG" ]; then
	rm "$QVM_CFG"
fi
touch "$QVM_CFG"
echo QVM_HOST="$QVM_HOST">>"$QVM_CFG"
echo QVM_DESCRIPTION="$QVM_DESCRIPTION">>"$QVM_CFG"
echo QVM_ID="$QVM_ID">>"$QVM_CFG"
echo QVM_MAC="$QVM_MAC">>"$QVM_CFG"
echo QVM_VNC_PORT="$QVM_VNC_PORT">>"$QVM_CFG"
echo QVM_SSH_PORT="$QVM_SSH_PORT">>"$QVM_CFG"


### MOVE TO SERVER
### ##############

echo making remote vm directory
$QVMS "mkdir -p $QVM_SERVER_DIR"
scp $QVM_DIR/* $QVM_SERVER:/$QVM_SERVER_DIR/

echo making vm disk $QVM_DISK
$QVMS qemu-img create -f qcow2 -o preallocation=metadata $QVM_DISK "$QVM_DISK_SIZE"G

# note --description value is UGLY
echo making vm $QVM_HOST
echo `date`>$QVM_DIR/installation_started_at

$QVMS virt-install \
	--name $QVM_HOST \
	--description "'$QVM_DESCRIPTION'" \
	--ram 1024 \
	--disk path="$QVM_DISK",size="$QVM_DISK_SIZE",format=qcow2 \
    --location http://mirrors.usc.edu/pub/linux/distributions/debian/dists/squeeze/main/installer-amd64/ \
	--os-type linux \
    --os-variant debiansqueeze \
	--hvm \
	--noautoconsole \
	--network bridge=br0,mac="$QVM_MAC" \
	--graphics vnc,password="$QVM_HOST",port="$QVM_VNC_PORT",listen=0.0.0.0 \
	--extra-args="preseed/file=/preseed.cfg" \
	--initrd-inject="$QVM_SERVER_DIR/preseed.cfg" \
	--initrd-inject="$QVM_SERVER_DIR/id_dsa_$QVM_HOST".pub \
	--initrd-inject="$QVM_SERVER_DIR/preseed.late.sh" \
	--initrd-inject="$QVM_SERVER_DIR/qvm.config"

exit 0
