#ifndef __COMMON_H__
#define __COMMON_H__

#define GPU_TIMER_START(elapased_time, event_start, event_stop) \
  do { \
      elapased_time = 0.0; \
      hipEventCreateWithFlags(&event_start, hipEventBlockingSync); \
      hipEventCreateWithFlags(&event_stop, hipEventBlockingSync); \
      hipEventRecord(event_start, NULL); \
  }while(0)

#define GPU_TIMER_END(elapased_time, event_start, event_stop) \
  do { \
      hipEventRecord(event_stop, NULL); \
      hipEventSynchronize(event_stop); \
      hipEventElapsedTime(&elapased_time, event_start, event_stop); \
      elapased_time /= 1000.0; \
  }while(0)

#define HIP_CHECK(status)                                                                          \
    if (status != hipSuccess) {                                                                    \
        std::cout << "Got Status: " << status << " at Line: " << __LINE__ << std::endl;            \
        exit(0);                                                                                   \
    }

#ifndef CHECK_ROCBLAS_ERROR
#define CHECK_ROCBLAS_ERROR(error)                              \
      if(error != rocblas_status_success)                         \
    {                                                           \
              fprintf(stderr, "rocBLAS error: ");                     \
              if(error == rocblas_status_invalid_handle)              \
                  fprintf(stderr, "rocblas_status_invalid_handle");   \
              if(error == rocblas_status_not_implemented)             \
                  fprintf(stderr, " rocblas_status_not_implemented"); \
              if(error == rocblas_status_invalid_pointer)             \
                  fprintf(stderr, "rocblas_status_invalid_pointer");  \
              if(error == rocblas_status_invalid_size)                \
                  fprintf(stderr, "rocblas_status_invalid_size");     \
              if(error == rocblas_status_memory_error)                \
                  fprintf(stderr, "rocblas_status_memory_error");     \
              if(error == rocblas_status_internal_error)              \
                  fprintf(stderr, "rocblas_status_internal_error");   \
              fprintf(stderr, "\n");                                  \
              exit(EXIT_FAILURE);                                     \
          }
#endif


#endif
