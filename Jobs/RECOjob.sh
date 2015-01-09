#!/bin/zsh
## make sure the right shell will be used
#$ -S /bin/zsh
## Job name
#$ -N RAWtoRECO
## the cpu time for this job
#$ -l h_rt=02:59:00
##$ -l h_rt=167:59:00
## the maximum memory usage of this job
#$ -l h_vmem=4000M
## operating system
#$ -l distro=sld6
## architecture
##$ -l arch=amd64
## environment and cwd
#$ -V
#$ -cwd
## stderr and stdout are merged together to stdout
#$ -j y
##(send mail on job's end and abort)
##$ -m a
#$ -l site=hh
## define outputdir,executable,config file and LD_LIBRARY_PATH
#$ -v EXECUTABLE=step2_GEN-SIM-RECO_template.py

echo job start at `date`
echo "Running job on machine " `uname -a`

# expect to be in basedir already
BASEDIR=`pwd -P`
echo "Locating in "$BASEDIR

eval `/cvmfs/cms.cern.ch/common/scramv1 runtime -sh`
CMSRUN=`which cmsRun`

TaskID=$((SGE_TASK_ID))
echo "SGE_TASK_ID: " $TaskID

InDir=$1

if [ $# = 2 ]; then
    OUTDIR=$BASEDIR/$2
else
    OUTDIR=$BASEDIR/Output
fi

if [ -d $InDir ]; then
    InDirName=$InDir
    Prefix=""
else
    InDirName=$(dirname $InDir)
    Prefix=$(basename $InDir)
fi

procfile=$(find $InDirName/ -name "processed" | sed ''$TaskID'q;d')
FileINdir=$(dirname $procfile)
INfile=$(find $FileINdir ! -name "histProbFunction.root" -name "$Prefix*.root")
INfile=$(readlink -f $INfile)

OutFile=$(basename $INfile)
OutFile=${OutFile/_GEN-SIM-RAW/_GEN-SIM-RECO}
LHEmodel=$(echo ${OutFile/_run_/x} | cut -d 'x' -f 1)
SeedName=$(echo ${OutFile/_chunk/x} | cut -d 'x' -f 1)
ChunkName=${OutFile/.root/}

echo "Running on file" $INfile
echo "To produce output" $OutFile

JobDir=$OUTDIR/$LHEmodel/$SeedName/$ChunkName

echo "Changing to workdir" $JobDir

if [ ! -d $JobDir ]; then
    mkdir -p $JobDir
fi

cd $JobDir

if [ -f processing ]  && [ ! -f failed ]; then
    echo "Already processing this chunk!"
    echo "Stopping."
    exit 1
fi

if [ -f processed ]; then
    echo "Already processed this chunk!"
    echo "Aborting."
    exit 1
fi

cp $BASEDIR/$EXECUTABLE RECO.py

sed -i "s|INPUT-GEN-SIM-RAW.root|$INfile|" RECO.py
sed -i "s|OUTPUT-GEN-SIM-RECO.root|$OutFile|" RECO.py

echo "Starting simulation at " `date`
touch processing
memtime=/usr/bin/time
$memtime -v time $CMSRUN RECO.py >>cmsRun.log 2>&1
rm processing

if [ -f $OutFile ]; then
    echo "Sucessfully processed!"
    touch processed
else
    echo "Failed processing!"
    touch failed
fi

echo "Complete at " `date`
