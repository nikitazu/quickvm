#!/bin/sh

EXPECTED_ARGS=6 # do i really need this?
E_BADARGS=65    # and this?

if [ $# -ne $EXPECTED_ARGS ]; then
  echo error: wrong arguments
  echo usage: qvm.create vmhost vmdescr vmdsize vmid vmmac vmserver
  exit $E_BADARGS
fi

# here we do things
QVM_ROOT="`pwd`/test"

# vm name and hostname
QVM_HOST="$1"
QVM_DESCRIPTION="$2"

# here we do things with this vm
QVM_DIR="$QVM_ROOT/$QVM_HOST".d

# ssh keys
QVM_SSH="$QVM_DIR/id_dsa_$QVM_HOST"
QVM_DISK="$QVM_DIR/$QVM_HOST".qcow2

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
QVM_SERVER="$5"

# vm will be stored here (path on remote server)
QVM_SERVER_ROOT="/mnt/data/kvm/$QVM_HOST"


echo making vm dir in $QVM_DIR
rm -rf $QVM_DIR
mkdir $QVM_DIR

echo making vm ssh keys $QVM_SSH
ssh-keygen -t dsa -N $QVM_HOST -C $QVM_HOST -f $QVM_SSH

echo making vm disk $QVM_DISK
echo qemu-img create -f qcow2 -o preallocation=metadata $QVM_DISK "$QVM_DISK_SIZE"G

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


echo making vm $QVM_HOST
echo virt-install \
	--name $QVM_HOST \
	--description "$QVM_DESCRIPTION" \
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
	--initrd-inject="$QVM_PRESEED" \
	--initrd-inject="$QVM_SSH".pub \
	--initrd-inject="$QVM_PRESEED_LATE" \
	--initrd-inject="$QVM_CFG"
