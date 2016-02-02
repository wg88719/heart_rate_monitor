#!/bin/bash

for i in {100..108}
#for((i=100;i<=108;i++))
do
        wfdb2mat -r mitdb/$i -f 0 -t 60 -l s1000000 > $im.info
done

#1805.556 # to end
