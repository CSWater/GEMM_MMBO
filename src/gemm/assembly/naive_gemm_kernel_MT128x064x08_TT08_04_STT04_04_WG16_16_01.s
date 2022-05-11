
/******************************************/
/* Function Prefix                        */
/******************************************/

/******************************************/
/* Begin Kernel                           */
/******************************************/
.hsa_code_object_version 2,0
.hsa_code_object_isa 9, 0, 6, "AMD", "AMDGPU" 
.text
.p2align 8
.amdgpu_hsa_kernel naive_gemm_kernel_MT128x064x08_TT08_04_STT04_04_WG16_16_01
naive_gemm_kernel_MT128x064x08_TT08_04_STT04_04_WG16_16_01:
.amd_kernel_code_t
  is_ptr64 = 1
  enable_sgpr_kernarg_segment_ptr = 1
  kernarg_segment_byte_size = 72 // bytes of kern args
  workitem_vgpr_count = 126 // vgprs
  wavefront_sgpr_count = 78 // sgprs
  compute_pgm_rsrc1_vgprs = 31 // floor((113-1)/4)
  compute_pgm_rsrc1_sgprs = 10 // floor((78-1)/8)
  compute_pgm_rsrc2_tidig_comp_cnt = 0 // 1D wg
  compute_pgm_rsrc2_tgid_x_en = 1 // wg.x
  compute_pgm_rsrc2_tgid_y_en = 1 // wg.y
  compute_pgm_rsrc2_tgid_z_en = 1 // wg.z
  workgroup_group_segment_byte_size = 24576 // lds bytes (128+64)*8*8*2
  compute_pgm_rsrc2_user_sgpr = 2 // vcc
  kernarg_segment_alignment = 4
  group_segment_alignment = 4
  private_segment_alignment = 4
.end_amd_kernel_code_t

/******************************************/
/* Optimizations and Config:              */
/******************************************/
/* ThreadTile=8 x 4 */
/* VectorWidth=2 */
/* GlobalLoadVectorWidthA=2, GlobalLoadVectorWidthB=2 */
/* DirectToLdsA=False */
/* DirectToLdsB=False */
/* UseSgprForGRO=False */
/* ThreadsPerWorkGroup=256 */
/* MicroBlock=128*64 */
/* Each Thread:
    - load A from GDS to LDS: 128*8/256 = 4 (double) = 2 buffer_load_dwordx4/ds_write_b128. require 2*4=8 regs; (vgrpG2LA)
    - load B from GDS to LDS: 64*8/256 = 2 (double) = 1 buffer_load_dwordx4/ds_write_b128. require 1*4=4 regs; (vgprG2LB)
    - load A from LDS: 8/2=4 (double) = 2 ds_read_b128. require 4*2 regs => half double regs 4*2*2 = 16 regs; (vgprValueA_X0_I0/vgprValueA_X1_I0 each 8)
    - load B from LDS: 4 (double) = 2 ds_read_b128. require 4*2 regs => double regs 4*2*2 = 16 regs; (vgprValueB_X0_I0/vgprValueB_X1_I0 each 8)
    - load/store C from/to GDS: 8x4=32 (double) = 16 buffer_load_dwordx4/buffer_store_dwordx4. require 32*2=64 regs (vgprValuC)
*/
/******************************************/
/* VGPR Assignments                       */
/******************************************/
.set vgprValuC, 0 // 64
.set vgprValuA_X0_I0, 64 // 8
.set vgprValuA_X1_I0, 72 // 8
.set vgprG2LA, 80 // 8
.set vgprValuB_X0_I0, 88 // 8
.set vgprValuB_X1_I0, 96 // 8
.set vgprG2LB, 104 // 4
.set vgprLocalReadAddrA, 108 // 1
.set vgprLocalReadAddrB, 109 // 1
.set vgprLocalWriteAddrA, 110 // 1
.set vgprLocalWriteAddrB, 111 // 1
.set vgprGlobalReadOffsetA_0_0_0_0, 112 // 1
.set vgprGlobalReadOffsetB_0_0_0_0, 113 // 1
.set vgprGlobalWriteOffsetC_0_0_0, 114 // 1
.set vgprGlobalWriteOffsetC_0_0_1, 115 // 1
.set vgprGlobalWriteOffsetC_0_1_0, 116 // 1
.set vgprGlobalWriteOffsetC_0_1_1, 117 // 1
.set vgprSerial_Mod_32_Mul_2, 118 // 1
.set vgprSerial_Div_32, 119 // 1
.set vgprSerial_Mod_16_Mul_2, 120 // 1
.set vgprSerial_Div_16, 121 // 1
.set vgprSerial, 122 // 1
.set vtmp1, 123 // 1
.set vtmp2, 124 // 1
.set vtmp3, 125 // 1
/* max VGPR=126 */

/******************************************/
/* SGPR Assignments                       */
/******************************************/
.set sgprKernArgAddress, 0
.set sgprBlockIdX, 2
.set sgprBlockIdY, 3
.set sgprBlockIdZ, 4
.set sgprGridDimX, 5
.set sgprGridDimY, 6
.set sgprSrdA, 8
.set sgprSrdB, 12
.set sgprSrdC, 16
.set sgprTensor2dSizeC, 20
.set sgprTensor2dSizeA, 22
.set sgprTensor2dSizeB, 24
.set sgprAddressC, 26
.set sgprAddressA, 28
.set sgprAddressB, 30
.set sgprAlpha, 32
.set sgprBeta, 34
.set sgprLdc, 36
.set sgprLda, 37
.set sgprLdb, 38
.set sgprSizesI, 39
.set sgprSizesJ, 40
.set sgprSizesL, 41
.set sgprSrdShadowLimitA, 42
.set sgprSrdShadowLimitB, 44
.set sgprGlobalReadIncsA, 46
.set sgprGlobalReadIncsB, 47
.set sgprLoopCounters, 48
.set stmp1, 60
.set stmp2, 61
.set stmp3, 62
.set sLow, 64
.set sHigh, 65
/* max SGPR=78 */

/******************************************/
/* 2GB limit - set offsets to -1 to exceed this and clamp */
/******************************************/
.set BufferLimit, 0x80000000

/******************************************/
/* Bits 127:96 of SRD.  Set DataFormat = 32 bit */
/******************************************/
.set Srd127_96, 0x0020000

/******************************************/
/* 6x4 thread-tile                        */
/******************************************/
.macro MAC_4x4_X00_FMA_F64 i,j
v_fma_f64 v[vgprValuC+(\i+\j*4)*2:vgprValuC+(\i+\j*4)*2+1], v[vgprValuA_X0_I0+\i*2:vgprValuA_X0_I0+\i*2+1], v[vgprValuB_X0_I0+\j*2:vgprValuB_X0_I0+\j*2+1], v[vgprValuC+(\i+\j*4)*2:vgprValuC+(\i+\j*4)*2+1]
.endm

.macro MAC_4x4_X10_FMA_F64 i,j
v_fma_f64 v[vgprValuC+32+(\i+\j*4)*2:vgprValuC+32+(\i+\j*4)*2+1], v[vgprValuA_X1_I0+\i*2:vgprValuA_X1_I0+\i*2+1], v[vgprValuB_X0_I0+\j*2:vgprValuB_X0_I0+\j*2+1], v[vgprValuC+32+(\i+\j*4)*2:vgprValuC+32+(\i+\j*4)*2+1]
.endm

.macro MAC_4x4_X01_FMA_F64 i,j
v_fma_f64 v[vgprValuC+(\i+\j*4)*2:vgprValuC+(\i+\j*4)*2+1], v[vgprValuA_X0_I0+\i*2:vgprValuA_X0_I0+\i*2+1], v[vgprValuB_X1_I0+\j*2:vgprValuB_X1_I0+\j*2+1], v[vgprValuC+(\i+\j*4)*2:vgprValuC+(\i+\j*4)*2+1]
.endm

.macro MAC_4x4_X11_FMA_F64 i,j
v_fma_f64 v[vgprValuC+32+(\i+\j*4)*2:vgprValuC+32+(\i+\j*4)*2+1], v[vgprValuA_X1_I0+\i*2:vgprValuA_X1_I0+\i*2+1], v[vgprValuB_X1_I0+\j*2:vgprValuB_X1_I0+\j*2+1], v[vgprValuC+32+(\i+\j*4)*2:vgprValuC+32+(\i+\j*4)*2+1]
.endm



//vgprValuA[8] vgprValueB[8] = > vgprValueC[32]
.macro MAC_4x4_X00
MAC_4x4_X00_FMA_F64 0 0
s_setprio 1 // Raise priority while processing macs 
MAC_4x4_X00_FMA_F64 1 0
MAC_4x4_X00_FMA_F64 2 0
MAC_4x4_X00_FMA_F64 3 0
MAC_4x4_X00_FMA_F64 0 1
MAC_4x4_X00_FMA_F64 1 1
MAC_4x4_X00_FMA_F64 2 1
MAC_4x4_X00_FMA_F64 3 1
MAC_4x4_X00_FMA_F64 0 2
MAC_4x4_X00_FMA_F64 1 2
MAC_4x4_X00_FMA_F64 2 2
MAC_4x4_X00_FMA_F64 3 2
MAC_4x4_X00_FMA_F64 0 3
MAC_4x4_X00_FMA_F64 1 3
MAC_4x4_X00_FMA_F64 2 3
MAC_4x4_X00_FMA_F64 3 3
s_setprio 0 // Reset priority after macs 
.endm

.macro MAC_4x4_X10
MAC_4x4_X10_FMA_F64 0 0
s_setprio 1 // Raise priority while processing macs 
MAC_4x4_X10_FMA_F64 1 0
MAC_4x4_X10_FMA_F64 2 0
MAC_4x4_X10_FMA_F64 3 0
MAC_4x4_X10_FMA_F64 0 1
MAC_4x4_X10_FMA_F64 1 1
MAC_4x4_X10_FMA_F64 2 1
MAC_4x4_X10_FMA_F64 3 1
MAC_4x4_X10_FMA_F64 0 2
MAC_4x4_X10_FMA_F64 1 2
MAC_4x4_X10_FMA_F64 2 2
MAC_4x4_X10_FMA_F64 3 2
MAC_4x4_X10_FMA_F64 0 3
MAC_4x4_X10_FMA_F64 1 3
MAC_4x4_X10_FMA_F64 2 3
MAC_4x4_X10_FMA_F64 3 3
s_setprio 0 // Reset priority after macs 
.endm

.macro MAC_4x4_X01
MAC_4x4_X01_FMA_F64 0 0
s_setprio 1 // Raise priority while processing macs 
MAC_4x4_X01_FMA_F64 1 0
MAC_4x4_X01_FMA_F64 2 0
MAC_4x4_X01_FMA_F64 3 0
MAC_4x4_X01_FMA_F64 0 1
MAC_4x4_X01_FMA_F64 1 1
MAC_4x4_X01_FMA_F64 2 1
MAC_4x4_X01_FMA_F64 3 1
MAC_4x4_X01_FMA_F64 0 2
MAC_4x4_X01_FMA_F64 1 2
MAC_4x4_X01_FMA_F64 2 2
MAC_4x4_X01_FMA_F64 3 2
MAC_4x4_X01_FMA_F64 0 3
MAC_4x4_X01_FMA_F64 1 3
MAC_4x4_X01_FMA_F64 2 3
MAC_4x4_X01_FMA_F64 3 3
s_setprio 0 // Reset priority after macs 
.endm

.macro MAC_4x4_X11
MAC_4x4_X11_FMA_F64 0 0
s_setprio 1 // Raise priority while processing macs 
MAC_4x4_X11_FMA_F64 1 0
MAC_4x4_X11_FMA_F64 2 0
MAC_4x4_X11_FMA_F64 3 0
MAC_4x4_X11_FMA_F64 0 1
MAC_4x4_X11_FMA_F64 1 1
MAC_4x4_X11_FMA_F64 2 1
MAC_4x4_X11_FMA_F64 3 1
MAC_4x4_X11_FMA_F64 0 2
MAC_4x4_X11_FMA_F64 1 2
MAC_4x4_X11_FMA_F64 2 2
MAC_4x4_X11_FMA_F64 3 2
MAC_4x4_X11_FMA_F64 0 3
MAC_4x4_X11_FMA_F64 1 3
MAC_4x4_X11_FMA_F64 2 3
MAC_4x4_X11_FMA_F64 3 3
s_setprio 0 // Reset priority after macs 
.endm

.macro GET_INVERT_OF_SIGN
v_xor_b32 v[vgprValuC+1 ], 0x80000000, v[vgprValuC+1 ]
v_xor_b32 v[vgprValuC+3 ], 0x80000000, v[vgprValuC+3 ]
v_xor_b32 v[vgprValuC+5 ], 0x80000000, v[vgprValuC+5 ]
v_xor_b32 v[vgprValuC+7 ], 0x80000000, v[vgprValuC+7 ]
v_xor_b32 v[vgprValuC+9 ], 0x80000000, v[vgprValuC+9 ]
v_xor_b32 v[vgprValuC+11], 0x80000000, v[vgprValuC+11]
v_xor_b32 v[vgprValuC+13], 0x80000000, v[vgprValuC+13]
v_xor_b32 v[vgprValuC+15], 0x80000000, v[vgprValuC+15]
v_xor_b32 v[vgprValuC+17], 0x80000000, v[vgprValuC+17]
v_xor_b32 v[vgprValuC+19], 0x80000000, v[vgprValuC+19]
v_xor_b32 v[vgprValuC+21], 0x80000000, v[vgprValuC+21]
v_xor_b32 v[vgprValuC+23], 0x80000000, v[vgprValuC+23]
v_xor_b32 v[vgprValuC+25], 0x80000000, v[vgprValuC+25]
v_xor_b32 v[vgprValuC+27], 0x80000000, v[vgprValuC+27]
v_xor_b32 v[vgprValuC+29], 0x80000000, v[vgprValuC+29]
v_xor_b32 v[vgprValuC+31], 0x80000000, v[vgprValuC+31]
v_xor_b32 v[vgprValuC+33], 0x80000000, v[vgprValuC+33]
v_xor_b32 v[vgprValuC+35], 0x80000000, v[vgprValuC+35]
v_xor_b32 v[vgprValuC+37], 0x80000000, v[vgprValuC+37]
v_xor_b32 v[vgprValuC+39], 0x80000000, v[vgprValuC+39]
v_xor_b32 v[vgprValuC+41], 0x80000000, v[vgprValuC+41]
v_xor_b32 v[vgprValuC+43], 0x80000000, v[vgprValuC+43]
v_xor_b32 v[vgprValuC+45], 0x80000000, v[vgprValuC+45]
v_xor_b32 v[vgprValuC+47], 0x80000000, v[vgprValuC+47]
v_xor_b32 v[vgprValuC+49], 0x80000000, v[vgprValuC+49]
v_xor_b32 v[vgprValuC+51], 0x80000000, v[vgprValuC+51]
v_xor_b32 v[vgprValuC+53], 0x80000000, v[vgprValuC+53]
v_xor_b32 v[vgprValuC+55], 0x80000000, v[vgprValuC+55]
v_xor_b32 v[vgprValuC+57], 0x80000000, v[vgprValuC+57]
v_xor_b32 v[vgprValuC+59], 0x80000000, v[vgprValuC+59]
v_xor_b32 v[vgprValuC+61], 0x80000000, v[vgprValuC+61]
v_xor_b32 v[vgprValuC+63], 0x80000000, v[vgprValuC+63]
.endm

/* global read inc a and b */
.macro  GLOBAL_READ_INC_A_AND_B
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s[sgprGlobalReadIncsA+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0        // gra SRD += inc(upper)
//s_sub_u32 s[sgprSrdShadowLimitA+0], s[sgprSrdShadowLimitA+0], s[sgprGlobalReadIncsA+0] // limit -= inc)
//s_subb_u32 s[sgprSrdShadowLimitA+1], s[sgprSrdShadowLimitA+1], 0 // limit -= inc)
//s_cmp_eq_u32 s[sgprSrdShadowLimitA+1], 0           // are we within 2^32?
//s_cmov_b32 s[sgprSrdA+2], s[sgprSrdShadowLimitA+0] // Move shadow to real if we are within 2^32
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s[sgprGlobalReadIncsB+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0        // gra SRD += inc(upper)
//s_sub_u32 s[sgprSrdShadowLimitB+0], s[sgprSrdShadowLimitB+0], s[sgprGlobalReadIncsB+0] // limit -= inc)
//s_subb_u32 s[sgprSrdShadowLimitB+1], s[sgprSrdShadowLimitB+1], 0 // limit -= inc)
//s_cmp_eq_u32 s[sgprSrdShadowLimitB+1], 0           // are we within 2^32?
//s_cmov_b32 s[sgprSrdB+2], s[sgprSrdShadowLimitB+0] // Move shadow to real if we are within 2^32
.endm

/*************************************************************/
/* Load Kernel Args                                          */
/*************************************************************/
s_load_dwordx2 s[sgprAddressC:sgprAddressC+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x0 // load addr c
s_load_dwordx2 s[sgprAddressA:sgprAddressA+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x8 // load addr a
s_load_dwordx2 s[sgprAddressB:sgprAddressB+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x10 // load addr b
s_load_dwordx2 s[sgprAlpha:sgprAlpha+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x18 // load alpha
s_load_dwordx2 s[sgprBeta:sgprBeta+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x20 // load beta
s_load_dword s[sgprLdc], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x28 // load ldc
s_load_dword s[sgprLda], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x2c // load lda
s_load_dword s[sgprLdb], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x30 // load ldb
s_load_dword s[sgprSizesI], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x34 // load m
s_load_dword s[sgprSizesJ], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x38 // load n
s_load_dword s[sgprSizesL], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x3c // load k
s_load_dword s[sgprGridDimX], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x40  // load sgprGridDimX
s_load_dword s[sgprGridDimY], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x44  // load sgprGridDimY

/************************************************************/
/* Allocate Resources    threadIdx is in v0                 */
/************************************************************/
s_mov_b32 m0, 0x6000                                                          // LDS clamp at 24576 bytes
v_and_b32 v[vgprSerial_Mod_32_Mul_2], 0x1f, v0                                 // serial % 32
v_lshlrev_b32 v[vgprSerial_Mod_32_Mul_2], 0x1, v[vgprSerial_Mod_32_Mul_2]     // (serial%32)*2
v_lshrrev_b32 v[vgprSerial_Div_32], 0x5, v0                                   // serial / 32

v_and_b32 v[vgprSerial_Mod_16_Mul_2], 0xf, v0                                 // serial % 16
v_lshlrev_b32 v[vgprSerial_Mod_16_Mul_2], 0x1, v[vgprSerial_Mod_16_Mul_2]     // (serial%16)*2
v_lshrrev_b32 v[vgprSerial_Div_16], 0x4, v0                                   // serial / 16

s_waitcnt lgkmcnt(0)                               // wait for 88 bytes of kern args  

/**********************************************************
/* because N === 2048, so block mapping is simplified into:
/* uint64_t wgSerial = wg0I + (wg1J % WGM) * nwg0I;
/* unsigned int block = wg1J / WGM;
/* wg0I = wgSerial / 8;
/* wg1J = wgSerial % 8 + block * WGM;
/* with WGM = 8, nwg0I in register sgprGridDimX
/* wg0I in register sgprBlockIdX, wg1J in register sgprBlockIdY
/* After block mapping:
/*   mapped-wgOI in sgprBlockIdX, mapped-wg1J in sgprBlockIdY
/* instruction hint:
/*   v_mul_lo_u32 D.u = S0.u * S1.u
/**********************************************************/
s_and_b32 s[stmp1], s[sgprBlockIdY], 0x7              // wg1J % WGM
s_mul_i32 s[stmp2], s[stmp1], s[sgprGridDimX]         // (wg1J % WGM) * nwg0I
s_add_u32 s[stmp3], s[stmp2], s[sgprBlockIdX]         // wgSerial = wg0I + (wg1J % WGM) * nwg0I
s_lshr_b32 s[stmp1], s[sgprBlockIdY], 0x3             // block = wg1J / WGM
s_lshr_b32 s[sgprBlockIdX], s[stmp3], 0x3             // mapped_wg0I = wgSerial / 8
s_and_b32 s[sgprBlockIdY], s[stmp3], 0x7              // wgSerial % 8
s_lshl_b32 s[stmp1], s[stmp1], 0x3                    // block * WGM
s_add_u32 s[sgprBlockIdY], s[sgprBlockIdY], s[stmp1]  // mapped_wg1J = wgSerial % 8 + block * WGM 


/********************************************************
/* SRD_base_A: the address of the block to be read in A
/*   sgprSrdA = sgprAddressA + wg0I * MT0I
/*
/* SRD_base_B: the address of the block to be read in B
/*   sgprSrdB = sgrpAddressB + wg1J * MT1J
/*
/* SRD_base_c: the address of the block to be calculated of C
/*   sgprSrdC = sgprAddressC + wg0I*MT0I + wg1J*MT1J*LDC
/*   globalC0I = (wg0I)*MT0I + (serial % SG0I)*VECTOR_WIDTH
/*   globalC1J = (wg1J)*MT1J + (serial / SG0I)*VECTOR_WIDTH
/* with SG0I = 16
/*
/* instruction hint:
/*   s_mul_hi_u32 D.u = (S0.u * S1.u) >> 32
/*   s_mul_i32 D.i = S0.i * S1.i
/********************************************************/

s_mul_i32 s[sLow], s[sgprBlockIdX], 0x80                    // wg0I * MT0I, within 2^32
//s_sub_u32 s[sgprSrdShadowLimitA+0], s[sgprTensor2dSizeA], s[sLow] // sub tileStart
//s_subb_u32 s[sgprSrdShadowLimitA+1], s[sgprTensor2dSizeA+1], s[sHigh] // sub tileStart ===0
//s_lshl_b64 s[sgprSrdShadowLimitA:sgprSrdShadowLimitA+1], s[sgprSrdShadowLimitA:sgprSrdShadowLimitA+1], 0x3 // set limit to use bytes
//s_cmp_eq_u32 s[sgprSrdShadowLimitA+1], 0x0           // are we within 2^32? ===1
//s_cselect_b32 s[sgprSrdA+2], s[sgprSrdShadowLimitA+0], BufferLimit // Move shadow to real if we are within 2^32 ===real
s_mov_b32 s[sgprSrdA+2], BufferLimit
s_lshl_b32 s[sLow], s[sLow], 0x3                                  // tileStart *= BPE, in bytes
s_add_u32 s[sgprSrdA+0], s[sgprAddressA+0], s[sLow]               // SRD_base(A) = Address + tileStart
s_addc_u32 s[sgprSrdA+1], s[sgprAddressA+1], 0                    // SRD_base(A) = Address + tileStart
s_mov_b32 s[sgprSrdA+3], Srd127_96                                // Set bits 127_96 in SRD
s_add_u32 s[sgprSrdC+0], s[sgprAddressC+0], s[sLow]               // SRD_base(C) = Address + tileStart(in dimension m)
s_addc_u32 s[sgprSrdC+1], s[sgprAddressC+1], 0                    // SRD_base(C) = Address + tileStart(in dimension m)
s_mov_b32 s[sgprSrdC+2], BufferLimit
s_mov_b32 s[sgprSrdC+3], Srd127_96                                // Set bits 127_96 in SRD

s_mul_i32 s[sLow], s[sgprBlockIdY], 0x40                          // wg1J * MT1J low 32 bit
//s_sub_u32 s[sgprSrdShadowLimitB+0], s[sgprTensor2dSizeB], s[sLow] //important value!, not correctly set will lead to memory error
//s_subb_u32 s[sgprSrdShadowLimitB+1], s[sgprTensor2dSizeB+1], s[sHigh] 
//s_lshl_b64 s[sgprSrdShadowLimitB:sgprSrdShadowLimitB+1], s[sgprSrdShadowLimitB:sgprSrdShadowLimitB+1], 0x3
//s_cmp_eq_u32 s[sgprSrdShadowLimitB+1], 0x0                   // are we within 2^32?
//s_cselect_b32 s[sgprSrdB+2], s[sgprSrdShadowLimitB+0], BufferLimit // Move shadow to real if we are within 2^32
s_mov_b32 s[sgprSrdB+2], BufferLimit
s_lshl_b32 s[sLow], s[sLow], 0x3
s_add_u32 s[sgprSrdB+0], s[sgprAddressB+0], s[sLow]          // SRD_base(B) = Address + tileStart  
s_addc_u32 s[sgprSrdB+1], s[sgprAddressB+1], 0               // SRD_base(B) = Address + tileStart
s_mov_b32 s[sgprSrdB+3], Srd127_96                           // Set bits 127_96 in SRD

s_mul_i32 s[sLow], s[sgprBlockIdY], 0x40                     // wg1J * MT1J, within 2^32
s_mul_i32 s[sLow], s[sLow], s[sgprLdc]                       // MT1J * 32 * LDC(low 32 bits)
s_lshl_b32 s[sLow], s[sLow], 0x3
s_add_u32 s[sgprSrdC+0], s[sgprSrdC+0], s[sLow]              // add lo to SRD_base(C)
s_addc_u32 s[sgprSrdC+1], s[sgprSrdC+1], 0                   // add hi to SRD_base(C)

/*********************************************************
/* global read addresses: tile offset assignment a
/* global read addresses: tile offset assignment b
/* globalReadOffsetA0I = (serial%LVCA)*GLVWA + (wg0I)*MT0I;
/* globalReadOffsetB1J = (serial%LVCB)*GLVWB + (wg1J)*MT1J;
/* with LVCA = LVCB = 16, GLVWA = GLVWB = 2
/* note (wg0I*MT0I) has been added to SRD
/* note (wg1J*MT1J) has been added to SRD
/* so globalReadOffsetA0I = globalReadOffsetA1J = (serial % 16) * 2
/*
/* global read addresses: unroll assignment a
/* global read addresses: unroll assignment b
/* globalReadOffsetAL = (serial/LVCA);
/* globalReadOffsetBL = (serial/LVCB);
/* so globalReadOffsetAL = globalReadOffsetBL = serial / 16
/*
/* globalReadOffsetA_0_0_0_0 
/*   = globalReadOffsetA0I + 0 * LSCA + globalReadOffsetAL * LDA 
/* globalReadOffsetA_1_0_0_0 
/*   = globalReadOffsetA0I + 1 * LSCA + globalReadOffsetAL * LDA 
/*   = globalReadOffsetA_0_0_0_0 + 1 * LSCA
/* globalReadOffsetA_2_0_0_0 
/*   = globalReadOffsetA0I + 2 * LSCA + globalReadOffsetAL * LDA 
/*   = globalReadOffsetA_0_0_0_0 + 2 * LSCA
/* globalReadOffsetB_0_0_0_0 
/*   = globalReadOffsetB1J + 0 * LSCB + globalReadOffsetBL * LDB
/* with LSCA = LSCB = 32, BPE = 8
/*
/* global read and write address index in block:
/*   globalReadOffsetC  = (serial % SG0I)*VECTOR_WIDTH + (serial / SG0I)*VECTOR_WIDTH * LDC
/**********************************************************/
/**********************************************************
/*   v_and_b32 v[vtmp1], 0xe, v[]gprSerial]                      
/*   no one can be more silly than me!!!!!!!!!!!!
/**********************************************************/
v_mul_lo_u32 v[vtmp1], s[sgprLda], v[vgprSerial_Div_32]
v_mul_lo_u32 v[vtmp2], s[sgprLdb], v[vgprSerial_Div_32]
v_add_lshl_u32 v[vgprGlobalReadOffsetA_0_0_0_0], v[vtmp1], v[vgprSerial_Mod_32_Mul_2], 0x3 //globalReadOffsetA_0_0_0_0, in bytes
v_add_lshl_u32 v[vgprGlobalReadOffsetB_0_0_0_0], v[vtmp2], v[vgprSerial_Mod_32_Mul_2], 0x3 //globalReadOffsetB_0_0_0_0, in bytes


/******************************************************************
/* Load and Write C offset:
/* there are 8(4*2) 2*2 sub_sub blocks
/* GlobalWriteOffsetC_0_0_0 = (serial / SG0I) * LDC + (serial % SG0I)
/* GlobalWriteOffsetC_0_0_1 = GlobalWriteOffsetC_0_0_0 + LDC
/* GlobalWriteOffsetC_0_1_0 = GlobalWriteOffsetC_0_0_0 + SG0I * LDC
/* GlobalWriteOffsetC_0_1_1 = GlobalWriteOffsetC_0_0_1 + SG0I * LDC
/* with SG0I = 32
/******************************************************************/
s_lshl_b32 s[stmp1], s[sgprLdc], 0x3  // LDC*BPE, ldc in bytes
s_lshl_b32 s[stmp2], s[stmp1],   0x5  // LDC * SG0I * BPE
v_lshlrev_b32 v[vtmp2], 0x1, v[vgprSerial_Div_16]
v_mul_lo_u32 v[vgprGlobalWriteOffsetC_0_0_0], s[sgprLdc], v[vtmp2]
v_add_lshl_u32 v[vgprGlobalWriteOffsetC_0_0_0], v[vgprGlobalWriteOffsetC_0_0_0], v[vgprSerial_Mod_16_Mul_2], 0x3  // offsets in bytes
v_add_u32 v[vgprGlobalWriteOffsetC_0_0_1], s[stmp1], v[vgprGlobalWriteOffsetC_0_0_0] 
v_add_u32 v[vgprGlobalWriteOffsetC_0_1_0], s[stmp2], v[vgprGlobalWriteOffsetC_0_0_0]
v_add_u32 v[vgprGlobalWriteOffsetC_0_1_1], s[stmp2], v[vgprGlobalWriteOffsetC_0_0_1]


/***********************************************************
/* global read a and b
/* global read address of a:
/*   SRD_base(A) + vgprGlobalReadOffsetA_0_0_0_0
/*   SRD_base(A) + vgprGlobalReadOffsetA_1_0_0_0
/*   SRD_base(A) + vgprGlobalReadOffsetA_2_0_0_0
/* global read address of b:
/*   SRD_base(B) + vgprGlobalReadOffsetB_0_0_0_0
/************************************************************/
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+3],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0, 
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+7],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x200
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+3],  v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0
//s_waitcnt vmcnt(0)
//v_mov_b32 v[vgprValuC+0], v[vgprG2LA+4]
//v_mov_b32 v[vgprValuC+1], v[vgprG2LA+5]
//v_mov_b32 v[vgprValuC+2], v[vgprG2LA+6]
//v_mov_b32 v[vgprValuC+3], v[vgprG2LA+7]
//v_cvt_f64_u32 v[vgprValuC:vgprValuC+1], v[vgprSerial_Div_16]
//v_cvt_f64_u32 v[vgprValuC+2:vgprValuC+3], v[vgprSerial_Div_16]
;v_cvt_f64_u32 v[vgprValuC+8:vgprValuC+9], 0x1
;v_cvt_f64_u32 v[vgprValuC+10:vgprValuC+11], 0x2
//s_branch label_write_c


/**************************************************************
/* Global Load C 
/**************************************************************/
buffer_load_dwordx4 v[vgprValuC+ 0:vgprValuC+ 3], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0   glc, slc
buffer_load_dwordx4 v[vgprValuC+ 4:vgprValuC+ 7], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+ 8:vgprValuC+11], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0   glc, slc
buffer_load_dwordx4 v[vgprValuC+12:vgprValuC+15], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+16:vgprValuC+19], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0   glc, slc
buffer_load_dwordx4 v[vgprValuC+20:vgprValuC+23], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+24:vgprValuC+27], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0   glc, slc
buffer_load_dwordx4 v[vgprValuC+28:vgprValuC+31], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc

buffer_load_dwordx4 v[vgprValuC+32:vgprValuC+35], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 glc, slc
buffer_load_dwordx4 v[vgprValuC+36:vgprValuC+39], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:768 glc, slc
buffer_load_dwordx4 v[vgprValuC+40:vgprValuC+43], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 glc, slc
buffer_load_dwordx4 v[vgprValuC+44:vgprValuC+47], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:768 glc, slc
buffer_load_dwordx4 v[vgprValuC+48:vgprValuC+51], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 glc, slc
buffer_load_dwordx4 v[vgprValuC+52:vgprValuC+55], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:768 glc, slc
buffer_load_dwordx4 v[vgprValuC+56:vgprValuC+59], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 glc, slc
buffer_load_dwordx4 v[vgprValuC+60:vgprValuC+63], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:768 glc, slc


/**************************************************************
/* global read address: increments a
/*   UNROLL * LDA * BPE
/* global read address: increments b
/*   UNROLL * LDB * BPE
/* with UNROLL = 8, BPE = 8
/**************************************************************/
s_mul_i32 s[sgprGlobalReadIncsA], 0x40, s[sgprLda]
s_mul_i32 s[sgprGlobalReadIncsB], 0x40, s[sgprLdb]

/**************************************************************
/* global read increment a:
/*   SRD_base(A) += sgprGlobalReadIncsA
/* global read increment b:
/*   SRD_base(B) += sgprGlobalReadIncsB
/**************************************************************/
GLOBAL_READ_INC_A_AND_B

/****************************************************************
/* local write address of a:
/*   lwA0I = (serial%LVCA) * GLVWA
/*   lwAL = (serial/LVCA)
/*   localWriteOffsetA = lwA0I + lwAL*MT0I;
/* local wirte address of b:
/*   lwB1J = (serial%LVCB) * GLVWB
/*   lwBL = (serial/LVCB)
/*   localWriteOffsetB = lwB1J + lwBL*MT1J;
/* with LVCA = LVCB = 32, GLVWA = GLVWB = 2, we have
/*   1wA0I = 1wB1J = (serial % 32) * 2, 1wAL = 1wBL = serial / 32
/* because the base of lds buffer is always 0, so address = offset
/*
/* local read address of a:
/*   lr0I = (serial % SG0I)  
/*   localReadOffsetA = lr0I*VECTOR_WIDTH
/* local read address of b:
/*   lr1J = (serial / SG0I) % SG1J (need this ?)
/*   localReadOffsetB = lr1J*VECTOR_WIDTH
/* with SG0I = 16, SG1J = 16, VECTOR_WIDTH = 2
/* becasue there are some common mediate values between write and read address, 
/* we put them together
/*
/* instruction hint:
/*   v_mul_u32_u24        D.u = S0.u[23:0] * S1.u[23:0] 
/*   v_add_lshl_u32       D.u = (S0.u + S1.u) << S2.u[4:0]
/****************************************************************/
v_mul_u32_u24 v[vgprLocalWriteAddrA], 0x80, v[vgprSerial_Div_32]  //1wAL * MT0I
v_mul_u32_u24 v[vgprLocalWriteAddrB], 0x40, v[vgprSerial_Div_32]  //1wBL * MY1J
v_add_lshl_u32 v[vgprLocalWriteAddrA], v[vgprLocalWriteAddrA], v[vgprSerial_Mod_32_Mul_2], 0x3 //offset in bytes
v_add_lshl_u32 v[vgprLocalWriteAddrB], v[vgprLocalWriteAddrB], v[vgprSerial_Mod_32_Mul_2], 0x3 //offset in bytes
v_add_u32 v[vgprLocalWriteAddrB], 0x2000, v[vgprLocalWriteAddrB]

v_mov_b32 v[vgprLocalReadAddrA], v[vgprSerial_Mod_16_Mul_2]          // localReadOffsetA = (serial % SG0I)*VECTOR_WIDTH
v_lshlrev_b32 v[vgprLocalReadAddrA], 0x3, v[vgprLocalReadAddrA]   // *BPE
v_and_b32 v[vgprLocalReadAddrB], 0xf, v[vgprSerial_Div_16]              // (serial/SG0I) % SG1J
v_lshlrev_b32 v[vgprLocalReadAddrB], 0x1, v[vgprLocalReadAddrB]         // localReadOffsetB = (serial/SG0I)%SG1J*VECTOR_WIDTH
v_lshlrev_b32 v[vgprLocalReadAddrB], 0x3, v[vgprLocalReadAddrB]         // *BPE
v_add_u32 v[vgprLocalReadAddrB], 0x2000, v[vgprLocalReadAddrB]               

/*****************************************************************
/* calculate loop counters
/*****************************************************************/
s_lshr_b32 s[sgprLoopCounters], s[sgprSizesL], 0x3       //sizeL / 8
s_sub_u32 s[sgprLoopCounters], 0x2, s[sgprLoopCounters]  //sgprLoopCounters = -sgprLoopCounters for tail loop

s_waitcnt vmcnt(0)


/****************************************************************
/* local write a and b
/* use hard-coded offset to represent localWriteOffsetA_0_0_0_0,
/* localWriteOffsetA_1_0_0_0, localWriteOffsetA_2_0_0_0 to save
/* registers
/****************************************************************/
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+3] offset:0    // 0*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+7] offset:512  // 1*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+3] offset:0    // 0*LSCB*BPE

GET_INVERT_OF_SIGN

s_waitcnt lgkmcnt(0)
s_barrier


/*****************************************************************
/*  local prefetch a and b
/*****************************************************************/
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256

/*****************************************************************
/* main unroll loops
/*****************************************************************/
unroll_loop_start:
/*****************************************************************
/* 1/2 unroll loop
/*****************************************************************/
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+3],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+7],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x200
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+3],  v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0
;s_waitcnt vmcnt(0)
;v_mov_b32 v[vgprValuC], v[vgprG2LB+0]
;v_mov_b32 v[vgprValuC+1], v[vgprG2LB+1]
;v_mov_b32 v[vgprValuC+2], v[vgprG2LB+2]
;v_mov_b32 v[vgprValuC+3], v[vgprG2LB+3]
;;v_cvt_f64_u32 v[vgprValuC:vgprValuC+1], 0x1
;;v_cvt_f64_u32 v[vgprValuC+2:vgprValuC+3], 0x2
;s_branch label_write_c
GLOBAL_READ_INC_A_AND_B

//iter 0
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:1024+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:1024+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:512+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:512+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:1024+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:1024+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:2048+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:2048+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1024+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1024+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:2048+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:2048+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter5
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:3072+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:3072+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:1536+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:1536+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter6
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:3072+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:3072+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter7
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:4096+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:4096+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:2048+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:2048+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter8
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:4096+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:4096+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter9
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:5120+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:5120+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:2560+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:2560+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter10
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:5120+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:5120+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter11
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:6144+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:6144+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:3072+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:3072+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter12
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:6144+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:6144+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter13
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:7168+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:7168+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:3584+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:3584+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter14
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:7168+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:7168+512+256
s_waitcnt vmcnt(0) // wait for global read
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+3] offset:12288+0    // 0*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+7] offset:12288+512  // 1*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+3] offset:12288+0    // 0*LSCB*BPE
s_waitcnt lgkmcnt(5)
MAC_4x4_X01
//iter15
s_waitcnt lgkmcnt(0)
s_barrier
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:12288+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:12288+256
MAC_4x4_X11
/*****************************************************************
/* 2/2 unroll loop
/*****************************************************************/
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+3],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+7],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x200
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+3],  v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0
GLOBAL_READ_INC_A_AND_B
//iter 0
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+1024+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+1024+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:12288+512+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:12288+512+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+1024+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+1024+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+2048+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+2048+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:12288+1024+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:12288+1024+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+2048+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+2048+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter5
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+3072+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+3072+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:12288+1536+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:12288+1536+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter6
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+3072+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+3072+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter7
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+4096+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+4096+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:12288+2048+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:12288+2048+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter8
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+4096+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+4096+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter9
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+5120+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+5120+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:12288+2560+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:12288+2560+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter10
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+5120+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+5120+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter11
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+6144+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+6144+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:12288+3072+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:12288+3072+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter12
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+6144+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+6144+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter13
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+7168+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+7168+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:12288+3584+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:12288+3584+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter14
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+7168+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+7168+512+256
s_waitcnt vmcnt(0) // wait for global read
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+3] offset:0    // 0*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+7] offset:512  // 1*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+3] offset:0    // 0*LSCB*BPE
s_waitcnt lgkmcnt(5)
MAC_4x4_X01
//iter15
s_waitcnt lgkmcnt(0)
s_barrier
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256
MAC_4x4_X11
//
s_add_u32 s[sgprLoopCounters], s[sgprLoopCounters], 0x2
s_cmp_eq_i32 s[sgprLoopCounters], 0
s_cbranch_scc0 unroll_loop_start

/*************************************************
/* do the last 2 iterations
/*************************************************/
unroll_loop_end:

buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+3],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+7],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x200
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+3],  v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0
//NO INC
//iter 0
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:1024+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:1024+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:512+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:512+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:1024+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:1024+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:2048+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:2048+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1024+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1024+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:2048+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:2048+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter5
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:3072+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:3072+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:1536+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:1536+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter6
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:3072+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:3072+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter7
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:4096+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:4096+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:2048+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:2048+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter8
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:4096+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:4096+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter9
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:5120+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:5120+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:2560+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:2560+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter10
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:5120+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:5120+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter11
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:6144+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:6144+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:3072+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:3072+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter12
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:6144+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:6144+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter13
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:7168+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:7168+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:3584+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:3584+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter14
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:7168+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:7168+512+256
s_waitcnt vmcnt(0) // wait for global read
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+3] offset:12288+0    // 0*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+7] offset:12288+512  // 1*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+3] offset:12288+0    // 0*LSCB*BPE
s_waitcnt lgkmcnt(5)
MAC_4x4_X01
//iter15
s_waitcnt lgkmcnt(0)
s_barrier
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:12288+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:12288+256
MAC_4x4_X11
//iter 0
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+1024+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+1024+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:12288+512+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:12288+512+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+1024+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+1024+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+2048+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+2048+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:12288+1024+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:12288+1024+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+2048+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+2048+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter5
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+3072+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+3072+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:12288+1536+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:12288+1536+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter6
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+3072+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+3072+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter7
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+4096+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+4096+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:12288+2048+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:12288+2048+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter8
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+4096+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+4096+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter9
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+5120+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+5120+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:12288+2560+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:12288+2560+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter10
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+5120+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+5120+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter11
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+6144+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+6144+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:12288+3072+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:12288+3072+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X11
//iter12
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+6144+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+6144+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X00
//iter13
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:12288+7168+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:12288+7168+256
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:12288+3584+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:12288+3584+256
s_waitcnt lgkmcnt(4)
MAC_4x4_X10
//iter14
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:12288+7168+512+0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:12288+7168+512+256
s_waitcnt lgkmcnt(2)
MAC_4x4_X01
//iter15
s_waitcnt lgkmcnt(0)
s_barrier
MAC_4x4_X11

/**************************************************************
/* Write C back
/**************************************************************/
GET_INVERT_OF_SIGN
                                       
label_write_c:

buffer_store_dwordx4 v[vgprValuC+ 0:vgprValuC+ 3], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+ 4:vgprValuC+ 7], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+ 8:vgprValuC+11], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+12:vgprValuC+15], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+16:vgprValuC+19], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+20:vgprValuC+23], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+24:vgprValuC+27], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+28:vgprValuC+31], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 ;glc, slc
;
buffer_store_dwordx4 v[vgprValuC+32:vgprValuC+35], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+36:vgprValuC+39], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:768 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+40:vgprValuC+43], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+44:vgprValuC+47], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:768 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+48:vgprValuC+51], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+52:vgprValuC+55], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:768 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+56:vgprValuC+59], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+60:vgprValuC+63], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:768 ;glc, slc

label_end:
s_endpgm                                           // End Kernel
