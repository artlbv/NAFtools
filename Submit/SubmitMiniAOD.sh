#!/bin/zsh

if [  $# = 0 ]; then
    echo "Usage:"
    echo "./SubmitSIM.sh InDir [OutDir] [JobName]"
    exit 0
else
    InDir=$1
fi

if [ -d $InDir ]; then
    #running over whole dir
    echo "Running over whole dir" $InDir

    NumbFiles=$(find $InDir -type f -name "processed" | wc -l)
else
    #running over pattern in dir
    prefix=$(basename $InDir)
    inDir=$(dirname $InDir)

    echo "Running over prefix" $prefix

    NumbFiles=$(find $inDir -type f -name "processed" | wc -l)
#    echo $NumbFiles
fi

echo "Found $NumbFiles processed files in $InDir"

NumbJobs=$((NumbFiles))

echo "Going to submit $NumbJobs Jobs:"

if [ $# -ge 1 ]; then
    OutDir=$2
else
    OutDir=""
fi

if [ $# = 3 ]; then
    qsub -t 1-$NumbJobs -o logs -N $3 MiniAODjob.sh $InDir $OutDir
else
    qsub -t 1-$NumbJobs -o logs MiniAODjob.sh $InDir $OutDir
fi
