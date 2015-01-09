#!/bin/zsh

if [  $# = 0 ]; then
    echo "Usage:"
    echo "./SubmitSIM.sh InDir(pattern) [SplitFactor]"
    exit 0
else
    InDir=$1
fi

if [ $# -ge 2 ]; then
    SplitF=$2
else
    SplitF=20
fi

maxLHEevents=10000

chunkSize=$((maxLHEevents/SplitF))
chunks=$SplitF

if [ -d $InDir ]; then
    #running over whole dir
    echo "Running over whole dir" $InDir

    NumbFiles=$(find $InDir -name "*.lhe" | wc -l)
else
    #running over pattern in dir
    prefix=$(basename $InDir)
    inDir=$(dirname $InDir)

    echo "Running over prefix" $prefix
    echo "Searching in" $inDir

    NumbFiles=$(find $inDir -name "$prefix*.lhe" | wc -l)
#    echo $NumbFiles
fi

echo "Found $NumbFiles matching files in $InDir"

NumbJobs=$((NumbFiles*chunks))

if [ "$NumbJobs" -lt 1 ]; then
    echo "No files found!"
    exit 0
fi

echo "Going to submit $NumbJobs Jobs:"
echo "with $chunks chunks per file ($chunkSize events)"

qsub -t 1-$NumbJobs GENjob.sh $InDir $chunkSize
