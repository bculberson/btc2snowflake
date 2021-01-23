#!/bin/bash

function stream
{
  export MIN=`cat position || echo 0`
  export MAX=`ls /data/blocks/blk* | tail -n 1 | grep -o "[0-9]*"`

  i=$MIN
  until [ $i -eq $MAX ]
  do
    /root/goxplorer -b $i -t -a -j
    ((i=i+1))
    echo $i > position
  done
}

while true
do
  stream
  sleep 1
done

