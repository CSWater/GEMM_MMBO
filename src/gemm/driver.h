#ifndef __DRIVER_H__
#define __DRIVER_H__

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <cstring>
#include "hip/hip_runtime.h"
#include "hip/hip_runtime_api.h"
#include "hip/hip_hcc.h"
#include "common.h"


void launchGemm(size_t m, size_t n, size_t k, std::string path, std::string kernel_name, void* args, int argsize,
    int MT0I, int MT1J, int blockDimX){
  //check if m n k are valid
  //if (m % 96 != 0) {
  //  printf("m must be a multiple of 96!\n");
  //  return;
  //} else if( n % 32 != 0) {
  //  printf("n must be a multiple of 32!\n");
  //  return;
  //} else if(k % 16 != 0) {
  //  printf("k must be a multiple of 16!\n");
  //  return;
  //}

  hipInit(0);
  //hipDevice_t device;
  //hipDeviceGet(&device, 0); // use the 0-th device
  //hipCtxCreate(&context, 0, device);

  void* config[] = {HIP_LAUNCH_PARAM_BUFFER_POINTER, args, HIP_LAUNCH_PARAM_BUFFER_SIZE, &argsize,
                      HIP_LAUNCH_PARAM_END};
  hipModule_t Module;
  hipFunction_t Function;
#ifdef DEBUG
  printf("%s\n", path.c_str() );
#endif
  HIP_CHECK(hipModuleLoad(&Module, path.c_str()));
#ifdef DEBUG
  printf("%s\n", kernel_name.c_str());
#endif
  HIP_CHECK(hipModuleGetFunction(&Function, Module, kernel_name.c_str()));
  //int blockDimX = 128;
  //int macroTile0 = 96;
  //int macroTile1 = 32;
  int totalWorkGroups0 = m / MT0I;
  int totalWorkGroups1 = n / MT1J;
#ifdef DEBUG
  printf("%d, %d, %d, %d, %d, %d\n", totalWorkGroups0 * blockDimX,
      totalWorkGroups1,
      1, blockDimX, 1, 1);
#endif
  HIP_CHECK(hipHccModuleLaunchKernel(Function, 
                                     totalWorkGroups0 * blockDimX, totalWorkGroups1, 1, 
                                     blockDimX, 1, 1,
                                     0, 0, NULL, (void**)config));
  //printf("%d, %d, %d, %d, %d, %d\n", totalWorkGroups0 * blockDimX, totalWorkGroups1, 1, blockDimX, 1, 1);
}


#endif
