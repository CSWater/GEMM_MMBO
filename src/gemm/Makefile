all: asm test benchmark

test: test.cc constants.h driver.h
	hipcc $< -o $@  -L/opt/rocm/rocblas/lib -lrocblas -I /opt/rocm/include

benchmark: benchmark.cc
	hipcc $< -o $@  -L/opt/rocm/rocblas/lib -lrocblas -I /opt/rocm/include 

asm: ./assembly/naive_gemm_kernel_96_32_6_4.s ./assembly/naive_gemm_kernel_64_64_4_4.s
	./assembly/asm.sh ./assembly/naive_gemm_kernel_96_32_6_4 -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/naive_gemm_kernel_64_64_4_4 -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/naive_gemm_kernel_MT128x064x08_TT08_04_STT04_04_WG16_16_01 -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/naive_gemm_kernel_MT096x096x08_TT06_06_STT03_06_WG16_16_01 -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/naive_gemm_kernel_MT096x096x08_TT06_06_STT03_06_WG16_16_01_HALF_A_HALF_B -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/naive_gemm_kernel_MT096x096x08_TT06_06_STT02_06_WG16_16_01_HALF_A_HALF_B -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/naive_gemm_kernel_MT096x096x08_TT06_06_STT02_06_04_06_WG16_16_01_HALF_A_HALF_B -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/naive_gemm_kernel_MT096x096x08_TT06_06_STT03_06_WG16_16_01_HALF_A_HALF_B_ver2 -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/naive_gemm_kernel_MT096x096x08_TT06_06_STT03_06_WG16_16_01_HALF_A_HALF_B_ver3 -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/test_main_loop -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/test_dual -mcpu=gfx906 -mno-code-object-v3
	./assembly/asm.sh ./assembly/naive_gemm_kernel_MT096x096x08_TT06_06_STT03_06_WG16_16_01_NN -mcpu=gfx906 -mno-code-object-v3
	rm -f assembly/*.o


clean:
	rm -f test *.o 
