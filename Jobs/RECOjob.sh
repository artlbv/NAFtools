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
#$ -v BASEDIR=/afs/desy.de/user/l/lobanov/scratch/SUSY/Run2/Generators/CMSSW_7_0_6/src/RAWtoRECO/Batch
#$ -v OUTDIR=/afs/desy.de/user/l/lobanov/scratch/SUSY/Run2/Generators/CMSSW_7_0_6/src/RAWtoRECO/Batch/Output
#$ -v EXECUTABLE=step2_GEN-SIM-RECO_template.py
#$ -v CMSRUN=/cvmfs/cms.cern.ch/slc6_amd64_gcc481/cms/cmssw/CMSSW_7_0_6/bin/slc6_amd64_gcc481/cmsRun
#$ -o /afs/desy.de/user/l/lobanov/scratch/SUSY/Run2/Generators/CMSSW_7_0_6/src/RAWtoRECO/Batch/logs
#$ -e /afs/desy.de/user/l/lobanov/scratch/SUSY/Run2/Generators/CMSSW_7_0_6/src/RAWtoRECO/Batch/erlogs

echo job start at `date`
echo "Running job on machine " `uname -a`

export PYTHONHOME=/cvmfs/cms.cern.ch/slc6_amd64_gcc472/external/python/2.7.3-cms5
#export SCRAM_ARCH=slc5_amd64_gcc472

cd $BASEDIR

TaskID=$((SGE_TASK_ID))
echo "SGE_TASK_ID: " $TaskID

InDir=$1

#echo "Calculated: ChunkSize Chunks FileNumb ChunkNumb"
#echo "Calculated:" $ChunkSize $Chunks $FileNumb $ChunkNumb

if [ -d $InDir ]; then
    InDirName=$InDir
    Prefix=""
else
    InDirName=$(dirname $InDir)
    Prefix=$(basename $InDir)
fi

SIMfile=$(find $InDirName/  ! -name "histProbFunction.root" -name "$Prefix*.root" | sed ''$TaskID'q;d')
SIMfile=$(readlink -f $SIMfile)

#echo "Searching in $InDirName ($InDir) $SIMfile"
#alias "cmsRun=/cvmfs/cms.cern.ch/slc6_amd64_gcc472/cms/cmssw/CMSSW_7_0_6/bin/slc6_amd64_gcc472/cmsRun"
#eval `scram runtime -sh`

#SIMfile=$(ls $inDir | sed ''$SGE_TASK_ID'q;d')

OutFile=$(basename $SIMfile)
OutFile=${OutFile/_GEN-SIM-RAW/_GEN-SIM-RECO}
LHEmodel=$(echo ${OutFile/_run_/x} | cut -d 'x' -f 1)
SeedName=$(echo ${OutFile/_chunk/x} | cut -d 'x' -f 1)
ChunkName=${OutFile/.root/}
#ChunkName=${OutFile/_GEN-SIM/_GEN-SIM-RAW}

echo "Running on file" $SIMfile
echo "To produce output" $OutFile

#JobDir=$OUTDIR/Job_$JobdD
JobDir=$OUTDIR/$LHEmodel/$SeedName/$ChunkName
#JobDir=${JobDir/_GEN-SIM/_GEN-SIM-RAW}

echo "Changing to workdir" $JobDir

if [ ! -d $JobDir ]; then
    mkdir -p $JobDir
fi

cd $JobDir

if [ -f processing ]; then
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

sed -i "s|INPUT-GEN-SIM-RAW.root|$SIMfile|" RECO.py
sed -i "s|OUTPUT-GEN-SIM-RECO.root|$OutFile|" RECO.py
#sed -i "s|MAXev|$ChunkSize|" RECO.py
#sed -i "s|SKIPev|$SkipEv|" RECO.py

echo "Starting simulation at " `date`
touch processing
memtime=/usr/bin/time
$memtime -v time $CMSRUN RECO.py >>cmsRun.log 2>&1
rm processing

if [ -f $OutFile ]; then
    touch processed
fi

echo "Complete at " `date`
