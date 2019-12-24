#!/bin/bash


fold_start() {
  echo -e "travis_fold:start:$1\033[33;1m$2\033[0m"
  travis_time_start
}

fold_end() {
  travis_time_finish
  echo -e "\ntravis_fold:end:$1\r"
}


create_osx_chroot() {
    ROOTFS=$1
    if [ $TRAVIS_OS_NAME == "osx" ]; then
	sudo mount -t devfs devfs $ROOTFS/dev
    fi
}

create_runu_aux_dir() {
    export RUNU_AUX_DIR="/tmp"

    if [ -a /tmp/lkick ] ; then
	return
    fi

    # download pre-built frankenlibc
    curl -L https://dl.bintray.com/ukontainer/ukontainer/$TRAVIS_OS_NAME/$ARCH/frankenlibc.tar.gz \
	 -o /tmp/frankenlibc.tar.gz
    tar xfz /tmp/frankenlibc.tar.gz -C /tmp/
    cp /tmp/opt/rump/bin/rexec /tmp/rexec
    cp /tmp/opt/rump/bin/lkick /tmp/lkick
    if [ $TRAVIS_OS_NAME == "osx" ]; then
	curl -L https://dl.bintray.com/ukontainer/ukontainer/linux/amd64/frankenlibc.tar.gz \
	     -o /tmp/frankenlibc-linux.tar.gz
	tar xfz /tmp/frankenlibc-linux.tar.gz -C /tmp opt/rump/lib/libc.so
    fi
    if [ -f /tmp/opt/rump/lib/libc.so ] ; then
	cp /tmp/opt/rump/lib/libc.so /tmp/libc.so
    fi
}
