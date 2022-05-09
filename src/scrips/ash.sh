#!/bin/bash
clang -x assembler -target amdgcn-amd-amdhsa -mno-code-object-v3 -mcpu=gfx906 -c -o ${1}.o ${1}.s 
clang -target amdgcn-amd-amdhsa  ${1}.o -o ${1}.co 
