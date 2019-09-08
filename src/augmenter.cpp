#include <compactnesslib/compactnesslib.hpp>
#include "Timer.hpp"
#include <iostream>
#include <fstream>

int main(int argc, char **argv) {
  if(argc!=5){
    std::cerr<<"Syntax: "<<argv[0]<<" <Subunit File> <Superunit File> <Output file> <Join On>"<<std::endl;
    return -1;
  }

  std::string in_sub_filename = argv[1];
  std::string in_sup_filename = argv[2];
  std::string out_filename    = argv[3];
  std::string join_on         = argv[4];

  std::cout<<"Processing '"<<in_sub_filename<<"' and '"<<in_sup_filename<<"'..."<<std::endl;
  auto gc_sub = complib::ReadShapefile(in_sub_filename);
  auto gc_sup = complib::ReadShapefile(in_sup_filename);

  gc_sub.clipperify();
  gc_sup.clipperify();

  // FindExteriorDistricts(gc_sub, gc_sup);
  complib::CalculateAllBoundedScores(gc_sub, gc_sup, join_on);
  complib::CalculateAllUnboundedScores(gc_sub);
  complib::WriteShapefile(gc_sub,out_filename);

  return 0;
}