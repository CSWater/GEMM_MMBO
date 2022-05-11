#include <iostream>
#include <stdio.h>
const int NWG0I = 460;
const int NWG1J = 64;
const int WORK_GROUP_MAPPING = 8;

void map_wg(int wg0I, int wg1J) {
  int temp1 = wg0I;
  int temp2 = wg1J;
  //original map
  int wgSerial = wg0I + (wg1J % WORK_GROUP_MAPPING) * NWG0I;  // within block
  unsigned int block = wg1J / WORK_GROUP_MAPPING;
  unsigned int blockRemainder = (wg1J < NWG1J-(NWG1J % WORK_GROUP_MAPPING) ) ? 0 : NWG1J % WORK_GROUP_MAPPING;
  if ( blockRemainder == 0) {
    wg0I = wgSerial / 8;
    wg1J = wgSerial % 8 + block*WORK_GROUP_MAPPING;
  } else if ( blockRemainder == 1) {
    wg0I = wgSerial / 1;
    wg1J = wgSerial % 1 + block*WORK_GROUP_MAPPING;
  } else if ( blockRemainder == 2) {
    wg0I = wgSerial / 2;
    wg1J = wgSerial % 2 + block*WORK_GROUP_MAPPING;
  } else if ( blockRemainder == 3) {
    wg0I = wgSerial / 3;
    wg1J = wgSerial % 3 + block*WORK_GROUP_MAPPING;
  } else if ( blockRemainder == 4) {
    wg0I = wgSerial / 4;
    wg1J = wgSerial % 4 + block*WORK_GROUP_MAPPING;
  } else if ( blockRemainder == 5) {
    wg0I = wgSerial / 5;
    wg1J = wgSerial % 5 + block*WORK_GROUP_MAPPING;
  } else if ( blockRemainder == 6) {
    wg0I = wgSerial / 6;
    wg1J = wgSerial % 6 + block*WORK_GROUP_MAPPING;
  } else {
    wg0I = wgSerial / 7;
    wg1J = wgSerial % 7 + block*WORK_GROUP_MAPPING;
  }
   
  printf("(%d,%d)--->(%d, %d) in original map\n", temp1, temp2, wg0I, wg1J);
  int wgs = temp1 + (temp2 % WORK_GROUP_MAPPING) * NWG0I;
  int blo = temp2 / WORK_GROUP_MAPPING;
  int wg0 = wgs / 8;
  int wg1 = wgs % 8 + blo * WORK_GROUP_MAPPING;
  //printf("(%d,%d)--->(%d, %d) in new map\n", temp1, temp2, wg0, wg1);
  if(wg0 != wg0I | wg1 != wg1J) {
    printf("(%d,%d)--->(%d, %d) in original map\n", temp1, temp2, wg0I, wg1J);
    printf("(%d,%d)--->(%d, %d) in new map\n", temp1, temp2, wg0, wg1);
  }
  // un map
  
  int old_wg0I = (wg0 * 8 + (wg1 % 8) + (wg1 / 8) * 8 * NWG0I) % NWG0I;
  int old_wg1J = (wg0 * 8 + (wg1 % 8) + (wg1 / 8) * 8 * NWG0I) / NWG0I;
  if( old_wg0I != temp1 && old_wg1J != temp2 ) {
    printf("error. mapped:(%d, %d) ---- unmapped:(%d, %d)\n",  wg0, wg1, old_wg0I, old_wg1J);
  }

}

int main() {
  for(int j = 0; j < NWG1J; j++) {
    for(int i = 0; i < NWG0I; i++) {
      map_wg(i, j);
    }
  }
  //map_wg(0, 1);
  std::cout << "finished check\n";
  return 0;

}
