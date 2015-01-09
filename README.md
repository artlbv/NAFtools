NAFtools
========

Tools to work with the NAF batch system (BIRD)

Usage
===
Jobs - script for jobs
Submit - script to submit these jobs
MCconfigs - configs for cmsRun

Preparation:
---
Best to put the job,submit and config files into the corresponding folders like:
CMSSW_X_X_X/src/RAWtoRECO/Batch/

The job need an Output and logs directory to run.

Submitting jobs:
./SubmitRECO_proc.sh INPUTFOLDER [OUTPUTFOLDER] [JOBNAME]
./SubmitRECO_proc.sh GEN-SIM-RAW/PHYS14_PU20_25ns/T1tttt_gluino_800_LSP_450 Output/PHYS14_PU20_25ns RECO_T1t4_800
