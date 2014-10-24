#!/bin/zsh
## make sure the right shell will be used
#$ -S /bin/zsh
## Job name
#$ -N RAWjob
## the cpu time for this job
#$ -l h_rt=02:59:00
##$ -l h_rt=167:59:00
## the maximum memory usage of this job
#$ -l h_vmem=2000M
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
#$ -v BASEDIR=/afs/desy.de/user/l/lobanov/scratch/SUSY/Run2/Generators/CMSSW_7_0_6/src/Batch
#$ -v OUTDIR=/afs/desy.de/user/l/lobanov/scratch/SUSY/Run2/Generators/CMSSW_7_0_6/src/Batch/Output
#$ -v EXECUTABLE=step1_GEN-SIM_RAW_template.py
#$ -v CMSRUN=/cvmfs/cms.cern.ch/slc6_amd64_gcc472/cms/cmssw/CMSSW_7_0_6/bin/slc6_amd64_gcc472/cmsRun
#$ -o /afs/desy.de/user/l/lobanov/scratch/SUSY/Run2/Generators/CMSSW_7_0_6/src/Batch/logs
#$ -e /afs/desy.de/user/l/lobanov/scratch/SUSY/Run2/Generators/CMSSW_7_0_6/src/Batch/erlogs

echo job start at `date`
echo "Running job on machine " `uname -a`
#echo "Shell: "$SHELL
#export SHELL=/bin/sh
#env SHELL=/bin/sh
export PYTHONHOME=/cvmfs/cms.cern.ch/slc6_amd64_gcc472/external/python/2.7.3-cms5
#export SCRAM_ARCH=slc5_amd64_gcc472

cd $BASEDIR

TaskID=$((SGE_TASK_ID - 1))
echo "SGE_TASK_ID: " $TaskID

InDir=$1
ChunkSize=$2
LHEMaxEv=10000
Chunks=$((LHEMaxEv/ChunkSize))

FileNumb=$((TaskID / Chunks + 1))
ChunkNumb=$((TaskID % Chunks ))

SkipEv=$((ChunkSize * ChunkNumb))

echo "Calculated: ChunkSize Chunks FileNumb ChunkNumb"
echo "Calculated:" $ChunkSize $Chunks $FileNumb $ChunkNumb

if [ -d $InDir ]; then
    InDirName=$InDir
    Prefix=""
else
    InDirName=$(dirname $InDir)
    Prefix=$(basename $InDir)
fi

lhefile=$(find $InDirName -name "$Prefix*" | sed ''$FileNumb'q;d')
lhefile=$(readlink -f $lhefile)

#alias "cmsRun=/cvmfs/cms.cern.ch/slc6_amd64_gcc472/cms/cmssw/CMSSW_7_0_6/bin/slc6_amd64_gcc472/cmsRun"
#eval `scram runtime -sh`

#lhefile=$(ls $inDir | sed ''$SGE_TASK_ID'q;d')

echo "Running on file" $lhefile

OutFile=$(basename $lhefile)
LHEmodel=$(echo ${OutFile/_run_seed_/x} | cut -d 'x' -f 1)
LHEname=${OutFile/_decayed_final.lhe/_chunk$ChunkNumb/}
OutFile=${OutFile/_decayed_final.lhe/_GEN-SIM_chunk$ChunkNumb.root}

#JobDir=$OUTDIR/Job_$JobdD
JobDir=$OUTDIR/$LHEmodel/$LHEname

echo "Changing to workdir" $JobDir
if [ ! -d $JobDir ]; then
    mkdir -p $JobDir
fi

cd $JobDir

cp $BASEDIR/$EXECUTABLE SIM.py

sed -i "s|INPUT-GEN-SIM.root|$lhefile|" SIM.py
sed -i "s|OUTPUT-GEN-SIM-RAW_step1.root|$OutFile|" SIM.py
sed -i "s|MAXev|$ChunkSize|" SIM.py
sed -i "s|SKIPev|$SkipEv|" SIM.py

echo "Starting simulation"
#time $CMSRUN SIM.py

echo "Complete at " `date`
