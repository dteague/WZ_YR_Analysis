# WZ Analysis for Yellow Report

## Setup

## Logic of Steps

### Generation of LHE File
The Generation is down with MadGraph. Because this analysis is looking at decays of WZ to see the polarization of the W and Z (can be used to look at such things as aQGC), we need to use an older version of MadGraph. This isn't much of a problem at LO, so we use MadGraph 1.5.17.  We also need the DECAY program in this, so that is downloaded as well. The decay is done in the usual way with MadGraph: any cuts needed for your signal region can be added to your discrestion in the ~run_card~

### Decaying of LHE

### Hadronizing and Simulating

### Analysis
