HIP_PATH?= $(wildcard /opt/rocm/hip)
ifeq (,$(HIP_PATH))
	HIP_PATH=../../..
endif

HIPCC=$(HIP_PATH)/bin/hipcc
CLANG=$(HIP_PATH)/../llvm/bin/clang
LLVM_MC=$(HIP_PATH)/../llvm/bin/llvm-mc
CLANG_OFFLOAD_BUNDLER=$(HIP_PATH)/../llvm/bin/clang-offload-bundler

DCU_ARCH=gfx906
DCU_SRC=test-kernel.cpp
DCU_ASM=test-kernel-$(DCU_ARCH).s
DCU_OBJECT=test-kernel-$(DCU_ARCH).o
DCU_CO=test-kernel-$(DCU_ARCH).co

all: test sta ato otco

test: test.cc
	$(HIPCC) $< -o $@

sta: 
	$(HIPCC)  -c -S --cuda-device-only --offload-arch=$(DCU_ARCH) -o $(DCU_ASM) $(DCU_SRC)

ato:
	$(CLANG) -target amdgcn-amd-amdhsa -mcpu=gfx906 -c -o $(DCU_OBJECT) $(DCU_ASM)

otco:
	$(CLANG) -target amdgcn-amd-amdhsa  $(DCU_OBJECT) -o $(DCU_CO)

clean:
	rm -f test *.o *.co *.code *.out *.hsaco *.isa *.isabin *.adipose
