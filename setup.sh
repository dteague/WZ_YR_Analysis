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

wget http://cp3.irmp.ucl.ac.be/downloads/Delphes-3.4.1.tar.gz
tar -xzf Delphes-3.4.1.tar.gz
rm Delphes-3.4.1.tar.gz
pushd Delphes-3.4.1
./configure
make -j 4
export PYTHIA8=/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/pythia8/223-mlhled2/
export LD_LIBRARY_PATH=$PYTHIA8/lib:$LD_LIBRARY_PATH
make -j 4 HAS_PYTHIA8=true DelphesPythia8
cp tmp/modules/Pythia8Dict_rdict.pcm . 
popd
tar -czf delphes.tar.gz Delphes-3.4.1
rm -r Delphes-3.4.1

#sed -n 's/\(set PileUpFile\).*/\1 test/p'