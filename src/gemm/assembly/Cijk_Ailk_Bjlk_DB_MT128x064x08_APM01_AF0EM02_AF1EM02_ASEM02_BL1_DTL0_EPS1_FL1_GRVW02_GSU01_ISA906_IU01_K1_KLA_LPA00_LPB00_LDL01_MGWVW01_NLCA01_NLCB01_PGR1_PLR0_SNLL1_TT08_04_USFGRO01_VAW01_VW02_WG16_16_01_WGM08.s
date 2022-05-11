

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
.amdgpu_hsa_kernel Cijk_Ailk_Bjlk_DB_MT128x064x08_APM01_AF0EM02_AF1EM02_ASEM02_BL1_DTL0_EPS1_FL1_GRVW02_GSU01_ISA906_IU01_K1_KLA_LPA00_LPB00_LDL01_MGWVW01_NLCA01_NLCB01_PGR1_PLR0_SNLL1_TT08_04_USFGRO01_VAW01_VW02_WG16_16_01_WGM08
Cijk_Ailk_Bjlk_DB_MT128x064x08_APM01_AF0EM02_AF1EM02_ASEM02_BL1_DTL0_EPS1_FL1_GRVW02_GSU01_ISA906_IU01_K1_KLA_LPA00_LPB00_LDL01_MGWVW01_NLCA01_NLCB01_PGR1_PLR0_SNLL1_TT08_04_USFGRO01_VAW01_VW02_WG16_16_01_WGM08:
.amd_kernel_code_t
  is_ptr64 = 1
  enable_sgpr_kernarg_segment_ptr = 1
  kernarg_segment_byte_size = 92 // bytes of kern args
  workitem_vgpr_count = 107 // vgprs
  wavefront_sgpr_count = 74 // sgprs
  compute_pgm_rsrc1_vgprs = 26 // floor((107-1)/4)
  compute_pgm_rsrc1_sgprs = 10 // floor((74-1)/8)
  compute_pgm_rsrc2_tidig_comp_cnt = 0 // 1D wg
  compute_pgm_rsrc2_tgid_x_en = 1 // wg.x
  compute_pgm_rsrc2_tgid_y_en = 1 // wg.y
  compute_pgm_rsrc2_tgid_z_en = 1 // wg.z
  workgroup_group_segment_byte_size = 28672 // lds bytes
  compute_pgm_rsrc2_user_sgpr = 2 // vcc
  kernarg_segment_alignment = 4
  group_segment_alignment = 4
  private_segment_alignment = 4
.end_amd_kernel_code_t

/******************************************/
/* Optimizations and Config:              */
/******************************************/
/* ThreadTile= 8 x 4 */
/* SubGroup= 16 x 16 */
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
.set vgprValuA_X0_I0, 64
.set vgprG2LA, 80
.set vgprValuB_X0_I0, 88
.set vgprG2LB, 96
.set vgprLocalReadAddrA, 100
.set vgprLocalReadAddrB, 101
.set vgprLocalWriteAddrA, 102
.set vgprLocalWriteAddrB, 103
.set vgprGlobalReadOffsetA, 104
.set vgprGlobalReadOffsetB, 105
.set vgprSerial, 106
/* max VGPR=107 */

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
.set sgprOrigLoopCounter, 41
.set sgprStridesA, 42
.set sgprStridesB, 44
.set sgprAddressA, 46
.set sgprAddressB, 48
.set sgprShadowLimitA, 50
.set sgprShadowLimitB, 52
.set sgprStaggerUIter, 54
.set sgprWrapUA, 55
.set sgprWrapUB, 56
.set sgprOffsetC, 57
.set sgprOffsetA, 58
.set sgprOffsetB, 59
.set sgprGlobalReadIncsA, 60
.set sgprGlobalReadIncsB, 61
.set sgprScalarGlobalReadOffsetA, 62
/* max SGPR=74 */

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
/* 8x4 thread-tile                        */
/******************************************/
.macro MAC_8x4_X0
v_fma_f64 v[vgprValuC+(0+0*8)*2:(vgprValuC+0+0*8)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(0+0*8)*2:(vgprValuC+0+0*8)*2+1]
s_setprio 1 // Raise priority while processing macs 
v_fma_f64 v[vgprValuC+(1+0*8)*2:(vgprValuC+1+0*8)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(1+0*8)*2:(vgprValuC+1+0*8)*2+1]
v_fma_f64 v[vgprValuC+(2+0*8)*2:(vgprValuC+2+0*8)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(2+0*8)*2:(vgprValuC+2+0*8)*2+1]
v_fma_f64 v[vgprValuC+(3+0*8)*2:(vgprValuC+3+0*8)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(3+0*8)*2:(vgprValuC+3+0*8)*2+1]
v_fma_f64 v[vgprValuC+(4+0*8)*2:(vgprValuC+4+0*8)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(4+0*8)*2:(vgprValuC+4+0*8)*2+1]
v_fma_f64 v[vgprValuC+(5+0*8)*2:(vgprValuC+5+0*8)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(5+0*8)*2:(vgprValuC+5+0*8)*2+1]
v_fma_f64 v[vgprValuC+(6+0*8)*2:(vgprValuC+6+0*8)*2+1], v[vgprValuA_X0_I0+6*2:vgprValuA_X0_I0+6*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(6+0*8)*2:(vgprValuC+6+0*8)*2+1]
v_fma_f64 v[vgprValuC+(7+0*8)*2:(vgprValuC+7+0*8)*2+1], v[vgprValuA_X0_I0+7*2:vgprValuA_X0_I0+7*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(7+0*8)*2:(vgprValuC+7+0*8)*2+1]
v_fma_f64 v[vgprValuC+(0+1*8)*2:(vgprValuC+0+1*8)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(0+1*8)*2:(vgprValuC+0+1*8)*2+1]
v_fma_f64 v[vgprValuC+(1+1*8)*2:(vgprValuC+1+1*8)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(1+1*8)*2:(vgprValuC+1+1*8)*2+1]
v_fma_f64 v[vgprValuC+(2+1*8)*2:(vgprValuC+2+1*8)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(2+1*8)*2:(vgprValuC+2+1*8)*2+1]
v_fma_f64 v[vgprValuC+(3+1*8)*2:(vgprValuC+3+1*8)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(3+1*8)*2:(vgprValuC+3+1*8)*2+1]
v_fma_f64 v[vgprValuC+(4+1*8)*2:(vgprValuC+4+1*8)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(4+1*8)*2:(vgprValuC+4+1*8)*2+1]
v_fma_f64 v[vgprValuC+(5+1*8)*2:(vgprValuC+5+1*8)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(5+1*8)*2:(vgprValuC+5+1*8)*2+1]
v_fma_f64 v[vgprValuC+(6+1*8)*2:(vgprValuC+6+1*8)*2+1], v[vgprValuA_X0_I0+6*2:vgprValuA_X0_I0+6*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(6+1*8)*2:(vgprValuC+6+1*8)*2+1]
v_fma_f64 v[vgprValuC+(7+1*8)*2:(vgprValuC+7+1*8)*2+1], v[vgprValuA_X0_I0+7*2:vgprValuA_X0_I0+7*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(7+1*8)*2:(vgprValuC+7+1*8)*2+1]
v_fma_f64 v[vgprValuC+(0+2*8)*2:(vgprValuC+0+2*8)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(0+2*8)*2:(vgprValuC+0+2*8)*2+1]
v_fma_f64 v[vgprValuC+(1+2*8)*2:(vgprValuC+1+2*8)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(1+2*8)*2:(vgprValuC+1+2*8)*2+1]
v_fma_f64 v[vgprValuC+(2+2*8)*2:(vgprValuC+2+2*8)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(2+2*8)*2:(vgprValuC+2+2*8)*2+1]
v_fma_f64 v[vgprValuC+(3+2*8)*2:(vgprValuC+3+2*8)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(3+2*8)*2:(vgprValuC+3+2*8)*2+1]
v_fma_f64 v[vgprValuC+(4+2*8)*2:(vgprValuC+4+2*8)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(4+2*8)*2:(vgprValuC+4+2*8)*2+1]
v_fma_f64 v[vgprValuC+(5+2*8)*2:(vgprValuC+5+2*8)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(5+2*8)*2:(vgprValuC+5+2*8)*2+1]
v_fma_f64 v[vgprValuC+(6+2*8)*2:(vgprValuC+6+2*8)*2+1], v[vgprValuA_X0_I0+6*2:vgprValuA_X0_I0+6*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(6+2*8)*2:(vgprValuC+6+2*8)*2+1]
v_fma_f64 v[vgprValuC+(7+2*8)*2:(vgprValuC+7+2*8)*2+1], v[vgprValuA_X0_I0+7*2:vgprValuA_X0_I0+7*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(7+2*8)*2:(vgprValuC+7+2*8)*2+1]
v_fma_f64 v[vgprValuC+(0+3*8)*2:(vgprValuC+0+3*8)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(0+3*8)*2:(vgprValuC+0+3*8)*2+1]
v_fma_f64 v[vgprValuC+(1+3*8)*2:(vgprValuC+1+3*8)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(1+3*8)*2:(vgprValuC+1+3*8)*2+1]
v_fma_f64 v[vgprValuC+(2+3*8)*2:(vgprValuC+2+3*8)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(2+3*8)*2:(vgprValuC+2+3*8)*2+1]
v_fma_f64 v[vgprValuC+(3+3*8)*2:(vgprValuC+3+3*8)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(3+3*8)*2:(vgprValuC+3+3*8)*2+1]
v_fma_f64 v[vgprValuC+(4+3*8)*2:(vgprValuC+4+3*8)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(4+3*8)*2:(vgprValuC+4+3*8)*2+1]
v_fma_f64 v[vgprValuC+(5+3*8)*2:(vgprValuC+5+3*8)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(5+3*8)*2:(vgprValuC+5+3*8)*2+1]
v_fma_f64 v[vgprValuC+(6+3*8)*2:(vgprValuC+6+3*8)*2+1], v[vgprValuA_X0_I0+6*2:vgprValuA_X0_I0+6*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(6+3*8)*2:(vgprValuC+6+3*8)*2+1]
v_fma_f64 v[vgprValuC+(7+3*8)*2:(vgprValuC+7+3*8)*2+1], v[vgprValuA_X0_I0+7*2:vgprValuA_X0_I0+7*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(7+3*8)*2:(vgprValuC+7+3*8)*2+1]
s_setprio 0 // Reset priority after macs 
.endm



/******************************************/
/* Allocate Resources                     */
/******************************************/

s_mov_b32 m0, 0x7000                               // LDS clamp at 28672 bytes
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
s_load_dword s[sgprStaggerUIter], s[sgprKernArgAddress:sgprKernArgAddress+1], 0x74 // load StaggerUIter
s_waitcnt lgkmcnt(0)                               // wait for 120 bytes of kern args

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
s_mov_b32 s63, 0x7f                                // 
_v_add_co_u32 v0, vcc, s63, v0                     // v0 = size0+MT0-1
v_lshrrev_b32 v3, 7, v0                            // vectorStaticDiv: v3 = v0 / 128
v_readfirstlane_b32 s[sgprNumWorkGroups0], v3      // 
// size1 = (size1J + MT1J - 1) / MT1J;
v_mov_b32 v0, s[sgprSizesFree+1]                   // 
s_mov_b32 s63, 0x3f                                // 
_v_add_co_u32 v0, vcc, s63, v0                     // v0 = size1+MT1-1
v_lshrrev_b32 v3, 6, v0                            // vectorStaticDiv: v3 = v0 / 64
v_readfirstlane_b32 s[sgprNumWorkGroups1], v3      // 


/******************************************/
/* Global Read Addresses                  */
/******************************************/


/* global read addresses: subgroup */

/*   not needed until local read addresses */


/* global read addresses: work-group */

// nwg0 = (size0I + MT0I - 1) / MT0I;
v_mov_b32 v2, s[sgprSizesFree+0]                   // 
s_mov_b32 s64, 0x7f                                // 
_v_add_co_u32 v2, vcc, s64, v2                     // v2 = size0+MT0-1
v_lshrrev_b32 v2, 7, v2                            // vectorStaticDiv: v2 = v2 / 128
// nwg1 = (size1J + MT1J - 1) / MT1J;
v_mov_b32 v3, s[sgprSizesFree+1]                   // 
s_mov_b32 s64, 0x3f                                // 
_v_add_co_u32 v3, vcc, s64, v3                     // v3 = size1+MT1-1
v_lshrrev_b32 v3, 6, v3                            // vectorStaticDiv: v3 = v3 / 64
v_mov_b32 v6, s[sgprWorkGroup1]                    // wg1
v_lshrrev_b32 v4, 3, v6                            // vectorStaticDiv: v4 = v6 / 8
v_and_b32 v5, 7, v6                                // vectorStaticDiv: v5 = v6 % 8
v_mul_lo_u32 v5, v5, v2                            // (wg1 % WGM)*nwg0
_v_add_co_u32 v5, vcc, s[sgprWorkGroup0], v5       // wgSerial = wg0 + (wg1 % WGM)*nwg0
// numFullBlocks = (nwg1) / WGM
v_lshrrev_b32 v2, 3, v3                            // vectorStaticDiv: v2 = v3 / 8
v_and_b32 v7, 7, v3                                // vectorStaticDiv: v7 = v3 % 8
v_cmp_lt_u32 s[64:65], v4, v2                      // blockId < numFullBlocks
v_cndmask_b32 v2, v7, 0x8, s[64:65]                // blockWidth = (blockId < numFullBlocks) ? WGM : remainder
DYNAMIC_VECTOR_DIVIDE 3 6 5 2 0 1 64
v_mul_lo_u32 v4, v4, 8                             // blockId * WGM
_v_add_co_u32 v6, vcc, v6, v4                      // wg1 += blockId * WGM
v_readfirstlane_b32 s[sgprWorkGroup0], v3          // 
v_readfirstlane_b32 s[sgprWorkGroup1], v6          // 


/* global read addresses: tile offset assignment a */

/* LVCA = 64 */
/* v0 = (local)groA-tile = serial%LVCA (note (wgA*MTA) will be added to SRD) */
/* v1 = groA-unroll = serial/LVCA */
v_lshrrev_b32 v1, 6, v[vgprSerial]                 // vectorStaticDiv: v1 = v[vgprSerial] / 64
v_and_b32 v0, 63, v[vgprSerial]                    // vectorStaticDiv: v0 = v[vgprSerial] % 64
/* gro-tile *= glvw */
v_lshlrev_b32 v0, 1, v0                            // staticMultiply: v0 = v0 * 2


/* global read addresses: tile offset assignment b */

/* LVCB = 32 */
/* v2 = (local)groB-tile = serial%LVCB (note (wgB*MTB) will be added to SRD) */
/* v3 = groB-unroll = serial/LVCB */
v_lshrrev_b32 v3, 5, v[vgprSerial]                 // vectorStaticDiv: v3 = v[vgprSerial] / 32
v_and_b32 v2, 31, v[vgprSerial]                    // vectorStaticDiv: v2 = v[vgprSerial] % 32
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
s_mul_i32 s[sgprScalarGlobalReadOffsetA+0], s[sgprStridesA+0], 4 // compute offset diff (scaled unrollDim)
s_lshl_b32 s[sgprScalarGlobalReadOffsetA+0], s[sgprScalarGlobalReadOffsetA+0], 0x3 // scalar offset *= bytes/element


/* global read addresses: final offsets b */

GLOBAL_OFFSET_B vgprGlobalReadOffsetB+0,  2,  3, 4 // gROB_0_0_0_0


/* global read addresses: apply user offsets */

/* moved earlier */


/* global read addresses: addresses a */

/* max read offset = size[n] * stride[n-1] */
s_mul_hi_u32 s67, s[sgprWorkGroup0], 128           // WorkGroup[01] * MT
s_mul_i32 s66, s[sgprWorkGroup0], 128              // WorkGroup[01] * MT
s_sub_u32 s[sgprShadowLimitA+0], s[sgprTensor2dSizeA], s66 // sub tileStart
s_subb_u32 s[sgprShadowLimitA+1], s[sgprTensor2dSizeA+1], s67 // sub tileStart
s_lshl_b64 s[sgprShadowLimitA:sgprShadowLimitA+1], s[sgprShadowLimitA:sgprShadowLimitA+1], 0x3 // Set limit to use bytes
s_add_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], 16 // extend limit for pre-pad
s_addc_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], 0 // extend limit for pre-pad
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0], BufferLimit // Move shadow to real if we are within 2^32
s_mul_hi_u32 s65, s[sgprStridesA+1], s[sgprWorkGroup2] // Stride*WG
s_mul_i32 s64, s[sgprStridesA+1], s[sgprWorkGroup2] // Stride*WG
s_add_u32 s66, s66, s64                            // accum wg term to tilestart
s_addc_u32 s67, s67, s65                           // accum wg term to tilestart
s_lshl_b64 s[66:67], s[66:67], 3                   // tileStart *= BPE
s_add_u32 s[sgprSrdA+0], s[sgprAddressA+0], s66    // SRD base = Address+ tileStart0
s_addc_u32 s[sgprSrdA+1], s[sgprAddressA+1], s67   // SRD base = Address+ tileStart1
s_sub_u32 s[sgprSrdA+0], s[sgprSrdA+0], 16         // pre-pad to make room for possible pointer shift
s_subb_u32 s[sgprSrdA+1], s[sgprSrdA+1], 0         // pre-pad to make room for possible pointer shift
s_mov_b32 s[sgprSrdA+3], Srd127_96                 // Set bits 127_96 in SRD


/* global read addresses: addresses b */

/* max read offset = size[n] * stride[n-1] */
s_mul_hi_u32 s67, s[sgprWorkGroup1], 64            // WorkGroup[01] * MT
s_mul_i32 s66, s[sgprWorkGroup1], 64               // WorkGroup[01] * MT
s_sub_u32 s[sgprShadowLimitB+0], s[sgprTensor2dSizeB], s66 // sub tileStart
s_subb_u32 s[sgprShadowLimitB+1], s[sgprTensor2dSizeB+1], s67 // sub tileStart
s_lshl_b64 s[sgprShadowLimitB:sgprShadowLimitB+1], s[sgprShadowLimitB:sgprShadowLimitB+1], 0x3 // Set limit to use bytes
s_add_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], 16 // extend limit for pre-pad
s_addc_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], 0 // extend limit for pre-pad
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cselect_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0], BufferLimit // Move shadow to real if we are within 2^32
s_mul_hi_u32 s65, s[sgprStridesB+1], s[sgprWorkGroup2] // Stride*WG
s_mul_i32 s64, s[sgprStridesB+1], s[sgprWorkGroup2] // Stride*WG
s_add_u32 s66, s66, s64                            // accum wg term to tilestart
s_addc_u32 s67, s67, s65                           // accum wg term to tilestart
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

v_mul_u32_u24 v[vgprLocalWriteAddrA], 0x80, v1     // lwAL**(MTA + PAD)
_v_add_lshl_u32 v[vgprLocalWriteAddrA], v0, v[vgprLocalWriteAddrA], 0x3 // lwFOA = (lwAA + lwAL*(MT0I+PAD))*bpe


/* local write addresses: first offset b */

v_mul_u32_u24 v[vgprLocalWriteAddrB], 0x40, v3     // lwBL**(MTB + PAD)
_v_add_lshl_u32 v[vgprLocalWriteAddrB], v2, v[vgprLocalWriteAddrB], 0x3 // lwFOB = (lwBB + lwBL*(MT1J+PAD))*bpe
_v_add_co_u32 v[vgprLocalWriteAddrB], vcc, 0x2000, v[vgprLocalWriteAddrB] // lwFOB = lwB1J + lwBL*MT1J + LDS_OFFSET_B=1024*8


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
v_lshrrev_b32 v0, 4, v[vgprSerial]                 // vectorStaticDiv: v0 = v[vgprSerial] / 16
v_and_b32 v1, 15, v[vgprSerial]                    // vectorStaticDiv: v1 = v[vgprSerial] % 16


/* local read addresses: tile assignments b */

/*lr1J = (serial / SG1J) % SG1J*/
v_lshrrev_b32 v2, 4, v0                            // vectorStaticDiv: v2 = v0 / 16
v_and_b32 v3, 15, v0                               // vectorStaticDiv: v3 = v0 % 16


/* local read addresses: final offsets a */

v_lshrrev_b32 v0, 8, v[vgprSerial]                 // vectorStaticDiv: v0 = v[vgprSerial] / 256
v_and_b32 v2, 255, v[vgprSerial]                   // vectorStaticDiv: v2 = v[vgprSerial] % 256
s_mov_b32 s63, 0x80                                // MT0+PAD
v_mul_lo_u32 v0, s63, v0                           // sgid=sgid*(MT0+PAD)
v_lshlrev_b32 v1, 1, v1                            // staticMultiply: v1 = v1 * 2
_v_add_lshl_u32 v[vgprLocalReadAddrA], v0, v1, 0x3 // o = (lroA*VW+sgid*MT0)*bpe


/* local read addresses: final offsets b */

v_lshrrev_b32 v0, 8, v[vgprSerial]                 // vectorStaticDiv: v0 = v[vgprSerial] / 256
v_and_b32 v1, 255, v[vgprSerial]                   // vectorStaticDiv: v1 = v[vgprSerial] % 256
s_mov_b32 s63, 0x40                                // MT1+PAD
v_mul_lo_u32 v0, s63, v0                           // sgid=sgid*(MT1+PAD)
v_lshlrev_b32 v3, 1, v3                            // staticMultiply: v3 = v3 * 2
_v_add_lshl_u32 v[vgprLocalReadAddrB], v0, v3, 0x3 // o = (lroB*VW+sgid*MT1)*bpe


/* local read addresses: declare addresses a */

/* N/A */


/* local read addresses: declare addresses b */

_v_add_co_u32 v[vgprLocalReadAddrB+0], vcc, 0x2000, v[vgprLocalReadAddrB+0] //  += LdsOffsetB (lower)


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
v_mov_b32 v[vgprValuC+48], 0x0                     // initC
v_mov_b32 v[vgprValuC+49], 0x0                     // initC
v_mov_b32 v[vgprValuC+50], 0x0                     // initC
v_mov_b32 v[vgprValuC+51], 0x0                     // initC
v_mov_b32 v[vgprValuC+52], 0x0                     // initC
v_mov_b32 v[vgprValuC+53], 0x0                     // initC
v_mov_b32 v[vgprValuC+54], 0x0                     // initC
v_mov_b32 v[vgprValuC+55], 0x0                     // initC
v_mov_b32 v[vgprValuC+56], 0x0                     // initC
v_mov_b32 v[vgprValuC+57], 0x0                     // initC
v_mov_b32 v[vgprValuC+58], 0x0                     // initC
v_mov_b32 v[vgprValuC+59], 0x0                     // initC
v_mov_b32 v[vgprValuC+60], 0x0                     // initC
v_mov_b32 v[vgprValuC+61], 0x0                     // initC
v_mov_b32 v[vgprValuC+62], 0x0                     // initC
v_mov_b32 v[vgprValuC+63], 0x0                     // initC

s_lshr_b32 s[sgprLoopCounters+0], s[sgprSizesSum+0], 3 // s[sgprLoopCounters+0] = s[sgprSizesSum+0] / 8
s_mov_b32 s[sgprOrigLoopCounter], s[sgprLoopCounters+0] // copy loop counter
s_sub_u32 s[sgprLoopCounters+0], 0x0, s[sgprLoopCounters+0] // counterL = -sizeL

s_and_b32 s[sgprStaggerUIter], s[sgprStaggerUIter], s[sgprWorkGroup0] // Compute actual stagger start for this kernel
s_lshl_b32 s[sgprStaggerUIter], s[sgprStaggerUIter], 2 // shift by StaggerUStride

/* SRDs += (StaggerUIter) * GlobalReadIncsA */
s_mul_i32 s63, s[sgprStaggerUIter], s[sgprGlobalReadIncsA] //  stagger byte offset
s_mul_i32 s[sgprWrapUA], s[sgprLoopCounters+0], s[sgprGlobalReadIncsA] // Number of bytes accessed by the unroll loop
s_add_u32 s[sgprWrapUA], s[sgprGlobalReadIncsA], s[sgprWrapUA] // Negative, and remove one iteration
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s63       // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s63 // limit -= inc)
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0]    // Move shadow to real if we are within 2^32

/* SRDs += (StaggerUIter) * GlobalReadIncsB */
s_mul_i32 s63, s[sgprStaggerUIter], s[sgprGlobalReadIncsB] //  stagger byte offset
s_mul_i32 s[sgprWrapUB], s[sgprLoopCounters+0], s[sgprGlobalReadIncsB] // Number of bytes accessed by the unroll loop
s_add_u32 s[sgprWrapUB], s[sgprGlobalReadIncsB], s[sgprWrapUB] // Negative, and remove one iteration
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s63       // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s63 // limit -= inc)
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0]    // Move shadow to real if we are within 2^32
s_sub_i32 s[sgprStaggerUIter], -2, s[sgprStaggerUIter] // Subtract (PGR-1); StaggerUIter now contains target iteration to wrap


/* local read addresses: init pointers a */



/* local read addresses: init pointers b */



/* prefetch: global -> local */

s_cmp_eq_u32 s[sgprLoopCounters+0], 0x0            // numIter0I == 0
s_cbranch_scc1 label_0002                          // skip to end of prefetch last iter b/c numIter==0


/* global read a */

buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_0_0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+4+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0], offen offset:0 // G -> Reg 0_0_1_0


/* global read b */

buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // G -> Reg 0_0_0_0


/* global read inc a */


/* global read inc A */
s_sub_u32 s66, s[sgprLoopCounters+0], 1            // remove pf(1)
s_cmp_eq_u32 s[sgprStaggerUIter], s66              // Is this wrapIter? (pf)
s_cselect_b32 s64, s[sgprWrapUA], s[sgprGlobalReadIncsA] // incLower <- ?
s_and_b32 s65, s64, 2147483648                     // test
s_subb_u32 s65, 0, 0                               // -1 or 0
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s64       // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], s65      // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s64 // limit -= inc)
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s65 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0]    // Move shadow to real if we are within 2^32


/* global read inc b */


/* global read inc B */
s_sub_u32 s66, s[sgprLoopCounters+0], 1            // remove pf(1)
s_cmp_eq_u32 s[sgprStaggerUIter], s66              // Is this wrapIter? (pf)
s_cselect_b32 s64, s[sgprWrapUB], s[sgprGlobalReadIncsB] // incLower <- ?
s_and_b32 s65, s64, 2147483648                     // test
s_subb_u32 s65, 0, 0                               // -1 or 0
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s64       // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], s65      // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s64 // limit -= inc)
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s65 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0]    // Move shadow to real if we are within 2^32

s_waitcnt vmcnt(0)                                 // 8wait for global read


/* local write a */

ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 0
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+4+3] offset:4096 // lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 4096


/* local write b */

ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 0


/* local write swap a */



/* local write swap b */



/* local write init pointers a */

/* N/A */


/* local write init pointers b */

/* N/A */



/******************************************/
/* Unrolled Loop(s) - Begin               */
/******************************************/

s_cmp_ge_i32 s[sgprLoopCounters+0], 0x0            // LoopCounterL < EndCounter
s_cbranch_scc1 label_0002                          // don't enter LoopL
label_0001:


/******************************************/
/* Unroll Loop 1/2 - Begin                */
/******************************************/

s_barrier //4sync for global read

s_cmp_eq_i32 s[sgprLoopCounters+0], -1             // is this the last iteration
s_cmov_b32 s[sgprSrdA+2], 0                        // Set limit to 0 for last iteration
s_cmov_b32 s[sgprSrdB+2], 0                        // Set limit to 0 for last iteration

s_waitcnt lgkmcnt(0)                               // 1wait for local write




/* iter 0 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:256 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:512 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_0_0
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:768 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->128 */

/* local read increment b */
/* N/A, lro->64 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 1 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:1024 // L -> Reg lro=128 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:1280 // L -> Reg lro=128 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:1536 // L -> Reg lro=128 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+4+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0], offen offset:0 // G -> Reg 0_0_1_0
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:1792 // L -> Reg lro=128 swapByteOffset=0 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:512 // L -> Reg lro=64 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:768 // L -> Reg lro=64 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->256 */

/* local read increment b */
/* N/A, lro->128 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 2 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:2048 // L -> Reg lro=256 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:2304 // L -> Reg lro=256 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:2560 // L -> Reg lro=256 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // G -> Reg 0_0_0_0
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:2816 // L -> Reg lro=256 swapByteOffset=0 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1024 // L -> Reg lro=128 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1280 // L -> Reg lro=128 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->384 */

/* local read increment b */
/* N/A, lro->192 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 3 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:3072 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:3328 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:3584 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* global read inc A */
s_cmp_eq_u32 s[sgprLoopCounters+0], s[sgprStaggerUIter] // Is this the wrapIter?
s_cselect_b32 s64, s[sgprWrapUA], s[sgprGlobalReadIncsA] // incLower <- ?
s_and_b32 s65, s64, 2147483648                     // test
s_subb_u32 s65, 0, 0                               // -1 or 0
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s64       // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], s65      // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s64 // limit -= inc)
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s65 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0]    // Move shadow to real if we are within 2^32
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:3840 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1536 // L -> Reg lro=192 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1792 // L -> Reg lro=192 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->512 */

/* local read increment b */
/* N/A, lro->256 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 4 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:4096 // L -> Reg lro=512 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:4352 // L -> Reg lro=512 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:4608 // L -> Reg lro=512 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* global read inc B */
s_cmp_eq_u32 s[sgprLoopCounters+0], s[sgprStaggerUIter] // Is this the wrapIter?
s_cselect_b32 s64, s[sgprWrapUB], s[sgprGlobalReadIncsB] // incLower <- ?
s_and_b32 s65, s64, 2147483648                     // test
s_subb_u32 s65, 0, 0                               // -1 or 0
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s64       // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], s65      // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s64 // limit -= inc)
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s65 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0]    // Move shadow to real if we are within 2^32
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:4864 // L -> Reg lro=512 swapByteOffset=0 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:2048 // L -> Reg lro=256 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:2304 // L -> Reg lro=256 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->640 */

/* local read increment b */
/* N/A, lro->320 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 5 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:5120 // L -> Reg lro=640 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:5376 // L -> Reg lro=640 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:5632 // L -> Reg lro=640 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
/* sched write - iter 5 writesPerItem=1 */
s_waitcnt vmcnt(2)                                 // wait for global read before writing to local
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:16384 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 16384
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:5888 // L -> Reg lro=640 swapByteOffset=0 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:2560 // L -> Reg lro=320 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:2816 // L -> Reg lro=320 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->768 */

/* local read increment b */
/* N/A, lro->384 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 6 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:6144 // L -> Reg lro=768 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:6400 // L -> Reg lro=768 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:6656 // L -> Reg lro=768 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
/* sched write - iter 6 writesPerItem=1 */
s_waitcnt vmcnt(1)                                 // wait for global read before writing to local
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+4+3] offset:20480 // lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 20480
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:6912 // L -> Reg lro=768 swapByteOffset=0 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:3072 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:3328 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->896 */

/* local read increment b */
/* N/A, lro->448 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0



/* iter 7 (last) */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:7168 // L -> Reg lro=896 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:7424 // L -> Reg lro=896 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:7680 // L -> Reg lro=896 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
/* sched write - iter 7 writesPerItem=1 */
s_waitcnt vmcnt(0)                                 // wait for global read before writing to local
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:16384 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 16384
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:7936 // L -> Reg lro=896 swapByteOffset=0 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:3584 // L -> Reg lro=448 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:3840 // L -> Reg lro=448 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local write swap offsets a */

/* local write swap offsets b */

/* local write init pointers a */
/* N/A */

/* local write init pointers b */
/* N/A */

/* local read swap offsets a */

/* local read swap internal offset -> 16384 */

/* local read swap offsets b */

/* local read swap internal offset -> 16384 */

/* local read init pointers a */

/* local read init pointers b */
s_waitcnt lgkmcnt(0)                               // 6wait for local read old=3 new=0
MAC_8x4_X0

/******************************************/
/* Unrolled Loop - End 1/2                */
/******************************************/

s_add_u32 s[sgprLoopCounters+0], s[sgprLoopCounters+0], 0x1 // inc counterL
s_cmp_eq_i32 s[sgprLoopCounters+0], 0x0            // counterL==0
s_cbranch_scc1 label_0003                          // exit LoopL


/******************************************/
/* Unroll Loop 2/2 - Begin                */
/******************************************/

s_barrier //4sync for global read

s_cmp_eq_i32 s[sgprLoopCounters+0], -1             // is this the last iteration
s_cmov_b32 s[sgprSrdA+2], 0                        // Set limit to 0 for last iteration
s_cmov_b32 s[sgprSrdB+2], 0                        // Set limit to 0 for last iteration

s_waitcnt lgkmcnt(0)                               // 1wait for local write




/* iter 0 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:16384 // L -> Reg lro=0 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:16640 // L -> Reg lro=0 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:16896 // L -> Reg lro=0 swapByteOffset=16384 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_0_0
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:17152 // L -> Reg lro=0 swapByteOffset=16384 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:16384 // L -> Reg lro=0 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:16640 // L -> Reg lro=0 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->128 */

/* local read increment b */
/* N/A, lro->64 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 1 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:17408 // L -> Reg lro=128 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:17664 // L -> Reg lro=128 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:17920 // L -> Reg lro=128 swapByteOffset=16384 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+4+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0], offen offset:0 // G -> Reg 0_0_1_0
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:18176 // L -> Reg lro=128 swapByteOffset=16384 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:16896 // L -> Reg lro=64 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:17152 // L -> Reg lro=64 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->256 */

/* local read increment b */
/* N/A, lro->128 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 2 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:18432 // L -> Reg lro=256 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:18688 // L -> Reg lro=256 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:18944 // L -> Reg lro=256 swapByteOffset=16384 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // G -> Reg 0_0_0_0
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:19200 // L -> Reg lro=256 swapByteOffset=16384 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:17408 // L -> Reg lro=128 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:17664 // L -> Reg lro=128 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->384 */

/* local read increment b */
/* N/A, lro->192 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 3 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:19456 // L -> Reg lro=384 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:19712 // L -> Reg lro=384 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:19968 // L -> Reg lro=384 swapByteOffset=16384 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* global read inc A */
s_cmp_eq_u32 s[sgprLoopCounters+0], s[sgprStaggerUIter] // Is this the wrapIter?
s_cselect_b32 s64, s[sgprWrapUA], s[sgprGlobalReadIncsA] // incLower <- ?
s_and_b32 s65, s64, 2147483648                     // test
s_subb_u32 s65, 0, 0                               // -1 or 0
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s64       // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], s65      // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s64 // limit -= inc)
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], s65 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0]    // Move shadow to real if we are within 2^32
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:20224 // L -> Reg lro=384 swapByteOffset=16384 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:17920 // L -> Reg lro=192 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:18176 // L -> Reg lro=192 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->512 */

/* local read increment b */
/* N/A, lro->256 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 4 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:20480 // L -> Reg lro=512 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:20736 // L -> Reg lro=512 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:20992 // L -> Reg lro=512 swapByteOffset=16384 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* global read inc B */
s_cmp_eq_u32 s[sgprLoopCounters+0], s[sgprStaggerUIter] // Is this the wrapIter?
s_cselect_b32 s64, s[sgprWrapUB], s[sgprGlobalReadIncsB] // incLower <- ?
s_and_b32 s65, s64, 2147483648                     // test
s_subb_u32 s65, 0, 0                               // -1 or 0
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s64       // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], s65      // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s64 // limit -= inc)
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], s65 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0]    // Move shadow to real if we are within 2^32
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:21248 // L -> Reg lro=512 swapByteOffset=16384 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:18432 // L -> Reg lro=256 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:18688 // L -> Reg lro=256 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->640 */

/* local read increment b */
/* N/A, lro->320 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 5 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:21504 // L -> Reg lro=640 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:21760 // L -> Reg lro=640 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:22016 // L -> Reg lro=640 swapByteOffset=16384 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
/* sched write - iter 5 writesPerItem=1 */
s_waitcnt vmcnt(2)                                 // wait for global read before writing to local
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 0
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:22272 // L -> Reg lro=640 swapByteOffset=16384 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:18944 // L -> Reg lro=320 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:19200 // L -> Reg lro=320 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->768 */

/* local read increment b */
/* N/A, lro->384 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0

/* iter 6 */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:22528 // L -> Reg lro=768 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:22784 // L -> Reg lro=768 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:23040 // L -> Reg lro=768 swapByteOffset=16384 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
/* sched write - iter 6 writesPerItem=1 */
s_waitcnt vmcnt(1)                                 // wait for global read before writing to local
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+4+3] offset:4096 // lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 4096
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:23296 // L -> Reg lro=768 swapByteOffset=16384 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:19456 // L -> Reg lro=384 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:19712 // L -> Reg lro=384 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read increment a */
/* N/A, lro->896 */

/* local read increment b */
/* N/A, lro->448 */
s_waitcnt lgkmcnt(0)                               // wait for prior local read old=0 new=0
MAC_8x4_X0



/* iter 7 (last) */


/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:23552 // L -> Reg lro=896 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:23808 // L -> Reg lro=896 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:24064 // L -> Reg lro=896 swapByteOffset=16384 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
/* sched write - iter 7 writesPerItem=1 */
s_waitcnt vmcnt(0)                                 // wait for global read before writing to local
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 0
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:24320 // L -> Reg lro=896 swapByteOffset=16384 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:19968 // L -> Reg lro=448 swapByteOffset=16384 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:20224 // L -> Reg lro=448 swapByteOffset=16384 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0

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
s_waitcnt lgkmcnt(0)                               // 6wait for local read old=3 new=0
MAC_8x4_X0

/******************************************/
/* Unrolled Loop - End 2/2 (final)        */
/******************************************/

s_add_u32 s[sgprLoopCounters+0], s[sgprLoopCounters+0], 0x1 // inc counterL
s_cmp_eq_i32 s[sgprLoopCounters+0], 0x0            // counterL==0
s_cbranch_scc0 label_0001                          // restart LoopL
label_0003: // unroll loop odditer exit
label_0002:


/******************************************/
/* Tail Loop                              */
/******************************************/


/* local write reset offsets a */



/* local write reset offsets b */



s_cmp_eq_u32 s[sgprOrigLoopCounter], 0             // completely skipped unroll loop?
s_cselect_b32 s64, 0, s[sgprGlobalReadIncsA]       // force to 0?
s_cselect_b32 s65, 0, s[sgprGlobalReadIncsB]       // force to 0?
s_sub_u32  s[sgprSrdA+0], s[sgprSrdA+0], s64       // gra SRD -= inc(lower)
s_subb_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0        // gra SRD -= inc(upper)
s_add_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s64 // limit -= inc)
s_addc_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0]    // Move shadow to real if we are within 2^32

s_sub_u32  s[sgprSrdB+0], s[sgprSrdB+0], s65       // gra SRD -= inc(lower)
s_subb_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0        // gra SRD -= inc(upper)
s_add_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s65 // limit -= inc)
s_addc_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0]    // Move shadow to real if we are within 2^32

//numIterL = (((sizeL % LOCAL_DEPTHU) + LOCAL_SPLITU - 1) / LOCAL_SPLITU)
s_lshr_b32 s64, s[sgprSizesSum+0], 3               // s64 = s[sgprSizesSum+0] / 8
s_and_b32 s[sgprLoopCounters+0], 7, s[sgprSizesSum+0] // s[sgprLoopCounters+0] = s[sgprSizesSum+0] % 8
s_cmp_eq_u32 s[sgprLoopCounters+0], 0x0            // numIterL == 0
s_cbranch_scc1 label_0006                          // skip to end of tail loop b/c numIter==0
s_sub_u32 s[sgprLoopCounters+0], 0x0, s[sgprLoopCounters+0] // counterL = -sizeL


/* remove stagger offsets for tail loop */

s_add_i32 s63, s[sgprStaggerUIter], 3              // 
s_mul_i32 s63, s63, s[sgprGlobalReadIncsA]         // start offset S in bytes
s_sub_u32 s63, s63, s[sgprWrapUA]                  // S - WrapU
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s63       // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitA+0], s[sgprShadowLimitA+0], s63 // limit -= inc)
s_subb_u32 s[sgprShadowLimitA+1], s[sgprShadowLimitA+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitA+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprShadowLimitA+0]    // Move shadow to real if we are within 2^32

s_add_i32 s63, s[sgprStaggerUIter], 3              // 
s_mul_i32 s63, s63, s[sgprGlobalReadIncsB]         // start offset S in bytes
s_sub_u32 s63, s63, s[sgprWrapUB]                  // S - WrapU
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s63       // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprShadowLimitB+0], s[sgprShadowLimitB+0], s63 // limit -= inc)
s_subb_u32 s[sgprShadowLimitB+1], s[sgprShadowLimitB+1], 0 // limit -= inc)
s_cmp_eq_u32 s[sgprShadowLimitB+1], 0              // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprShadowLimitB+0]    // Move shadow to real if we are within 2^32


/* global read a */

/* g2l=0, load component 0 */
buffer_load_dwordx2 v[vgprG2LA+0+0:vgprG2LA+0+0+1], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // load one buffer value
/* g2l=0, load component 1 */
buffer_load_dwordx2 v[vgprG2LA+0+2:vgprG2LA+0+2+1], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:8 // load one buffer value
/* g2l=4, load component 0 */
buffer_load_dwordx2 v[vgprG2LA+4+0:vgprG2LA+4+0+1], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0], offen offset:0 // load one buffer value
/* g2l=4, load component 1 */
buffer_load_dwordx2 v[vgprG2LA+4+2:vgprG2LA+4+2+1], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], s[sgprScalarGlobalReadOffsetA+0], offen offset:8 // load one buffer value
_v_add_co_u32 v[vgprGlobalReadOffsetA+0], vcc, v[vgprGlobalReadOffsetA+0], 8 // graOffset += bpe


/* global read b */

/* g2l=0, load component 0 */
buffer_load_dwordx2 v[vgprG2LB+0+0:vgprG2LB+0+0+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // load one buffer value
/* g2l=0, load component 1 */
buffer_load_dwordx2 v[vgprG2LB+0+2:vgprG2LB+0+2+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:8 // load one buffer value
_v_add_co_u32 v[vgprGlobalReadOffsetB+0], vcc, v[vgprGlobalReadOffsetB+0], 8 // graOffset += bpe

s_waitcnt vmcnt(0)                                 // 2wait for global read

s_barrier //


/* local write init pointers a */

/* N/A */


/* local write init pointers b */

/* N/A */


/* local write a */

ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 0
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+4:vgprG2LA+4+3] offset:4096 // lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 4096


/* local write b */

ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 0

s_waitcnt lgkmcnt(0)                               // 5wait for local write

s_barrier //


/* local read reset offsets a */

/* handled internally */
v_and_b32 v[vgprLocalReadAddrA], 0x3fff, v[vgprLocalReadAddrA] // reset Red,Blk -> Red


/* local read reset offsets b */

/* handled internally */
v_and_b32 v[vgprLocalReadAddrB], 0x3fff, v[vgprLocalReadAddrB] // reset Red,Blk -> Red


/* local read init pointers a */



/* local read init pointers b */



/* tail loop: macs */

s_cmp_ge_i32 s[sgprLoopCounters+0], 0x0            // LoopCounterL < EndCounter
s_cbranch_scc1 label_0006                          // don't enter LoopL
label_0005:


/* local read a */

ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:256 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:512 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+12:vgprValuA_X0_I0+12+3], v[vgprLocalReadAddrA] offset:768 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=3 rIdx=0 oIdx=0 buffer=0 iui=0


/* local read b */

ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0


/* local read inc a */

s_mov_b32 s63, 0x400                               // inc
_v_add_co_u32 v[vgprLocalReadAddrA], vcc, s63, v[vgprLocalReadAddrA] // lrA += 1024 (LSU*(MT+PAD)*bpe)


/* local read inc b */

s_mov_b32 s63, 0x200                               // inc
_v_add_co_u32 v[vgprLocalReadAddrB], vcc, s63, v[vgprLocalReadAddrB] // lrB += 512 (LSU*(MT+PAD)*bpe)

s_waitcnt lgkmcnt(0)                               // 4wait for local read

MAC_8x4_X0
s_add_u32 s[sgprLoopCounters+0], s[sgprLoopCounters+0], 0x1 // inc counterL
s_cmp_eq_i32 s[sgprLoopCounters+0], 0x0            // counterL==0
s_cbranch_scc0 label_0005                          // restart LoopL
label_0006:

s_waitcnt lgkmcnt(0) & vmcnt(0)                    // wait for all summation activity



/* not-LocalSplitU: global write indices */

s_mov_b32 s[sgprSrdC+0], s[sgprAddressC+0]         // init SRD base address (lower)
s_mov_b32 s[sgprSrdC+1], s[sgprAddressC+1]         // init SRD base address (upper) + other fields
s_mov_b32 s[sgprSrdC+2], 0x80000000                // 
s_mov_b32 s[sgprSrdC+3], Srd127_96                 // Set bits 127_96 in SRD
v_lshrrev_b32 v65, 4, v[vgprSerial]                // vectorStaticDiv: v65 = v[vgprSerial] / 16
v_and_b32 v64, 15, v[vgprSerial]                   // vectorStaticDiv: v64 = v[vgprSerial] % 16
v_lshlrev_b32 v64, 1, v64                          // staticMultiply: v64 = v64 * 2
v_lshlrev_b32 v65, 1, v65                          // staticMultiply: v65 = v65 * 2

s_mul_i32 s52, 0x40, s[sgprWorkGroup1]             // <- wg1*MT1
s_mul_hi_u32 s51, s52, s[sgprStridesC+0]           // Scale s52 by Stride
s_mul_i32 s50, s52, s[sgprStridesC+0]              // Scale s52 by Stride
s_lshl_b64 s[50:51], s[50:51], 3                   // scale by bpe
s_add_u32 s[sgprSrdC+0], s[sgprSrdC+0], s50        // add lo to SRD
s_addc_u32 s[sgprSrdC+1], s[sgprSrdC+1], s51       // add hi to SRD

s_mul_hi_u32 s51, s[sgprWorkGroup2], s[sgprStridesC+1] // Scale s[sgprWorkGroup2] by Stride
s_mul_i32 s50, s[sgprWorkGroup2], s[sgprStridesC+1] // Scale s[sgprWorkGroup2] by Stride
s_lshl_b64 s[50:51], s[50:51], 3                   // scale by bpe
s_add_u32 s[sgprSrdC+0], s[sgprSrdC+0], s50        // add lo to SRD
s_addc_u32 s[sgprSrdC+1], s[sgprSrdC+1], s51       // add hi to SRD

v_mul_lo_u32 v66, v65, s[sgprStridesC+0]           // rowStart vgpr

s_mul_i32 s50, 0x80, s[sgprWorkGroup0]             // s50 = wg0*MT0
_v_add_co_u32 v64, vcc, s50, v64                   // coord0 = tid0*VW + wg0*MT0
_v_add_co_u32 v65, vcc, s52, v65                   // coord1 = tid1*VW + wg1*MT1


/* not-LocalSplitU: global write */

s_mov_b32 s50, s[sgprBeta+0]                       // tmp = Beta[0]
s_or_b32 s50, s[sgprBeta+1], s50                   // tmp |= Beta[1] 
s_cmpk_eq_u32 s50, 0x0                             // Beta == 0
s_cbranch_scc0 label_0014                          // Beta is not zero; so jump to B nonzero

s_mov_b32 s50, 0x0                                 // rMT0=0
s_add_u32 s52, -0x1, s[sgprNumWorkGroups0]         // 
s_cmp_lt_u32 s[sgprWorkGroup0], s52                // wg0 < nwg0-1
s_cbranch_scc1 label_0011                          // wg0 < nwg0-1 so skip rMT0 = Size0 % MT0
/* TODO-packed- compare against product of all packed C0 sizes not just SizesFree+0 */
s_lshr_b32 s52, s[sgprSizesFree+0], 7              // s52 = s[sgprSizesFree+0] / 128
s_and_b32 s50, 127, s[sgprSizesFree+0]             // s50 = s[sgprSizesFree+0] % 128
label_0011:
s_cmpk_gt_u32 s50, 0x0                             // rMT0 > 0
s_cbranch_scc1 label_0013                          // edges required so jump to E1
s_mov_b32 s50, 0x0                                 // rMT1=0
s_add_u32 s52, -0x1, s[sgprNumWorkGroups1]         // 
s_cmp_lt_u32 s[sgprWorkGroup1], s52                // wg1 < nwg1-1
s_cbranch_scc1 label_0012                          // wg1 < nwg1-1 so skip rMT1 = Size1 % MT1
s_lshr_b32 s52, s[sgprSizesFree+1], 6              // s52 = s[sgprSizesFree+1] / 64
s_and_b32 s50, 63, s[sgprSizesFree+1]              // s50 = s[sgprSizesFree+1] % 64
label_0012:
s_cmpk_gt_u32 s50, 0x0                             // rMT1 > 0
s_cbranch_scc1 label_0013                          // edges required so jump to E1
label_0010:

/******************************************/
/* Global Write Batch:(0,0,0,0:vw2); (0,0,1,0:vw2); (0,1,0,0:vw2); (0,1,1,0:vw2); (0,2,0,0:vw2); (0,2,1,0:vw2); (0,3,0,0:vw2); (0,3,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v70, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v71, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v72, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v73, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,0,2,0) coordOffset1=0 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v74, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,1,2,0) coordOffset1=1 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v75, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,0,3,0) coordOffset1=0 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v76, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,1,3,0) coordOffset1=1 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v77, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 1, 0), (0, 1, 0, 0), (0, 1, 1, 0), (0, 2, 0, 0), (0, 2, 1, 0), (0, 3, 0, 0), (0, 3, 1, 0)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[0:3], v70, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[16:19], v71, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[4:7], v72, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[20:23], v73, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[8:11], v74, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[24:27], v75, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[12:15], v76, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[28:31], v77, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Batch:(1,0,0,0:vw2); (1,0,1,0:vw2); (1,1,0,0:vw2); (1,1,1,0:vw2); (1,2,0,0:vw2); (1,2,1,0:vw2); (1,3,0,0:vw2); (1,3,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v70, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v71, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v72, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v73, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,0,2,0) coordOffset1=32 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v74, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,1,2,0) coordOffset1=33 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v75, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,0,3,0) coordOffset1=32 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v76, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,1,3,0) coordOffset1=33 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v77, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr

/* rC *= alpha batchEements=[(1, 0, 0, 0), (1, 0, 1, 0), (1, 1, 0, 0), (1, 1, 1, 0), (1, 2, 0, 0), (1, 2, 1, 0), (1, 3, 0, 0), (1, 3, 1, 0)] */
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+48:vgprValuC+48+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+48:vgprValuC+48+1] // *= alpha
v_mul_f64 v[vgprValuC+50:vgprValuC+50+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+50:vgprValuC+50+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha
v_mul_f64 v[vgprValuC+52:vgprValuC+52+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+52:vgprValuC+52+1] // *= alpha
v_mul_f64 v[vgprValuC+54:vgprValuC+54+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+54:vgprValuC+54+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+56:vgprValuC+56+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+56:vgprValuC+56+1] // *= alpha
v_mul_f64 v[vgprValuC+58:vgprValuC+58+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+58:vgprValuC+58+1] // *= alpha
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha
v_mul_f64 v[vgprValuC+60:vgprValuC+60+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+60:vgprValuC+60+1] // *= alpha
v_mul_f64 v[vgprValuC+62:vgprValuC+62+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+62:vgprValuC+62+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[32:35], v70, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[48:51], v71, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[36:39], v72, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[52:55], v73, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[40:43], v74, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[56:59], v75, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[44:47], v76, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[60:63], v77, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0021                                // jump to end
label_0013:

/******************************************/
/* Global Write Edge Batch:(0,0,0,0:vw2); (0,0,1,0:vw2); (0,1,0,0:vw2); (0,1,1,0:vw2); (0,2,0,0:vw2); (0,2,1,0:vw2); (0,3,0,0:vw2); (0,3,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v65 directly */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v70, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v64, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v65, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[56:57], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v70, -1, v70, s[56:57]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v71, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v64, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[58:59], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v71, -1, v71, s[58:59]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v65 directly */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v72, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v65, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[60:61], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v72, -1, v72, s[60:61]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v73, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v73, -1, v73, s[62:63]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,2,0) coordOffset1=0 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v65 directly */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v74, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v65, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v74, -1, v74, s[64:65]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,2,0) coordOffset1=1 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v75, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v75, -1, v75, s[66:67]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,3,0) coordOffset1=0 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v65 directly */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v76, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v65, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v76, -1, v76, s[68:69]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,3,0) coordOffset1=1 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v77, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v77, -1, v77, s[70:71]               // clip if OOB. offset

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 1, 0), (0, 1, 0, 0), (0, 1, 1, 0), (0, 2, 0, 0), (0, 2, 1, 0), (0, 3, 0, 0), (0, 3, 1, 0)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[0:3], v70, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[16:19], v71, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[4:7], v72, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[20:23], v73, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[8:11], v74, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[24:27], v75, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[12:15], v76, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[28:31], v77, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Edge Batch:(1,0,0,0:vw2); (1,0,1,0:vw2); (1,1,0,0:vw2); (1,1,1,0:vw2); (1,2,0,0:vw2); (1,2,1,0:vw2); (1,3,0,0:vw2); (1,3,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v69, vcc, v65, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v70, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v64, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[56:57], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v70, -1, v70, s[56:57]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v71, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v64, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[58:59], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v71, -1, v71, s[58:59]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v69, vcc, v65, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v72, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[60:61], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v72, -1, v72, s[60:61]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v73, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v73, -1, v73, s[62:63]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,0,2,0) coordOffset1=32 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v69, vcc, v65, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v74, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v74, -1, v74, s[64:65]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,2,0) coordOffset1=33 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v75, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v75, -1, v75, s[66:67]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,0,3,0) coordOffset1=32 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v69, vcc, v65, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v76, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v76, -1, v76, s[68:69]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,3,0) coordOffset1=33 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v77, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v77, -1, v77, s[70:71]               // clip if OOB. offset

/* rC *= alpha batchEements=[(1, 0, 0, 0), (1, 0, 1, 0), (1, 1, 0, 0), (1, 1, 1, 0), (1, 2, 0, 0), (1, 2, 1, 0), (1, 3, 0, 0), (1, 3, 1, 0)] */
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+48:vgprValuC+48+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+48:vgprValuC+48+1] // *= alpha
v_mul_f64 v[vgprValuC+50:vgprValuC+50+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+50:vgprValuC+50+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha
v_mul_f64 v[vgprValuC+52:vgprValuC+52+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+52:vgprValuC+52+1] // *= alpha
v_mul_f64 v[vgprValuC+54:vgprValuC+54+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+54:vgprValuC+54+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+56:vgprValuC+56+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+56:vgprValuC+56+1] // *= alpha
v_mul_f64 v[vgprValuC+58:vgprValuC+58+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+58:vgprValuC+58+1] // *= alpha
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha
v_mul_f64 v[vgprValuC+60:vgprValuC+60+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+60:vgprValuC+60+1] // *= alpha
v_mul_f64 v[vgprValuC+62:vgprValuC+62+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+62:vgprValuC+62+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[32:35], v70, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[48:51], v71, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[36:39], v72, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[52:55], v73, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[40:43], v74, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[56:59], v75, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[44:47], v76, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[60:63], v77, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0021                                // jump to end
label_0014:
s_mov_b32 s50, 0x0                                 // rMT0=0
s_add_u32 s52, -0x1, s[sgprNumWorkGroups0]         // 
s_cmp_lt_u32 s[sgprWorkGroup0], s52                // wg0 < nwg0-1
s_cbranch_scc1 label_0018                          // wg0 < nwg0-1 so skip rMT0 = Size0 % MT0
/* TODO-packed- compare against product of all packed C0 sizes not just SizesFree+0 */
s_lshr_b32 s52, s[sgprSizesFree+0], 7              // s52 = s[sgprSizesFree+0] / 128
s_and_b32 s50, 127, s[sgprSizesFree+0]             // s50 = s[sgprSizesFree+0] % 128
label_0018:
s_cmpk_gt_u32 s50, 0x0                             // rMT0 > 0
s_cbranch_scc1 label_0020                          // edges required so jump to E1
s_mov_b32 s50, 0x0                                 // rMT1=0
s_add_u32 s52, -0x1, s[sgprNumWorkGroups1]         // 
s_cmp_lt_u32 s[sgprWorkGroup1], s52                // wg1 < nwg1-1
s_cbranch_scc1 label_0019                          // wg1 < nwg1-1 so skip rMT1 = Size1 % MT1
s_lshr_b32 s52, s[sgprSizesFree+1], 6              // s52 = s[sgprSizesFree+1] / 64
s_and_b32 s50, 63, s[sgprSizesFree+1]              // s50 = s[sgprSizesFree+1] % 64
label_0019:
s_cmpk_gt_u32 s50, 0x0                             // rMT1 > 0
s_cbranch_scc1 label_0020                          // edges required so jump to E1
label_0017:

/******************************************/
/* Global Write Beta Batch:(0,0,0,0:vw2); (0,0,1,0:vw2); (0,1,0,0:vw2); (0,1,1,0:vw2); (0,2,0,0:vw2); (0,2,1,0:vw2); (0,3,0,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v70, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[71:74], v70, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v75, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[76:79], v75, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v80, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[81:84], v80, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v85, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[86:89], v85, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,2,0) coordOffset1=0 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v90, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[91:94], v90, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,2,0) coordOffset1=1 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v95, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[96:99], v95, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,3,0) coordOffset1=0 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v100, v67, v68, 0x3                // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[101:104], v100, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 1, 0), (0, 1, 0, 0), (0, 1, 1, 0), (0, 2, 0, 0), (0, 2, 1, 0), (0, 3, 0, 0)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+0:vgprValuC+0+1], v[71:72], s[sgprBeta:sgprBeta+1], v[vgprValuC+0:vgprValuC+0+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+2:vgprValuC+2+1], v[73:74], s[sgprBeta:sgprBeta+1], v[vgprValuC+2:vgprValuC+2+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[0:3], v70, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+16:vgprValuC+16+1], v[76:77], s[sgprBeta:sgprBeta+1], v[vgprValuC+16:vgprValuC+16+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+18:vgprValuC+18+1], v[78:79], s[sgprBeta:sgprBeta+1], v[vgprValuC+18:vgprValuC+18+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[16:19], v75, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+4:vgprValuC+4+1], v[81:82], s[sgprBeta:sgprBeta+1], v[vgprValuC+4:vgprValuC+4+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+6:vgprValuC+6+1], v[83:84], s[sgprBeta:sgprBeta+1], v[vgprValuC+6:vgprValuC+6+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[4:7], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+20:vgprValuC+20+1], v[86:87], s[sgprBeta:sgprBeta+1], v[vgprValuC+20:vgprValuC+20+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+22:vgprValuC+22+1], v[88:89], s[sgprBeta:sgprBeta+1], v[vgprValuC+22:vgprValuC+22+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[20:23], v85, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+8:vgprValuC+8+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+8:vgprValuC+8+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+10:vgprValuC+10+1], v[93:94], s[sgprBeta:sgprBeta+1], v[vgprValuC+10:vgprValuC+10+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[8:11], v90, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+24:vgprValuC+24+1], v[96:97], s[sgprBeta:sgprBeta+1], v[vgprValuC+24:vgprValuC+24+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+26:vgprValuC+26+1], v[98:99], s[sgprBeta:sgprBeta+1], v[vgprValuC+26:vgprValuC+26+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[24:27], v95, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+12:vgprValuC+12+1], v[101:102], s[sgprBeta:sgprBeta+1], v[vgprValuC+12:vgprValuC+12+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+14:vgprValuC+14+1], v[103:104], s[sgprBeta:sgprBeta+1], v[vgprValuC+14:vgprValuC+14+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[12:15], v100, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Batch:(0,3,1,0:vw2); (1,0,0,0:vw2); (1,0,1,0:vw2); (1,1,0,0:vw2); (1,1,1,0:vw2); (1,2,0,0:vw2); (1,2,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,1,3,0) coordOffset1=1 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v70, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[71:74], v70, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v75, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[76:79], v75, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v80, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[81:84], v80, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v85, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[86:89], v85, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v90, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[91:94], v90, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,2,0) coordOffset1=32 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v95, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[96:99], v95, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,2,0) coordOffset1=33 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v100, v67, v68, 0x3                // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[101:104], v100, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(0, 3, 1, 0), (1, 0, 0, 0), (1, 0, 1, 0), (1, 1, 0, 0), (1, 1, 1, 0), (1, 2, 0, 0), (1, 2, 1, 0)] */
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+48:vgprValuC+48+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+48:vgprValuC+48+1] // *= alpha
v_mul_f64 v[vgprValuC+50:vgprValuC+50+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+50:vgprValuC+50+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha
v_mul_f64 v[vgprValuC+52:vgprValuC+52+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+52:vgprValuC+52+1] // *= alpha
v_mul_f64 v[vgprValuC+54:vgprValuC+54+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+54:vgprValuC+54+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+56:vgprValuC+56+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+56:vgprValuC+56+1] // *= alpha
v_mul_f64 v[vgprValuC+58:vgprValuC+58+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+58:vgprValuC+58+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+28:vgprValuC+28+1], v[71:72], s[sgprBeta:sgprBeta+1], v[vgprValuC+28:vgprValuC+28+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+30:vgprValuC+30+1], v[73:74], s[sgprBeta:sgprBeta+1], v[vgprValuC+30:vgprValuC+30+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[28:31], v70, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+32:vgprValuC+32+1], v[76:77], s[sgprBeta:sgprBeta+1], v[vgprValuC+32:vgprValuC+32+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+34:vgprValuC+34+1], v[78:79], s[sgprBeta:sgprBeta+1], v[vgprValuC+34:vgprValuC+34+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[32:35], v75, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+48:vgprValuC+48+1], v[81:82], s[sgprBeta:sgprBeta+1], v[vgprValuC+48:vgprValuC+48+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+50:vgprValuC+50+1], v[83:84], s[sgprBeta:sgprBeta+1], v[vgprValuC+50:vgprValuC+50+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[48:51], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+36:vgprValuC+36+1], v[86:87], s[sgprBeta:sgprBeta+1], v[vgprValuC+36:vgprValuC+36+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+38:vgprValuC+38+1], v[88:89], s[sgprBeta:sgprBeta+1], v[vgprValuC+38:vgprValuC+38+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[36:39], v85, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+52:vgprValuC+52+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+52:vgprValuC+52+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+54:vgprValuC+54+1], v[93:94], s[sgprBeta:sgprBeta+1], v[vgprValuC+54:vgprValuC+54+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[52:55], v90, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+40:vgprValuC+40+1], v[96:97], s[sgprBeta:sgprBeta+1], v[vgprValuC+40:vgprValuC+40+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+42:vgprValuC+42+1], v[98:99], s[sgprBeta:sgprBeta+1], v[vgprValuC+42:vgprValuC+42+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[40:43], v95, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+56:vgprValuC+56+1], v[101:102], s[sgprBeta:sgprBeta+1], v[vgprValuC+56:vgprValuC+56+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+58:vgprValuC+58+1], v[103:104], s[sgprBeta:sgprBeta+1], v[vgprValuC+58:vgprValuC+58+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[56:59], v100, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Batch:(1,3,0,0:vw2); (1,3,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(1,0,3,0) coordOffset1=32 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v70, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[71:74], v70, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,3,0) coordOffset1=33 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v75, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[76:79], v75, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(1, 3, 0, 0), (1, 3, 1, 0)] */
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha
v_mul_f64 v[vgprValuC+60:vgprValuC+60+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+60:vgprValuC+60+1] // *= alpha
v_mul_f64 v[vgprValuC+62:vgprValuC+62+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+62:vgprValuC+62+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+44:vgprValuC+44+1], v[71:72], s[sgprBeta:sgprBeta+1], v[vgprValuC+44:vgprValuC+44+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+46:vgprValuC+46+1], v[73:74], s[sgprBeta:sgprBeta+1], v[vgprValuC+46:vgprValuC+46+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[44:47], v70, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+60:vgprValuC+60+1], v[76:77], s[sgprBeta:sgprBeta+1], v[vgprValuC+60:vgprValuC+60+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+62:vgprValuC+62+1], v[78:79], s[sgprBeta:sgprBeta+1], v[vgprValuC+62:vgprValuC+62+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[60:63], v75, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0021                                // jump to end
label_0020:

/******************************************/
/* Global Write Beta Edge Batch:(0,0,0,0:vw2); (0,0,1,0:vw2); (0,1,0,0:vw2); (0,1,1,0:vw2); (0,2,0,0:vw2); (0,2,1,0:vw2); (0,3,0,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v65 directly */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v70, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v64, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v65, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[56:57], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v70, -1, v70, s[56:57]               // clip if OOB. offset
buffer_load_dwordx4 v[71:74], v70, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v75, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v64, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[58:59], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v75, -1, v75, s[58:59]               // clip if OOB. offset
buffer_load_dwordx4 v[76:79], v75, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v65 directly */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v80, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v65, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[60:61], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v80, -1, v80, s[60:61]               // clip if OOB. offset
buffer_load_dwordx4 v[81:84], v80, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v85, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v85, -1, v85, s[62:63]               // clip if OOB. offset
buffer_load_dwordx4 v[86:89], v85, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,2,0) coordOffset1=0 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v65 directly */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v90, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v65, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v90, -1, v90, s[64:65]               // clip if OOB. offset
buffer_load_dwordx4 v[91:94], v90, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,2,0) coordOffset1=1 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v95, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v95, -1, v95, s[66:67]               // clip if OOB. offset
buffer_load_dwordx4 v[96:99], v95, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,3,0) coordOffset1=0 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v65 directly */
v_mov_b32 v67, v66                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v100, v67, v68, 0x3                // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v65, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v100, -1, v100, s[68:69]             // clip if OOB. offset
buffer_load_dwordx4 v[101:104], v100, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 1, 0), (0, 1, 0, 0), (0, 1, 1, 0), (0, 2, 0, 0), (0, 2, 1, 0), (0, 3, 0, 0)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+0:vgprValuC+0+1], v[71:72], s[sgprBeta:sgprBeta+1], v[vgprValuC+0:vgprValuC+0+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+2:vgprValuC+2+1], v[73:74], s[sgprBeta:sgprBeta+1], v[vgprValuC+2:vgprValuC+2+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[0:3], v70, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+16:vgprValuC+16+1], v[76:77], s[sgprBeta:sgprBeta+1], v[vgprValuC+16:vgprValuC+16+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+18:vgprValuC+18+1], v[78:79], s[sgprBeta:sgprBeta+1], v[vgprValuC+18:vgprValuC+18+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[16:19], v75, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+4:vgprValuC+4+1], v[81:82], s[sgprBeta:sgprBeta+1], v[vgprValuC+4:vgprValuC+4+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+6:vgprValuC+6+1], v[83:84], s[sgprBeta:sgprBeta+1], v[vgprValuC+6:vgprValuC+6+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[4:7], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+20:vgprValuC+20+1], v[86:87], s[sgprBeta:sgprBeta+1], v[vgprValuC+20:vgprValuC+20+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+22:vgprValuC+22+1], v[88:89], s[sgprBeta:sgprBeta+1], v[vgprValuC+22:vgprValuC+22+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[20:23], v85, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+8:vgprValuC+8+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+8:vgprValuC+8+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+10:vgprValuC+10+1], v[93:94], s[sgprBeta:sgprBeta+1], v[vgprValuC+10:vgprValuC+10+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[8:11], v90, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+24:vgprValuC+24+1], v[96:97], s[sgprBeta:sgprBeta+1], v[vgprValuC+24:vgprValuC+24+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+26:vgprValuC+26+1], v[98:99], s[sgprBeta:sgprBeta+1], v[vgprValuC+26:vgprValuC+26+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[24:27], v95, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+12:vgprValuC+12+1], v[101:102], s[sgprBeta:sgprBeta+1], v[vgprValuC+12:vgprValuC+12+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+14:vgprValuC+14+1], v[103:104], s[sgprBeta:sgprBeta+1], v[vgprValuC+14:vgprValuC+14+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[12:15], v100, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Edge Batch:(0,3,1,0:vw2); (1,0,0,0:vw2); (1,0,1,0:vw2); (1,1,0,0:vw2); (1,1,1,0:vw2); (1,2,0,0:vw2); (1,2,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,1,3,0) coordOffset1=1 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v70, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[56:57], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v70, -1, v70, s[56:57]               // clip if OOB. offset
buffer_load_dwordx4 v[71:74], v70, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v69, vcc, v65, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v75, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v64, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[58:59], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v75, -1, v75, s[58:59]               // clip if OOB. offset
buffer_load_dwordx4 v[76:79], v75, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v64 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v80, v67, v64, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v64, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[60:61], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v80, -1, v80, s[60:61]               // clip if OOB. offset
buffer_load_dwordx4 v[81:84], v80, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v69, vcc, v65, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v85, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v85, -1, v85, s[62:63]               // clip if OOB. offset
buffer_load_dwordx4 v[86:89], v85, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=32 */
_v_add_co_u32 v68, vcc, v64, 32                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v90, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v90, -1, v90, s[64:65]               // clip if OOB. offset
buffer_load_dwordx4 v[91:94], v90, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,2,0) coordOffset1=32 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v69, vcc, v65, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v95, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v95, -1, v95, s[66:67]               // clip if OOB. offset
buffer_load_dwordx4 v[96:99], v95, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,2,0) coordOffset1=33 coordOffset0=64 */
_v_add_co_u32 v68, vcc, v64, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v100, v67, v68, 0x3                // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v100, -1, v100, s[68:69]             // clip if OOB. offset
buffer_load_dwordx4 v[101:104], v100, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(0, 3, 1, 0), (1, 0, 0, 0), (1, 0, 1, 0), (1, 1, 0, 0), (1, 1, 1, 0), (1, 2, 0, 0), (1, 2, 1, 0)] */
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+48:vgprValuC+48+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+48:vgprValuC+48+1] // *= alpha
v_mul_f64 v[vgprValuC+50:vgprValuC+50+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+50:vgprValuC+50+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha
v_mul_f64 v[vgprValuC+52:vgprValuC+52+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+52:vgprValuC+52+1] // *= alpha
v_mul_f64 v[vgprValuC+54:vgprValuC+54+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+54:vgprValuC+54+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+56:vgprValuC+56+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+56:vgprValuC+56+1] // *= alpha
v_mul_f64 v[vgprValuC+58:vgprValuC+58+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+58:vgprValuC+58+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+28:vgprValuC+28+1], v[71:72], s[sgprBeta:sgprBeta+1], v[vgprValuC+28:vgprValuC+28+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+30:vgprValuC+30+1], v[73:74], s[sgprBeta:sgprBeta+1], v[vgprValuC+30:vgprValuC+30+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[28:31], v70, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+32:vgprValuC+32+1], v[76:77], s[sgprBeta:sgprBeta+1], v[vgprValuC+32:vgprValuC+32+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+34:vgprValuC+34+1], v[78:79], s[sgprBeta:sgprBeta+1], v[vgprValuC+34:vgprValuC+34+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[32:35], v75, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+48:vgprValuC+48+1], v[81:82], s[sgprBeta:sgprBeta+1], v[vgprValuC+48:vgprValuC+48+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+50:vgprValuC+50+1], v[83:84], s[sgprBeta:sgprBeta+1], v[vgprValuC+50:vgprValuC+50+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[48:51], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+36:vgprValuC+36+1], v[86:87], s[sgprBeta:sgprBeta+1], v[vgprValuC+36:vgprValuC+36+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+38:vgprValuC+38+1], v[88:89], s[sgprBeta:sgprBeta+1], v[vgprValuC+38:vgprValuC+38+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[36:39], v85, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+52:vgprValuC+52+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+52:vgprValuC+52+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+54:vgprValuC+54+1], v[93:94], s[sgprBeta:sgprBeta+1], v[vgprValuC+54:vgprValuC+54+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[52:55], v90, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+40:vgprValuC+40+1], v[96:97], s[sgprBeta:sgprBeta+1], v[vgprValuC+40:vgprValuC+40+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+42:vgprValuC+42+1], v[98:99], s[sgprBeta:sgprBeta+1], v[vgprValuC+42:vgprValuC+42+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[40:43], v95, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+56:vgprValuC+56+1], v[101:102], s[sgprBeta:sgprBeta+1], v[vgprValuC+56:vgprValuC+56+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+58:vgprValuC+58+1], v[103:104], s[sgprBeta:sgprBeta+1], v[vgprValuC+58:vgprValuC+58+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[56:59], v100, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Edge Batch:(1,3,0,0:vw2); (1,3,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(1,0,3,0) coordOffset1=32 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v69, vcc, v65, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s50, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v67, vcc, v66, s50                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v70, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[56:57], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v70, -1, v70, s[56:57]               // clip if OOB. offset
buffer_load_dwordx4 v[71:74], v70, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,3,0) coordOffset1=33 coordOffset0=96 */
s_mov_b32 s50, 96                                  // coord0Offset d0=3 vc0=0
_v_add_co_u32 v68, vcc, v64, s50                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v69, vcc, v65, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v67, vcc, v67, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v75, v67, v68, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[50:51], v68, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[52:53], v69, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[58:59], s[50:51], s[52:53]             // in0 && in1
v_cndmask_b32 v75, -1, v75, s[58:59]               // clip if OOB. offset
buffer_load_dwordx4 v[76:79], v75, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(1, 3, 0, 0), (1, 3, 1, 0)] */
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha
v_mul_f64 v[vgprValuC+60:vgprValuC+60+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+60:vgprValuC+60+1] // *= alpha
v_mul_f64 v[vgprValuC+62:vgprValuC+62+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+62:vgprValuC+62+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+44:vgprValuC+44+1], v[71:72], s[sgprBeta:sgprBeta+1], v[vgprValuC+44:vgprValuC+44+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+46:vgprValuC+46+1], v[73:74], s[sgprBeta:sgprBeta+1], v[vgprValuC+46:vgprValuC+46+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[44:47], v70, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+60:vgprValuC+60+1], v[76:77], s[sgprBeta:sgprBeta+1], v[vgprValuC+60:vgprValuC+60+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+62:vgprValuC+62+1], v[78:79], s[sgprBeta:sgprBeta+1], v[vgprValuC+62:vgprValuC+62+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[60:63], v75, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0021                                // jump to end
label_0021:

s_endpgm                                           // End Kernel


