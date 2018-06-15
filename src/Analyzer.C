#include "Particles.C"
#include "Histogramer.C"


void overlap(Part& Jet, Part& Muon, Part& Elec, Tau& Tau);




void Analyzer() {
  // Create chain of root trees
  gErrorIgnoreLevel=kError; /// Ignores silly errors in ExRoot dictionaries
  TChain chain("Delphes");
  chain.Add("total.root");
  
  // Create object of class ExRootTreeReader
  TTreeReader *treeReader = new TTreeReader(&chain);
  Long64_t numberOfEntries = treeReader->GetEntries(1);
  
  cout << numberOfEntries << " = #" << endl;

  Part Jet = Part(treeReader, "Jet");
  Part Electron = Part(treeReader, "Electron", 0);
  Part Muon_T = Part(treeReader, "MuonTight", 0);
  Part Muon_L = Part(treeReader, "MuonLoose", 0);
  Tau Tau;

  TTreeReaderArray<float> MET(*treeReader, "MissingET.MET");

  vector<Part*> partList;
  partList.push_back(&Jet);
  partList.push_back(&Electron);
  partList.push_back(&Muon_T);
  partList.push_back(&Muon_L);
  partList.push_back(&Tau);

  Histograms histo;

  bool TESTING = false;
  int counter = 0;
  int passed = 0;


  while(treeReader->Next()) {
    counter++;
    if(counter%1000 == 0 ) cout << "Event: " << counter << endl;
    
    if(TESTING && counter > 10000) break;

    for(auto part : partList) part->setup_lvectors();

    //////////////////////////////////////////////
    ////////////// SELECTIONS ////////////////////
    //////////////////////////////////////////////
    if(MET.At(0) < 30) continue;
    Muon_T.basic_cuts(15, 2.4);
    Electron.basic_cuts(15, 2.4);
    Jet.basic_cuts(15, 4.7);
    overlap(Jet, Muon_T, Electron, Tau);


    if(Muon_T.size()+Electron.size() != 3) continue;
    ZCandidate Z(Muon_T, Electron);
    if(Z.size() == 0) continue;

    TLorentzVector triLep;
    for(auto lep : Muon_T) triLep += lep;
    for(auto lep : Electron) triLep += lep;
    if(triLep.M() < 100) continue;
    if(fabs( triLep.Eta() - 0.5*(Jet[1].Eta() + Jet[2].Eta())) > 2.5) continue;


    /// vbs selection
    if(Jet[0].Pt() < 50 || Jet[1].Pt() < 50 ) continue;
    histo.fill("BEFORE_hvbsjetsDEta", Jet[0].Eta()-Jet[1].Eta());
    histo.fill("BEFORE_hvbsjetsMass", (Jet[0]+Jet[1]).M());


    if(fabs(Jet[0].Eta()-Jet[1].Eta()) > 2.5) continue;
    if((Jet[0]+Jet[1]).M() < 500) continue;
    histo.fill("AFTER_hvbsjetsDEta", Jet[0].Eta()-Jet[1].Eta());
    histo.fill("AFTER_hvbsjetsMass", (Jet[0]+Jet[1]).M());


    //////////////////////////////////////////////
    ///////////// FILL UP HISTO //////////////////
    //////////////////////////////////////////////
    // histo.fill("hleadjetPt", Jet[0].Pt());
    // histo.fill("hleadjetEta", Jet[0].Eta());
    // histo.fill("hlepN", Muon_T.size()+Electron.size());


    // for( auto jet : Jet) {

    //   histo.fill("hjetPt",jet.Pt());
    //   histo.fill("hjetEta",jet.Eta());
    // }
    // histo.fill("hjetN",Jet.size());
    // histo.fill("htauN",Tau.size());
    // histo.fill("hMet",MET.At(0));
    passed++;
  }
  cout << "Number passed: " << passed << endl;
}









void overlap(Part& Jet, Part& Muon, Part& Elec, Tau& Tau) {
  for( auto it = Jet.begin(); it != Jet.end(); it++) {
    bool failed = false;
    for( auto e : Elec) {
      if(it->DeltaR(e) < 0.05) {
	Jet.remove(it - Jet.begin());
	failed = true;
	break;
      }
    }
    if(failed) {
      it--;
      continue;
    }
    for( auto mu : Muon) {
      if(it->DeltaR(mu) < 0.05) {
	Jet.remove(it - Jet.begin());
	failed = true;
	break;
      }
    }
    if(failed) {
      it--;
      continue;
    }
    if(Jet.is_tau(it - Jet.begin())) {
      Tau.add_tau(*it);
    }
  }
  
}
