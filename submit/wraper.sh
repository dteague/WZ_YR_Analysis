#!/usr/bin/env bash 

# TODO: these could be filled in from a template 
CMSSW_RELEASE_BASE="/cvmfs/cms.cern.ch/slc6_amd64_gcc530/cms/cmssw/CMSSW_8_0_27" 

source /cvmfs/cms.cern.ch/cmsset_default.sh
pushd $CMSSW_RELEASE_BASE
eval `scramv1 runtime -sh` 
popd 
export LD_LIBRARY_PATH=$PWD/lib:$LD_LIBRARY_PATH
export X509_USER_PROXY=userproxy 
export PYTHIA8=/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/pythia8/223-mlhled2
export LD_LIBRARY_PATH=$PYTHIA8/lib:$LD_LIBRARY_PATH

process=$1

card=delphes/cards/CMS_PhaseII/CMS_PhaseII_140PU_v02.tcl
MinBias="delphes/MinBias.pileup"

tar -xzf delphes.tar.gz && mv Delphes-3.4.1 delphes
sed -i'' -e "s/INPUT_FILE/output_events${process}.lhe/g" configLHE.cmnd
sed -i -e "s/\(set PileUpFile\).*/\1 $MinBias/g" $card
./delphes/DelphesPythia8 $card configLHE.cmnd delphes_output$process.root 2>&1 || exit $? 
#strace -o trace.log -e trace=open -f ./runSelector $@

