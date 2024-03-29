#!/bin/bash

function stream
{
  if [ -f /data/blocks/blk00001.dat ]; then
    export MIN=`cat position || echo 0`
    export MAX=`ls /data/blocks/blk* | tail -n 1 | grep -o "[0-9]*"`

    i=$MIN
    until [ $i -eq $MAX ]
    do
      /root/goxplorer -b ${i} -t -a -j | gzip > /root/batch_${i}.json.gz
      echo "batch_${i}.json.gz"
      ((i=i+1))
      echo "${i}" > position
    done
  fi
}

while true
do
  stream
  sleep 1
done

