Quick Virtual Manager
=====================

A bunch of scripts to quickly create virtual image of debian linux from scratch.

Features
--------

* One command to go
* Automatic installation
* Fully working system after everything is done

Depends on
----------

* Internet connection
* Shell scripts
* KVM

Steps to create virtual machine
-------------------------------

You
* start script on your client machine
* provide vm parameters (name, disk size etc..)

Script
* generates ssh keys for vm
* TODO saves private key on your machine
* TODO sets up ~/.ssh/config
* creates installation files (preseed, late command etc..)
* moves installation files to kvm server via ssh
* creates qcow2 image for vm
* starts virt-install with setups to network boot debian
* injects installation files to vm's initrd
* instructions in preseed.cfg do the rest (packages, ssh keys)

