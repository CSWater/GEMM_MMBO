
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
.amdgpu_hsa_kernel Cijk_Ailk_Bjlk_DB_MT032x096x08_AF0EM02_AF1EM02_AMAS01_ASEM02_BL1_DTL0_EPS1_FL00_GRVW02_GSU01_ISA906_K1_KLA_LPA00_LPB00_MGWVW01_NLCA01_NLCB03_PGR1_PLR1_SNLL1_TT04_06_USFGRO01_VAW01_VW02_WG08_16_01_WGM08
Cijk_Ailk_Bjlk_DB_MT032x096x08_AF0EM02_AF1EM02_AMAS01_ASEM02_BL1_DTL0_EPS1_FL00_GRVW02_GSU01_ISA906_K1_KLA_LPA00_LPB00_MGWVW01_NLCA01_NLCB03_PGR1_PLR1_SNLL1_TT04_06_USFGRO01_VAW01_VW02_WG08_16_01_WGM08:
.amd_kernel_code_t
  is_ptr64 = 1
  enable_sgpr_kernarg_segment_ptr = 1
  kernarg_segment_byte_size = 92 // bytes of kern args
  workitem_vgpr_count = 111 // vgprs
  wavefront_sgpr_count = 78 // sgprs
  compute_pgm_rsrc1_vgprs = 27 // floor((111-1)/4)
  compute_pgm_rsrc1_sgprs = 10 // floor((78-1)/8)
  compute_pgm_rsrc2_tidig_comp_cnt = 0 // 1D wg
  compute_pgm_rsrc2_tgid_x_en = 1 // wg.x
  compute_pgm_rsrc2_tgid_y_en = 1 // wg.y
  compute_pgm_rsrc2_tgid_z_en = 1 // wg.z
  workgroup_group_segment_byte_size = 16384 // lds bytes
  compute_pgm_rsrc2_user_sgpr = 2 // vcc
  kernarg_segment_alignment = 4
  group_segment_alignment = 4
  private_segment_alignment = 4
.end_amd_kernel_code_t

/******************************************/
/* Optimizations and Config:              */
/******************************************/
/* ThreadTile= 4 x 6 */
/* SubGroup= 8 x 16 */
/* VectorWidth=2 */
/* GlobalLoadVectorWidthA=2, GlobalLoadVectorWidthB=2 */
/* DirectToLdsA=False */
/* DirectToLdsB=False */
/* UseSgprForGRO=1 */

/******************************************/
/* Asm syntax workarounds                 */
/******************************************/
.macro _v_add_co_u32 dst, cc, src0, src1, dpp=
   v_add_co_u32 \dst, \cc, \src0, \src1 \dpp
.endm
.macro _v_sub_co_u32 dst, cc, src0, src1, dpp=
   v_sub_co_u32 \dst, \cc, \src0, \src1 \dpp
.endm
.macro _v_addc_co_u32 dst, ccOut, src0, ccIn, src1, dpp=
   v_addc_co_u32 \dst, \ccOut, \src0, \ccIn, \src1 \dpp
.endm
.macro _v_add_lshl_u32 dst, src0, src1, shiftCnt
    v_add_lshl_u32 \dst, \src0, \src1, \shiftCnt
.endm
.macro _v_lshl_add_u32 dst, src0, src1, shiftCnt
    v_lshl_add_u32 \dst, \src0, \src1, \shiftCnt
.endm

/******************************************/
/* Magic div and mod functions            */
/******************************************/
.macro V_MAGIC_DIV dstIdx, dividend, magicNumber, magicShift
    v_mul_lo_u32 v[\dstIdx+0], \dividend, \magicNumber
    v_mul_hi_u32 v[\dstIdx+1], \dividend, \magicNumber
    v_lshrrev_b64 v[\dstIdx:\dstIdx+1], \magicShift, v[\dstIdx:\dstIdx+1]
.endm

/******************************************/
/* VGPR Assignments                       */
/******************************************/
.set vgprValuC, 0
/* ValuA/B   Xn=PLR buffer idx,  In=InnerUnroll idx */
.set vgprValuA_X0_I0, 48
.set vgprValuA_X1_I0, 56
.set vgprG2LA, 64
.set vgprValuB_X0_I0, 68
.set vgprValuB_X1_I0, 80
.set vgprG2LB, 92
.set vgprLocalReadAddrA, 104
.set vgprLocalReadAddrB, 105
.set vgprLocalWriteAddrA, 106
.set vgprLocalWriteAddrB, 107
.set vgprGlobalReadOffsetA, 108
.set vgprGlobalReadOffsetB, 109
.set vgprSerial, 110
/* max VGPR=111 */

/******************************************/
/* SGPR Assignments                       */
/******************************************/
.set sgprKernArgAddress, 0
.set sgprWorkGroup0, 2
.set sgprWorkGroup1, 3
.set sgprWorkGroup2, 4
.set sgprNumWorkGroups0, 5
.set sgprNumWorkGroups1, 6
.set sgprSrdA, 8
.set sgprSrdB, 12
.set sgprSrdC, 16
.set sgprTensor2dSizeC, 20
.set sgprTensor2dSizeA, 22
.set sgprTensor2dSizeB, 24
.set sgprSaveExecMask, 26
.set sgprAddressC, 28
.set sgprStridesC, 30
.set sgprAlpha, 32
.set sgprBeta, 34
.set sgprSizesFree, 36
.set sgprSizesSum, 39
.set sgprLoopCounters, 40
.set sgprStridesA, 41
.set sgprStridesB, 43
.set sgprAddressA, 45
.set sgprAddressB, 47
.set sgprSrdShadowLimitA, 50
.set sgprSrdShadowLimitB, 52
.set sgprOffsetC, 54
.set sgprOffsetA, 55
.set sgprOffsetB, 56
.set sgprGlobalReadIncsA, 57
.set sgprGlobalReadIncsB, 58
.set sgprScalarGlobalReadOffsetB, 59
/* max SGPR=78 */

/******************************************/
/* 2GB limit - set offsets to -1 to exceed this and clamp */
/******************************************/
.set BufferLimit, 0x80000000

/******************************************/
/* Bits 127:96 of SRD.  Set DataFormat = 32 bit */
/******************************************/
.set Srd127_96, 0x0020000
.set BufferOOB, 0x80000000

/* Global Offset A */
.macro GLOBAL_OFFSET_A vgprAddr vgprOffset0I vgprOffsetL vgprTmp
v_mul_lo_u32 v[\vgprTmp+0], s[sgprStridesA+0], v[\vgprOffsetL] // mul d1 lower
_v_add_co_u32 v[\vgprAddr+0], vcc, v[\vgprTmp+0], v[\vgprOffset0I] // accumulate d1 lower
_v_add_co_u32 v[\vgprAddr+0], vcc, 0x2, v[\vgprAddr+0] // add prepad for pointer shift
v_lshlrev_b32 v[\vgprAddr+0], 0x3, v[\vgprAddr+0]  // offset *= bytes/element
.endm

/* Global Offset B */
.macro GLOBAL_OFFSET_B vgprAddr vgprOffset1J vgprOffsetL vgprTmp
v_mul_lo_u32 v[\vgprTmp+0], s[sgprStridesB+0], v[\vgprOffsetL] // mul d1 lower
_v_add_co_u32 v[\vgprAddr+0], vcc, v[\vgprTmp+0], v[\vgprOffset1J] // accumulate d1 lower
_v_add_co_u32 v[\vgprAddr+0], vcc, 0x2, v[\vgprAddr+0] // add prepad for pointer shift
v_lshlrev_b32 v[\vgprAddr+0], 0x3, v[\vgprAddr+0]  // offset *= bytes/element
.endm

/******************************************/
/* Dynamic Scalar Divide: vQuotient=vDividend/vDivisor; vRemainder=vDividend%vDivisor; */
/******************************************/
.macro DYNAMIC_VECTOR_DIVIDE vQuotient vRemainder vDividend vDivisor vTmp0 vTmp1 sTmp
v_cvt_f32_u32 v[\vQuotient], v[\vDivisor]          // 
v_rcp_f32 v[\vQuotient], v[\vQuotient]             // 
v_mul_f32 v[\vQuotient], 0x4f800000, v[\vQuotient] // 
v_cvt_u32_f32 v[\vQuotient], v[\vQuotient]         // 
v_mul_lo_u32 v[\vRemainder], v[\vDivisor], v[\vQuotient] // 
v_mul_hi_u32 v[\vTmp0], v[\vDivisor], v[\vQuotient] // 
_v_sub_co_u32 v[\vTmp1], vcc, 0x0, v[\vRemainder]  // 
v_cmp_ne_i32 s[\sTmp:\sTmp+1], 0x0, v[\vTmp0]      // 
v_cndmask_b32 v[\vRemainder], v[\vTmp1], v[\vRemainder], s[\sTmp:\sTmp+1] // 
v_mul_hi_u32 v[\vRemainder], v[\vRemainder], v[\vQuotient] // 
_v_sub_co_u32 v[\vTmp0], vcc, v[\vQuotient], v[\vRemainder] // 
_v_add_co_u32 v[\vQuotient], vcc, v[\vQuotient], v[\vRemainder] // 
v_cndmask_b32 v[\vQuotient], v[\vQuotient], v[\vTmp0], s[\sTmp:\sTmp+1] // 
v_mul_hi_u32 v[\vQuotient], v[\vQuotient], v[\vDividend] // 
v_mul_lo_u32 v[\vRemainder], v[\vQuotient], v[\vDivisor] // 
_v_sub_co_u32 v[\vTmp0], vcc, v[\vDividend], v[\vRemainder] // 
v_cmp_ge_u32 s[\sTmp:\sTmp+1], v[\vDividend], v[\vRemainder] // 
_v_add_co_u32 v[\vRemainder], vcc, 0x1, v[\vQuotient] // 
_v_add_co_u32 v[\vTmp1], vcc, -1, v[\vQuotient]    // 
v_cmp_le_u32 vcc, v[\vDivisor], v[\vTmp0]          // 
s_and_b64 vcc, s[\sTmp:\sTmp+1], vcc               // 
v_cndmask_b32 v[\vQuotient], v[\vQuotient], v[\vRemainder], vcc // 
v_cndmask_b32 v[\vQuotient], v[\vTmp1], v[\vQuotient], s[\sTmp:\sTmp+1] // 
v_cmp_ne_i32 vcc, 0x0, v[\vDivisor]                // 
v_cndmask_b32 v[\vQuotient], -1, v[\vQuotient], vcc // final result
v_mul_lo_u32 v[\vRemainder], v[\vQuotient], v[\vDivisor] // 
_v_sub_co_u32 v[\vRemainder], vcc, v[\vDividend], v[\vRemainder] // final result
.endm

/******************************************/
/* 4x6 thread-tile                        */
/******************************************/
.macro MAC_4x6_X0
v_fma_f64 v[vgprValuC+(0+0*4)*2:(vgprValuC+0+0*4)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(0+0*4)*2:(vgprValuC+0+0*4)*2+1]
s_setprio 1 // Raise priority while processing macs 
v_fma_f64 v[vgprValuC+(1+0*4)*2:(vgprValuC+1+0*4)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(1+0*4)*2:(vgprValuC+1+0*4)*2+1]
v_fma_f64 v[vgprValuC+(2+0*4)*2:(vgprValuC+2+0*4)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(2+0*4)*2:(vgprValuC+2+0*4)*2+1]
v_fma_f64 v[vgprValuC+(3+0*4)*2:(vgprValuC+3+0*4)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(3+0*4)*2:(vgprValuC+3+0*4)*2+1]
v_fma_f64 v[vgprValuC+(0+1*4)*2:(vgprValuC+0+1*4)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(0+1*4)*2:(vgprValuC+0+1*4)*2+1]
v_fma_f64 v[vgprValuC+(1+1*4)*2:(vgprValuC+1+1*4)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(1+1*4)*2:(vgprValuC+1+1*4)*2+1]
v_fma_f64 v[vgprValuC+(2+1*4)*2:(vgprValuC+2+1*4)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(2+1*4)*2:(vgprValuC+2+1*4)*2+1]
v_fma_f64 v[vgprValuC+(3+1*4)*2:(vgprValuC+3+1*4)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(3+1*4)*2:(vgprValuC+3+1*4)*2+1]
v_fma_f64 v[vgprValuC+(0+2*4)*2:(vgprValuC+0+2*4)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(0+2*4)*2:(vgprValuC+0+2*4)*2+1]
v_fma_f64 v[vgprValuC+(1+2*4)*2:(vgprValuC+1+2*4)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(1+2*4)*2:(vgprValuC+1+2*4)*2+1]
v_fma_f64 v[vgprValuC+(2+2*4)*2:(vgprValuC+2+2*4)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(2+2*4)*2:(vgprValuC+2+2*4)*2+1]
v_fma_f64 v[vgprValuC+(3+2*4)*2:(vgprValuC+3+2*4)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(3+2*4)*2:(vgprValuC+3+2*4)*2+1]
v_fma_f64 v[vgprValuC+(0+3*4)*2:(vgprValuC+0+3*4)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(0+3*4)*2:(vgprValuC+0+3*4)*2+1]
v_fma_f64 v[vgprValuC+(1+3*4)*2:(vgprValuC+1+3*4)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(1+3*4)*2:(vgprValuC+1+3*4)*2+1]
v_fma_f64 v[vgprValuC+(2+3*4)*2:(vgprValuC+2+3*4)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(2+3*4)*2:(vgprValuC+2+3*4)*2+1]
v_fma_f64 v[vgprValuC+(3+3*4)*2:(vgprValuC+3+3*4)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(3+3*4)*2:(vgprValuC+3+3*4)*2+1]
v_fma_f64 v[vgprValuC+(0+4*4)*2:(vgprValuC+0+4*4)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(0+4*4)*2:(vgprValuC+0+4*4)*2+1]
v_fma_f64 v[vgprValuC+(1+4*4)*2:(vgprValuC+1+4*4)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(1+4*4)*2:(vgprValuC+1+4*4)*2+1]
v_fma_f64 v[vgprValuC+(2+4*4)*2:(vgprValuC+2+4*4)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(2+4*4)*2:(vgprValuC+2+4*4)*2+1]
v_fma_f64 v[vgprValuC+(3+4*4)*2:(vgprValuC+3+4*4)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(3+4*4)*2:(vgprValuC+3+4*4)*2+1]
v_fma_f64 v[vgprValuC+(0+5*4)*2:(vgprValuC+0+5*4)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(0+5*4)*2:(vgprValuC+0+5*4)*2+1]
v_fma_f64 v[vgprValuC+(1+5*4)*2:(vgprValuC+1+5*4)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(1+5*4)*2:(vgprValuC+1+5*4)*2+1]
v_fma_f64 v[vgprValuC+(2+5*4)*2:(vgprValuC+2+5*4)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(2+5*4)*2:(vgprValuC+2+5*4)*2+1]
v_fma_f64 v[vgprValuC+(3+5*4)*2:(vgprValuC+3+5*4)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(3+5*4)*2:(vgprValuC+3+5*4)*2+1]
s_setprio 0 // Reset priority after macs 
.endm
.macro MAC_4x6_X1
v_fma_f64 v[vgprValuC+(0+0*4)*2:(vgprValuC+0+0*4)*2+1], v[vgprValuA_X1_I0+0*2:vgprValuA_X1_I0+0*2+1], v[vgprValuB_X1_I0+0*2:vgprValuB_X1_I0+0*2+1], v[vgprValuC+(0+0*4)*2:(vgprValuC+0+0*4)*2+1]
s_setprio 1 // Raise priority while processing macs 
v_fma_f64 v[vgprValuC+(1+0*4)*2:(vgprValuC+1+0*4)*2+1], v[vgprValuA_X1_I0+1*2:vgprValuA_X1_I0+1*2+1], v[vgprValuB_X1_I0+0*2:vgprValuB_X1_I0+0*2+1], v[vgprValuC+(1+0*4)*2:(vgprValuC+1+0*4)*2+1]
v_fma_f64 v[vgprValuC+(2+0*4)*2:(vgprValuC+2+0*4)*2+1], v[vgprValuA_X1_I0+2*2:vgprValuA_X1_I0+2*2+1], v[vgprValuB_X1_I0+0*2:vgprValuB_X1_I0+0*2+1], v[vgprValuC+(2+0*4)*2:(vgprValuC+2+0*4)*2+1]
v_fma_f64 v[vgprValuC+(3+0*4)*2:(vgprValuC+3+0*4)*2+1], v[vgprValuA_X1_I0+3*2:vgprValuA_X1_I0+3*2+1], v[vgprValuB_X1_I0+0*2:vgprValuB_X1_I0+0*2+1], v[vgprValuC+(3+0*4)*2:(vgprValuC+3+0*4)*2+1]
v_fma_f64 v[vgprValuC+(0+1*4)*2:(vgprValuC+0+1*4)*2+1], v[vgprValuA_X1_I0+0*2:vgprValuA_X1_I0+0*2+1], v[vgprValuB_X1_I0+1*2:vgprValuB_X1_I0+1*2+1], v[vgprValuC+(0+1*4)*2:(vgprValuC+0+1*4)*2+1]
v_fma_f64 v[vgprValuC+(1+1*4)*2:(vgprValuC+1+1*4)*2+1], v[vgprValuA_X1_I0+1*2:vgprValuA_X1_I0+1*2+1], v[vgprValuB_X1_I0+1*2:vgprValuB_X1_I0+1*2+1], v[vgprValuC+(1+1*4)*2:(vgprValuC+1+1*4)*2+1]
v_fma_f64 v[vgprValuC+(2+1*4)*2:(vgprValuC+2+1*4)*2+1], v[vgprValuA_X1_I0+2*2:vgprValuA_X1_I0+2*2+1], v[vgprValuB_X1_I0+1*2:vgprValuB_X1_I0+1*2+1], v[vgprValuC+(2+1*4)*2:(vgprValuC+2+1*4)*2+1]
v_fma_f64 v[vgprValuC+(3+1*4)*2:(vgprValuC+3+1*4)*2+1], v[vgprValuA_X1_I0+3*2:vgprValuA_X1_I0+3*2+1], v[vgprValuB_X1_I0+1*2:vgprValuB_X1_I0+1*2+1], v[vgprValuC+(3+1*4)*2:(vgprValuC+3+1*4)*2+1]
v_fma_f64 v[vgprValuC+(0+2*4)*2:(vgprValuC+0+2*4)*2+1], v[vgprValuA_X1_I0+0*2:vgprValuA_X1_I0+0*2+1], v[vgprValuB_X1_I0+2*2:vgprValuB_X1_I0+2*2+1], v[vgprValuC+(0+2*4)*2:(vgprValuC+0+2*4)*2+1]
v_fma_f64 v[vgprValuC+(1+2*4)*2:(vgprValuC+1+2*4)*2+1], v[vgprValuA_X1_I0+1*2:vgprValuA_X1_I0+1*2+1], v[vgprValuB_X1_I0+2*2:vgprValuB_X1_I0+2*2+1], v[vgprValuC+(1+2*4)*2:(vgprValuC+1+2*4)*2+1]
v_fma_f64 v[vgprValuC+(2+2*4)*2:(vgprValuC+2+2*4)*2+1], v[vgprValuA_X1_I0+2*2:vgprValuA_X1_I0+2*2+1], v[vgprValuB_X1_I0+2*2:vgprValuB_X1_I0+2*2+1], v[vgprValuC+(2+2*4)*2:(vgprValuC+2+2*4)*2+1]
v_fma_f64 v[vgprValuC+(3+2*4)*2:(vgprValuC+3+2*4)*2+1], v[vgprValuA_X1_I0+3*2:vgprValuA_X1_I0+3*2+1], v[vgprValuB_X1_I0+2*2:vgprValuB_X1_I0+2*2+1], v[vgprValuC+(3+2*4)*2:(vgprValuC+3+2*4)*2+1]
v_fma_f64 v[vgprValuC+(0+3*4)*2:(vgprValuC+0+3*4)*2+1], v[vgprValuA_X1_I0+0*2:vgprValuA_X1_I0+0*2+1], v[vgprValuB_X1_I0+3*2:vgprValuB_X1_I0+3*2+1], v[vgprValuC+(0+3*4)*2:(vgprValuC+0+3*4)*2+1]
v_fma_f64 v[vgprValuC+(1+3*4)*2:(vgprValuC+1+3*4)*2+1], v[vgprValuA_X1_I0+1*2:vgprValuA_X1_I0+1*2+1], v[vgprValuB_X1_I0+3*2:vgprValuB_X1_I0+3*2+1], v[vgprValuC+(1+3*4)*2:(vgprValuC+1+3*4)*2+1]
v_fma_f64 v[vgprValuC+(2+3*4)*2:(vgprValuC+2+3*4)*2+1], v[vgprValuA_X1_I0+2*2:vgprValuA_X1_I0+2*2+1], v[vgprValuB_X1_I0+3*2:vgprValuB_X1_I0+3*2+1], v[vgprValuC+(2+3*4)*2:(vgprValuC+2+3*4)*2+1]
v_fma_f64 v[vgprValuC+(3+3*4)*2:(vgprValuC+3+3*4)*2+1], v[vgprValuA_X1_I0+3*2:vgprValuA_X1_I0+3*2+1], v[vgprValuB_X1_I0+3*2:vgprValuB_X1_I0+3*2+1], v[vgprValuC+(3+3*4)*2:(vgprValuC+3+3*4)*2+1]
v_fma_f64 v[vgprValuC+(0+4*4)*2:(vgprValuC+0+4*4)*2+1], v[vgprValuA_X1_I0+0*2:vgprValuA_X1_I0+0*2+1], v[vgprValuB_X1_I0+4*2:vgprValuB_X1_I0+4*2+1], v[vgprValuC+(0+4*4)*2:(vgprValuC+0+4*4)*2+1]
v_fma_f64 v[vgprValuC+(1+4*4)*2:(vgprValuC+1+4*4)*2+1], v[vgprValuA_X1_I0+1*2:vgprValuA_X1_I0+1*2+1], v[vgprValuB_X1_I0+4*2:vgprValuB_X1_I0+4*2+1], v[vgprValuC+(1+4*4)*2:(vgprValuC+1+4*4)*2+1]
v_fma_f64 v[vgprValuC+(2+4*4)*2:(vgprValuC+2+4*4)*2+1], v[vgprValuA_X1_I0+2*2:vgprValuA_X1_I0+2*2+1], v[vgprValuB_X1_I0+4*2:vgprValuB_X1_I0+4*2+1], v[vgprValuC+(2+4*4)*2:(vgprValuC+2+4*4)*2+1]
v_fma_f64 v[vgprValuC+(3+4*4)*2:(vgprValuC+3+4*4)*2+1], v[vgprValuA_X1_I0+3*2:vgprValuA_X1_I0+3*2+1], v[vgprValuB_X1_I0+4*2:vgprValuB_X1_I0+4*2+1], v[vgprValuC+(3+4*4)*2:(vgprValuC+3+4*4)*2+1]
v_fma_f64 v[vgprValuC+(0+5*4)*2:(vgprValuC+0+5*4)*2+1], v[vgprValuA_X1_I0+0*2:vgprValuA_X1_I0+0*2+1], v[vgprValuB_X1_I0+5*2:vgprValuB_X1_I0+5*2+1], v[vgprValuC+(0+5*4)*2:(vgprValuC+0+5*4)*2+1]
v_fma_f64 v[vgprValuC+(1+5*4)*2:(vgprValuC+1+5*4)*2+1], v[vgprValuA_X1_I0+1*2:vgprValuA_X1_I0+1*2+1], v[vgprValuB_X1_I0+5*2:vgprValuB_X1_I0+5*2+1], v[vgprValuC+(1+5*4)*2:(vgprValuC+1+5*4)*2+1]
v_fma_f64 v[vgprValuC+(2+5*4)*2:(vgprValuC+2+5*4)*2+1], v[vgprValuA_X1_I0+2*2:vgprValuA_X1_I0+2*2+1], v[vgprValuB_X1_I0+5*2:vgprValuB_X1_I0+5*2+1], v[vgprValuC+(2+5*4)*2:(vgprValuC+2+5*4)*2+1]
v_fma_f64 v[vgprValuC+(3+5*4)*2:(vgprValuC+3+5*4)*2+1], v[vgprValuA_X1_I0+3*2:vgprValuA_X1_I0+3*2+1], v[vgprValuB_X1_I0+5*2:vgprValuB_X1_I0+5*2+1], v[vgprValuC+(3+5*4)*2:(vgprValuC+3+5*4)*2+1]
s_setprio 0 // Reset priority after macs 
.endm

/******************************************/
/* Allocate Resources                     */
/******************************************/
s_mov_b32 m0, 0x4000                               // LDS clamp at 16384 bytes
v_mov_b32 v[vgprSerial], v0                        // thread serial id

/* Load Kernel Args */
s_load_dword s[sgprTensor2dSizeC+0], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x0 // load tensor size
s_load_dword s[sgprTensor2dSizeC+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x4 // load tensor size
s_load_dword s[sgprTensor2dSizeA+0], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x8 // load tensor size
s_load_dword s[sgprTensor2dSizeA+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0xc // load tensor size
s_load_dword s[sgprTensor2dSizeB+0], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x10 // load tensor size
s_load_dword s[sgprTensor2dSizeB+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x14 // load tensor size
s_load_dword s[sgprAddressC], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x18 // load addr c
s_load_dword s[sgprAddressC+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x1c // load addr c
s_load_dword s[sgprAddressA], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x20 // load addr a
s_load_dword s[sgprAddressA+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x24 // load addr a
s_load_dword s[sgprAddressB], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x28 // load addr b
s_load_dword s[sgprAddressB+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x2c // load addr b
s_load_dword s[sgprAlpha+0], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x30 // load alpha
s_load_dword s[sgprAlpha+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x34 // load alpha
s_load_dword s[sgprBeta+0], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x38 // load beta
s_load_dword s[sgprBeta+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x3c // load beta
s_load_dword s[sgprOffsetC], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x40 // load offset c
s_load_dword s[sgprOffsetA], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x44 // load offset a
s_load_dword s[sgprOffsetB], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x48 // load offset b
s_load_dword s[sgprStridesC+0], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x4c // load stride c 0
s_load_dword s[sgprStridesC+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x50 // load stride c 1
s_load_dword s[sgprStridesA+0], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x54 // load stride a 0
s_load_dword s[sgprStridesA+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x58 // load stride a 1
s_load_dword s[sgprStridesB+0], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x5c // load stride b 0
s_load_dword s[sgprStridesB+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x60 // load stride b 1
s_load_dword s[sgprSizesFree+0], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x64 // load size free 0
s_load_dword s[sgprSizesFree+1], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x68 // load size free 1
s_load_dword s[sgprSizesFree+2], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x6c // load size free 2
s_load_dword s[sgprSizesSum+0], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x70 // load size sum 0
s_waitcnt lgkmcnt(0)                               // wait for 116 bytes of kern args

/* User Offsets */
s_add_u32 s[sgprAddressC], s[sgprOffsetC], s[sgprAddressC] // addrC += offsetC
s_mov_b32 s[sgprOffsetC], 0                        // 
s_addc_u32 s[sgprAddressC], s[sgprOffsetC], s[sgprAddressC] // addrC += offsetC carry
s_add_u32 s[sgprAddressA], s[sgprOffsetA], s[sgprAddressA] // addrA += offsetA
s_mov_b32 s[sgprOffsetA], 0                        // 
s_addc_u32 s[sgprAddressA], s[sgprOffsetA], s[sgprAddressA] // addrA += offsetA carry
s_add_u32 s[sgprAddressB], s[sgprOffsetB], s[sgprAddressB] // addrB += offsetB
s_mov_b32 s[sgprOffsetB], 0                        // 
s_addc_u32 s[sgprAddressB], s[sgprOffsetB], s[sgprAddressB] // addrB += offsetB carry
// size0 = (size0I + MT0I - 1) / MT0I;
v_mov_b32 v0, s[sgprSizesFree+0]                   // 
s_mov_b32 s61, 0x1f                                // 
_v_add_co_u32 v0, vcc, s61, v0                     // v0 = size0+MT0-1
v_lshrrev_b32 v3, 5, v0                            // vectorStaticDiv: v3 = v0 / 32
v_readfirstlane_b32 s[sgprNumWorkGroups0], v3      // 
// size1 = (size1J + MT1J - 1) / MT1J;
v_mov_b32 v0, s[sgprSizesFree+1]                   // 
s_mov_b32 s61, 0x5f                                // 
_v_add_co_u32 v0, vcc, s61, v0                     // v0 = size1+MT1-1
s_mov_b32 s61, 0x5555556                           // 
v_mul_hi_u32 v2, v0, s61                           // 
v_mul_lo_u32 v1, v0, s61                           // 
s_mov_b32 s61, 0x21                                // 
v_lshrrev_b64 v[1:2], s61, v[1:2]                  // 
v_mov_b32 v3, v1                                   // vectorStaticDiv: quotient
v_readfirstlane_b32 s[sgprNumWorkGroups1], v3      // 

/******************************************/
/* Global Read Addresses                  */
/******************************************/

/* global read addresses: subgroup */
/*   not needed until local read addresses */

/* global read addresses: work-group */
// nwg0 = (size0I + MT0I - 1) / MT0I;
v_mov_b32 v2, s[sgprSizesFree+0]                   // 
s_mov_b32 s62, 0x1f                                // 
_v_add_co_u32 v2, vcc, s62, v2                     // v2 = size0+MT0-1
v_lshrrev_b32 v2, 5, v2                            // vectorStaticDiv: v2 = v2 / 32
// nwg1 = (size1J + MT1J - 1) / MT1J;
v_mov_b32 v3, s[sgprSizesFree+1]                   // 
s_mov_b32 s62, 0x5f                                // 
_v_add_co_u32 v3, vcc, s62, v3                     // v3 = size1+MT1-1
s_mov_b32 s62, 0x5555556                           // 
v_mul_hi_u32 v1, v3, s62                           // 
v_mul_lo_u32 v0, v3, s62                           // 
s_mov_b32 s62, 0x21                                // 
v_lshrrev_b64 v[0:1], s62, v[0:1]                  // 
v_mov_b32 v3, v0                                   // vectorStaticDiv: quotient
v_mov_b32 v6, s[sgprWorkGroup1]                    // wg1
v_lshrrev_b32 v4, 3, v6                            // vectorStaticDiv: v4 = v6 / 8
v_and_b32 v5, 7, v6                                // vectorStaticDiv: v5 = v6 % 8
v_mul_lo_u32 v5, v5, v2                            // (wg1 % WGM)*nwg0
_v_add_co_u32 v5, vcc, s[sgprWorkGroup0], v5       // wgSerial = wg0 + (wg1 % WGM)*nwg0
// numFullBlocks = (nwg1) / WGM
v_lshrrev_b32 v2, 3, v3                            // vectorStaticDiv: v2 = v3 / 8
v_and_b32 v7, 7, v3                                // vectorStaticDiv: v7 = v3 % 8
v_cmp_lt_u32 s[62:63], v4, v2                      // blockId < numFullBlocks
v_cndmask_b32 v2, v7, 0x8, s[62:63]                // blockWidth = (blockId < numFullBlocks) ? WGM : remainder
DYNAMIC_VECTOR_DIVIDE 3 6 5 2 0 1 62
v_mul_lo_u32 v4, v4, 8                             // blockId * WGM
_v_add_co_u32 v6, vcc, v6, v4                      // wg1 += blockId * WGM
v_readfirstlane_b32 s[sgprWorkGroup0], v3          // 
v_readfirstlane_b32 s[sgprWorkGroup1], v6          // 

/* global read addresses: tile offset assignment a */
/* LVCA = 16 */
/* v0 = (local)groA-tile = serial%LVCA (note (wgA*MTA) will be added to SRD) */
/* v1 = groA-unroll = serial/LVCA */
v_lshrrev_b32 v1, 4, v[vgprSerial]                 // vectorStaticDiv: v1 = v[vgprSerial] / 16
v_and_b32 v0, 15, v[vgprSerial]                    // vectorStaticDiv: v0 = v[vgprSerial] % 16
/* gro-tile *= glvw */
v_lshlrev_b32 v0, 1, v0                            // staticMultiply: v0 = v0 * 2

/* global read addresses: tile offset assignment b */
/* LVCB = 16 */
/* v2 = (local)groB-tile = serial%LVCB (note (wgB*MTB) will be added to SRD) */
/* v3 = groB-unroll = serial/LVCB */
v_lshrrev_b32 v3, 4, v[vgprSerial]                 // vectorStaticDiv: v3 = v[vgprSerial] / 16
v_and_b32 v2, 15, v[vgprSerial]                    // vectorStaticDiv: v2 = v[vgprSerial] % 16
/* gro-tile *= glvw */
v_lshlrev_b32 v2, 1, v2                            // staticMultiply: v2 = v2 * 2

/* global read addresses: unroll assignment a */
/* v1 */

/* global read addresses: unroll assignment b */
/* v3 */

/* global read addresses: other free assignments */
/* s[sgprWorkGroup2] */

/* global read addresses: tile offsets a */

/* global read addresses: tile offsets b */

/* global read addresses: unroll offsets a */

/* global read addresses: unroll offsets b */

/* global read addresses: final offsets a */
GLOBAL_OFFSET_A vgprGlobalReadOffsetA+0,  0,  1, 4 // gROA_0_0_0_0

/* global read addresses: final offsets b */
GLOBAL_OFFSET_B vgprGlobalReadOffsetB+0,  2,  3, 4 // gROB_0_0_0_0
s_mul_i32 s[sgprScalarGlobalReadOffsetB+0], s[sgprStridesB+0], 0 // compute offset diff (scaled unrollDim)
s_add_u32 s[sgprScalarGlobalReadOffsetB+0], s[sgprScalarGlobalReadOffsetB+0], 32 // compute offset diff (tileDim)
s_lshl_b32 s[sgprScalarGlobalReadOffsetB+0], s[sgprScalarGlobalReadOffsetB+0], 0x3 // scalar offset *= bytes/element
s_mul_i32 s[sgprScalarGlobalReadOffsetB+1], s[sgprStridesB+0], 0 // compute offset diff (scaled unrollDim)
s_add_u32 s[sgprScalarGlobalReadOffsetB+1], s[sgprScalarGlobalReadOffsetB+1], 64 // compute offset diff (tileDim)
s_lshl_b32 s[sgprScalarGlobalReadOffsetB+1], s[sgprScalarGlobalReadOffsetB+1], 0x3 // scalar offset *= bytes/element

/* global read addresses: apply user offsets */
/* moved earlier */

/* global read addresses: addresses a */
/* max read offset = size[n] * stride[n-1] */
s_mul_hi_u32 s67, s[sgprWorkGroup0], 32            // WorkGroup[01] * MT
s_mul_i32 s66, s[sgprWorkGroup0], 32               // WorkGroup[01] * MT
s_sub_u32 s[sgprSrdShadowLimitA+0], s[sgprTensor2dSizeA], s66 // sub tileStart
s_subb_u32 s[sgprSrdShadowLimitA+1], s[sgprTensor2dSizeA+1], s67 // sub tileStart
s_lshl_b64 s[sgprSrdShadowLimitA:sgprSrdShadowLimitA+1], s[sgprSrdShadowLimitA:sgprSrdShadowLimitA+1], 0x3 // Set limit to use bytes
s_add_u32 s[sgprSrdShadowLimitA+0], s[sgprSrdShadowLimitA+0], 16 // extend limit for pre-pad
s_addc_u32 s[sgprSrdShadowLimitA+1], s[sgprSrdShadowLimitA+1], 0 // extend limit for pre-pad
s_cmp_eq_u32 s[sgprSrdShadowLimitA+1], 0           // are we within 2^32?
s_cselect_b32 s[sgprSrdA+2], s[sgprSrdShadowLimitA+0], BufferLimit // Move shadow to real if we are within 2^32
s_mul_hi_u32 s63, s[sgprStridesA+1], s[sgprWorkGroup2] // Stride*WG
s_mul_i32 s62, s[sgprStridesA+1], s[sgprWorkGroup2] // Stride*WG
s_add_u32 s66, s66, s62                            // accum wg term to tilestart
s_addc_u32 s67, s67, s63                           // accum wg term to tilestart
s_lshl_b64 s[66:67], s[66:67], 3                   // tileStart *= BPE
s_add_u32 s[sgprSrdA+0], s[sgprAddressA+0], s66    // SRD base = Address+ tileStart0
s_addc_u32 s[sgprSrdA+1], s[sgprAddressA+1], s67   // SRD base = Address+ tileStart1
s_sub_u32 s[sgprSrdA+0], s[sgprSrdA+0], 16         // pre-pad to make room for possible pointer shift
s_subb_u32 s[sgprSrdA+1], s[sgprSrdA+1], 0         // pre-pad to make room for possible pointer shift
s_mov_b32 s[sgprSrdA+3], Srd127_96                 // Set bits 127_96 in SRD

/* global read addresses: addresses b */
/* max read offset = size[n] * stride[n-1] */
s_mul_hi_u32 s67, s[sgprWorkGroup1], 96            // WorkGroup[01] * MT
s_mul_i32 s66, s[sgprWorkGroup1], 96               // WorkGroup[01] * MT
s_sub_u32 s[sgprSrdShadowLimitB+0], s[sgprTensor2dSizeB], s66 // sub tileStart
s_subb_u32 s[sgprSrdShadowLimitB+1], s[sgprTensor2dSizeB+1], s67 // sub tileStart
s_lshl_b64 s[sgprSrdShadowLimitB:sgprSrdShadowLimitB+1], s[sgprSrdShadowLimitB:sgprSrdShadowLimitB+1], 0x3 // Set limit to use bytes
s_add_u32 s[sgprSrdShadowLimitB+0], s[sgprSrdShadowLimitB+0], 16 // extend limit for pre-pad
s_addc_u32 s[sgprSrdShadowLimitB+1], s[sgprSrdShadowLimitB+1], 0 // extend limit for pre-pad
s_cmp_eq_u32 s[sgprSrdShadowLimitB+1], 0           // are we within 2^32?
s_cselect_b32 s[sgprSrdB+2], s[sgprSrdShadowLimitB+0], BufferLimit // Move shadow to real if we are within 2^32
s_mul_hi_u32 s63, s[sgprStridesB+1], s[sgprWorkGroup2] // Stride*WG
s_mul_i32 s62, s[sgprStridesB+1], s[sgprWorkGroup2] // Stride*WG
s_add_u32 s66, s66, s62                            // accum wg term to tilestart
s_addc_u32 s67, s67, s63                           // accum wg term to tilestart
s_lshl_b64 s[66:67], s[66:67], 3                   // tileStart *= BPE
s_add_u32 s[sgprSrdB+0], s[sgprAddressB+0], s66    // SRD base = Address+ tileStart0
s_addc_u32 s[sgprSrdB+1], s[sgprAddressB+1], s67   // SRD base = Address+ tileStart1
s_sub_u32 s[sgprSrdB+0], s[sgprSrdB+0], 16         // pre-pad to make room for possible pointer shift
s_subb_u32 s[sgprSrdB+1], s[sgprSrdB+1], 0         // pre-pad to make room for possible pointer shift
s_mov_b32 s[sgprSrdB+3], Srd127_96                 // Set bits 127_96 in SRD

/* global read addresses: increments a */
s_mul_i32 s[sgprGlobalReadIncsA+0], 0x40, s[sgprStridesA] // incr = stride*8*bytes

/* global read addresses: increments b */
s_mul_i32 s[sgprGlobalReadIncsB+0], 0x40, s[sgprStridesB] // incr = stride*8*bytes

/******************************************/
/* Local Write Addresses                  */
/******************************************/

/* local write addresses: tile assignment a */
/* lwaTileA = v0 */

/* local write addresses: tile assignment b */
/* lwaTileB = v2 */

/* local write addresses: unroll assignment a */
/* lwaUnrollA = v1 */

/* local write addresses: unroll assignment b */
/* lwaUnrollB = v3 */

/* local write addresses: first offset a */
v_mul_u32_u24 v[vgprLocalWriteAddrA], 0x20, v1     // lwAL**(MTA + PAD)
_v_add_lshl_u32 v[vgprLocalWriteAddrA], v0, v[vgprLocalWriteAddrA], 0x3 // lwFOA = (lwAA + lwAL*(MT0I+PAD))*bpe

/* local write addresses: first offset b */
v_mul_u32_u24 v[vgprLocalWriteAddrB], 0x60, v3     // lwBL**(MTB + PAD)
_v_add_lshl_u32 v[vgprLocalWriteAddrB], v2, v[vgprLocalWriteAddrB], 0x3 // lwFOB = (lwBB + lwBL*(MT1J+PAD))*bpe
_v_add_co_u32 v[vgprLocalWriteAddrB], vcc, 0x800, v[vgprLocalWriteAddrB] // lwFOB = lwB1J + lwBL*MT1J + LDS_OFFSET_B=256*8

/* local write addresses: final offsets a */

/* N/A */

/* local write addresses: final offsets b */

/* N/A */

/* local write addresses: declare addresses a */
/* N/A */

/* local write addresses: declare addresses b */
/* N/A */

/* local write addresses: init pointers a */
/* N/A */

/* local write addresses: init pointers b */
/* N/A */

/******************************************/
/* Local Read Addresses                   */
/******************************************/

/* local read addresses: tile assignments a */
/*lr0I = serial % SG0I*/
v_lshrrev_b32 v0, 3, v[vgprSerial]                 // vectorStaticDiv: v0 = v[vgprSerial] / 8
v_and_b32 v1, 7, v[vgprSerial]                     // vectorStaticDiv: v1 = v[vgprSerial] % 8

/* local read addresses: tile assignments b */
/*lr1J = (serial / SG1J) % SG1J*/
v_lshrrev_b32 v2, 4, v0                            // vectorStaticDiv: v2 = v0 / 16
v_and_b32 v3, 15, v0                               // vectorStaticDiv: v3 = v0 % 16

/* local read addresses: final offsets a */
v_lshrrev_b32 v0, 7, v[vgprSerial]                 // vectorStaticDiv: v0 = v[vgprSerial] / 128
v_and_b32 v2, 127, v[vgprSerial]                   // vectorStaticDiv: v2 = v[vgprSerial] % 128
s_mov_b32 s61, 0x20                                // MT0+PAD
v_mul_lo_u32 v0, s61, v0                           // sgid=sgid*(MT0+PAD)
v_lshlrev_b32 v1, 1, v1                            // staticMultiply: v1 = v1 * 2
_v_add_lshl_u32 v[vgprLocalReadAddrA], v0, v1, 0x3 // o = (lroA*VW+sgid*MT0)*bpe

/* local read addresses: final offsets b */
v_lshrrev_b32 v0, 7, v[vgprSerial]                 // vectorStaticDiv: v0 = v[vgprSerial] / 128
v_and_b32 v1, 127, v[vgprSerial]                   // vectorStaticDiv: v1 = v[vgprSerial] % 128
s_mov_b32 s61, 0x60                                // MT1+PAD
v_mul_lo_u32 v0, s61, v0                           // sgid=sgid*(MT1+PAD)
v_lshlrev_b32 v3, 1, v3                            // staticMultiply: v3 = v3 * 2
_v_add_lshl_u32 v[vgprLocalReadAddrB], v0, v3, 0x3 // o = (lroB*VW+sgid*MT1)*bpe

/* local read addresses: declare addresses a */
/* N/A */

/* local read addresses: declare addresses b */
_v_add_co_u32 v[vgprLocalReadAddrB+0], vcc, 0x800, v[vgprLocalReadAddrB+0] //  += LdsOffsetB (lower)

/* declare loop num iterations */
v_mov_b32 v[vgprValuC+0], 0x0                      // initC
v_mov_b32 v[vgprValuC+1], 0x0                      // initC
v_mov_b32 v[vgprValuC+2], 0x0                      // initC
v_mov_b32 v[vgprValuC+3], 0x0                      // initC
v_mov_b32 v[vgprValuC+4], 0x0                      // initC
v_mov_b32 v[vgprValuC+5], 0x0                      // initC
v_mov_b32 v[vgprValuC+6], 0x0                      // initC
v_mov_b32 v[vgprValuC+7], 0x0                      // initC
v_mov_b32 v[vgprValuC+8], 0x0                      // initC
v_mov_b32 v[vgprValuC+9], 0x0                      // initC
v_mov_b32 v[vgprValuC+10], 0x0                     // initC
v_mov_b32 v[vgprValuC+11], 0x0                     // initC
v_mov_b32 v[vgprValuC+12], 0x0                     // initC
v_mov_b32 v[vgprValuC+13], 0x0                     // initC
v_mov_b32 v[vgprValuC+14], 0x0                     // initC
v_mov_b32 v[vgprValuC+15], 0x0                     // initC
v_mov_b32 v[vgprValuC+16], 0x0                     // initC
v_mov_b32 v[vgprValuC+17], 0x0                     // initC
v_mov_b32 v[vgprValuC+18], 0x0                     // initC
v_mov_b32 v[vgprValuC+19], 0x0                     // initC
v_mov_b32 v[vgprValuC+20], 0x0                     // initC
v_mov_b32 v[vgprValuC+21], 0x0                     // initC
v_mov_b32 v[vgprValuC+22], 0x0                     // initC
v_mov_b32 v[vgprValuC+23], 0x0                     // initC
v_mov_b32 v[vgprValuC+24], 0x0                     // initC
v_mov_b32 v[vgprValuC+25], 0x0                     // initC
v_mov_b32 v[vgprValuC+26], 0x0                     // initC
v_mov_b32 v[vgprValuC+27], 0x0                     // initC
v_mov_b32 v[vgprValuC+28], 0x0                     // initC
v_mov_b32 v[vgprValuC+29], 0x0                     // initC
v_mov_b32 v[vgprValuC+30], 0x0                     // initC
v_mov_b32 v[vgprValuC+31], 0x0                     // initC
v_mov_b32 v[vgprValuC+32], 0x0                     // initC
v_mov_b32 v[vgprValuC+33], 0x0                     // initC
v_mov_b32 v[vgprValuC+34], 0x0                     // initC
v_mov_b32 v[vgprValuC+35], 0x0                     // initC
v_mov_b32 v[vgprValuC+36], 0x0                     // initC
v_mov_b32 v[vgprValuC+37], 0x0                     // initC
v_mov_b32 v[vgprValuC+38], 0x0                     // initC
v_mov_b32 v[vgprValuC+39], 0x0                     // initC
v_mov_b32 v[vgprValuC+40], 0x0                     // initC
v_mov_b32 v[vgprValuC+41], 0x0                     // initC
v_mov_b32 v[vgprValuC+42], 0x0                     // initC
v_mov_b32 v[vgprValuC+43], 0x0                     // initC
v_mov_b32 v[vgprValuC+44], 0x0                     // initC
v_mov_b32 v[vgprValuC+45], 0x0                     // initC
v_mov_b32 v[vgprValuC+46], 0x0                     // initC
v_mov_b32 v[vgprValuC+47], 0x0                     // initC
s_lshr_b32 s[sgprLoopCounters+0], s[sgprSizesSum+0], 3 // s[sgprLoopCounters+0] = s[sgprSizesSum+0] / 8
s_sub_u32 s[sgprLoopCounters+0], 0x0, s[sgprLoopCounters+0] // counterL = -sizeL

/* local read addresses: init pointers a */

/* local read addresses: init pointers b */

/* prefetch: global -> local */
s_cmp_eq_u32 s[sgprLoopCounters+0], 0x0            // numIter0I == 0
s_cbranch_scc1 label_0002                          // skip to end of prefetch last iter b/c numIter==0

/* global read a */
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_0_0

/* global read b */
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // G -> Reg 0_0_0_0
buffer_load_dwordx4 v[vgprG2LB+4:vgprG2LB+4+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0], offen offset:0 // G -> Reg 1_0_0_0
buffer_load_dwordx4 v[vgprG2LB+8:vgprG2LB+8+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+1], offen offset:0 // G -> Reg 2_0_0_0

/* global read inc a */
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s[sgprGlobalReadIncsA+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprSrdShadowLimitA+0], s[sgprSrdShadowLimitA+0], s[sgprGlobalReadIncsA+0] // limit -= inc)
s_subb_u32 s[sgprSrdShadowLimitA+1], s[sgprSrdShadowLimitA+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprSrdShadowLimitA+1], 0           // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprSrdShadowLimitA+0] // Move shadow to real if we are within 2^32

/* global read inc b */
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s[sgprGlobalReadIncsB+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprSrdShadowLimitB+0], s[sgprSrdShadowLimitB+0], s[sgprGlobalReadIncsB+0] // limit -= inc)
s_subb_u32 s[sgprSrdShadowLimitB+1], s[sgprSrdShadowLimitB+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprSrdShadowLimitB+1], 0           // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprSrdShadowLimitB+0] // Move shadow to real if we are within 2^32
s_waitcnt vmcnt(0) // 3wait for global read

/* local write a */
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 0 #7761

/* local write b */
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 0 #7762
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+4:vgprG2LB+4+3] offset:256 // lwoB_1_0_0_0 = (1*LSCB) + (0*LSPB)(*MT1J+PAD) = 256 #7762
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+8:vgprG2LB+8+3] offset:512 // lwoB_2_0_0_0 = (2*LSCB) + (0*LSPB)(*MT1J+PAD) = 512 #7762

/* local write swap a */

/* local write swap b */

/* local write init pointers a */
/* N/A */

/* local write init pointers b */
/* N/A */
s_waitcnt lgkmcnt(0) // 0wait for local write
s_barrier //

/* local read prefetch a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:128 // L -> Reg lro=0 swapByteOffset=0 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read prefetch b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:512 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read inc a */
/* N/A, lro->32 */

/* local read inc b */
/* N/A, lro->96 */

/******************************************/
/* Unrolled Loop(s) - Begin               */
/******************************************/
s_cmp_ge_i32 s[sgprLoopCounters+0], 0x0            // LoopCounterL < EndCounter
s_cbranch_scc1 label_0002                          // don't enter LoopL
label_0001:

/******************************************/
/* Unroll Loop 1/2 - Begin                */
/******************************************/

/* global read a */
s_cmp_eq_i32 s[sgprLoopCounters+0], -1             // is this the last iteration
s_cmov_b32 s[sgprGlobalReadIncsA], 0               // Set inc to 0 for last iteration
s_cmov_b32 s[sgprSrdA+2], 0                        // Set limit to 0 for last iteration
s_cmov_b32 s[sgprGlobalReadIncsB], 0               // Set inc to 0 for last iteration
s_cmov_b32 s[sgprSrdB+2], 0                        // Set limit to 0 for last iteration
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_0_0

/* global read b */
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // G -> Reg 0_0_0_0
buffer_load_dwordx4 v[vgprG2LB+4:vgprG2LB+4+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0], offen offset:0 // G -> Reg 1_0_0_0
buffer_load_dwordx4 v[vgprG2LB+8:vgprG2LB+8+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+1], offen offset:0 // G -> Reg 2_0_0_0

/* global read inc a */
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s[sgprGlobalReadIncsA+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprSrdShadowLimitA+0], s[sgprSrdShadowLimitA+0], s[sgprGlobalReadIncsA+0] // limit -= inc)
s_subb_u32 s[sgprSrdShadowLimitA+1], s[sgprSrdShadowLimitA+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprSrdShadowLimitA+1], 0           // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprSrdShadowLimitA+0] // Move shadow to real if we are within 2^32

/* global read inc b */
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s[sgprGlobalReadIncsB+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprSrdShadowLimitB+0], s[sgprSrdShadowLimitB+0], s[sgprGlobalReadIncsB+0] // limit -= inc)
s_subb_u32 s[sgprSrdShadowLimitB+1], s[sgprSrdShadowLimitB+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprSrdShadowLimitB+1], 0           // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprSrdShadowLimitB+0] // Move shadow to real if we are within 2^32

/* iter 0 */

/* local read a */
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:256 // L -> Reg lro=32 swapByteOffset=0 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:384 // L -> Reg lro=32 swapByteOffset=0 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:768 // L -> Reg lro=96 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:1024 // L -> Reg lro=96 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+8:vgprValuB_X1_I0+8+3], v[vgprLocalReadAddrB] offset:1280 // L -> Reg lro=96 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read increment a */
/* N/A, lro->64 */

/* local read increment b */
/* N/A, lro->192 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X0

/* iter 1 */

/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:512 // L -> Reg lro=64 swapByteOffset=0 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:640 // L -> Reg lro=64 swapByteOffset=0 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1536 // L -> Reg lro=192 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1792 // L -> Reg lro=192 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:2048 // L -> Reg lro=192 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->96 */

/* local read increment b */
/* N/A, lro->288 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X1

/* iter 2 */

/* local read a */
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:768 // L -> Reg lro=96 swapByteOffset=0 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:896 // L -> Reg lro=96 swapByteOffset=0 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:2304 // L -> Reg lro=288 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:2560 // L -> Reg lro=288 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+8:vgprValuB_X1_I0+8+3], v[vgprLocalReadAddrB] offset:2816 // L -> Reg lro=288 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read increment a */
/* N/A, lro->128 */

/* local read increment b */
/* N/A, lro->384 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X0

/* iter 3 */

/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:1024 // L -> Reg lro=128 swapByteOffset=0 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:1152 // L -> Reg lro=128 swapByteOffset=0 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:3072 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:3328 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:3584 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->160 */

/* local read increment b */
/* N/A, lro->480 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X1

/* iter 4 */

/* local read a */
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:1280 // L -> Reg lro=160 swapByteOffset=0 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:1408 // L -> Reg lro=160 swapByteOffset=0 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:3840 // L -> Reg lro=480 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:4096 // L -> Reg lro=480 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+8:vgprValuB_X1_I0+8+3], v[vgprLocalReadAddrB] offset:4352 // L -> Reg lro=480 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read increment a */
/* N/A, lro->192 */

/* local read increment b */
/* N/A, lro->576 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X0

/* iter 5 */

/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:1536 // L -> Reg lro=192 swapByteOffset=0 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:1664 // L -> Reg lro=192 swapByteOffset=0 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:4608 // L -> Reg lro=576 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:4864 // L -> Reg lro=576 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:5120 // L -> Reg lro=576 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->224 */

/* local read increment b */
/* N/A, lro->672 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X1

/* iter 6 (swap local pointers iteration) */

/* local read a */
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:1792 // L -> Reg lro=224 swapByteOffset=0 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:1920 // L -> Reg lro=224 swapByteOffset=0 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:5376 // L -> Reg lro=672 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:5632 // L -> Reg lro=672 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+8:vgprValuB_X1_I0+8+3], v[vgprLocalReadAddrB] offset:5888 // L -> Reg lro=672 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=1 iui=0
s_waitcnt vmcnt(0) // 4wait for global read

/* local write a */
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:8192 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 8192 #7763

/* local write b */
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:8192 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 8192 #7764
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+4:vgprG2LB+4+3] offset:8448 // lwoB_1_0_0_0 = (1*LSCB) + (0*LSPB)(*MT1J+PAD) = 8448 #7764
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+8:vgprG2LB+8+3] offset:8704 // lwoB_2_0_0_0 = (2*LSCB) + (0*LSPB)(*MT1J+PAD) = 8704 #7764

/* local write swap offsets a */

/* local write swap offsets b */

/* local write init pointers a */
/* N/A */

/* local write init pointers b */
/* N/A */

/* local read swap offsets a */

/* local read swap internal offset -> 8192 */

/* local read swap offsets b */

/* local read swap internal offset -> 8192 */

/* local read init pointers a */

/* local read init pointers b */
s_waitcnt lgkmcnt(9) // wait for prior local read
MAC_4x6_X0

/* iter 7 (last) */
s_waitcnt lgkmcnt(0) // 3wait for local write
s_barrier //

/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8192 // L -> Reg lro=0 swapByteOffset=8192 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8320 // L -> Reg lro=0 swapByteOffset=8192 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:8192 // L -> Reg lro=0 swapByteOffset=8192 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:8448 // L -> Reg lro=0 swapByteOffset=8192 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:8704 // L -> Reg lro=0 swapByteOffset=8192 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read inc a */
/* N/A, lro->32 */

/* local read inc b */
/* N/A, lro->96 */
MAC_4x6_X1

/******************************************/
/* Unrolled Loop - End 1/2                */
/******************************************/
s_add_u32 s[sgprLoopCounters+0], s[sgprLoopCounters+0], 0x1 // inc counterL
s_cmp_eq_i32 s[sgprLoopCounters+0], 0x0            // counterL==0
s_cbranch_scc1 label_0003                          // exit LoopL

/******************************************/
/* Unroll Loop 2/2 - Begin                */
/******************************************/

/* global read a */
s_cmp_eq_i32 s[sgprLoopCounters+0], -1             // is this the last iteration
s_cmov_b32 s[sgprGlobalReadIncsA], 0               // Set inc to 0 for last iteration
s_cmov_b32 s[sgprSrdA+2], 0                        // Set limit to 0 for last iteration
s_cmov_b32 s[sgprGlobalReadIncsB], 0               // Set inc to 0 for last iteration
s_cmov_b32 s[sgprSrdB+2], 0                        // Set limit to 0 for last iteration
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_0_0

/* global read b */
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // G -> Reg 0_0_0_0
buffer_load_dwordx4 v[vgprG2LB+4:vgprG2LB+4+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0], offen offset:0 // G -> Reg 1_0_0_0
buffer_load_dwordx4 v[vgprG2LB+8:vgprG2LB+8+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+1], offen offset:0 // G -> Reg 2_0_0_0

/* global read inc a */
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s[sgprGlobalReadIncsA+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprSrdShadowLimitA+0], s[sgprSrdShadowLimitA+0], s[sgprGlobalReadIncsA+0] // limit -= inc)
s_subb_u32 s[sgprSrdShadowLimitA+1], s[sgprSrdShadowLimitA+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprSrdShadowLimitA+1], 0           // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprSrdShadowLimitA+0] // Move shadow to real if we are within 2^32

/* global read inc b */
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s[sgprGlobalReadIncsB+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprSrdShadowLimitB+0], s[sgprSrdShadowLimitB+0], s[sgprGlobalReadIncsB+0] // limit -= inc)
s_subb_u32 s[sgprSrdShadowLimitB+1], s[sgprSrdShadowLimitB+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprSrdShadowLimitB+1], 0           // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprSrdShadowLimitB+0] // Move shadow to real if we are within 2^32

/* iter 0 */

/* local read a */
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8448 // L -> Reg lro=32 swapByteOffset=8192 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:8576 // L -> Reg lro=32 swapByteOffset=8192 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:8960 // L -> Reg lro=96 swapByteOffset=8192 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:9216 // L -> Reg lro=96 swapByteOffset=8192 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+8:vgprValuB_X1_I0+8+3], v[vgprLocalReadAddrB] offset:9472 // L -> Reg lro=96 swapByteOffset=8192 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read increment a */
/* N/A, lro->64 */

/* local read increment b */
/* N/A, lro->192 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X0

/* iter 1 */

/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:8704 // L -> Reg lro=64 swapByteOffset=8192 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8832 // L -> Reg lro=64 swapByteOffset=8192 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:9728 // L -> Reg lro=192 swapByteOffset=8192 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:9984 // L -> Reg lro=192 swapByteOffset=8192 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:10240 // L -> Reg lro=192 swapByteOffset=8192 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->96 */

/* local read increment b */
/* N/A, lro->288 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X1

/* iter 2 */

/* local read a */
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:8960 // L -> Reg lro=96 swapByteOffset=8192 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:9088 // L -> Reg lro=96 swapByteOffset=8192 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:10496 // L -> Reg lro=288 swapByteOffset=8192 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:10752 // L -> Reg lro=288 swapByteOffset=8192 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+8:vgprValuB_X1_I0+8+3], v[vgprLocalReadAddrB] offset:11008 // L -> Reg lro=288 swapByteOffset=8192 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read increment a */
/* N/A, lro->128 */

/* local read increment b */
/* N/A, lro->384 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X0

/* iter 3 */

/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:9216 // L -> Reg lro=128 swapByteOffset=8192 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:9344 // L -> Reg lro=128 swapByteOffset=8192 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:11264 // L -> Reg lro=384 swapByteOffset=8192 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:11520 // L -> Reg lro=384 swapByteOffset=8192 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:11776 // L -> Reg lro=384 swapByteOffset=8192 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->160 */

/* local read increment b */
/* N/A, lro->480 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X1

/* iter 4 */

/* local read a */
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:9472 // L -> Reg lro=160 swapByteOffset=8192 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:9600 // L -> Reg lro=160 swapByteOffset=8192 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:12032 // L -> Reg lro=480 swapByteOffset=8192 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:12288 // L -> Reg lro=480 swapByteOffset=8192 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+8:vgprValuB_X1_I0+8+3], v[vgprLocalReadAddrB] offset:12544 // L -> Reg lro=480 swapByteOffset=8192 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read increment a */
/* N/A, lro->192 */

/* local read increment b */
/* N/A, lro->576 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X0

/* iter 5 */

/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:9728 // L -> Reg lro=192 swapByteOffset=8192 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:9856 // L -> Reg lro=192 swapByteOffset=8192 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:12800 // L -> Reg lro=576 swapByteOffset=8192 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:13056 // L -> Reg lro=576 swapByteOffset=8192 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:13312 // L -> Reg lro=576 swapByteOffset=8192 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->224 */

/* local read increment b */
/* N/A, lro->672 */
s_waitcnt lgkmcnt(5) // wait for prior local read
MAC_4x6_X1

/* iter 6 (swap local pointers iteration) */

/* local read a */
ds_read_b128 v[vgprValuA_X1_I0+0:vgprValuA_X1_I0+0+3], v[vgprLocalReadAddrA] offset:9984 // L -> Reg lro=224 swapByteOffset=8192 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuA_X1_I0+4:vgprValuA_X1_I0+4+3], v[vgprLocalReadAddrA] offset:10112 // L -> Reg lro=224 swapByteOffset=8192 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X1_I0+0:vgprValuB_X1_I0+0+3], v[vgprLocalReadAddrB] offset:13568 // L -> Reg lro=672 swapByteOffset=8192 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+4:vgprValuB_X1_I0+4+3], v[vgprLocalReadAddrB] offset:13824 // L -> Reg lro=672 swapByteOffset=8192 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=1 iui=0
ds_read_b128 v[vgprValuB_X1_I0+8:vgprValuB_X1_I0+8+3], v[vgprLocalReadAddrB] offset:14080 // L -> Reg lro=672 swapByteOffset=8192 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=1 iui=0
s_waitcnt vmcnt(0) // 4wait for global read

/* local write a */
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 0 #7765

/* local write b */
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 0 #7766
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+4:vgprG2LB+4+3] offset:256 // lwoB_1_0_0_0 = (1*LSCB) + (0*LSPB)(*MT1J+PAD) = 256 #7766
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+8:vgprG2LB+8+3] offset:512 // lwoB_2_0_0_0 = (2*LSCB) + (0*LSPB)(*MT1J+PAD) = 512 #7766

/* local write swap offsets a */

/* local write swap offsets b */

/* local write init pointers a */
/* N/A */

/* local write init pointers b */
/* N/A */

/* local read swap offsets a */

/* local read swap internal offset -> 0 */

/* local read swap offsets b */

/* local read swap internal offset -> 0 */

/* local read init pointers a */

/* local read init pointers b */
s_waitcnt lgkmcnt(9) // wait for prior local read
MAC_4x6_X0

/* iter 7 (last) */
s_waitcnt lgkmcnt(0) // 3wait for local write
s_barrier //

/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:128 // L -> Reg lro=0 swapByteOffset=0 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:512 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read inc a */
/* N/A, lro->32 */

/* local read inc b */
/* N/A, lro->96 */
MAC_4x6_X1

/******************************************/
/* Unrolled Loop - End 2/2 (final)        */
/******************************************/
s_add_u32 s[sgprLoopCounters+0], s[sgprLoopCounters+0], 0x1 // inc counterL
s_cmp_eq_i32 s[sgprLoopCounters+0], 0x0            // counterL==0
s_cbranch_scc1 label_0002                          // exit LoopL
s_branch label_0001                                // restart unrolled loop LoopL
label_0003: // unroll loop odditer exit
label_0002:

/******************************************/
/* Tail Loop                              */
/******************************************/

/* local write reset offsets a */

/* local write reset offsets b */
//numIterL = (((sizeL % LOCAL_DEPTHU) + LOCAL_SPLITU - 1) / LOCAL_SPLITU)
s_lshr_b32 s62, s[sgprSizesSum+0], 3               // s62 = s[sgprSizesSum+0] / 8
s_and_b32 s[sgprLoopCounters+0], 7, s[sgprSizesSum+0] // s[sgprLoopCounters+0] = s[sgprSizesSum+0] % 8
s_cmp_eq_u32 s[sgprLoopCounters+0], 0x0            // numIterL == 0
s_cbranch_scc1 label_0006                          // skip to end of tail loop b/c numIter==0
s_sub_u32 s[sgprLoopCounters+0], 0x0, s[sgprLoopCounters+0] // counterL = -sizeL

/* global read a */
/* g2l=0, load component 0 */
buffer_load_dwordx2 v[vgprG2LA+0+0:vgprG2LA+0+0+1], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // load one buffer value
/* g2l=0, load component 1 */
buffer_load_dwordx2 v[vgprG2LA+0+2:vgprG2LA+0+2+1], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:8 // load one buffer value
_v_add_co_u32 v[vgprGlobalReadOffsetA+0], vcc, v[vgprGlobalReadOffsetA+0], 8 // graOffset += bpe

/* global read b */
/* g2l=0, load component 0 */
buffer_load_dwordx2 v[vgprG2LB+0+0:vgprG2LB+0+0+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // load one buffer value
/* g2l=0, load component 1 */
buffer_load_dwordx2 v[vgprG2LB+0+2:vgprG2LB+0+2+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:8 // load one buffer value
/* g2l=4, load component 0 */
buffer_load_dwordx2 v[vgprG2LB+4+0:vgprG2LB+4+0+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0], offen offset:0 // load one buffer value
/* g2l=4, load component 1 */
buffer_load_dwordx2 v[vgprG2LB+4+2:vgprG2LB+4+2+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+0], offen offset:8 // load one buffer value
/* g2l=8, load component 0 */
buffer_load_dwordx2 v[vgprG2LB+8+0:vgprG2LB+8+0+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+1], offen offset:0 // load one buffer value
/* g2l=8, load component 1 */
buffer_load_dwordx2 v[vgprG2LB+8+2:vgprG2LB+8+2+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], s[sgprScalarGlobalReadOffsetB+1], offen offset:8 // load one buffer value
_v_add_co_u32 v[vgprGlobalReadOffsetB+0], vcc, v[vgprGlobalReadOffsetB+0], 8 // graOffset += bpe
s_waitcnt vmcnt(0) // 2wait for global read
s_barrier //

/* local write init pointers a */
/* N/A */

/* local write init pointers b */
/* N/A */

/* local write a */
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 0 #7767

/* local write b */
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 0 #7768
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+4:vgprG2LB+4+3] offset:256 // lwoB_1_0_0_0 = (1*LSCB) + (0*LSPB)(*MT1J+PAD) = 256 #7768
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+8:vgprG2LB+8+3] offset:512 // lwoB_2_0_0_0 = (2*LSCB) + (0*LSPB)(*MT1J+PAD) = 512 #7768
s_waitcnt lgkmcnt(0) // 5wait for local write
s_barrier //

/* local read reset offsets a */
/* handled internally */
v_and_b32 v[vgprLocalReadAddrA], 0x1fff, v[vgprLocalReadAddrA] // reset Red,Blk -> Red

/* local read reset offsets b */
/* handled internally */
v_and_b32 v[vgprLocalReadAddrB], 0x1fff, v[vgprLocalReadAddrB] // reset Red,Blk -> Red

/* local read init pointers a */

/* local read init pointers b */

/* tail loop: macs */
s_cmp_ge_i32 s[sgprLoopCounters+0], 0x0            // LoopCounterL < EndCounter
s_cbranch_scc1 label_0006                          // don't enter LoopL
label_0005:

/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=8 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:128 // L -> Reg lro=0 swapByteOffset=0 ti=8 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:512 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read inc a */
s_mov_b32 s61, 0x100                               // inc
_v_add_co_u32 v[vgprLocalReadAddrA], vcc, s61, v[vgprLocalReadAddrA] // lrA += 256 (LSU*(MT+PAD)*bpe)

/* local read inc b */
s_mov_b32 s61, 0x300                               // inc
_v_add_co_u32 v[vgprLocalReadAddrB], vcc, s61, v[vgprLocalReadAddrB] // lrB += 768 (LSU*(MT+PAD)*bpe)
s_waitcnt lgkmcnt(0) // 4wait for local read
MAC_4x6_X0
s_add_u32 s[sgprLoopCounters+0], s[sgprLoopCounters+0], 0x1 // inc counterL
s_cmp_eq_i32 s[sgprLoopCounters+0], 0x0            // counterL==0
s_cbranch_scc1 label_0006                          // exit LoopL
s_branch label_0005                                // restart tailLoop LoopL
label_0007: // unroll loop odditer exit
label_0006:
s_waitcnt lgkmcnt(0) & vmcnt(0)                    // wait for all summation activity

/* not-LocalSplitU: global write indices */
s_mov_b32 s[sgprSrdC+0], s[sgprAddressC+0]         // init SRD base address (lower)
s_mov_b32 s[sgprSrdC+1], s[sgprAddressC+1]         // init SRD base address (upper) + other fields
s_mov_b32 s[sgprSrdC+2], 0x80000000                // 
s_mov_b32 s[sgprSrdC+3], Srd127_96                 // Set bits 127_96 in SRD
v_lshrrev_b32 v49, 3, v[vgprSerial]                // vectorStaticDiv: v49 = v[vgprSerial] / 8
v_and_b32 v48, 7, v[vgprSerial]                    // vectorStaticDiv: v48 = v[vgprSerial] % 8
v_lshlrev_b32 v48, 1, v48                          // staticMultiply: v48 = v48 * 2
v_lshlrev_b32 v49, 1, v49                          // staticMultiply: v49 = v49 * 2

s_mul_i32 s56, 0x60, s[sgprWorkGroup1]             // <- wg1*MT1
s_mul_hi_u32 s55, s56, s[sgprStridesC+0]           // Scale s56 by Stride
s_mul_i32 s54, s56, s[sgprStridesC+0]              // Scale s56 by Stride
s_lshl_b64 s[54:55], s[54:55], 3                   // scale by bpe
s_add_u32 s[sgprSrdC+0], s[sgprSrdC+0], s54        // add lo to SRD
s_addc_u32 s[sgprSrdC+1], s[sgprSrdC+1], s55       // add hi to SRD

s_mul_hi_u32 s55, s[sgprWorkGroup2], s[sgprStridesC+1] // Scale s[sgprWorkGroup2] by Stride
s_mul_i32 s54, s[sgprWorkGroup2], s[sgprStridesC+1] // Scale s[sgprWorkGroup2] by Stride
s_lshl_b64 s[54:55], s[54:55], 3                   // scale by bpe
s_add_u32 s[sgprSrdC+0], s[sgprSrdC+0], s54        // add lo to SRD
s_addc_u32 s[sgprSrdC+1], s[sgprSrdC+1], s55       // add hi to SRD

v_mul_lo_u32 v50, v49, s[sgprStridesC+0]           // rowStart vgpr

s_mul_i32 s54, 0x20, s[sgprWorkGroup0]             // s54 = wg0*MT0
_v_add_co_u32 v48, vcc, s54, v48                   // coord0 = tid0*VW + wg0*MT0
_v_add_co_u32 v49, vcc, s56, v49                   // coord1 = tid1*VW + wg1*MT1

/* not-LocalSplitU: global write */
s_mov_b32 s54, s[sgprBeta+0]                       // tmp = Beta[0]
s_or_b32 s54, s[sgprBeta+1], s54                   // tmp |= Beta[1] 
s_cmpk_eq_u32 s54, 0x0                             // Beta == 0
s_cbranch_scc0 label_0014                          // Beta is not zero; so jump to B nonzero

s_mov_b32 s54, 0x0                                 // rMT0=0
s_add_u32 s56, -0x1, s[sgprNumWorkGroups0]         // 
s_cmp_lt_u32 s[sgprWorkGroup0], s56                // wg0 < nwg0-1
s_cbranch_scc1 label_0011                          // wg0 < nwg0-1 so skip rMT0 = Size0 % MT0
/* TODO-packed- compare against product of all packed C0 sizes not just SizesFree+0 */
s_lshr_b32 s56, s[sgprSizesFree+0], 5              // s56 = s[sgprSizesFree+0] / 32
s_and_b32 s54, 31, s[sgprSizesFree+0]              // s54 = s[sgprSizesFree+0] % 32
label_0011:
s_cmpk_gt_u32 s54, 0x0                             // rMT0 > 0
s_cbranch_scc1 label_0013                          // edges required so jump to E1
s_mov_b32 s54, 0x0                                 // rMT1=0
s_add_u32 s56, -0x1, s[sgprNumWorkGroups1]         // 
s_cmp_lt_u32 s[sgprWorkGroup1], s56                // wg1 < nwg1-1
s_cbranch_scc1 label_0012                          // wg1 < nwg1-1 so skip rMT1 = Size1 % MT1
s_mov_b32 s59, 0x0                                 // STATIC_DIV: divisior=96
s_mul_i32 s58, 0x555, s[sgprSizesFree+1]           // tmp1 = dividend * magic hi
s_lshl_b64 s[58:59], s[58:59], 0x10                // left shift 16 bits
s_mul_i32 s56, s[sgprSizesFree+1], 0x5556          // tmp0 = dividend * magic lo
s_add_u32 s58, s56, s58                            // add lo
s_addc_u32 s59, s59, 0x0                           // add hi
s_lshr_b64 s[58:59], s[58:59], 0x21                // tmp1 = (dividend * magic) << shift
s_mov_b32 s56, s58                                 // quotient
s_mul_i32 s58, s56, 0x60                           // quotient*divisor
s_sub_u32 s54, s[sgprSizesFree+1], s58             // rReg = dividend - quotient*divisor
label_0012:
s_cmpk_gt_u32 s54, 0x0                             // rMT1 > 0
s_cbranch_scc1 label_0013                          // edges required so jump to E1
label_0010:

/******************************************/
/* Global Write Batch:(0,0,0,0:vw2); (0,0,1,0:vw2); (0,1,0,0:vw2); (0,1,1,0:vw2); (1,0,0,0:vw2); (1,0,1,0:vw2); (1,1,0,0:vw2); (1,1,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v51, v50                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v54, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v55, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v51, v50                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v56, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v57, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s54, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v58, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v59, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s54, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v60, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v61, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 1, 0), (0, 1, 0, 0), (0, 1, 1, 0), (1, 0, 0, 0), (1, 0, 1, 0), (1, 1, 0, 0), (1, 1, 1, 0)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[0:3], v54, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[8:11], v55, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[4:7], v56, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[12:15], v57, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[16:19], v58, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[24:27], v59, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[20:23], v60, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[28:31], v61, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Batch:(2,0,0,0:vw2); (2,0,1,0:vw2); (2,1,0,0:vw2); (2,1,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(2,0,0,0) coordOffset1=64 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=64: d1=2 vc1=0 */
s_mul_i32 s54, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v54, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(2,1,0,0) coordOffset1=65 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=65: d1=2 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v55, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(2,0,1,0) coordOffset1=64 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
s_mul_i32 s54, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v56, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(2,1,1,0) coordOffset1=65 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v57, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr

/* rC *= alpha batchEements=[(2, 0, 0, 0), (2, 0, 1, 0), (2, 1, 0, 0), (2, 1, 1, 0)] */
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[32:35], v54, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[40:43], v55, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[36:39], v56, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[44:47], v57, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0021                                // jump to end
label_0013:

/******************************************/
/* Global Write Edge Batch:(0,0,0,0:vw2); (0,0,1,0:vw2); (0,1,0,0:vw2); (0,1,1,0:vw2); (1,0,0,0:vw2); (1,0,1,0:vw2); (1,1,0,0:vw2); (1,1,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v49 directly */
v_mov_b32 v51, v50                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v54, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v49, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[60:61], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v54, -1, v54, s[60:61]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v53, vcc, v49, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v55, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v55, -1, v55, s[62:63]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v49 directly */
v_mov_b32 v51, v50                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v56, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v49, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v56, -1, v56, s[64:65]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v53, vcc, v49, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v57, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v57, -1, v57, s[66:67]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v53, vcc, v49, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s54, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v58, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v58, -1, v58, s[68:69]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v53, vcc, v49, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v59, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v59, -1, v59, s[70:71]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v53, vcc, v49, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s54, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v60, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[72:73], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v60, -1, v60, s[72:73]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v53, vcc, v49, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v61, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[74:75], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v61, -1, v61, s[74:75]               // clip if OOB. offset

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 1, 0), (0, 1, 0, 0), (0, 1, 1, 0), (1, 0, 0, 0), (1, 0, 1, 0), (1, 1, 0, 0), (1, 1, 1, 0)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[0:3], v54, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[8:11], v55, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[4:7], v56, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[12:15], v57, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[16:19], v58, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[24:27], v59, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[20:23], v60, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[28:31], v61, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Edge Batch:(2,0,0,0:vw2); (2,0,1,0:vw2); (2,1,0,0:vw2); (2,1,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(2,0,0,0) coordOffset1=64 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=64: d1=2 vc1=0 */
_v_add_co_u32 v53, vcc, v49, 64                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s54, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v54, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[60:61], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v54, -1, v54, s[60:61]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,1,0,0) coordOffset1=65 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=65: d1=2 vc1=1 */
s_mov_b32 s54, 65                                  // coordOffset1 d1=0 vc1=0
_v_add_co_u32 v53, vcc, v49, s54                   // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v55, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v55, -1, v55, s[62:63]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,0,1,0) coordOffset1=64 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
_v_add_co_u32 v53, vcc, v49, 64                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s54, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v56, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v56, -1, v56, s[64:65]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,1,1,0) coordOffset1=65 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
s_mov_b32 s54, 65                                  // coordOffset1 d1=1 vc1=0
_v_add_co_u32 v53, vcc, v49, s54                   // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v57, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v57, -1, v57, s[66:67]               // clip if OOB. offset

/* rC *= alpha batchEements=[(2, 0, 0, 0), (2, 0, 1, 0), (2, 1, 0, 0), (2, 1, 1, 0)] */
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[32:35], v54, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[40:43], v55, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[36:39], v56, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[44:47], v57, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0021                                // jump to end
label_0014:
s_mov_b32 s54, 0x0                                 // rMT0=0
s_add_u32 s56, -0x1, s[sgprNumWorkGroups0]         // 
s_cmp_lt_u32 s[sgprWorkGroup0], s56                // wg0 < nwg0-1
s_cbranch_scc1 label_0018                          // wg0 < nwg0-1 so skip rMT0 = Size0 % MT0
/* TODO-packed- compare against product of all packed C0 sizes not just SizesFree+0 */
s_lshr_b32 s56, s[sgprSizesFree+0], 5              // s56 = s[sgprSizesFree+0] / 32
s_and_b32 s54, 31, s[sgprSizesFree+0]              // s54 = s[sgprSizesFree+0] % 32
label_0018:
s_cmpk_gt_u32 s54, 0x0                             // rMT0 > 0
s_cbranch_scc1 label_0020                          // edges required so jump to E1
s_mov_b32 s54, 0x0                                 // rMT1=0
s_add_u32 s56, -0x1, s[sgprNumWorkGroups1]         // 
s_cmp_lt_u32 s[sgprWorkGroup1], s56                // wg1 < nwg1-1
s_cbranch_scc1 label_0019                          // wg1 < nwg1-1 so skip rMT1 = Size1 % MT1
s_mov_b32 s59, 0x0                                 // STATIC_DIV: divisior=96
s_mul_i32 s58, 0x555, s[sgprSizesFree+1]           // tmp1 = dividend * magic hi
s_lshl_b64 s[58:59], s[58:59], 0x10                // left shift 16 bits
s_mul_i32 s56, s[sgprSizesFree+1], 0x5556          // tmp0 = dividend * magic lo
s_add_u32 s58, s56, s58                            // add lo
s_addc_u32 s59, s59, 0x0                           // add hi
s_lshr_b64 s[58:59], s[58:59], 0x21                // tmp1 = (dividend * magic) << shift
s_mov_b32 s56, s58                                 // quotient
s_mul_i32 s58, s56, 0x60                           // quotient*divisor
s_sub_u32 s54, s[sgprSizesFree+1], s58             // rReg = dividend - quotient*divisor
label_0019:
s_cmpk_gt_u32 s54, 0x0                             // rMT1 > 0
s_cbranch_scc1 label_0020                          // edges required so jump to E1
label_0017:

/******************************************/
/* Global Write Beta Batch:(0,0,0,0:vw2); (0,0,1,0:vw2); (0,1,0,0:vw2); (0,1,1,0:vw2); (1,0,0,0:vw2); (1,0,1,0:vw2); (1,1,0,0:vw2); (1,1,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v51, v50                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v54, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[55:58], v54, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v59, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[60:63], v59, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v51, v50                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v64, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[65:68], v64, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v69, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[70:73], v69, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s54, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v74, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[75:78], v74, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v79, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[80:83], v79, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s54, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v84, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[85:88], v84, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v89, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[90:93], v89, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 1, 0), (0, 1, 0, 0), (0, 1, 1, 0), (1, 0, 0, 0), (1, 0, 1, 0), (1, 1, 0, 0), (1, 1, 1, 0)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+0:vgprValuC+0+1], v[55:56], s[sgprBeta:sgprBeta+1], v[vgprValuC+0:vgprValuC+0+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+2:vgprValuC+2+1], v[57:58], s[sgprBeta:sgprBeta+1], v[vgprValuC+2:vgprValuC+2+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[0:3], v54, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+8:vgprValuC+8+1], v[60:61], s[sgprBeta:sgprBeta+1], v[vgprValuC+8:vgprValuC+8+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+10:vgprValuC+10+1], v[62:63], s[sgprBeta:sgprBeta+1], v[vgprValuC+10:vgprValuC+10+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[8:11], v59, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+4:vgprValuC+4+1], v[65:66], s[sgprBeta:sgprBeta+1], v[vgprValuC+4:vgprValuC+4+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+6:vgprValuC+6+1], v[67:68], s[sgprBeta:sgprBeta+1], v[vgprValuC+6:vgprValuC+6+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[4:7], v64, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+12:vgprValuC+12+1], v[70:71], s[sgprBeta:sgprBeta+1], v[vgprValuC+12:vgprValuC+12+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+14:vgprValuC+14+1], v[72:73], s[sgprBeta:sgprBeta+1], v[vgprValuC+14:vgprValuC+14+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[12:15], v69, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+16:vgprValuC+16+1], v[75:76], s[sgprBeta:sgprBeta+1], v[vgprValuC+16:vgprValuC+16+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+18:vgprValuC+18+1], v[77:78], s[sgprBeta:sgprBeta+1], v[vgprValuC+18:vgprValuC+18+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[16:19], v74, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+24:vgprValuC+24+1], v[80:81], s[sgprBeta:sgprBeta+1], v[vgprValuC+24:vgprValuC+24+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+26:vgprValuC+26+1], v[82:83], s[sgprBeta:sgprBeta+1], v[vgprValuC+26:vgprValuC+26+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[24:27], v79, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+20:vgprValuC+20+1], v[85:86], s[sgprBeta:sgprBeta+1], v[vgprValuC+20:vgprValuC+20+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+22:vgprValuC+22+1], v[87:88], s[sgprBeta:sgprBeta+1], v[vgprValuC+22:vgprValuC+22+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[20:23], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+28:vgprValuC+28+1], v[90:91], s[sgprBeta:sgprBeta+1], v[vgprValuC+28:vgprValuC+28+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+30:vgprValuC+30+1], v[92:93], s[sgprBeta:sgprBeta+1], v[vgprValuC+30:vgprValuC+30+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[28:31], v89, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Batch:(2,0,0,0:vw2); (2,0,1,0:vw2); (2,1,0,0:vw2); (2,1,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(2,0,0,0) coordOffset1=64 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=64: d1=2 vc1=0 */
s_mul_i32 s54, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v54, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[55:58], v54, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,0,0) coordOffset1=65 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=65: d1=2 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v59, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[60:63], v59, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,0,1,0) coordOffset1=64 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
s_mul_i32 s54, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v64, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[65:68], v64, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,1,0) coordOffset1=65 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v69, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[70:73], v69, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(2, 0, 0, 0), (2, 0, 1, 0), (2, 1, 0, 0), (2, 1, 1, 0)] */
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+32:vgprValuC+32+1], v[55:56], s[sgprBeta:sgprBeta+1], v[vgprValuC+32:vgprValuC+32+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+34:vgprValuC+34+1], v[57:58], s[sgprBeta:sgprBeta+1], v[vgprValuC+34:vgprValuC+34+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[32:35], v54, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+40:vgprValuC+40+1], v[60:61], s[sgprBeta:sgprBeta+1], v[vgprValuC+40:vgprValuC+40+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+42:vgprValuC+42+1], v[62:63], s[sgprBeta:sgprBeta+1], v[vgprValuC+42:vgprValuC+42+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[40:43], v59, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+36:vgprValuC+36+1], v[65:66], s[sgprBeta:sgprBeta+1], v[vgprValuC+36:vgprValuC+36+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+38:vgprValuC+38+1], v[67:68], s[sgprBeta:sgprBeta+1], v[vgprValuC+38:vgprValuC+38+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[36:39], v64, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+44:vgprValuC+44+1], v[70:71], s[sgprBeta:sgprBeta+1], v[vgprValuC+44:vgprValuC+44+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+46:vgprValuC+46+1], v[72:73], s[sgprBeta:sgprBeta+1], v[vgprValuC+46:vgprValuC+46+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[44:47], v69, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0021                                // jump to end
label_0020:

/******************************************/
/* Global Write Beta Edge Batch:(0,0,0,0:vw2); (0,0,1,0:vw2); (0,1,0,0:vw2); (0,1,1,0:vw2); (1,0,0,0:vw2); (1,0,1,0:vw2); (1,1,0,0:vw2); (1,1,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v49 directly */
v_mov_b32 v51, v50                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v54, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v49, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[60:61], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v54, -1, v54, s[60:61]               // clip if OOB. offset
buffer_load_dwordx4 v[55:58], v54, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v53, vcc, v49, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v59, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v59, -1, v59, s[62:63]               // clip if OOB. offset
buffer_load_dwordx4 v[60:63], v59, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v49 directly */
v_mov_b32 v51, v50                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v64, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v49, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v64, -1, v64, s[64:65]               // clip if OOB. offset
buffer_load_dwordx4 v[65:68], v64, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v53, vcc, v49, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v69, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v69, -1, v69, s[66:67]               // clip if OOB. offset
buffer_load_dwordx4 v[70:73], v69, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v53, vcc, v49, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s54, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v74, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v74, -1, v74, s[68:69]               // clip if OOB. offset
buffer_load_dwordx4 v[75:78], v74, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v53, vcc, v49, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v79, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v79, -1, v79, s[70:71]               // clip if OOB. offset
buffer_load_dwordx4 v[80:83], v79, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v53, vcc, v49, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s54, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v84, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[72:73], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v84, -1, v84, s[72:73]               // clip if OOB. offset
buffer_load_dwordx4 v[85:88], v84, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v53, vcc, v49, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v89, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[74:75], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v89, -1, v89, s[74:75]               // clip if OOB. offset
buffer_load_dwordx4 v[90:93], v89, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 1, 0), (0, 1, 0, 0), (0, 1, 1, 0), (1, 0, 0, 0), (1, 0, 1, 0), (1, 1, 0, 0), (1, 1, 1, 0)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+0:vgprValuC+0+1], v[55:56], s[sgprBeta:sgprBeta+1], v[vgprValuC+0:vgprValuC+0+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+2:vgprValuC+2+1], v[57:58], s[sgprBeta:sgprBeta+1], v[vgprValuC+2:vgprValuC+2+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[0:3], v54, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+8:vgprValuC+8+1], v[60:61], s[sgprBeta:sgprBeta+1], v[vgprValuC+8:vgprValuC+8+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+10:vgprValuC+10+1], v[62:63], s[sgprBeta:sgprBeta+1], v[vgprValuC+10:vgprValuC+10+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[8:11], v59, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+4:vgprValuC+4+1], v[65:66], s[sgprBeta:sgprBeta+1], v[vgprValuC+4:vgprValuC+4+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+6:vgprValuC+6+1], v[67:68], s[sgprBeta:sgprBeta+1], v[vgprValuC+6:vgprValuC+6+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[4:7], v64, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+12:vgprValuC+12+1], v[70:71], s[sgprBeta:sgprBeta+1], v[vgprValuC+12:vgprValuC+12+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+14:vgprValuC+14+1], v[72:73], s[sgprBeta:sgprBeta+1], v[vgprValuC+14:vgprValuC+14+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[12:15], v69, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+16:vgprValuC+16+1], v[75:76], s[sgprBeta:sgprBeta+1], v[vgprValuC+16:vgprValuC+16+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+18:vgprValuC+18+1], v[77:78], s[sgprBeta:sgprBeta+1], v[vgprValuC+18:vgprValuC+18+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[16:19], v74, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+24:vgprValuC+24+1], v[80:81], s[sgprBeta:sgprBeta+1], v[vgprValuC+24:vgprValuC+24+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+26:vgprValuC+26+1], v[82:83], s[sgprBeta:sgprBeta+1], v[vgprValuC+26:vgprValuC+26+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[24:27], v79, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+20:vgprValuC+20+1], v[85:86], s[sgprBeta:sgprBeta+1], v[vgprValuC+20:vgprValuC+20+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+22:vgprValuC+22+1], v[87:88], s[sgprBeta:sgprBeta+1], v[vgprValuC+22:vgprValuC+22+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[20:23], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+28:vgprValuC+28+1], v[90:91], s[sgprBeta:sgprBeta+1], v[vgprValuC+28:vgprValuC+28+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+30:vgprValuC+30+1], v[92:93], s[sgprBeta:sgprBeta+1], v[vgprValuC+30:vgprValuC+30+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[28:31], v89, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Edge Batch:(2,0,0,0:vw2); (2,0,1,0:vw2); (2,1,0,0:vw2); (2,1,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(2,0,0,0) coordOffset1=64 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=64: d1=2 vc1=0 */
_v_add_co_u32 v53, vcc, v49, 64                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s54, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v54, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[60:61], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v54, -1, v54, s[60:61]               // clip if OOB. offset
buffer_load_dwordx4 v[55:58], v54, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,0,0) coordOffset1=65 coordOffset0=0 */
/*   coordOffset=0, use coord0=v48 directly */
/*   new coordOffset1=65: d1=2 vc1=1 */
s_mov_b32 s54, 65                                  // coordOffset1 d1=0 vc1=0
_v_add_co_u32 v53, vcc, v49, s54                   // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v59, v51, v48, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v48, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v59, -1, v59, s[62:63]               // clip if OOB. offset
buffer_load_dwordx4 v[60:63], v59, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,0,1,0) coordOffset1=64 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
_v_add_co_u32 v53, vcc, v49, 64                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s54, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v51, vcc, v50, s54                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v64, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v64, -1, v64, s[64:65]               // clip if OOB. offset
buffer_load_dwordx4 v[65:68], v64, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,1,0) coordOffset1=65 coordOffset0=16 */
_v_add_co_u32 v52, vcc, v48, 16                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
s_mov_b32 s54, 65                                  // coordOffset1 d1=1 vc1=0
_v_add_co_u32 v53, vcc, v49, s54                   // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v51, vcc, v51, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v69, v51, v52, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[54:55], v52, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[56:57], v53, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[54:55], s[56:57]             // in0 && in1
v_cndmask_b32 v69, -1, v69, s[66:67]               // clip if OOB. offset
buffer_load_dwordx4 v[70:73], v69, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(2, 0, 0, 0), (2, 0, 1, 0), (2, 1, 0, 0), (2, 1, 1, 0)] */
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+32:vgprValuC+32+1], v[55:56], s[sgprBeta:sgprBeta+1], v[vgprValuC+32:vgprValuC+32+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+34:vgprValuC+34+1], v[57:58], s[sgprBeta:sgprBeta+1], v[vgprValuC+34:vgprValuC+34+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[32:35], v54, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+40:vgprValuC+40+1], v[60:61], s[sgprBeta:sgprBeta+1], v[vgprValuC+40:vgprValuC+40+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+42:vgprValuC+42+1], v[62:63], s[sgprBeta:sgprBeta+1], v[vgprValuC+42:vgprValuC+42+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[40:43], v59, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+36:vgprValuC+36+1], v[65:66], s[sgprBeta:sgprBeta+1], v[vgprValuC+36:vgprValuC+36+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+38:vgprValuC+38+1], v[67:68], s[sgprBeta:sgprBeta+1], v[vgprValuC+38:vgprValuC+38+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[36:39], v64, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+44:vgprValuC+44+1], v[70:71], s[sgprBeta:sgprBeta+1], v[vgprValuC+44:vgprValuC+44+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+46:vgprValuC+46+1], v[72:73], s[sgprBeta:sgprBeta+1], v[vgprValuC+46:vgprValuC+46+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[44:47], v69, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0021                                // jump to end
label_0021:
s_endpgm                                           // End Kernel
