#!/bin/zsh

if [  $# = 0 ]; then
    echo "Usage:"
    echo "./SubmitSIM.sh InDir(pattern) [SplitFactor]"
    exit 0
else
    InDir=$1
fi

if [ -d $InDir ]; then
    #running over whole dir
    echo "Running over whole dir" $InDir

    NumbFiles=$(find $InDir/ -type f -name "*.root" | wc -l)
else
    #running over pattern in dir
    prefix=$(basename $InDir)
    inDir=$(dirname $InDir)

    echo "Running over prefix" $prefix

    NumbFiles=$(find $inDir/ -type f -name "$prefix*.root" | wc -l)
#    echo $NumbFiles
fi

echo "Found $NumbFiles matching files in $InDir"

NumbJobs=$((NumbFiles))

echo "Going to submit $NumbJobs Jobs:"
#echo "with $chunks chunks per file ($chunkSize events)"

qsub -t 1-$NumbJobs RAWjob.sh $InDir
#SumEvents=$(())
#qsub -t 1-$NumJobs -cwd -V MGjob.sh $OutDir $OutName
#qsub -V -cwd -t 1-10 SIMjob.sh LHE/
