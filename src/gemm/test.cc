#include <algorithm>
#include <rocblas.h>
#include "driver.h"
#include "gemm.h"
#include "common.h"
//#define M 44160
//#define N 2048
//#define K 384
//#define LDA M
//#define LDB N   //for B is transposed
//#define LDC M
#define EPSILON 0.00001
#define ALPHA -1
#define BETA 0

int main(int argc, char *args[]){
  double *A, *B, *C, *C_0, *C_1, *C_2;
  const double *dA, *dB;
  double *dC, *dC_0, *dC_1, *dC_2;
  double alpha = -1, beta = 1;
  int M = 44160, N = 2048, K = 384;
  if(argc == 4) {
    M = atoi(args[1]);
    N = atoi(args[2]);
    K = atoi(args[3]);
    printf("M = %d, N = %d, K = %d\n", M, N, K);
  } else {
    printf("use default M = 44160 N = 2048 K = 384\n");
  }
  size_t lda = M, ldb = N, ldc = M;
  // malloc memory on host
  A = new double[lda * K];
  B = new double[ldb * K];
  C = new double[ldc * N];
  C_0 = new double[ldc * N];
  C_1 = new double[ldc * N];
  C_2 = new double[ldc * N];

  for(size_t i = 0; i < lda * K; i++){
    A[i] = rand() * 1.0 / RAND_MAX; //different A different eff, why
    //A[i] = rand() % 8 + 1;
  }
  for(size_t i = 0; i < ldb * K; i++) {
    B[i] = rand() * 1.0 / RAND_MAX; //different A different eff, why
    //B[i] = rand() % 8 + 1;
  }
  for(size_t i = 0; i < ldc * N; i++) {
    C[i] = rand() * 1.0 / RAND_MAX; //different A different eff, why
    //C[i] = 0;
  }
  hipSetDevice(1);
  //malloc memory on device
  HIP_CHECK(hipMalloc((void**)&dA,   lda * K * sizeof(double)) );   // size of A: M * K
  HIP_CHECK(hipMalloc((void**)&dB,   ldb * K * sizeof(double)) );   // size of B: N * K 
  HIP_CHECK(hipMalloc((void**)&dC,   ldc * N * sizeof(double)) );   // size of C: M * N
  HIP_CHECK(hipMalloc((void**)&dC_0, ldc * N * sizeof(double)) );   // size of C: M * N
  HIP_CHECK(hipMalloc((void**)&dC_1, ldc * N * sizeof(double)) );   // size of C: M * N
  HIP_CHECK(hipMalloc((void**)&dC_2, ldc * N * sizeof(double)) );   // size of C: M * N
  printf("%p\t%p\t%p\n", dA, dB, dC);
  //return 0;
  hipMemcpy((void *)dA,   A, lda * K * sizeof(double), hipMemcpyHostToDevice);
  hipMemcpy((void *)dB,   B, ldb * K * sizeof(double), hipMemcpyHostToDevice);
  hipMemcpy((void *)dC,   C, ldc * N * sizeof(double), hipMemcpyHostToDevice);
  hipMemcpy((void *)dC_0, C, ldc * N * sizeof(double), hipMemcpyHostToDevice);
  hipMemcpy((void *)dC_1, C, ldc * N * sizeof(double), hipMemcpyHostToDevice);
  hipMemcpy((void *)dC_2, C, ldc * N * sizeof(double), hipMemcpyHostToDevice);

  rocblas_handle handle;
  rocblas_create_handle(&handle);

  float elapased_time = 0.0f;
  double tflops = 0.0f;
  hipEvent_t event_start, event_stop;
  //dgemm_NT(M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC, ldc, 0);
  //GPU_TIMER_START(elapased_time, event_start, event_stop);
  //dgemm_NT(M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC_1, ldc, 0);
  //GPU_TIMER_END(elapased_time, event_start, event_stop);
  //tflops = 1e-12 * 2 * M * N * K / elapased_time;
  //printf("tensile_dgemm(NT): m, n, k, time, tflops, efficiency = %d, %d, %d, %.5f, %.5f, %.2f%%\n", M, N, K, elapased_time, tflops, tflops / 6.5 * 100);
  //hipMemcpy((void *)C_1, dC_1, M * N *sizeof(double), hipMemcpyDeviceToHost);

  //warm up
  naive_dgemm(M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC, ldc, 5);
  GPU_TIMER_START(elapased_time, event_start, event_stop);
  naive_dgemm(M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC_0, ldc, 5);
  GPU_TIMER_END(elapased_time, event_start, event_stop);
  tflops = 1e-12 * 2 * M * N * K / elapased_time;
  printf("naive_dgemm(NT): m, n, k, time, tflops, efficiency = %d, %d, %d, %.5f, %.5f, %.2f%%\n", M, N, K, elapased_time, tflops, tflops / 6.5 * 100);
  hipMemcpy((void *)C_0, dC_0, M * N *sizeof(double), hipMemcpyDeviceToHost);

  //naive_dgemm(M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC_2, ldc, 4);
  //hipMemcpy((void *)C_2, dC_2, M * N *sizeof(double), hipMemcpyDeviceToHost);

  
  CHECK_ROCBLAS_ERROR(rocblas_dgemm(handle, rocblas_operation_none, rocblas_operation_transpose, M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC, ldc) );
  GPU_TIMER_START(elapased_time, event_start, event_stop);
  rocblas_dgemm(handle, rocblas_operation_none, rocblas_operation_transpose, M, N, K, &alpha, dA, lda, dB, ldb, &beta, dC_2, ldc); 
  GPU_TIMER_END(elapased_time, event_start, event_stop);
  tflops = 2.0 * M * N * K * 1e-12 / elapased_time;
  printf("rocblas_dgemm(NT): m, n, k, time, tflops, efficiency = %d, %d, %d, %.5f, %.5f, %.2f%%\n", M, N, K, elapased_time, tflops, tflops / 6.5 * 100);
  hipMemcpy((void *)C_2, dC_2, M * N *sizeof(double), hipMemcpyDeviceToHost);

  //check result
  int error_flag_tensile = 0, error_flag_naive = 0;
  printf(" C[0][0]: %f;  C_0[0][0]: %f\n", C_2[0], C_0[0]);
  printf(" C[1][0]: %f;  C_0[1][0]: %f\n", C_2[1], C_0[1]);
  printf("C[0][16]: %f; C_0[0][16]: %f\n", C_2[16*ldc+0], C_0[16*ldc+0]);
  printf("C[1][16]: %f; C_0[1][16]: %f\n", C_2[16*ldc+1], C_0[16*ldc+1]);
  for(int i = 0; i < ldc; i++) {
    for(int j = 0; j < N; j++) {
      if( (C_2[i+j*ldc] - C_0[i+j*ldc] < -EPSILON) | (C_2[i+j*ldc] - C_0[i+j*ldc] > EPSILON) ) {
        //printf("(%d, %d), %f, %f\n", i, j, C_2[i+j*M], C_0[i+j*M]);
        error_flag_naive = 1; 
        //return 0;
      }
      if( (C_2[i+j*ldc] - C_1[i+j*ldc] < -EPSILON) | (C_2[i+j*ldc] - C_1[i+j*ldc] > EPSILON) ) {
        error_flag_tensile = 1; 
      }
    }
  }
  if(error_flag_tensile) {
    printf("error! result check for tensile not pass\n");
  }
  else {
    printf("result check for tensile passed\n"); 
  }
  if(error_flag_naive) {
    printf("error! result check for naive not pass\n");
  } else {
    printf("result check for naive passed\n"); 
  }

  hipFree((void *)dA);
  hipFree((void *)dB);
  hipFree((void *)dC);
  hipFree((void *)dC_0);
  hipFree((void *)dC_1);
  hipFree((void *)dC_2);
  delete A;
  delete B;
  delete C_0;
  delete C_1;
  delete C_2;

  return 0;
}
