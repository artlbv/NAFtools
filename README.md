NAFtools
========

Tools to work with the NAF batch system (BIRD)
___
Jobs - script for jobs,
Submit - script to submit these jobs,
MCconfigs - configs for cmsRun

Preparation:
---
**The jobs REQUIRE to be executed from a CMSSW release area, otherwise they will fail!**

Best to put the job,submit and config files into the corresponding folders like:
CMSSW_X_X_X/src/RAWtoRECO/Batch/

Usage
---
The jobs need an Output and logs directory to run.

Submitting jobs:
``` bash
./SubmitRECO.sh INPUTFOLDER [OUTPUTFOLDER] [JOBNAME]
./SubmitRECO.sh GEN-SIM-RAW/PHYS14_PU20_25ns/T1tttt_gluino_800_LSP_450 Output/PHYS14_PU20_25ns RECO_T1t4_800
```

Verify Output
---
You can check how many files are processed/processing/failed in a dir using:
``` 
for f in `ls`; do echo $(find $f -name "processed" | wc -l; echo $f); ; done | sort -n 
```

To verify the ROOT files in an Output directory, you need to run:
`./VerifyOutput.sh DIRNAME`
The scrip will check the consisntency of the output files and label the directories "failed", if they are broken.

Then you can clean up these directories like:
``` for f in `find . -name "failed"`; do rm -r $(dirname $f); done  ```
