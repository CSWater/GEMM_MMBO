#include <algorithm>
#include <rocblas.h>
#include "driver.h"
#include "gemm.h"
#include "common.h"

#define EPSILON 0.00001
#define ALPHA -1
#define BETA 0
#define NUM_KERNELS 23
#define NUM_NAIVE_KERNELS 3
#define NAIVE 0
#define TENSILE 1
#define ROCBLAS 2


int main(int argc, char *args[]){
  double *A, *B, *C, *C_0, *C_1, *C_2;
  const double *dA, *dB;
  double *dC;
  double alpha = -1, beta = 1;
  int M = 44160;
  int N = 2048;
  int K = 384;
  int dgemmType = -1;
  size_t lda = M, ldb = N, ldc = M;
  if(argc == 8) {
    dgemmType = atoi(args[1]);
    M = atoi(args[2]);
    N = atoi(args[3]);
    K = atoi(args[4]);
    lda = atoi(args[5]);
    ldb = atoi(args[6]);
    ldc = atoi(args[7]);
  }
  else {
    printf("wrong parameters\n");
  }
  // malloc memory on host
  A = new double[lda * K];
  B = new double[ldb * K];
  C = new double[ldc * N];
  C_0 = new double[ldc * N];

  for(size_t i = 0; i < lda * K; i++){
    A[i] = rand() * 1.0 / RAND_MAX; //different A different eff, why
  }
  for(size_t i = 0; i < ldb * K; i++) {
    B[i] = rand() * 1.0 / RAND_MAX; //different A different eff, why
  }
  for(size_t i = 0; i < ldc * N; i++) {
    C[i] = rand() * 1.0 / RAND_MAX; //different A different eff, why
  }
  hipSetDevice(2);

  //malloc memory on device
  hipMalloc((void**)&dA, lda * K * sizeof(double));   // size of A: lda * K
  hipMalloc((void**)&dB, ldb * K * sizeof(double));   // size of B: ldb * K 
  hipMalloc((void**)&dC, ldc * N * sizeof(double));   // size of C: ldc * N
  //init data
  hipMemcpy((void *)dA,   A, lda * K * sizeof(double), hipMemcpyHostToDevice);
  hipMemcpy((void *)dB,   B, ldb * K * sizeof(double), hipMemcpyHostToDevice);
  hipMemcpy((void *)dC,   C, ldc * N * sizeof(double), hipMemcpyHostToDevice);

  rocblas_handle handle;
  rocblas_create_handle(&handle);

  float elapased_time = 0.0f;
  double tflops = 0.0f;
  hipEvent_t event_start, event_stop;
  if(dgemmType == NAIVE) {
    double max_tflops = 0.0;
    int id = -1;
    for(int i = 0; i < NUM_NAIVE_KERNELS; i++) {
      //warm up
      naive_dgemm(M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC, ldc, 0);
      GPU_TIMER_START(elapased_time, event_start, event_stop);
      naive_dgemm(M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC, ldc, 0);
      GPU_TIMER_END(elapased_time, event_start, event_stop);
      tflops = 1e-12 * 2 * M * N * K / elapased_time;
      if(max_tflops < tflops) {
        id = i;
        max_tflops = tflops;
      }
      tflops = max_tflops;
      printf("naive_dgemm(NT): kernel, m, n, k, lda, ldb, time, tflops, efficiency = %d, %d, %d, %d, %d, %d, %.5f, %.5f, %.2f%%\n", id, M, N, K, (int)lda, (int)ldb, elapased_time, tflops, tflops / 6.5 * 100);
    }
  }
  else if(dgemmType == TENSILE) {
    double max_tflops = 0.0;
    int id = -1;
    for(int i = 0; i < NUM_KERNELS; i++) {
      dgemm_NT(M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC, ldc, i);
      //hipDeviceSynchronize();
      GPU_TIMER_START(elapased_time, event_start, event_stop);
      dgemm_NT(M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC, ldc, i);
      GPU_TIMER_END(elapased_time, event_start, event_stop);
      tflops = 1e-12 * 2 * M * N * K / elapased_time;
      if(max_tflops < tflops) {
        id = i;
        max_tflops = tflops;
      }
      //hipDeviceSynchronize();
    }
    tflops = max_tflops;
    printf("tensile_dgemm(NT): kernel, m, n, k, lda, ldb, time, tflops, efficiency = %d, %d, %d, %d, %d, %d, %.5f, %.5f, %.2f%%\n", id, M, N, K, (int)lda, (int)ldb, elapased_time, tflops, tflops / 6.5 * 100);

    //hipMemcpy((void *)C_1, dC_1, M * N *sizeof(double), hipMemcpyDeviceToHost);
  }
  else if(dgemmType == ROCBLAS) {
    rocblas_dgemm(handle, rocblas_operation_none, rocblas_operation_transpose, M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC, ldc); 
    GPU_TIMER_START(elapased_time, event_start, event_stop);
    rocblas_dgemm(handle, rocblas_operation_none, rocblas_operation_transpose, M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC, ldc); 
    GPU_TIMER_END(elapased_time, event_start, event_stop);
    tflops = 1e-12 * 2 * M * N * K / elapased_time;
    printf("rocblas_dgemm(NT): m, n, k, lda, ldb, time, tflops, efficiency = %d, %d, %d, %d, %d, %.5f, %.5f, %.2f%%\n", M, N, K, (int)lda, (int)ldb, elapased_time, tflops, tflops / 6.5 * 100);

    //hipMemcpy((void *)C_2, dC_2, M * N *sizeof(double), hipMemcpyDeviceToHost);
  }

  hipFree((void *)dA);
  hipFree((void *)dB);
  hipFree((void *)dC);
  delete A;
  delete B;
  delete C_0;

  return 0;
}
