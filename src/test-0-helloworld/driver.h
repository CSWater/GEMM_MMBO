#ifndef DRIVERH
#define DRIVERH

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cstring>
#include "hip/hip_runtime.h"
#include "hip/hip_runtime_api.h"
#include "hip/hip_hcc.h"

#define HIP_CHECK(status)                                                                          \
    if (status != hipSuccess) {                                                                    \
        std::cout << "Got Status: " << status << " at Line: " << __LINE__ << std::endl;            \
        exit(0);                                                                                   \
    }

template<int blknum, int thdnum>
void launch(std::string path, std::string kernel_name, void* args, int argsize){
  printf("launch: <%d,%d>\n",blknum, thdnum);
  hipInit(0);
  //hipDevice_t device;
  //hipDeviceGet(&device, 0); // use the 0-th device
  //hipCtxCreate(&context, 0, device);

  void* config[] = {HIP_LAUNCH_PARAM_BUFFER_POINTER, args, HIP_LAUNCH_PARAM_BUFFER_SIZE, &argsize,
                      HIP_LAUNCH_PARAM_END};
  hipModule_t Module;
  hipFunction_t Function;
  HIP_CHECK(hipModuleLoad(&Module, path.c_str()));
  HIP_CHECK(hipModuleGetFunction(&Function, Module, kernel_name.c_str()));
  HIP_CHECK(hipHccModuleLaunchKernel(Function, blknum*thdnum, 1, 1, thdnum, 1, 1, 0, 0, NULL, (void**)&config));
}


#endif
