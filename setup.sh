##############################################
############### SETUP LHE STUFF ##############
##############################################


wget https://launchpad.net/mg5amcnlo/trunk/1.5.0/+download/MadGraph5_v1.5.14.tar.gz
tar -xzf MadGraph5_v1.5.14.tar.gz
rm MadGraph5_v1.5.14.tar.gz
cp lhe decay*.f MadGraph5_v1_5_14/DECAY
pushd MadGraph5_v1_5_14/DECAY
make -j 4
decay_dir=$(pwd)
popd
sed -i -e "s@DECAY_DIRECTORY@$decay_dir@g" lhe_sup/decay_lhe.sh


##############################################
########### SETUP DELPHES STUFF ##############
##############################################

git clone https://github.com/delphes/delphes.git
pushd delphes
git checkout tags/3.4.2pre15
./configure
sed -i -e 's/c++0x/c++1y/g' Makefile
CMSSW_RELEASE_BASE="/cvmfs/cms.cern.ch/slc6_amd64_gcc530/cms/cmssw/CMSSW_9_1_0_pre3" 
source /cvmfs/cms.cern.ch/cmsset_default.sh
pushd $CMSSW_RELEASE_BASE
eval `scramv1 runtime -sh` 
popd 
export PYTHIA8=/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/pythia8/223-mlhled2/
export LD_LIBRARY_PATH=$PYTHIA8/lib:$LD_LIBRARY_PATH
make -j 12 HAS_PYTHIA8=true DelphesPythia8
cp tmp/modules/Pythia8Dict_rdict.pcm . 
popd
tar -czf delphes.tar.gz delphes
rm -rf delphes

#sed -n 's/\(set PileUpFile\).*/\1 test/p'