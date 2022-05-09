#include <algorithm>
#include "driver.h"

#define LEN 64

int main(){
  float *A, *B;
  hipDeviceptr_t Ad, Bd;

  // init host ptr
  A = new float[LEN];
  B = new float[LEN];

  for(size_t i=0; i<LEN; i++){
    A[i] = (i+1)*1.0f;
    B[i] = 0.0f;
  }

  // init device ptr
  hipMalloc((void**)&Ad, LEN*sizeof(float));
  hipMalloc((void**)&Bd, LEN*sizeof(float));

  hipMemcpyHtoD(Ad, A, LEN*sizeof(float));
  hipMemcpyHtoD(Bd, B, LEN*sizeof(float));

  struct{
    void *Ad;
    void *Bd;
  } args;
  args.Ad = Ad;
  args.Bd = Bd;

  launch<1,64>("test-kernel-gfx906.co", "hello_world", (void*)&args, sizeof(args));
  
  // validate 
  int errors = 0;
  hipMemcpyDtoH(B, Bd, LEN*sizeof(float));
  for(uint32_t i=0; i<LEN; ++i){
    if(A[i] != B[i]){ 
      errors ++;
      std::cout << A[i] << " " << B[i] << std::endl;
    }
  }
  std::cout << errors << " errors." << std::endl;
  return 0;
}
