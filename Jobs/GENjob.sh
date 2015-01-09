#!/bin/zsh
## make sure the right shell will be used
#$ -S /bin/zsh
## Job name
#$ -N SIMjob
## the cpu time for this job
#$ -l h_rt=23:59:00
##$ -l h_rt=167:59:00
## the maximum memory usage of this job
#$ -l h_vmem=7900M
## operating system
#$ -l distro=sld6
## architecture
##$ -l arch=amd64
## environment and cwd
#$ -V
#$ -cwd
## stderr and stdout are merged together to stdout
##$ -j y
##(send mail on job's end and abort)
##$ -m a
#$ -l site=hh
## define outputdir,executable,config file and LD_LIBRARY_PATH
#$ -v EXECUTABLE=Hadr_SIM_template.py

echo job start at `date`
echo "Running job on machine " `uname -a`

# expect to be in basedir already
BASEDIR=`pwd -P`
echo "Locating in "$BASEDIR

eval `/cvmfs/cms.cern.ch/common/scramv1 runtime -sh`
CMSRUN=`which cmsRun`
echo "CMSSW environnment: $CMSSW_VERSION"

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

echo "Running on file" $lhefile

OutFile=$(basename $lhefile)
LHEmodel=$(echo ${OutFile/_run_/x} | cut -d 'x' -f 1)
RunName=${OutFile/_decayed_final.lhe/}
ChunkName=$RunName"_chunk$ChunkNumb"
OutFile=$RunName"_GEN-SIM_chunk$ChunkNumb.root"

#JobDir=$OUTDIR/Job_$JobdD
JobDir=$OUTDIR/$LHEmodel/$RunName/$ChunkName

echo "Changing to workdir" $JobDir
if [ ! -d $JobDir ]; then
    mkdir -p $JobDir
fi

cd $JobDir

if [ -f processing ] && [ ! -f failed ] ; then
    echo "Already processing!"
    echo "Aborting."
    exit 1
fi

if [ -f processed ]; then
    echo "Already processed!"
    echo "Aborting."
    exit 1
fi

cp $BASEDIR/$EXECUTABLE SIM.py

sed -i "s|input_LHE.lhe|$lhefile|" SIM.py
sed -i "s|OutputSIM.root|$OutFile|" SIM.py
sed -i "s|MAXev|$ChunkSize|" SIM.py
sed -i "s|SKIPev|$SkipEv|" SIM.py

echo "Starting simulation"
touch processing

memtime=/usr/bin/time
$memtime -v time $CMSRUN SIM.py >>cmsRun.log 2>&1
rm processing

if [ -f $OutFile ]; then
    echo "Sucessfully processed!"
    touch processed
else
    echo "Failed processing!"
    touch failed
fi

echo "Complete at" `date`
