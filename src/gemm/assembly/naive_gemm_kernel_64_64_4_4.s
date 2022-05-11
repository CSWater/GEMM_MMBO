
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
.amdgpu_hsa_kernel Cijk_Ailk_Bjlk_DB_MT064x064x08_K1_NLCA01_NLCB01_TT04_04_USFGRO0_WG16_16_01
Cijk_Ailk_Bjlk_DB_MT064x064x08_K1_NLCA01_NLCB01_TT04_04_USFGRO0_WG16_16_01:
.amd_kernel_code_t
  is_ptr64 = 1
  enable_sgpr_kernarg_segment_ptr = 1
  kernarg_segment_byte_size = 88 // bytes of kern args
  workitem_vgpr_count = 79 // vgprs
  wavefront_sgpr_count = 78 // sgprs
  compute_pgm_rsrc1_vgprs = 21 // floor((85-1)/4)
  compute_pgm_rsrc1_sgprs = 10 // floor((78-1)/8)
  compute_pgm_rsrc2_tidig_comp_cnt = 0 // 1D wg
  compute_pgm_rsrc2_tgid_x_en = 1 // wg.x
  compute_pgm_rsrc2_tgid_y_en = 1 // wg.y
  compute_pgm_rsrc2_tgid_z_en = 1 // wg.z
  workgroup_group_segment_byte_size = 16384 // lds bytes 2048*8
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
.set vgprValuC, 0
.set vgprValuA_X0_I0, 32
.set vgprValuA_X1_I0, 40
.set vgprG2LA, 48
.set vgprValuB_X0_I0, 52
.set vgprValuB_X1_I0, 60
.set vgprG2LB,68
.set vgprLocalReadAddrA, 72
.set vgprLocalReadAddrB, 73
.set vgprLocalWriteAddrA, 74
.set vgprLocalWriteAddrB, 75
.set vgprGlobalReadOffsetA_0_0_0_0, 76
.set vgprGlobalReadOffsetB_0_0_0_0, 77
.set vgprSerial, 78
.set vgprGlobalWriteOffsetC_0_0_0, 79
.set vgprGlobalWriteOffsetC_0_0_1, 80
.set vgprGlobalWriteOffsetC_0_1_0, 81
.set vgprGlobalWriteOffsetC_0_1_1, 82
.set vtmp1, 83
.set vtmp2, 84

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
.macro MAC_6x4_X0_FMA_F64 i,j
v_fma_f64 v[vgprValuC+(\i+\j*4)*2:vgprValuC+(\i+\j*4)*2+1], v[vgprValuA_X0_I0+\i*2:vgprValuA_X0_I0+\i*2+1], v[vgprValuB_X0_I0+\j*2:vgprValuB_X0_I0+\j*2+1], v[vgprValuC+(\i+\j*4)*2:(vgprValuC+\i+\j*4)*2+1]
.endm

.macro MAC_6x4_X1_FMA_F64 i,j
v_fma_f64 v[vgprValuC+(\i+\j*4)*2:vgprValuC+(\i+\j*4)*2+1], v[vgprValuA_X1_I0+\i*2:vgprValuA_X1_I0+\i*2+1], v[vgprValuB_X1_I0+\j*2:vgprValuB_X1_I0+\j*2+1], v[vgprValuC+(\i+\j*4)*2:(vgprValuC+\i+\j*4)*2+1]
.endm

.macro MAC_6x4_X0
MAC_6x4_X0_FMA_F64 0, 0
s_setprio 1
MAC_6x4_X0_FMA_F64 1, 0
MAC_6x4_X0_FMA_F64 2, 0
MAC_6x4_X0_FMA_F64 3, 0
MAC_6x4_X0_FMA_F64 0, 1
MAC_6x4_X0_FMA_F64 1, 1
MAC_6x4_X0_FMA_F64 2, 1
MAC_6x4_X0_FMA_F64 3, 1
MAC_6x4_X0_FMA_F64 0, 2
MAC_6x4_X0_FMA_F64 1, 2
MAC_6x4_X0_FMA_F64 2, 2
MAC_6x4_X0_FMA_F64 3, 2
MAC_6x4_X0_FMA_F64 0, 3
MAC_6x4_X0_FMA_F64 1, 3
MAC_6x4_X0_FMA_F64 2, 3
MAC_6x4_X0_FMA_F64 3, 3
s_setprio 0
.endm

.macro MAC_6x4_X1
MAC_6x4_X1_FMA_F64 0, 0
s_setprio 1
MAC_6x4_X1_FMA_F64 1, 0
MAC_6x4_X1_FMA_F64 2, 0
MAC_6x4_X1_FMA_F64 3, 0
MAC_6x4_X1_FMA_F64 0, 1
MAC_6x4_X1_FMA_F64 1, 1
MAC_6x4_X1_FMA_F64 2, 1
MAC_6x4_X1_FMA_F64 3, 1
MAC_6x4_X1_FMA_F64 0, 2
MAC_6x4_X1_FMA_F64 1, 2
MAC_6x4_X1_FMA_F64 2, 2
MAC_6x4_X1_FMA_F64 3, 2
MAC_6x4_X1_FMA_F64 0, 3
MAC_6x4_X1_FMA_F64 1, 3
MAC_6x4_X1_FMA_F64 2, 3
MAC_6x4_X1_FMA_F64 3, 3
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
.endm

/* global read inc a and b */
.macro  GLOBAL_READ_INC_A_AND_B
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s[sgprGlobalReadIncsA+0]  // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0                        // gra SRD += inc(upper)

s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s[sgprGlobalReadIncsB+0]  // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0                        // gra SRD += inc(upper)
.endm

/*************************************************************/
/* Load Kernel Args                                          */
/*************************************************************/
s_load_dwordx2 s[sgprTensor2dSizeC:sgprTensor2dSizeC+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x0 // load size of Matrix C
s_load_dwordx2 s[sgprTensor2dSizeA:sgprTensor2dSizeA+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x8 // load size of Matrix A
s_load_dwordx2 s[sgprTensor2dSizeB:sgprTensor2dSizeB+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x10 // load size of Matrix B
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
s_mov_b32 m0, 0x4000                                                          // LDS clamp at 16384 bytes
v_mov_b32 v[vgprSerial], v0
//v_and_b32 v[vgprSerial_Mod_32_Mul_2], 0x1f, v0                                 // serial % 16
//v_lshlrev_b32 v[vgprSerial_Mod_32_Mul_2], 0x1, v[vgprSerial_Mod_32_Mul_2]     // (serial%16)*2
//v_lshrrev_b32 v[vgprSerial_Div_32], 0x5, v0                                   // serial / 16

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
s_mul_i32 s[sLow], s[sgprBlockIdX], 0x40                    // wg0I * MT0I, within 2^32
s_lshl_b32 s[sLow], s[sLow], 0x3                            // tileStart *= BPE, in bytes
s_add_u32 s[sgprSrdA+0], s[sgprAddressA+0], s[sLow]         // SRD_base(A) = Address + tileStart
s_addc_u32 s[sgprSrdA+1], s[sgprAddressA+1], 0              // SRD_base(A) = Address + tileStart
s_mov_b32 s[sgprSrdA+2], BufferLimit
s_mov_b32 s[sgprSrdA+3], Srd127_96                          // Set bits 127_96 in SRD
s_add_u32 s[sgprSrdC+0], s[sgprAddressC+0], s[sLow]         // SRD_base(C) = Address + tileStart(in dimension m)
s_addc_u32 s[sgprSrdC+1], s[sgprAddressC+1], 0              // SRD_base(C) = Address + tileStart(in dimension m)
s_mov_b32 s[sgprSrdC+2], BufferLimit
s_mov_b32 s[sgprSrdC+3], Srd127_96                          // Set bits 127_96 in SRD

s_mul_i32 s[sLow], s[sgprBlockIdY], 0x40                    // wg1J * MT1J low 32 bit
s_lshl_b32 s[sLow], s[sLow], 0x3
s_add_u32 s[sgprSrdB+0], s[sgprAddressB+0], s[sLow]          // SRD_base(B) = Address + tileStart  
s_addc_u32 s[sgprSrdB+1], s[sgprAddressB+1], 0               // SRD_base(B) = Address + tileStart
s_mov_b32 s[sgprSrdB+2], BufferLimit
s_mov_b32 s[sgprSrdB+3], Srd127_96                           // Set bits 127_96 in SRD

s_mul_i32 s[sLow], s[sgprBlockIdY], 0x40                     // wg1J * MT1J, within 2^32
s_mul_i32 s[sLow], s[sLow], s[sgprLdc]                       // MT1J * 32 * LDC(low 32 bits)
s_lshl_b32 s[sLow], s[sLow], 0x3
s_add_u32 s[sgprSrdC+0], s[sgprSrdC+0], s[sLow]              // add lo to SRD_base(C)
s_addc_u32 s[sgprSrdC+1], s[sgprSrdC+1], 0                   // add hi to SRD_base(C)


/*********************************************************
/* global read offset: globalReadOffsetA_0_0_0_0
/* global read offset: globalReadOffsetB_0_0_0_0 
/* globalReadOffsetA_0_0_0_0 
/*   = globalReadOffsetA0I + 0 * LSCA + globalReadOffsetAL * LDA 
/* globalReadOffsetB_0_0_0_0 
/*   = globalReadOffsetB1J + 0 * LSCB + globalReadOffsetBL * LDB
/*
/* globalReadOffsetA0I = (serial%LVCA)*GLVWA + (wg0I)*MT0I;
/* globalReadOffsetB1J = (serial%LVCB)*GLVWB + (wg1J)*MT1J;
/* with LVCA = LVCB = 32, GLVWA = GLVWB = 2
/* so globalReadOffsetA0I = globalReadOffsetA1J = (serial % 32) * 2
/*
/* global read addresses: unroll assignment a
/* global read addresses: unroll assignment b
/* globalReadOffsetAL = (serial/LVCA);
/* globalReadOffsetBL = (serial/LVCB);
/* so globalReadOffsetAL = globalReadOffsetBL = serial / 32
/*
/* with LSCA = LSCB = 64, BPE = 8
/* note (wg0I*MT0I) has been added to SRD
/* note (wg1J*MT1J) has been added to SRD
/**********************************************************/
v_lshrrev_b32 v[vtmp1], 0x5, v[vgprSerial]          
v_mul_lo_u32 v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprLda], v[vtmp1]
v_mul_lo_u32 v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprLdb], v[vtmp1]

v_and_b32 v[vtmp2], 0x1f, v[vgprSerial]
v_lshlrev_b32 v[vtmp2], 0x1, v[vtmp2]
v_add_lshl_u32 v[vgprGlobalReadOffsetA_0_0_0_0], v[vgprGlobalReadOffsetA_0_0_0_0], v[vtmp2], 0x3 
v_add_lshl_u32 v[vgprGlobalReadOffsetB_0_0_0_0], v[vgprGlobalReadOffsetB_0_0_0_0], v[vtmp2], 0x3


/******************************************************************
/* Load and Write C offset:
/* there are 4(2*2) 2*2 sub_sub blocks
/* GlobalWriteOffsetC_0_0_0 = (serial/SG0I)*2*LDC+(serial%SG0I)*2
/* GlobalWriteOffsetC_0_0_1 = GlobalWriteOffsetC_0_0_0 + LDC
/* GlobalWriteOffsetC_0_1_0 = GlobalWriteOffsetC_0_0_0 + SG1J * LDC
/* GlobalWriteOffsetC_0_1_1 = GlobalWriteOffsetC_0_0_1 + SG1J * LDC
/* with SG0I = 16, SG1J = 16
/******************************************************************/
v_lshrrev_b32 v[vgprGlobalWriteOffsetC_0_0_0], 0x4, v[vgprSerial]   //serial / 16
v_lshlrev_b32 v[vgprGlobalWriteOffsetC_0_0_0], 0x1, v[vgprGlobalWriteOffsetC_0_0_0]  //serial / 16 * 2
v_mul_lo_u32 v[vgprGlobalWriteOffsetC_0_0_0], s[sgprLdc], v[vgprGlobalWriteOffsetC_0_0_0]
v_and_b32 v[vtmp1], 0xf, v[vgprSerial]    // serial % 16
v_lshlrev_b32 v[vtmp1], 0x1, v[vtmp1]
v_add_lshl_u32 v[vgprGlobalWriteOffsetC_0_0_0], v[vgprGlobalWriteOffsetC_0_0_0], v[vtmp1], 0x3  
s_lshl_b32 s[stmp1], s[sgprLdc], 0x3  // LDC*BPE, ldc in bytes
s_lshl_b32 s[stmp2], s[stmp1],   0x5  // * VECTOR_WIDTH * SG1J 
v_add_u32 v[vgprGlobalWriteOffsetC_0_0_1], s[stmp1], v[vgprGlobalWriteOffsetC_0_0_0] 
v_add_u32 v[vgprGlobalWriteOffsetC_0_1_0], s[stmp2], v[vgprGlobalWriteOffsetC_0_0_0]
v_add_u32 v[vgprGlobalWriteOffsetC_0_1_1], s[stmp2], v[vgprGlobalWriteOffsetC_0_0_1]


/***********************************************************
/* global read a and b
/* global read address of a:
/*   SRD_base(A) + vgprGlobalReadOffsetA_0_0_0_0
/* global read address of b:
/*   SRD_base(B) + vgprGlobalReadOffsetB_0_0_0_0
/************************************************************/
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+3],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen, offset:0
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+3],  v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen, offset:0


/**************************************************************
/* Global Load C 
/**************************************************************/
buffer_load_dwordx4 v[vgprValuC+ 0:vgprValuC+ 3], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0, glc, slc
buffer_load_dwordx4 v[vgprValuC+ 4:vgprValuC+ 7], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+ 8:vgprValuC+11], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0 glc, slc
buffer_load_dwordx4 v[vgprValuC+12:vgprValuC+15], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+16:vgprValuC+19], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0  glc, slc
buffer_load_dwordx4 v[vgprValuC+20:vgprValuC+23], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+24:vgprValuC+27], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0 glc, slc
buffer_load_dwordx4 v[vgprValuC+28:vgprValuC+31], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc


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
/*   lr1J = (serial / SG0I) % SG1J
/*   localReadOffsetB = lr1J*VECTOR_WIDTH
/* with SG0I = 16, SG1J = 16, VECTOR_WIDTH = 2
/* becasue there are some common mediate values between write and read address, 
/* we put them together
/*
/* instruction hint:
/*   v_mul_u32_u24        D.u = S0.u[23:0] * S1.u[23:0] 
/*   v_add_lshl_u32       D.u = (S0.u + S1.u) << S2.u[4:0]
/****************************************************************/
v_lshrrev_b32 v[vgprLocalWriteAddrA], 0x5, v[vgprSerial]
v_mul_u32_u24 v[vgprLocalWriteAddrA], 0x40, v[vgprLocalWriteAddrA]  //1wAL * MT0I
v_mov_b32 v[vgprLocalWriteAddrB], v[vgprLocalWriteAddrA]            //1wBL * MY1J = 1wAL * MT0I
v_and_b32 v[vtmp1], 0x1f, v[vgprSerial]
v_lshlrev_b32 v[vtmp1], 0x1, v[vtmp1]
v_add_lshl_u32 v[vgprLocalWriteAddrA], v[vgprLocalWriteAddrA], v[vtmp1], 0x3 //offset in bytes
v_add_lshl_u32 v[vgprLocalWriteAddrB], v[vgprLocalWriteAddrB], v[vtmp1], 0x3 //offset in bytes
v_add_u32 v[vgprLocalWriteAddrB], 0x1000, v[vgprLocalWriteAddrB]

v_and_b32 v[vgprLocalReadAddrA], 0xf, v[vgprSerial]                    
v_lshlrev_b32 v[vgprLocalReadAddrA], 0x1, v[vgprLocalReadAddrA]
v_lshlrev_b32 v[vgprLocalReadAddrA], 0x3, v[vgprLocalReadAddrA]   

v_lshrrev_b32 v[vgprLocalReadAddrB], 0x4, v[vgprSerial]
v_and_b32 v[vgprLocalReadAddrB], 0xf, v[vgprLocalReadAddrB]     // (serial/SG0I)%SG1J = serial/SG0I
v_lshlrev_b32 v[vgprLocalReadAddrB], 0x1, v[vgprLocalReadAddrB]   //localReadOffsetB = (serial/SG0I)%SG1J*VECTOR_WIDTH
v_lshlrev_b32 v[vgprLocalReadAddrB], 0x3, v[vgprLocalReadAddrB]   //*BPE
v_add_u32 v[vgprLocalReadAddrB], 0x1000, v[vgprLocalReadAddrB]               

/*****************************************************************
/* calculate loop counters
/*****************************************************************/
s_lshr_b32 s[sgprLoopCounters], s[sgprSizesL], 0x3          //sizeL / 8
s_sub_u32 s[sgprLoopCounters], 0x2, s[sgprLoopCounters]  //sgprLoopCounters = -sgprLoopCounters


/****************************************************************
/* local write a and b
/****************************************************************/
s_waitcnt vmcnt(0)              //wait buffer load
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+3] offset:0 
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+3] offset:0   

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
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+3], v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen, offset:0
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+3], v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen, offset:0

GLOBAL_READ_INC_A_AND_B

//iter 0
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:512
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:768
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:512
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:768
s_waitcnt lgkmcnt(4)
MAC_6x4_X0
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:1024
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:1280
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1024
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1280
s_waitcnt lgkmcnt(4)
MAC_6x4_X1
//iter 2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:1536
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:1792
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:1536
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:1792
s_waitcnt lgkmcnt(4)
MAC_6x4_X0
//iter 3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:2048
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:2304
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:2048
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:2304
s_waitcnt lgkmcnt(4)
MAC_6x4_X1          //may be right
//iter 4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:2560
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:2816
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:2560
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:2816
s_waitcnt lgkmcnt(4)
MAC_6x4_X0
//iter 5
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:3072
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:3328
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:3072
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:3328
s_waitcnt lgkmcnt(4)
MAC_6x4_X1
//iter 6
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:3584
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:3840
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:3584
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:3840
s_waitcnt vmcnt(0) // wait for global read
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+3] offset:8192+0
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+3] offset:8192+0
s_waitcnt lgkmcnt(6)
MAC_6x4_X0
//iter 7
s_barrier
s_waitcnt lgkmcnt(0)
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+256
MAC_6x4_X1
/*****************************************************************
/* 2/2 unroll loop
/*****************************************************************/
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen, offset:0
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen, offset:0

GLOBAL_READ_INC_A_AND_B
//iter 0 
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+512
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+768
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+512
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+768
s_waitcnt lgkmcnt(4)
MAC_6x4_X0
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+1024
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+1280
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1024
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1280
s_waitcnt lgkmcnt(4)
MAC_6x4_X1
//iter 2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+1536
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+1792
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1536
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1792
s_waitcnt lgkmcnt(4)
MAC_6x4_X0
//iter 3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+2048
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+2304
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+2048
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+2304
s_waitcnt lgkmcnt(4)
MAC_6x4_X1
//iter 4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+2560
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+2816
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+2560
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+2816
s_waitcnt lgkmcnt(4)
MAC_6x4_X0
//iter 5
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+3072
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+3328
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+3072
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+3328
s_waitcnt lgkmcnt(4)
MAC_6x4_X1
//iter 6
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+3584
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+3840
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+3584
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+3840
s_waitcnt vmcnt(0) // wait for global read
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+3] offset:0
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+3] offset:0
s_waitcnt lgkmcnt(6) // wait for prior local read
MAC_6x4_X0
//iter 7
s_waitcnt lgkmcnt(0)
s_barrier
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0 
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0 
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256
MAC_6x4_X1
//
s_add_u32 s[sgprLoopCounters], s[sgprLoopCounters], 0x2
s_cmp_eq_i32 s[sgprLoopCounters], 0
s_cbranch_scc0 unroll_loop_start

/*************************************************
/* do the last 2 iterations
/*************************************************/
unroll_loop_end:
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+3],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen, offset:0
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+3],  v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen, offset:0
//iter 0
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:512
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:768
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:512
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:768
s_waitcnt lgkmcnt(4)
MAC_6x4_X0
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:1024
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:1280  
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1024
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1280   
s_waitcnt lgkmcnt(4)                                                                    
MAC_6x4_X1                                                                              
//iter 2                                                                            
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:1536
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:1792
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:1536  
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:1792  
s_waitcnt lgkmcnt(4)                                                                    
MAC_6x4_X0                                                                          
//iter 3                                                                            
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:2048 
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:2304 
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:2048    
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:2304    
s_waitcnt lgkmcnt(4)                                                                
MAC_6x4_X1                                                                          
//iter 4                                                                            
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:2560 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:2816     
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:2560    
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:2816
s_waitcnt lgkmcnt(4)                                                                
MAC_6x4_X0                                                                          
//iter 5                                                                            
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:3072 
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:3328 
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:3072
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:3328
s_waitcnt lgkmcnt(4)                                                                 
MAC_6x4_X1                                                                           
//iter 6                                                                                
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:3584
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:3840     
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:3584
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:3840
s_waitcnt vmcnt(0) // wait for global read                                          
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+3] offset:8192+0
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+3] offset:8192+0
s_waitcnt lgkmcnt(6)
MAC_6x4_X0
//iter 7
s_barrier
s_waitcnt lgkmcnt(0)
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+256
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+256
MAC_6x4_X1
//iter 0 
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+512
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+768
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+512
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+768
s_waitcnt lgkmcnt(4)
MAC_6x4_X0
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+1024
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+1280
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1024
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1280
s_waitcnt lgkmcnt(4)
MAC_6x4_X1
//iter 2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+1536
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+1792
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1536
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1792
s_waitcnt lgkmcnt(4)
MAC_6x4_X0
//iter 3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+2048
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+2304
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+2048
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+2304
s_waitcnt lgkmcnt(4)
MAC_6x4_X1
//iter 4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+2560
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+2816
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+2560
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+2816
s_waitcnt lgkmcnt(4)                                                                     
MAC_6x4_X0                                                                               
//iter 5                                                                                 
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+3072
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+3328
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+3072
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+3328
s_waitcnt lgkmcnt(4)                                                                      
MAC_6x4_X1                                                                                
//iter 6                                                                                     
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+3584
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+3840
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+3584
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+3840
s_waitcnt lgkmcnt(4) // wait for prior local read
MAC_6x4_X0
//iter 7
s_waitcnt lgkmcnt(0)
MAC_6x4_X1

/**************************************************************
/* Write C back
/**************************************************************/
GET_INVERT_OF_SIGN
                                       
label_write_c:
buffer_store_dwordx4 v[vgprValuC+ 0:vgprValuC+ 3], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+ 4:vgprValuC+ 7], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256, ;glc, slc
buffer_store_dwordx4 v[vgprValuC+ 8:vgprValuC+11], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+12:vgprValuC+15], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256, ;glc, slc
buffer_store_dwordx4 v[vgprValuC+16:vgprValuC+19], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+20:vgprValuC+23], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256, ;glc, slc
buffer_store_dwordx4 v[vgprValuC+24:vgprValuC+27], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+28:vgprValuC+31], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256, ;glc, slc

label_end:
s_endpgm                                           // End Kernel


