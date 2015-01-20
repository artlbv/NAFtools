#!/bin/zsh

if [  $# = 0 ]; then
    echo "Usage:"
    echo "./verify.sh InputDir"
    exit 0
else
    InDir=$1
fi

for proc in `find $InDir -name "processed"`;
do
    file=$(find $(dirname $proc) -name "*chunk*.root")

    echo "======= Analyzing file ======="
    echo $file

    # searches for error in EDM Filt Util output
    if edmFileUtil $file 2>&1 > /dev/null | grep -i "error";
    then
        echo "======= File corrupt"
        rm -f $(dirname $file)/processed
        touch $(dirname $file)/failed
    else
        echo "======= File correct"
        rm -f $(dirname $file)/failed
    fi
done
