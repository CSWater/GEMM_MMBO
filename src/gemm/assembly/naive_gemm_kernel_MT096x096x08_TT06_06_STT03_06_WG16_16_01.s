
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
.amdgpu_hsa_kernel naive_gemm_kernel_MT096x096x08_TT06_06_STT03_06_WG16_16_01
naive_gemm_kernel_MT096x096x08_TT06_06_STT03_06_WG16_16_01:
.amd_kernel_code_t
  is_ptr64 = 1
  enable_sgpr_kernarg_segment_ptr = 1
  kernarg_segment_byte_size = 88 // bytes of kern args
  workitem_vgpr_count = 128 // vgprs
  wavefront_sgpr_count = 78 // sgprs
  compute_pgm_rsrc1_vgprs = 31 // floor((128-1)/4)
  compute_pgm_rsrc1_sgprs = 10 // floor((78-1)/8)
  compute_pgm_rsrc2_tidig_comp_cnt = 0 // 1D wg
  compute_pgm_rsrc2_tgid_x_en = 1 // wg.x
  compute_pgm_rsrc2_tgid_y_en = 1 // wg.y
  compute_pgm_rsrc2_tgid_z_en = 1 // wg.z
  workgroup_group_segment_byte_size = 24576 // lds bytes 96 * 8 * 8 * 2 * 2
  compute_pgm_rsrc2_user_sgpr = 2 // vcc
  kernarg_segment_alignment = 4
  group_segment_alignment = 4
  private_segment_alignment = 4
.end_amd_kernel_code_t

/******************************************/
/* Optimizations and Config:              */
/******************************************/
/* ThreadTile=6 x 4 */
/* VectorWidth=2 */
/* GlobalLoadVectorWidthA=2, GlobalLoadVectorWidthB=2 */
/* DirectToLdsA=False */
/* DirectToLdsB=False */
/* UseSgprForGRO=False */

/******************************************/
/* VGPR Assignments                       */
/******************************************/
.set vgprValuC, 0                         ;72
.set vgprValuA_X0_I0, 72                  ;6
.set vgprValuA_X1_I0, 78                  ;6
.set vgprG2LA, 84                         ;6
.set vgprG2LB, 90                         ;6
.set vgprValuB_X0_I0, 96                  ;12
.set vgprValuB_X1_I0, 108                 ;12
.set vgprLocalReadAddrA, 120              ;vgprLocalReadAddrA
.set vgprLocalReadAddrB, 121
.set vgprLocalWriteAddrA, 122             ;cube macroTile, 
.set vgprLocalWriteAddrB, 122
.set vgprGROA, 123                        ;vgprGlobalReadOffsetA_0_0_0_0
.set vgprGROB, 124                        ;vgprGlobalReadOffsetB_0_0_0_0
.set vgprGRWOC_0_0, 125                   ;vgprGlobalReadWriteOffset_C_0_0_0_0
.set vgprGRWOC_0_1, 126                   ;vgprGlobalReadWriteOffset_C_0_0_0_1
.set vgprSerial, 127
.set vtmp1, 96
.set vtmp2, 97
/* max VGPR=128 */

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
.set sgprSrdC0, 16
.set sgprSrdC1, 20
.set sgprSrdC2, 24
.set sgprTensor2dSizeC, 28
.set sgprTensor2dSizeA, 30
.set sgprTensor2dSizeB, 32
.set sgprAddressC, 34
.set sgprAddressA, 36
.set sgprAddressB, 38
.set sgprAlpha, 40
.set sgprBeta, 42
.set sgprLdc, 44
.set sgprLda, 45
.set sgprLdb, 46
.set sgprSizesI, 47
.set sgprSizesJ, 48
.set sgprSizesL, 49
.set sgprGlobalReadIncsA, 50 
.set sgprGlobalReadIncsB, 51
.set sgprLoopCounters, 52
.set stmp1, 53
.set stmp2, 54
.set stmp3, 55
.set sLow, 56
.set sHigh, 57
/* max SGPR=78 */

/******************************************/
/* 2GB limit - set offsets to -1 to exceed this and clamp */
/******************************************/
.set BufferLimit, 0x80000000

/******************************************/
/* Bits 127:96 of SRD.  Set DataFormat = 32 bit */
/******************************************/
.set Srd127_96, 0x0020000

/*******************************************/
/* each thread load 3 A and 3 B
/*******************************************/
.macro GLOBAL_LOAD_A_AND_B
buffer_load_dwordx2 v[vgprG2LA+0:vgprG2LA+1], v[vgprGROA], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0
buffer_load_dwordx2 v[vgprG2LA+2:vgprG2LA+3], v[vgprGROA], s[sgprSrdA:sgprSrdA+3], 0, offen offset:256
buffer_load_dwordx2 v[vgprG2LA+4:vgprG2LA+5], v[vgprGROA], s[sgprSrdA:sgprSrdA+3], 0, offen offset:512
buffer_load_dwordx2 v[vgprG2LB+0:vgprG2LB+1], v[vgprGROB], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0
buffer_load_dwordx2 v[vgprG2LB+2:vgprG2LB+3], v[vgprGROB], s[sgprSrdB:sgprSrdB+3], 0, offen offset:256
buffer_load_dwordx2 v[vgprG2LB+4:vgprG2LB+5], v[vgprGROB], s[sgprSrdB:sgprSrdB+3], 0, offen offset:512
.endm

.macro DS_READ_B0 base,iter
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:\base+768*\iter+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:\base+768*\iter+256
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:\base+768*\iter+512
.endm

.macro DS_READ_B1 base,iter
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:\base+768*\iter+0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:\base+768*\iter+256
ds_read_b128 v[vgprValuB_X1_I0+8:vgprValuB_X1_I0+8+3], v[vgprLocalReadAddrB] offset:\base+768*\iter+512
.endm

.macro DS_READ_0A base,iter
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:\base+768*\iter+0
ds_read_b64  v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+1], v[vgprLocalReadAddrA] offset:\base+768*\iter+256
.endm

.macro DS_READ_1A base,iter
ds_read_b64   v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+1], v[vgprLocalReadAddrA] offset:\base+768*\iter+256+8
ds_read_b128  v[vgprValuA_X1_I0+2:vgprValuA_X1_I0+2+3], v[vgprLocalReadAddrA] offset:\base+768*\iter+512
.endm

.macro DS_WRITE_A base
//v_cvt_f64_u32 v[vgprG2LA+0:vgprG2LA+1], 4
//v_cvt_f64_u32 v[vgprG2LA+2:vgprG2LA+3], 5
//v_cvt_f64_u32 v[vgprG2LA+4:vgprG2LA+5], 6
ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+1] offset:\base+0 
ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+2:vgprG2LA+3] offset:\base+0x100
ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+5] offset:\base+0x200      ;
.endm

.macro DS_WRITE_B base
//v_cvt_f64_u32 v[vgprG2LB+0:vgprG2LB+1], 0x10
//v_cvt_f64_u32 v[vgprG2LB+2:vgprG2LB+3], 0x11
//v_cvt_f64_u32 v[vgprG2LB+4:vgprG2LB+5], 0x12
ds_write_b64 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+1] offset:\base+0x1800+0
ds_write_b64 v[vgprLocalWriteAddrB], v[vgprG2LB+2:vgprG2LB+3] offset:\base+0x1800+0x100
ds_write_b64 v[vgprLocalWriteAddrB], v[vgprG2LB+4:vgprG2LB+5] offset:\base+0x1800+0x200
.endm
/******************************************/
/* 6x6 thread-tile                        */
/******************************************/
.macro MAC_6x4_X0_FMA_F64 i,j
v_fma_f64 v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1], v[vgprValuA_X0_I0+\i*2:vgprValuA_X0_I0+\i*2+1], v[vgprValuB_X0_I0+\j*2:vgprValuB_X0_I0+\j*2+1], v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1]
.endm

.macro MAC_6x4_X1_FMA_F64 i,j
v_fma_f64 v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1], v[vgprValuA_X0_I0+\i*2:vgprValuA_X0_I0+\i*2+1], v[vgprValuB_X1_I0+\j*2:vgprValuB_X1_I0+\j*2+1], v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1]
.endm

.macro MAC_X0_6x6_UP
MAC_6x4_X0_FMA_F64 0, 0
s_setprio 1
MAC_6x4_X0_FMA_F64 1, 0
MAC_6x4_X0_FMA_F64 2, 0
MAC_6x4_X0_FMA_F64 0, 1
MAC_6x4_X0_FMA_F64 1, 1
MAC_6x4_X0_FMA_F64 2, 1
MAC_6x4_X0_FMA_F64 0, 2
MAC_6x4_X0_FMA_F64 1, 2
MAC_6x4_X0_FMA_F64 2, 2
MAC_6x4_X0_FMA_F64 0, 3
MAC_6x4_X0_FMA_F64 1, 3
MAC_6x4_X0_FMA_F64 2, 3
MAC_6x4_X0_FMA_F64 0, 4
MAC_6x4_X0_FMA_F64 1, 4
MAC_6x4_X0_FMA_F64 2, 4
MAC_6x4_X0_FMA_F64 0, 5
MAC_6x4_X0_FMA_F64 1, 5
MAC_6x4_X0_FMA_F64 2, 5
s_setprio 0
.endm

.macro MAC_X0_6x6_LOW
MAC_6x4_X0_FMA_F64 3, 0
s_setprio 1
MAC_6x4_X0_FMA_F64 4, 0
MAC_6x4_X0_FMA_F64 5, 0
MAC_6x4_X0_FMA_F64 3, 1
MAC_6x4_X0_FMA_F64 4, 1
MAC_6x4_X0_FMA_F64 5, 1
MAC_6x4_X0_FMA_F64 3, 2
MAC_6x4_X0_FMA_F64 4, 2
MAC_6x4_X0_FMA_F64 5, 2
MAC_6x4_X0_FMA_F64 3, 3
MAC_6x4_X0_FMA_F64 4, 3
MAC_6x4_X0_FMA_F64 5, 3
MAC_6x4_X0_FMA_F64 3, 4
MAC_6x4_X0_FMA_F64 4, 4
MAC_6x4_X0_FMA_F64 5, 4
MAC_6x4_X0_FMA_F64 3, 5
MAC_6x4_X0_FMA_F64 4, 5
MAC_6x4_X0_FMA_F64 5, 5
s_setprio 0
.endm

.macro MAC_X1_6x6_UP
MAC_6x4_X1_FMA_F64 0, 0
s_setprio 1
MAC_6x4_X1_FMA_F64 1, 0
MAC_6x4_X1_FMA_F64 2, 0
MAC_6x4_X1_FMA_F64 0, 1
MAC_6x4_X1_FMA_F64 1, 1
MAC_6x4_X1_FMA_F64 2, 1
MAC_6x4_X1_FMA_F64 0, 2
MAC_6x4_X1_FMA_F64 1, 2
MAC_6x4_X1_FMA_F64 2, 2
MAC_6x4_X1_FMA_F64 0, 3
MAC_6x4_X1_FMA_F64 1, 3
MAC_6x4_X1_FMA_F64 2, 3
MAC_6x4_X1_FMA_F64 0, 4
MAC_6x4_X1_FMA_F64 1, 4
MAC_6x4_X1_FMA_F64 2, 4
MAC_6x4_X1_FMA_F64 0, 5
MAC_6x4_X1_FMA_F64 1, 5
MAC_6x4_X1_FMA_F64 2, 5
s_setprio 0
.endm

.macro MAC_X1_6x6_LOW
MAC_6x4_X1_FMA_F64 3, 0
s_setprio 1
MAC_6x4_X1_FMA_F64 4, 0
MAC_6x4_X1_FMA_F64 5, 0
MAC_6x4_X1_FMA_F64 3, 1
MAC_6x4_X1_FMA_F64 4, 1
MAC_6x4_X1_FMA_F64 5, 1
MAC_6x4_X1_FMA_F64 3, 2
MAC_6x4_X1_FMA_F64 4, 2
MAC_6x4_X1_FMA_F64 5, 2
MAC_6x4_X1_FMA_F64 3, 3
MAC_6x4_X1_FMA_F64 4, 3
MAC_6x4_X1_FMA_F64 5, 3
MAC_6x4_X1_FMA_F64 3, 4
MAC_6x4_X1_FMA_F64 4, 4
MAC_6x4_X1_FMA_F64 5, 4
MAC_6x4_X1_FMA_F64 3, 5
MAC_6x4_X1_FMA_F64 4, 5
MAC_6x4_X1_FMA_F64 5, 5
s_setprio 0
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
v_xor_b32 v[vgprValuC+65], 0x80000000, v[vgprValuC+65]
v_xor_b32 v[vgprValuC+67], 0x80000000, v[vgprValuC+67]
v_xor_b32 v[vgprValuC+69], 0x80000000, v[vgprValuC+69]
v_xor_b32 v[vgprValuC+71], 0x80000000, v[vgprValuC+71]
.endm

/* global read inc a and b */
.macro  GLOBAL_READ_INC_ADDRESS_A_AND_B
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s[sgprGlobalReadIncsA+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0        // gra SRD += inc(upper)

s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s[sgprGlobalReadIncsB+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0        // gra SRD += inc(upper)
.endm

/*************************************************************/
/* Load Kernel Args                                          */
/*************************************************************/
//s_load_dwordx2 s[sgprTensor2dSizeC:sgprTensor2dSizeC+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x0 // load size of Matrix C
//s_load_dwordx2 s[sgprTensor2dSizeA:sgprTensor2dSizeA+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x8 // load size of Matrix A
//s_load_dwordx2 s[sgprTensor2dSizeB:sgprTensor2dSizeB+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x10 // load size of Matrix B
s_load_dwordx2 s[sgprAddressC:sgprAddressC+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x18 // load addr c
s_load_dwordx2 s[sgprAddressA:sgprAddressA+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x20 // load addr a
s_load_dwordx2 s[sgprAddressB:sgprAddressB+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x28 // load addr b
s_load_dwordx2 s[sgprAlpha:sgprAlpha+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x30 // load alpha
s_load_dwordx2 s[sgprBeta:sgprBeta+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x38 // load beta
s_load_dword s[sgprLdc], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x40 // load ldc
s_load_dword s[sgprLda], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x44 // load lda
s_load_dword s[sgprLdb], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x48 // load ldb
s_load_dword s[sgprSizesI], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x4c // load m
s_load_dword s[sgprSizesJ], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x50 // load n
s_load_dword s[sgprSizesL], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x54 // load k
s_load_dword s[sgprGridDimX], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x58  // load sgprGridDimX
s_load_dword s[sgprGridDimY], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x5c  // load sgprGridDimY

/************************************************************/
/* Allocate Resources    threadIdx is in v0                 */
/************************************************************/
s_mov_b32 m0, 0x6000                                                          // LDS clamp at 24576 bytes
v_mov_b32 v[vgprSerial], v0
s_waitcnt lgkmcnt(0)                               // wait for 88 bytes of kern args  

/**********************************************************
/* because nwg1J % WGM === 0, so block mapping is simplified into:
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
/*   sgprSrdC0 = sgprAddressC + wg0I*MT0I + wg1J*MT1J*LDC
/*
/* instruction hint
/*   s_mul_hi_u32 D.u = (S0.u * S1.u) >> 32
/*   s_mul_i32 D.i = S0.i * S1.i
/********************************************************/
s_mul_i32 s[sLow], s[sgprBlockIdX], 0x60                          // wg0I * MT0I
s_lshl_b32 s[sLow], s[sLow], 0x3                                  // tileStart *= BPE, in bytes
s_add_u32 s[sgprSrdA+0], s[sgprAddressA+0], s[sLow]               // SRD_base(A) = Address + tileStart
s_addc_u32 s[sgprSrdA+1], s[sgprAddressA+1], 0                    // SRD_base(A) = Address + tileStart
s_mov_b32 s[sgprSrdA+2], BufferLimit
s_mov_b32 s[sgprSrdA+3], Srd127_96                                // Set bits 127_96 in SRD

s_add_u32 s[sgprSrdC0+0], s[sgprAddressC+0], s[sLow]              // SRD_base(C) = Address + tileStart(in dimension m)
s_addc_u32 s[sgprSrdC0+1], s[sgprAddressC+1], 0                   // SRD_base(C) = Address + tileStart(in dimension m)
s_mov_b32 s[sgprSrdC0+2], BufferLimit
s_mov_b32 s[sgprSrdC0+3], Srd127_96                               // Set bits 127_96 in SRD

s_mul_i32 s[sLow], s[sgprBlockIdY], 0x60                          // wg1J * MT1J low 32 bit
s_lshl_b32 s[sLow], s[sLow], 0x3
s_add_u32 s[sgprSrdB+0], s[sgprAddressB+0], s[sLow]               // SRD_base(B) = Address + tileStart  
s_addc_u32 s[sgprSrdB+1], s[sgprAddressB+1], 0                    // SRD_base(B) = Address + tileStart
s_mov_b32 s[sgprSrdB+2], BufferLimit
s_mov_b32 s[sgprSrdB+3], Srd127_96                                // Set bits 127_96 in SRD

s_mul_i32 s[sLow], s[sLow], s[sgprLdc]                            // (wg1J * MT1J * BPE) * LDC
s_add_u32 s[sgprSrdC0+0], s[sgprSrdC0+0], s[sLow]                 // add lo to SRD_base(C)
s_addc_u32 s[sgprSrdC0+1], s[sgprSrdC0+1], 0                      // add hi to SRD_base(C)


/*********************************************************
/* global read address offset: globalReadOffsetA_0_0_0_0
/* global read address offset: globalReadOffsetB_0_0_0_0
/*
/* globalReadOffsetA_0_0_0_0 
/*   = (serial % 32) * 2 + (serial / 32) * LDA
/* globalReadOffsetB_0_0_0_0 
/*   = (serial % 32) * 2 + (serial / 32) * LDB
/**********************************************************/
v_lshrrev_b32 v[vtmp1], 0x5, v[vgprSerial]             //serial / 32
v_mul_lo_u32 v[vgprGROA], s[sgprLda], v[vtmp1]         // * LDA
v_mul_lo_u32 v[vgprGROB], s[sgprLdb], v[vtmp1]         // * LDB
#v_lshrrev_b32 v[vgprGROA], 0x5, v[vgprSerial]             //serial / 32
#v_mul_lo_u32 v[vgprGROB], s[sgprLdb], v[vgprGR0A]         // * LDB
#v_mul_lo_u32 v[vgprGROA], s[sgprLda], v[vgprGR0A]         // * LDA
v_and_b32 v[vtmp1], 0x1f, v[vgprSerial]                //serial % 32
//v_lshlrev_b32 v[vtmp1], 0x1, v[vtmp1]                  // * 2
v_add_lshl_u32 v[vgprGROA], v[vgprGROA], v[vtmp1], 0x3 //globalReadOffsetA_0_0_0_0, in bytes
v_add_lshl_u32 v[vgprGROB], v[vgprGROB], v[vtmp1], 0x3 //globalReadOffsetB_0_0_0_0, in bytes


/******************************************************************
/* Load and Write C offset:
/* there are 9(3*3) 2*2 sub_sub blocks
/* GlobalWriteOffsetC_0_0_0 = (serial/16)*2*LDC+(serial%16)*2
/* GlobalWriteOffsetC_0_0_1 = GlobalWriteOffsetC_0_0_0 + LDC
/* GlobalWriteOffsetC_0_1_0 = GlobalWriteOffsetC_0_0_0 + 32 * LDC
/* GlobalWriteOffsetC_0_1_1 = GlobalWriteOffsetC_0_0_1 + 32 * LDC
/* GlobalWriteOffsetC_0_2_0 = GlobalWriteOffsetC_0_1_0 + 32 * LDC 
/* GlobalWriteOffsetC_0_2_1 = GlobalWriteOffsetC_0_1_1 + 32 * LDC
/******************************************************************/
s_lshl_b32 s[stmp1], s[sgprLdc], 0x3  
s_lshl_b32 s[stmp2], s[sgprLdc], 0x8    // LDC*BPE*32, ldc in bytes
v_lshrrev_b32 v[vtmp1], 0x4, v[vgprSerial]        //serial / 16
v_and_b32 v[vtmp2], 0xf, v[vgprSerial]            //serial % 16
v_mul_lo_u32 v[vgprGRWOC_0_0], s[sgprLdc], v[vtmp1]    // (serial / 16) * LDC
v_add_lshl_u32 v[vgprGRWOC_0_0], v[vgprGRWOC_0_0], v[vtmp2], 0x4  
v_add_u32 v[vgprGRWOC_0_1], s[stmp1], v[vgprGRWOC_0_0] 
//change SRD_base_c to save vgpr
//GlobalWriteOffsetC_0_1_0 and GlobalWriteOffsetC_0_1_1
s_add_u32 s[sgprSrdC1+0], s[sgprSrdC0+0], s[stmp2]                 // 
s_addc_u32 s[sgprSrdC1+1], s[sgprSrdC0+1], 0                        // 
s_mov_b64 s[sgprSrdC1+2:sgprSrdC1+3], s[sgprSrdC0+2:sgprSrdC0+3]
//GlobalWriteOffsetC_0_2_0 and GlobalWriteOffsetC_0_2_1
s_add_u32 s[sgprSrdC2+0], s[sgprSrdC1+0], s[stmp2]                 // 
s_addc_u32 s[sgprSrdC2+1], s[sgprSrdC1+1], 0                        // 
s_mov_b64 s[sgprSrdC2+2:sgprSrdC2+3], s[sgprSrdC1+2:sgprSrdC1+3]



/***********************************************************
/* global read a and b, each thread load 3 A and 3 B
/* global read address of a:
/*   SRD_base(A) + vgprGROA
/*   SRD_base(A) + vgprGROA + 64 * 8
/* global read address of b:
/*   SRD_base(B) + vgprGROB
/*   SRD_base(B) + vgprGROB + 64 * 8
/************************************************************/
GLOBAL_LOAD_A_AND_B

/**************************************************************
/* Global Load C 
/**************************************************************/
buffer_load_dwordx4 v[vgprValuC+ 0:vgprValuC+ 3], v[vgprGRWOC_0_0], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:0 glc, slc
buffer_load_dwordx4 v[vgprValuC+ 4:vgprValuC+ 7], v[vgprGRWOC_0_0], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+ 8:vgprValuC+11], v[vgprGRWOC_0_0], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:512 glc, slc
buffer_load_dwordx4 v[vgprValuC+12:vgprValuC+15], v[vgprGRWOC_0_1], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:0 glc, slc
buffer_load_dwordx4 v[vgprValuC+16:vgprValuC+19], v[vgprGRWOC_0_1], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+20:vgprValuC+23], v[vgprGRWOC_0_1], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:512 glc, slc

buffer_load_dwordx4 v[vgprValuC+24:vgprValuC+27], v[vgprGRWOC_0_0], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:0  glc, slc
buffer_load_dwordx4 v[vgprValuC+28:vgprValuC+31], v[vgprGRWOC_0_0], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+32:vgprValuC+35], v[vgprGRWOC_0_0], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:512 glc, slc
buffer_load_dwordx4 v[vgprValuC+36:vgprValuC+39], v[vgprGRWOC_0_1], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:0 glc, slc
buffer_load_dwordx4 v[vgprValuC+40:vgprValuC+43], v[vgprGRWOC_0_1], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+44:vgprValuC+47], v[vgprGRWOC_0_1], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:512 glc, slc

buffer_load_dwordx4 v[vgprValuC+48:vgprValuC+51], v[vgprGRWOC_0_0], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:0  glc, slc
buffer_load_dwordx4 v[vgprValuC+52:vgprValuC+55], v[vgprGRWOC_0_0], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+56:vgprValuC+59], v[vgprGRWOC_0_0], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:512 glc, slc
buffer_load_dwordx4 v[vgprValuC+60:vgprValuC+63], v[vgprGRWOC_0_1], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:0 glc, slc
buffer_load_dwordx4 v[vgprValuC+64:vgprValuC+67], v[vgprGRWOC_0_1], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+68:vgprValuC+71], v[vgprGRWOC_0_1], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:512 glc, slc


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
GLOBAL_READ_INC_ADDRESS_A_AND_B

/****************************************************************
/* local write address of a:
/*   lwA0I = (serial%32) * 2
/*   lwAL = (serial/32)
/*   localWriteOffsetA = lwA0I + lwAL*MT0I;
/* local wirte address of b:
/*   lwB1J = (serial%32) * 2
/*   lwBL = (serial/32)
/*   localWriteOffsetB = lwB1J + lwBL*MT1J;
/*
/* instruction hint:
/*   v_mul_u32_u24        D.u = S0.u[23:0] * S1.u[23:0] 
/*   v_add_lshl_u32       D.u = (S0.u + S1.u) << S2.u[4:0]
/****************************************************************/
v_lshrrev_b32 v[vtmp1], 0x5, v[vgprSerial]            //serial / 32
v_mul_u32_u24 v[vgprLocalWriteAddrA], 0x60, v[vtmp1]  //1wAL * MT0I
//v_mul_u32_u24 v[vgprLocalWriteAddrB], 0x60, v[vtmp1]  //1wBL * MT1J
v_and_b32 v[vtmp2], 0x1f, v[vgprSerial]               //serial % 32
//v_lshlrev_b32 v[vtmp2], 0x1, v[vtmp2]                 //(serial % 32) * 2
v_add_lshl_u32 v[vgprLocalWriteAddrA], v[vgprLocalWriteAddrA], v[vtmp2], 0x3 //offset in bytes
//v_add_lshl_u32 v[vgprLocalWriteAddrB], v[vgprLocalWriteAddrB], v[vtmp2], 0x3 //offset in bytes
//v_add_u32 v[vgprLocalWriteAddrB], 0x1800, v[vgprLocalWriteAddrB]


/*********************************************************************
/* local read address of a:
/*   lr0I = (serial % SG0I)  
/*   localReadOffsetA = lr0I*VECTOR_WIDTH
/* local read address of b:
/*   lr1J = (serial / SG0I) % SG1J
/*   localReadOffsetB = lr1J*VECTOR_WIDTH
/**********************************************************************/
v_and_b32 v[vtmp2], 0xf, v[vgprSerial]                             // serial % 16
v_lshlrev_b32 v[vgprLocalReadAddrA], 0x4, v[vtmp2]                 // * 2 * BPE
v_lshrrev_b32 v[vtmp1], 0x4, v[vgprSerial]                         // serial / 16
v_lshlrev_b32 v[vgprLocalReadAddrB], 0x4, v[vtmp1]                 // * 2 * BPE
v_add_u32 v[vgprLocalReadAddrB], 0x1800, v[vgprLocalReadAddrB]               

/*****************************************************************
/* calculate loop counters
/*****************************************************************/
s_lshr_b32 s[sgprLoopCounters], s[sgprSizesL], 0x3          //sizeL / 8
s_sub_u32 s[sgprLoopCounters], 0x2, s[sgprLoopCounters]  //sgprLoopCounters = -sgprLoopCounters

s_waitcnt vmcnt(0)
/* load right value  */

//v_cvt_f64_u32 v[vgprG2LA+0:vgprG2LA+1], 99
//v_cvt_f64_u32 v[vgprG2LA+2:vgprG2LA+3], 99
//v_cvt_f64_u32 v[vgprG2LA+4:vgprG2LA+5], 99
//ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+1] offset:0x4000
//ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+2:vgprG2LA+3] offset:0x4000+256
//ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+5] offset:0x4000+512
//s_waitcnt lgkmcnt(0)
//v_mov_b32 v[vgprLocalReadAddrB], 0
//ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0x4000
//s_waitcnt lgkmcnt(0)
//v_mov_b32 v[vgprValuC+0], v[vgprValuB_X0_I0+0] 
//v_mov_b32 v[vgprValuC+1], v[vgprValuB_X0_I0+1] 
//v_mov_b32 v[vgprValuC+2], v[vgprValuB_X0_I0+2] 
//v_mov_b32 v[vgprValuC+3], v[vgprValuB_X0_I0+3] 
//s_branch label_write_c
/****************************************************************
/* local write a and b
/* use hard-coded offset to represent localWriteOffsetA_0_0_0_0,
/* localWriteOffsetA_1_0_0_0, localWriteOffsetA_2_0_0_0 to save
/* registers
/****************************************************************/
DS_WRITE_A 0x0
DS_WRITE_B 0x0

GET_INVERT_OF_SIGN

s_waitcnt lgkmcnt(0)
s_barrier


/*****************************************************************
/*  local prefetch a and b
/*****************************************************************/
DS_READ_B0 0,0  //ds_read B0 into register
DS_READ_0A 0,0   //ds_read 0A into registers

/*****************************************************************
/* main unroll loops
/*****************************************************************/
unroll_loop_start:
/*****************************************************************
/* 1/2 unroll loop
/*****************************************************************/
GLOBAL_LOAD_A_AND_B
GLOBAL_READ_INC_ADDRESS_A_AND_B
//iter 0
DS_READ_1A 0,0
DS_READ_B1 0,1
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0,1
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW
s_branch label_write_c

//iter 1
DS_READ_1A 0,1
DS_READ_B0 0,2
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0,2
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 2
DS_READ_1A 0,2
DS_READ_B1 0,3
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0,3
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 3
DS_READ_1A 0,3
DS_READ_B0 0,4
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0,4
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 4
DS_READ_1A 0,4
DS_READ_B1 0,5
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0,5
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 5
DS_READ_1A 0,5
DS_READ_B0 0,6
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0,6
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 6
DS_READ_1A 0,6
DS_READ_B1 0,7
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0,7
s_waitcnt vmcnt(0) // wait for global read
DS_WRITE_A 0x3000
DS_WRITE_B 0x3000
s_waitcnt lgkmcnt(11)
MAC_X0_6x6_LOW

//iter 7
s_barrier
s_waitcnt lgkmcnt(0)
DS_READ_1A 0,7
DS_READ_B0 0x3000,0 
MAC_X1_6x6_UP
DS_READ_0A 0x3000,0 
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

/*****************************************************************
/* 2/2 unroll loop
/*****************************************************************/
GLOBAL_LOAD_A_AND_B
GLOBAL_READ_INC_ADDRESS_A_AND_B

//iter 0
DS_READ_1A 0x3000,0
DS_READ_B1 0x3000,1
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0x3000,1
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 1
DS_READ_1A 0x3000,1
DS_READ_B0 0x3000,2
s_waitcnt lgkmcnt(5)
//v_mov_b32 v[vgprValuC+0], v[vgprValuA_X0_I0+0]
//v_mov_b32 v[vgprValuC+1], v[vgprValuA_X0_I0+1]
//v_mov_b32 v[vgprValuC+3], v[vgprValuB_X0_I0+0]
//v_mov_b32 v[vgprValuC+4], v[vgprValuB_X0_I0+1]
MAC_X1_6x6_UP
DS_READ_0A 0x3000,2
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 2
DS_READ_1A 0x3000,2
DS_READ_B1 0x3000,3
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0x3000,3
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 3
DS_READ_1A 0x3000,3
DS_READ_B0 0x3000,4
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0x3000,4
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 4
DS_READ_1A 0x3000,4
DS_READ_B1 0x3000,5
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0x3000,5
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 5
DS_READ_1A 0x3000,5
DS_READ_B0 0x3000,6
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0x3000,6
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 6
DS_READ_1A 0x3000,6
DS_READ_B1 0x3000,7
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0x3000,7
s_waitcnt vmcnt(0) // wait for global read
DS_WRITE_A 0
DS_WRITE_B 0
s_waitcnt lgkmcnt(9)
MAC_X0_6x6_LOW

//iter 7
s_barrier
s_waitcnt lgkmcnt(0)
DS_READ_1A 0x3000,7
DS_READ_B0 0,0
MAC_X1_6x6_UP
DS_READ_0A 0,0
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//check if loop ended
s_add_u32 s[sgprLoopCounters], s[sgprLoopCounters], 0x2
s_cmp_eq_i32 s[sgprLoopCounters], 0
s_cbranch_scc0 unroll_loop_start

/*************************************************
/* do the last 2 iterations
/*************************************************/
unroll_loop_end:
GLOBAL_LOAD_A_AND_B
GLOBAL_READ_INC_ADDRESS_A_AND_B
//iter 0
DS_READ_1A 0,0
DS_READ_B1 0,1
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0,1
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 1
DS_READ_1A 0,1
DS_READ_B0 0,2
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0,2
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 2
DS_READ_1A 0,2
DS_READ_B1 0,3
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0,3
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 3
DS_READ_1A 0,3
DS_READ_B0 0,4
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0,4
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 4
DS_READ_1A 0,4
DS_READ_B1 0,5
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0,5
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 5
DS_READ_1A 0,5
DS_READ_B0 0,6
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0,6
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 6
DS_READ_1A 0,6
DS_READ_B1 0,7
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0,7
s_waitcnt vmcnt(0) // wait for global read
DS_WRITE_A 0x3000
DS_WRITE_B 0x3000
s_waitcnt lgkmcnt(9)
MAC_X0_6x6_LOW

//iter 7
s_barrier
s_waitcnt lgkmcnt(0)
DS_READ_1A 0,7
DS_READ_B0 0x3000,0 
MAC_X1_6x6_UP
DS_READ_0A 0x3000,0 
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 0
DS_READ_1A 0x3000,0
DS_READ_B1 0x3000,1
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0x3000,1
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 1
DS_READ_1A 0x3000,1
DS_READ_B0 0x3000,2
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0x3000,2
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 2
DS_READ_1A 0x3000,2
DS_READ_B1 0x3000,3
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0x3000,3
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 3
DS_READ_1A 0x3000,3
DS_READ_B0 0x3000,4
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0x3000,4
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 4
DS_READ_1A 0x3000,4
DS_READ_B1 0x3000,5
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0x3000,5
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 5
DS_READ_1A 0x3000,5
DS_READ_B0 0x3000,6
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_UP
DS_READ_0A 0x3000,6
s_waitcnt lgkmcnt(5)
MAC_X1_6x6_LOW

//iter 6
DS_READ_1A 0x3000,6
DS_READ_B1 0x3000,7
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
DS_READ_0A 0x3000,7
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 7
DS_READ_1A 0x3000,7
s_waitcnt lgkmcnt(2)
MAC_X1_6x6_UP
s_waitcnt lgkmcnt(0)
MAC_X1_6x6_LOW

/**************************************************************
/* Write C back
/**************************************************************/
GET_INVERT_OF_SIGN
                                       
label_write_c:
buffer_store_dwordx4 v[vgprValuC+ 0:vgprValuC+ 3], v[vgprGRWOC_0_0], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:0   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+ 4:vgprValuC+ 7], v[vgprGRWOC_0_0], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:256 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+ 8:vgprValuC+11], v[vgprGRWOC_0_0], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:512 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+12:vgprValuC+15], v[vgprGRWOC_0_1], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:0   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+16:vgprValuC+19], v[vgprGRWOC_0_1], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:256 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+20:vgprValuC+23], v[vgprGRWOC_0_1], s[sgprSrdC0:sgprSrdC0+3], 0, offen, offset:512 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+24:vgprValuC+27], v[vgprGRWOC_0_0], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:0   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+28:vgprValuC+31], v[vgprGRWOC_0_0], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:256 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+32:vgprValuC+35], v[vgprGRWOC_0_0], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:512 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+36:vgprValuC+39], v[vgprGRWOC_0_1], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:0   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+40:vgprValuC+43], v[vgprGRWOC_0_1], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:256 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+44:vgprValuC+47], v[vgprGRWOC_0_1], s[sgprSrdC1:sgprSrdC1+3], 0, offen, offset:512 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+48:vgprValuC+51], v[vgprGRWOC_0_0], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:0   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+52:vgprValuC+55], v[vgprGRWOC_0_0], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:256 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+56:vgprValuC+59], v[vgprGRWOC_0_0], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:512 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+60:vgprValuC+63], v[vgprGRWOC_0_1], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:0   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+64:vgprValuC+67], v[vgprGRWOC_0_1], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:256 ;glc, slc
buffer_store_dwordx4 v[vgprValuC+68:vgprValuC+71], v[vgprGRWOC_0_1], s[sgprSrdC2:sgprSrdC2+3], 0, offen, offset:512 ;glc, slc

label_end:
s_endpgm                                           // End Kernel


