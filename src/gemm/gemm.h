#include "driver.h"
#include "constants.h"

void naive_dgemm(size_t m, size_t n, size_t k, double *alpha, const double *A, size_t lda, const double *B, 
    size_t ldb, double *beta, double *C, size_t ldc, int kernelId) {
 struct {
    //uint64_t tensor2dSizeC;
    //uint64_t tensor2dSizeA;
    //uint64_t tensor2dSizeB;
    double * dataC;
    const double * dataA;
    const double * dataB;
    double alpha;
    double beta;
    unsigned int strideC1J;  //ldc
    unsigned int strideA1L;  //lda
    unsigned int strideB1L;  //ldb
    unsigned int sizeI;
    unsigned int sizeJ;
    unsigned int sizeL;
    unsigned int gridDimX;
    unsigned int gridDimY;
  } args; 
  //args.tensor2dSizeC = m * n;
  //args.tensor2dSizeA = m * k;
  //args.tensor2dSizeA = N * K;
  //args.tensor2dSizeB = n * k;
  args.dataC = C;
  args.dataA = A;
  args.dataB = B;
  args.alpha = *alpha;
  args.beta = *beta;
  args.strideC1J = ldc;
  args.strideA1L = lda;
  args.strideB1L = ldb;
  args.sizeI = m;
  args.sizeJ = n;
  args.sizeL = k;
  args.gridDimX = m / naive_kernel_parameters[kernelId][0];
  args.gridDimY = n / naive_kernel_parameters[kernelId][1];

  //launchGemm(m, n, k, "./assembly/gemm-kernel.co", "Cijk_Ailk_Bjlk_DB_MT096x032x08_K1_NLCA03_NLCB01_TT06_04_USFGRO0_WG16_08_01", (void*)&args, sizeof(args), 96, 32, 128);
  launchGemm(m, n, k, naive_hsaco_files[kernelId], naive_kernels[kernelId], (void*)&args, sizeof(args), naive_kernel_parameters[kernelId][0], naive_kernel_parameters[kernelId][1], naive_kernel_parameters[kernelId][2]);

}

void dgemm_NT(size_t m, size_t n, size_t k, double *alpha, const double *A, size_t lda, const double *B, 
    size_t ldb, double *beta, double *C, size_t ldc, int kernelId) {
 struct {
    uint64_t tensor2dSizeC;
    uint64_t tensor2dSizeA;
    uint64_t tensor2dSizeB;
    double * dataC;
    const double * dataA;
    const double * dataB;
    double alpha;
    double beta;
    unsigned int offsetC;
    unsigned int offsetA;
    unsigned int offsetB;
    unsigned int strideC1J;
    unsigned int strideC2K;
    unsigned int strideA1L;
    unsigned int strideA2K;
    unsigned int strideB1L;
    unsigned int strideB2K;
    unsigned int sizeI;
    unsigned int sizeJ;
    unsigned int sizeK;
    unsigned int sizeL;
    unsigned int pad;
  } hipFunctionArgs;
  hipFunctionArgs.dataC = C;
  hipFunctionArgs.dataA = A;
  hipFunctionArgs.dataB = B;
  hipFunctionArgs.alpha = *alpha;
  hipFunctionArgs.beta = *beta;
  hipFunctionArgs.offsetC = 0; 
  hipFunctionArgs.offsetA = 0;
  hipFunctionArgs.offsetB = 0;
  hipFunctionArgs.strideC1J = ldc;
  hipFunctionArgs.strideC2K = m * n;
  hipFunctionArgs.strideA1L = lda;
  hipFunctionArgs.strideA2K = m * k;
  hipFunctionArgs.strideB1L = ldb;
  hipFunctionArgs.strideB2K = n * k;
  hipFunctionArgs.sizeI = m;
  hipFunctionArgs.sizeJ = n;
  hipFunctionArgs.sizeK = 1;
  hipFunctionArgs.sizeL = k;
  hipFunctionArgs.tensor2dSizeC = m * n;
  hipFunctionArgs.tensor2dSizeA = m * k;
  hipFunctionArgs.tensor2dSizeB = n * k;
  printf("%s\n", kernels[kernelId]);
  launchGemm(m, n, k, hsaco_files[kernelId], kernels[kernelId], (void*)&hipFunctionArgs, sizeof(hipFunctionArgs), kernel_parameters[kernelId][0], kernel_parameters[kernelId][1], kernel_parameters[kernelId][2]);

}

