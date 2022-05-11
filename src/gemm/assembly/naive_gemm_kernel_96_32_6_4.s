
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
.amdgpu_hsa_kernel Cijk_Ailk_Bjlk_DB_MT096x032x08_K1_NLCA03_NLCB01_TT06_04_USFGRO0_WG16_08_01
Cijk_Ailk_Bjlk_DB_MT096x032x08_K1_NLCA03_NLCB01_TT06_04_USFGRO0_WG16_08_01:
.amd_kernel_code_t
  is_ptr64 = 1
  enable_sgpr_kernarg_segment_ptr = 1
  kernarg_segment_byte_size = 88 // bytes of kern args
  workitem_vgpr_count = 120 // vgprs
  wavefront_sgpr_count = 78 // sgprs
  compute_pgm_rsrc1_vgprs = 30 // floor((113-1)/4)
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
.set vgprValuA_X0_I0, 48
.set vgprValuA_X1_I0, 60
.set vgprG2LA, 72
.set vgprValuB_X0_I0, 84
.set vgprValuB_X1_I0, 92
.set vgprG2LB, 100
.set vgprLocalReadAddrA, 104
.set vgprLocalReadAddrB, 105
.set vgprLocalWriteAddrA, 106
.set vgprLocalWriteAddrB, 107
.set vgprGlobalReadOffsetA_0_0_0_0, 108
.set vgprGlobalReadOffsetB_0_0_0_0, 109
.set vgprSerial, 110
.set vtmp1, 111
.set vtmp2, 112
.set vtmp3, 113
.set vgprGlobalWriteOffsetC_0_0_0, 114
.set vgprGlobalWriteOffsetC_0_0_1, 115
.set vgprGlobalWriteOffsetC_0_1_0, 116
.set vgprGlobalWriteOffsetC_0_1_1, 117
.set vgprSerial_Mod_16_Mul_2, 118
.set vgprSerial_Div_16, 119
/* max VGPR=113 */

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
v_fma_f64 v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1], v[vgprValuA_X0_I0+\i*2:vgprValuA_X0_I0+\i*2+1], v[vgprValuB_X0_I0+\j*2:vgprValuB_X0_I0+\j*2+1], v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1]
.endm

.macro MAC_6x4_X1_FMA_F64 i,j
v_fma_f64 v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1], v[vgprValuA_X1_I0+\i*2:vgprValuA_X1_I0+\i*2+1], v[vgprValuB_X1_I0+\j*2:vgprValuB_X1_I0+\j*2+1], v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1]
.endm

.macro MAC_6x4_X0
v_fma_f64 v[vgprValuC+(0+0*6)*2:(vgprValuC+0+0*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(0+0*6)*2:(vgprValuC+0+0*6)*2+1]
s_setprio 1 // Raise priority while processing macs 
v_fma_f64 v[vgprValuC+(1+0*6)*2:(vgprValuC+1+0*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(1+0*6)*2:(vgprValuC+1+0*6)*2+1]
v_fma_f64 v[vgprValuC+(2+0*6)*2:(vgprValuC+2+0*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(2+0*6)*2:(vgprValuC+2+0*6)*2+1]
v_fma_f64 v[vgprValuC+(3+0*6)*2:(vgprValuC+3+0*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(3+0*6)*2:(vgprValuC+3+0*6)*2+1]
v_fma_f64 v[vgprValuC+(4+0*6)*2:(vgprValuC+4+0*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(4+0*6)*2:(vgprValuC+4+0*6)*2+1]
v_fma_f64 v[vgprValuC+(5+0*6)*2:(vgprValuC+5+0*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(5+0*6)*2:(vgprValuC+5+0*6)*2+1]
v_fma_f64 v[vgprValuC+(0+1*6)*2:(vgprValuC+0+1*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(0+1*6)*2:(vgprValuC+0+1*6)*2+1]
v_fma_f64 v[vgprValuC+(1+1*6)*2:(vgprValuC+1+1*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(1+1*6)*2:(vgprValuC+1+1*6)*2+1]
v_fma_f64 v[vgprValuC+(2+1*6)*2:(vgprValuC+2+1*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(2+1*6)*2:(vgprValuC+2+1*6)*2+1]
v_fma_f64 v[vgprValuC+(3+1*6)*2:(vgprValuC+3+1*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(3+1*6)*2:(vgprValuC+3+1*6)*2+1]
v_fma_f64 v[vgprValuC+(4+1*6)*2:(vgprValuC+4+1*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(4+1*6)*2:(vgprValuC+4+1*6)*2+1]
v_fma_f64 v[vgprValuC+(5+1*6)*2:(vgprValuC+5+1*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(5+1*6)*2:(vgprValuC+5+1*6)*2+1]
v_fma_f64 v[vgprValuC+(0+2*6)*2:(vgprValuC+0+2*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(0+2*6)*2:(vgprValuC+0+2*6)*2+1]
v_fma_f64 v[vgprValuC+(1+2*6)*2:(vgprValuC+1+2*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(1+2*6)*2:(vgprValuC+1+2*6)*2+1]
v_fma_f64 v[vgprValuC+(2+2*6)*2:(vgprValuC+2+2*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(2+2*6)*2:(vgprValuC+2+2*6)*2+1]
v_fma_f64 v[vgprValuC+(3+2*6)*2:(vgprValuC+3+2*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(3+2*6)*2:(vgprValuC+3+2*6)*2+1]
v_fma_f64 v[vgprValuC+(4+2*6)*2:(vgprValuC+4+2*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(4+2*6)*2:(vgprValuC+4+2*6)*2+1]
v_fma_f64 v[vgprValuC+(5+2*6)*2:(vgprValuC+5+2*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(5+2*6)*2:(vgprValuC+5+2*6)*2+1]
v_fma_f64 v[vgprValuC+(0+3*6)*2:(vgprValuC+0+3*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(0+3*6)*2:(vgprValuC+0+3*6)*2+1]
v_fma_f64 v[vgprValuC+(1+3*6)*2:(vgprValuC+1+3*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(1+3*6)*2:(vgprValuC+1+3*6)*2+1]
v_fma_f64 v[vgprValuC+(2+3*6)*2:(vgprValuC+2+3*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(2+3*6)*2:(vgprValuC+2+3*6)*2+1]
v_fma_f64 v[vgprValuC+(3+3*6)*2:(vgprValuC+3+3*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(3+3*6)*2:(vgprValuC+3+3*6)*2+1]
v_fma_f64 v[vgprValuC+(4+3*6)*2:(vgprValuC+4+3*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(4+3*6)*2:(vgprValuC+4+3*6)*2+1]
v_fma_f64 v[vgprValuC+(5+3*6)*2:(vgprValuC+5+3*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(5+3*6)*2:(vgprValuC+5+3*6)*2+1]
s_setprio 0 // Reset priority after macs 
.endm
.macro MAC_6x4_X1
//v_cvt_f64_u32 v[vgprValuA_X1_I0:vgprValuA_X1_I0+1], 0x1
v_fma_f64 v[vgprValuC+(0+0*6)*2:(vgprValuC+0+0*6)*2+1], v[vgprValuA_X1_I0+0*2:vgprValuA_X1_I0+0*2+1], v[vgprValuB_X1_I0+0*2:vgprValuB_X1_I0+0*2+1], v[vgprValuC+(0+0*6)*2:(vgprValuC+0+0*6)*2+1]
s_setprio 1 // Raise priority while processing macs 
v_fma_f64 v[vgprValuC+(1+0*6)*2:(vgprValuC+1+0*6)*2+1], v[vgprValuA_X1_I0+1*2:vgprValuA_X1_I0+1*2+1], v[vgprValuB_X1_I0+0*2:vgprValuB_X1_I0+0*2+1], v[vgprValuC+(1+0*6)*2:(vgprValuC+1+0*6)*2+1]
v_fma_f64 v[vgprValuC+(2+0*6)*2:(vgprValuC+2+0*6)*2+1], v[vgprValuA_X1_I0+2*2:vgprValuA_X1_I0+2*2+1], v[vgprValuB_X1_I0+0*2:vgprValuB_X1_I0+0*2+1], v[vgprValuC+(2+0*6)*2:(vgprValuC+2+0*6)*2+1]
v_fma_f64 v[vgprValuC+(3+0*6)*2:(vgprValuC+3+0*6)*2+1], v[vgprValuA_X1_I0+3*2:vgprValuA_X1_I0+3*2+1], v[vgprValuB_X1_I0+0*2:vgprValuB_X1_I0+0*2+1], v[vgprValuC+(3+0*6)*2:(vgprValuC+3+0*6)*2+1]
v_fma_f64 v[vgprValuC+(4+0*6)*2:(vgprValuC+4+0*6)*2+1], v[vgprValuA_X1_I0+4*2:vgprValuA_X1_I0+4*2+1], v[vgprValuB_X1_I0+0*2:vgprValuB_X1_I0+0*2+1], v[vgprValuC+(4+0*6)*2:(vgprValuC+4+0*6)*2+1]
v_fma_f64 v[vgprValuC+(5+0*6)*2:(vgprValuC+5+0*6)*2+1], v[vgprValuA_X1_I0+5*2:vgprValuA_X1_I0+5*2+1], v[vgprValuB_X1_I0+0*2:vgprValuB_X1_I0+0*2+1], v[vgprValuC+(5+0*6)*2:(vgprValuC+5+0*6)*2+1]
v_fma_f64 v[vgprValuC+(0+1*6)*2:(vgprValuC+0+1*6)*2+1], v[vgprValuA_X1_I0+0*2:vgprValuA_X1_I0+0*2+1], v[vgprValuB_X1_I0+1*2:vgprValuB_X1_I0+1*2+1], v[vgprValuC+(0+1*6)*2:(vgprValuC+0+1*6)*2+1]
v_fma_f64 v[vgprValuC+(1+1*6)*2:(vgprValuC+1+1*6)*2+1], v[vgprValuA_X1_I0+1*2:vgprValuA_X1_I0+1*2+1], v[vgprValuB_X1_I0+1*2:vgprValuB_X1_I0+1*2+1], v[vgprValuC+(1+1*6)*2:(vgprValuC+1+1*6)*2+1]
v_fma_f64 v[vgprValuC+(2+1*6)*2:(vgprValuC+2+1*6)*2+1], v[vgprValuA_X1_I0+2*2:vgprValuA_X1_I0+2*2+1], v[vgprValuB_X1_I0+1*2:vgprValuB_X1_I0+1*2+1], v[vgprValuC+(2+1*6)*2:(vgprValuC+2+1*6)*2+1]
v_fma_f64 v[vgprValuC+(3+1*6)*2:(vgprValuC+3+1*6)*2+1], v[vgprValuA_X1_I0+3*2:vgprValuA_X1_I0+3*2+1], v[vgprValuB_X1_I0+1*2:vgprValuB_X1_I0+1*2+1], v[vgprValuC+(3+1*6)*2:(vgprValuC+3+1*6)*2+1]
v_fma_f64 v[vgprValuC+(4+1*6)*2:(vgprValuC+4+1*6)*2+1], v[vgprValuA_X1_I0+4*2:vgprValuA_X1_I0+4*2+1], v[vgprValuB_X1_I0+1*2:vgprValuB_X1_I0+1*2+1], v[vgprValuC+(4+1*6)*2:(vgprValuC+4+1*6)*2+1]
v_fma_f64 v[vgprValuC+(5+1*6)*2:(vgprValuC+5+1*6)*2+1], v[vgprValuA_X1_I0+5*2:vgprValuA_X1_I0+5*2+1], v[vgprValuB_X1_I0+1*2:vgprValuB_X1_I0+1*2+1], v[vgprValuC+(5+1*6)*2:(vgprValuC+5+1*6)*2+1]
v_fma_f64 v[vgprValuC+(0+2*6)*2:(vgprValuC+0+2*6)*2+1], v[vgprValuA_X1_I0+0*2:vgprValuA_X1_I0+0*2+1], v[vgprValuB_X1_I0+2*2:vgprValuB_X1_I0+2*2+1], v[vgprValuC+(0+2*6)*2:(vgprValuC+0+2*6)*2+1]
v_fma_f64 v[vgprValuC+(1+2*6)*2:(vgprValuC+1+2*6)*2+1], v[vgprValuA_X1_I0+1*2:vgprValuA_X1_I0+1*2+1], v[vgprValuB_X1_I0+2*2:vgprValuB_X1_I0+2*2+1], v[vgprValuC+(1+2*6)*2:(vgprValuC+1+2*6)*2+1]
v_fma_f64 v[vgprValuC+(2+2*6)*2:(vgprValuC+2+2*6)*2+1], v[vgprValuA_X1_I0+2*2:vgprValuA_X1_I0+2*2+1], v[vgprValuB_X1_I0+2*2:vgprValuB_X1_I0+2*2+1], v[vgprValuC+(2+2*6)*2:(vgprValuC+2+2*6)*2+1]
v_fma_f64 v[vgprValuC+(3+2*6)*2:(vgprValuC+3+2*6)*2+1], v[vgprValuA_X1_I0+3*2:vgprValuA_X1_I0+3*2+1], v[vgprValuB_X1_I0+2*2:vgprValuB_X1_I0+2*2+1], v[vgprValuC+(3+2*6)*2:(vgprValuC+3+2*6)*2+1]
v_fma_f64 v[vgprValuC+(4+2*6)*2:(vgprValuC+4+2*6)*2+1], v[vgprValuA_X1_I0+4*2:vgprValuA_X1_I0+4*2+1], v[vgprValuB_X1_I0+2*2:vgprValuB_X1_I0+2*2+1], v[vgprValuC+(4+2*6)*2:(vgprValuC+4+2*6)*2+1]
v_fma_f64 v[vgprValuC+(5+2*6)*2:(vgprValuC+5+2*6)*2+1], v[vgprValuA_X1_I0+5*2:vgprValuA_X1_I0+5*2+1], v[vgprValuB_X1_I0+2*2:vgprValuB_X1_I0+2*2+1], v[vgprValuC+(5+2*6)*2:(vgprValuC+5+2*6)*2+1]
v_fma_f64 v[vgprValuC+(0+3*6)*2:(vgprValuC+0+3*6)*2+1], v[vgprValuA_X1_I0+0*2:vgprValuA_X1_I0+0*2+1], v[vgprValuB_X1_I0+3*2:vgprValuB_X1_I0+3*2+1], v[vgprValuC+(0+3*6)*2:(vgprValuC+0+3*6)*2+1]
v_fma_f64 v[vgprValuC+(1+3*6)*2:(vgprValuC+1+3*6)*2+1], v[vgprValuA_X1_I0+1*2:vgprValuA_X1_I0+1*2+1], v[vgprValuB_X1_I0+3*2:vgprValuB_X1_I0+3*2+1], v[vgprValuC+(1+3*6)*2:(vgprValuC+1+3*6)*2+1]
v_fma_f64 v[vgprValuC+(2+3*6)*2:(vgprValuC+2+3*6)*2+1], v[vgprValuA_X1_I0+2*2:vgprValuA_X1_I0+2*2+1], v[vgprValuB_X1_I0+3*2:vgprValuB_X1_I0+3*2+1], v[vgprValuC+(2+3*6)*2:(vgprValuC+2+3*6)*2+1]
v_fma_f64 v[vgprValuC+(3+3*6)*2:(vgprValuC+3+3*6)*2+1], v[vgprValuA_X1_I0+3*2:vgprValuA_X1_I0+3*2+1], v[vgprValuB_X1_I0+3*2:vgprValuB_X1_I0+3*2+1], v[vgprValuC+(3+3*6)*2:(vgprValuC+3+3*6)*2+1]
v_fma_f64 v[vgprValuC+(4+3*6)*2:(vgprValuC+4+3*6)*2+1], v[vgprValuA_X1_I0+4*2:vgprValuA_X1_I0+4*2+1], v[vgprValuB_X1_I0+3*2:vgprValuB_X1_I0+3*2+1], v[vgprValuC+(4+3*6)*2:(vgprValuC+4+3*6)*2+1]
v_fma_f64 v[vgprValuC+(5+3*6)*2:(vgprValuC+5+3*6)*2+1], v[vgprValuA_X1_I0+5*2:vgprValuA_X1_I0+5*2+1], v[vgprValuB_X1_I0+3*2:vgprValuB_X1_I0+3*2+1], v[vgprValuC+(5+3*6)*2:(vgprValuC+5+3*6)*2+1]
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

s_mul_i32 s[sLow], s[sgprBlockIdX], 0x60                    // wg0I * MT0I, within 2^32
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

s_mul_i32 s[sLow], s[sgprBlockIdY], 0x20                          // wg1J * MT1J low 32 bit
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

s_mul_i32 s[sLow], s[sgprBlockIdY], 0x20                     // wg1J * MT1J, within 2^32
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
v_mul_lo_u32 v[vtmp1], s[sgprLda], v[vgprSerial_Div_16]
v_mul_lo_u32 v[vtmp2], s[sgprLdb], v[vgprSerial_Div_16]
v_add_lshl_u32 v[vgprGlobalReadOffsetA_0_0_0_0], v[vtmp1], v[vgprSerial_Mod_16_Mul_2], 0x3 //globalReadOffsetA_0_0_0_0, in bytes
v_add_lshl_u32 v[vgprGlobalReadOffsetB_0_0_0_0], v[vtmp2], v[vgprSerial_Mod_16_Mul_2], 0x3 //globalReadOffsetB_0_0_0_0, in bytes


/******************************************************************
/* Load and Write C offset:
/* there are 6(3*2) 2*2 sub_sub blocks
/* GlobalWriteOffsetC_0_0_0 = (serial/SG0I)*2*LDC+(serial%SG0I)*2
/* GlobalWriteOffsetC_0_0_1 = GlobalWriteOffsetC_0_0_0 + LDC
/* GlobalWriteOffsetC_0_1_0 = GlobalWriteOffsetC_0_0_0 + SG0I * LDC
/* GlobalWriteOffsetC_0_1_1 = GlobalWriteOffsetC_0_0_1 + SG0I * LDC
/* with SG0I = 16
/******************************************************************/
s_lshl_b32 s[stmp1], s[sgprLdc], 0x3  // LDC*BPE, ldc in bytes
s_lshl_b32 s[stmp2], s[stmp1],   0x4  // LDC * SG0I * BPE
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
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+7],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x100
buffer_load_dwordx4 v[vgprG2LA+8:vgprG2LA+11], v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x200
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+3],  v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0


/**************************************************************
/* Global Load C 
/**************************************************************/
buffer_load_dwordx4 v[vgprValuC+ 0:vgprValuC+ 3], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0, glc, slc
buffer_load_dwordx4 v[vgprValuC+ 4:vgprValuC+ 7], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+ 8:vgprValuC+11], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 glc, slc
buffer_load_dwordx4 v[vgprValuC+12:vgprValuC+15], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0 glc, slc
buffer_load_dwordx4 v[vgprValuC+16:vgprValuC+19], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+20:vgprValuC+23], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 glc, slc
buffer_load_dwordx4 v[vgprValuC+24:vgprValuC+27], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0  glc, slc
buffer_load_dwordx4 v[vgprValuC+28:vgprValuC+31], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+32:vgprValuC+35], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 glc, slc
buffer_load_dwordx4 v[vgprValuC+36:vgprValuC+39], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0 glc, slc
buffer_load_dwordx4 v[vgprValuC+40:vgprValuC+43], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256 glc, slc
buffer_load_dwordx4 v[vgprValuC+44:vgprValuC+47], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512 glc, slc



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
/* with LVCA = LVCB = 16, GLVWA = GLVWB = 2, we have
/*   1wA0I = 1wB1J = (serial % 16) * 2, 1wAL = 1wBL = serial / 16
/* because the base of lds buffer is always 0, so address = offset
/*
/* local read address of a:
/*   lr0I = (serial % SG0I)  
/*   localReadOffsetA = lr0I*VECTOR_WIDTH
/* local read address of b:
/*   lr1J = (serial / SG0I) % SG1J
/*   localReadOffsetB = lr1J*VECTOR_WIDTH
/* with SG0I = 16, SG1J = 8, VECTOR_WIDTH = 2
/* becasue there are some common mediate values between write and read address, 
/* we put them together
/*
/* instruction hint:
/*   v_mul_u32_u24        D.u = S0.u[23:0] * S1.u[23:0] 
/*   v_add_lshl_u32       D.u = (S0.u + S1.u) << S2.u[4:0]
/****************************************************************/
v_mul_u32_u24 v[vgprLocalWriteAddrA], 0x60, v[vgprSerial_Div_16]  //1wAL * MT0I
v_mul_u32_u24 v[vgprLocalWriteAddrB], 0x20, v[vgprSerial_Div_16]  //1wBL * MY1J
v_add_lshl_u32 v[vgprLocalWriteAddrA], v[vgprLocalWriteAddrA], v[vgprSerial_Mod_16_Mul_2], 0x3 //offset in bytes
v_add_lshl_u32 v[vgprLocalWriteAddrB], v[vgprLocalWriteAddrB], v[vgprSerial_Mod_16_Mul_2], 0x3 //offset in bytes
v_add_u32 v[vgprLocalWriteAddrB], 0x1800, v[vgprLocalWriteAddrB]
v_mov_b32 v[vgprLocalReadAddrA], v[vgprSerial_Mod_16_Mul_2]                    // localReadOffsetA = (serial % SG0I)*VECTOR_WIDTH

//v_lshlrev_b32 v[vgprLocalReadAddrA], v[vgprLocalReadAddrA], 0x3   //*BPE  vital error in syntax
v_lshlrev_b32 v[vgprLocalReadAddrA], 0x3, v[vgprLocalReadAddrA]   //*BPE
v_and_b32 v[vgprLocalReadAddrB], 0x7, v[vgprSerial_Div_16]                    // (serial/SG0I) % SG1J
v_lshlrev_b32 v[vgprLocalReadAddrB], 0x1, v[vgprLocalReadAddrB]   //localReadOffsetB = (serial/SG0I)%SG1J*VECTOR_WIDTH
v_lshlrev_b32 v[vgprLocalReadAddrB], 0x3, v[vgprLocalReadAddrB]   //*BPE
v_add_u32 v[vgprLocalReadAddrB], 0x1800, v[vgprLocalReadAddrB]               

/*****************************************************************
/* calculate loop counters
/*****************************************************************/
s_lshr_b32 s[sgprLoopCounters], s[sgprSizesL], 0x3          //sizeL / 8
s_sub_u32 s[sgprLoopCounters], 0x2, s[sgprLoopCounters]  //sgprLoopCounters = -sgprLoopCounters

s_waitcnt vmcnt(0)


/****************************************************************
/* local write a and b
/* use hard-coded offset to represent localWriteOffsetA_0_0_0_0,
/* localWriteOffsetA_1_0_0_0, localWriteOffsetA_2_0_0_0 to save
/* registers
/****************************************************************/
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+3] offset:0    // 0*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+7] offset:256  // 1*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+8:vgprG2LA+11] offset:512  // 2*LSCA*BPE
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+3] offset:0    // 0*LSCB*BPE

GET_INVERT_OF_SIGN

s_waitcnt lgkmcnt(0)
s_barrier


/*****************************************************************
/*  local prefetch a and b
/*****************************************************************/
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:256
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:512
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:128
/******************************************************************
/* these mistakes in calculate LDS access address are worth remembering
/*v_mov_b32 v[vgprLocalReadAddrA], 0x0
/*v_mov_b32 v[vgprLocalReadAddrB], 0x400
/*v_mov_b32 v[vgprLocalWriteAddrA], 0x400
/*v_mov_b32 v[vgprLocalWriteAddrB], 0x400
/*****************************************************************/

/*****************************************************************
/* main unroll loops
/*****************************************************************/
unroll_loop_start:
/*****************************************************************
/* 1/2 unroll loop
/*****************************************************************/
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+3],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+7],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x100
buffer_load_dwordx4 v[vgprG2LA+8:vgprG2LA+11], v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x200
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+3],  v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0
GLOBAL_READ_INC_A_AND_B

//iter 0
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:768 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:1024
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:1280
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:256 
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:384 
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:1536 
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:1792 
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:2048 
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:512 
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:640
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:2304 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:2560 
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:2816 
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:768 
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:896
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:3072 
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:3328 
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:3584 
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1024 
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1152 
s_waitcnt lgkmcnt(5)
MAC_6x4_X1          //may be right
//iter 4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:3840 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:4096 
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:4352 
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:1280 
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:1408 
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 5
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:4608 
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:4864 
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:5120 
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1536 
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1664 
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 6
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:5376 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:5632 
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:5888 
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:1792 
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:1920 
s_waitcnt vmcnt(0) // wait for global read
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:8192+0
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+4+3] offset:8192+256
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+8:vgprG2LA+8+3] offset:8192+512
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:8192+0
s_waitcnt lgkmcnt(9)
MAC_6x4_X0
//iter 7
s_barrier
s_waitcnt lgkmcnt(0)
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+256
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:8192+512
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+128
MAC_6x4_X1
/*****************************************************************
/* 2/2 unroll loop
/*****************************************************************/
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+4+3], v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x100
buffer_load_dwordx4 v[vgprG2LA+8:vgprG2LA+8+3], v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x200
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0
GLOBAL_READ_INC_A_AND_B
//iter 0 
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+768 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+1024
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:8192+1280
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+256
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+384
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+1536
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+1792
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:8192+2048
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+512
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+640
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+2304
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+2560
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:8192+2816
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+768
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+896
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+3072
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+3328
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:8192+3584
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1024
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1152
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+3840
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+4096
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:8192+4352
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1280
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1408
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 5
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+4608
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+4864
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:8192+5120
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1536
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1664
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 6
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+5376
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+5632
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:8192+5888
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1792
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1920
s_waitcnt vmcnt(0) // wait for global read
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+4+3] offset:256
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+8:vgprG2LA+8+3] offset:512
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 
s_waitcnt lgkmcnt(9) // wait for prior local read
MAC_6x4_X0
//iter 7
s_waitcnt lgkmcnt(0)
s_barrier
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0 
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:256
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:512
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0 
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:128
MAC_6x4_X1
//
s_add_u32 s[sgprLoopCounters], s[sgprLoopCounters], 0x2
s_cmp_eq_i32 s[sgprLoopCounters], 0
s_cbranch_scc0 unroll_loop_start

/*************************************************
/* do the last 2 iterations
/*************************************************/
unroll_loop_end:
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+3],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+7],  v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x100
buffer_load_dwordx4 v[vgprG2LA+8:vgprG2LA+11], v[vgprGlobalReadOffsetA_0_0_0_0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0x200
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+3],  v[vgprGlobalReadOffsetB_0_0_0_0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0
//iter 0
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:768 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:1024
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:1280
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:256 
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:384 
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:1536 
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:1792 
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:2048 
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:512 
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:640
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:2304 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:2560 
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:2816 
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:768 
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:896
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:3072 
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:3328 
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:3584 
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1024 
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1152 
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:3840 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:4096 
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:4352 
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:1280 
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:1408 
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 5
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:4608 
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:4864 
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:5120 
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1536 
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1664 
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 6
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:5376 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:5632 
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:5888 
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:1792 
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:1920 
s_waitcnt vmcnt(0) // wait for global read
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:8192 
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+4+3] offset:8448 
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+8:vgprG2LA+8+3] offset:8704 
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:8192 
s_waitcnt lgkmcnt(9)
MAC_6x4_X0
//iter 7
s_barrier
s_waitcnt lgkmcnt(0)
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+256
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:8192+512
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+128
MAC_6x4_X1
//iter 0 
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+768 
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+1024
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:8192+1280
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+256
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+384
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 1
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+1536
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+1792
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:8192+2048
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+512
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+640
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 2
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+2304
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+2560
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:8192+2816
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+768
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+896
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 3
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+3072
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+3328
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:8192+3584
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1024
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1152
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 4
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+3840
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+4096
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:8192+4352
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1280
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1408
s_waitcnt lgkmcnt(5)
MAC_6x4_X0
//iter 5
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192+4608
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192+4864
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:8192+5120
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1536
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1664
s_waitcnt lgkmcnt(5)
MAC_6x4_X1
//iter 6
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8192+5376
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8192+5632
ds_read_b128 v[vgprValuA_X1_I0+8:vgprValuA_X1_I0+8+3], v[vgprLocalReadAddrA] offset:8192+5888
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8192+1792
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:8192+1920
s_waitcnt lgkmcnt(5) // wait for prior local read
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
buffer_store_dwordx4 v[vgprValuC+ 8:vgprValuC+11], v[vgprGlobalWriteOffsetC_0_0_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512, ;glc, slc
buffer_store_dwordx4 v[vgprValuC+12:vgprValuC+15], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+16:vgprValuC+19], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256, ;glc, slc
buffer_store_dwordx4 v[vgprValuC+20:vgprValuC+23], v[vgprGlobalWriteOffsetC_0_0_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512, ;glc, slc
buffer_store_dwordx4 v[vgprValuC+24:vgprValuC+27], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+28:vgprValuC+31], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256, ;glc, slc
buffer_store_dwordx4 v[vgprValuC+32:vgprValuC+35], v[vgprGlobalWriteOffsetC_0_1_0], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512, ;glc, slc
buffer_store_dwordx4 v[vgprValuC+36:vgprValuC+39], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,   ;glc, slc
buffer_store_dwordx4 v[vgprValuC+40:vgprValuC+43], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:256, ;glc, slc
buffer_store_dwordx4 v[vgprValuC+44:vgprValuC+47], v[vgprGlobalWriteOffsetC_0_1_1], s[sgprSrdC:sgprSrdC+3], 0, offen, offset:512, ;glc, slc

label_end:
s_endpgm                                           // End Kernel


