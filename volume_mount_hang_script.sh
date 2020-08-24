#!/bin/bash
set -eu

DOCKER_RUN_ARGS="run -i --runtime=runu-dev --net=none -d"
LKL_ARGS="-e RUMP_VERBOSE=1 -e LKL_CONFIG=/lkl.json -e LKL_USE_9PFS=1"
DOCKER_IMG_VERSION=0.3

MNT_SRC=$PWD/host_dir
MNT_SRC_FILE=$MNT_SRC/hello.txt
MNT_DST=/mnt
MNT_DST_FILE=$MNT_DST/hello.txt
rm -rf ${MNT_SRC}
mkdir -p $MNT_SRC
echo -n HELLO > $MNT_SRC_FILE

script=$(cat <<EOF
import time
print("START")
time.sleep(3)
f=open('$MNT_DST_FILE','r')
print("OPENED")
s=f.read()
print("READ")
f.close()
print("CLOSED")
ftmp=open('/tmpfile','w')
print("tmpfile OPENED with 'w'")
print('%s WORLD' % s)
print('%s WORLD' % s, end='', file=ftmp)
print("WRITTEN to tmpfile")
ftmp.close()
ftmp=open('/tmpfile','r')

print("tmpfile OPENED")
sftmp=ftmp.read()
print("READ from tmpfile %s" % sftmp)

print("OPENING with 'w'")
f=open('$MNT_DST_FILE','w')
print("OPENED with 'w'")
print('%s WORLD' % s, end='', file=f)
print("FILE WRITTEN")
f.close()
print("CLOSED OPENED")
EOF
)

echo =======START FIRST EXEC=======
cid1=$(docker $DOCKER_RUN_ARGS $LKL_ARGS \
       -v ${MNT_SRC}:${MNT_DST} \
       thehajime/runu-python:$DOCKER_IMG_VERSION \
       python -c "${script}")
sleep 1
ps -p $(pgrep  runu)
i=0
while $(docker inspect -f "{{.State.Running}}" $cid1); do
echo $i
# docker logs ${cid1}
i=$((i+1))
sleep 1
done

echo file contents
cat ${MNT_SRC_FILE}
echo
if [ -n "$(cat ${MNT_SRC_FILE} | egrep "HELLO WORLD")" ]; then
  echo [OK] written
else
  echo [NG] not written
fi


if [ -z "$(pgrep  runu)" ];then
  echo there is no runu process
else
  echo runu processes remain
  ps -p $(pgrep  runu) 
  docker kill $cid1
  exit 1
fi

sleep 1

MNT_SRC=$PWD/host_dir
MNT_SRC_FILE=$MNT_SRC/hello.txt
MNT_DST=/mnt2
MNT_DST_FILE=$MNT_DST/hello.txt

script=$(cat <<EOF
import time
print("START")
time.sleep(3)
f=open('$MNT_DST_FILE','r')
print("OPENED")
s=f.read()
print("READ")
f.close()
print("CLOSED")
ftmp=open('/tmpfile','w')
print("tmpfile OPENED with 'w'")
print('%s WORLD' % s)
print('%s WORLD' % s, end='', file=ftmp)
print("WRITTEN to tmpfile")
ftmp.close()
ftmp=open('/tmpfile','r')

print("tmpfile OPENED")
sftmp=ftmp.read()
print("READ from tmpfile %s" % sftmp)

print("OPENING with 'w'")
f=open('$MNT_DST_FILE','w')
print("OPENED with 'w'")
print('%s WORLD' % s, end='', file=f)
print("FILE WRITTEN")
f.close()
print("CLOSED OPENED")
EOF
)

echo =======START SECOND EXEC=======
cid2=$(docker $DOCKER_RUN_ARGS $LKL_ARGS \
       -v ${MNT_SRC}:${MNT_DST} \
       thehajime/runu-python:$DOCKER_IMG_VERSION \
       python -c "${script}")
sleep 1
ps -p $(pgrep  runu)
i=0
while $(docker inspect -f "{{.State.Running}}" $cid2); do
echo $i
if (( i > 10 )); then 
  echo "the container seems hungging"
  echo "=====runu processes====="
  ps -p $(pgrep  runu)
  echo "==========container logs============="
  docker logs ${cid2}
  echo "====================================="
  break
fi
i=$((i+1))
sleep 1
done

echo file contents
cat ${MNT_SRC_FILE}
echo
if [ -n "$(cat ${MNT_SRC_FILE} | egrep "HELLO WORLD WORLD")" ]; then
  echo [OK] written
else
  echo [NG] not written
fi

if [ -z "$(pgrep  runu)" ];then
  echo there is no runu process
else
  echo runu processes remain
  ps -p $(pgrep  runu) 
  docker kill $cid2
fi

