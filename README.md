# WZ Analysis for Yellow Report
This is the basic flow used by me in looking at VBS EWK-WZ decay at the LHC.  
## Setup

## Logic of Steps

### Generation of LHE File
The Generation is down with MadGraph. Because this analysis is looking at decays of WZ to see the polarization of the W and Z (can be used to look at such things as aQGC), we need to use an older version of MadGraph. This isn't much of a problem at LO, so we use MadGraph 1.5.17.  We also need the DECAY program in this, so that is downloaded as well. The decay is done in the usual way with MadGraph: any cuts needed for your signal region can be added to your discrestion in the `run_card.dat`. 

### Decaying of LHE
As stated before, since this analysis is looking at polarizations of the WZ, we need to get that information out of the LHE files. MadSpin doesn't keep this information, so we have to use an older piece of softwafe: DECAY. The included `decay_lhe.py` takes all of the W and Z's in the event and decays them leptonically. After this, the files are ready to be sent to Pythia for the full hadronization.

### Hadronizing and Simulating
Pythia is the hadronizaiton software, and Delphes is the simulation software. Delphes actually comes with a combined Pythia/Delphes program that we use here.
Delphes can be a little troublesome when it comes to version and linking. On some machines, the `DelphesPythia` program doesn't compile, so be wary of this issue. 
Because this is one of the longest steps in the process, it has been written to run with Condor.  Right now, the setup file is for using at `login.hep.wisc.edu`, but this may change in the future.

### Analysis
Right now, the Anaysis is done using a ROOT macro. This will probably change in future version because of the long time it tkaes to go through hundreds of thousands of events.  This Analysis has only Three main files
+ `Analyzer.C` -- Does the actual looping of the events and selections
+ `Histogramer.C` -- creates the histograms that will be used. These are defined based on the `hist.config` file
+ `Particles.C` -- Defines the different particles in a nice object.
