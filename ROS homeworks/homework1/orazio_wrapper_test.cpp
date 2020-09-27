#include "orazio_wrapper.h"
#include <iostream>
using namespace std;

int main(int argc, char** argv){
  OrazioWrapper orazio;
  orazio.connect(); // takes default parameter for serial port
  if (! orazio.isConnected()) {
    cerr << "fatal error, unable to connect" << endl;
    return 0;
  }
  while(1) {
    orazio.sync();
    float tv, rv;
    orazio.getVelocities(tv, rv);
    cerr << "E:" << orazio.currentEpoch() << " "
         << "veloc:[" << tv << ", " << rv << "]" << endl;
    
      
  }
    
}
