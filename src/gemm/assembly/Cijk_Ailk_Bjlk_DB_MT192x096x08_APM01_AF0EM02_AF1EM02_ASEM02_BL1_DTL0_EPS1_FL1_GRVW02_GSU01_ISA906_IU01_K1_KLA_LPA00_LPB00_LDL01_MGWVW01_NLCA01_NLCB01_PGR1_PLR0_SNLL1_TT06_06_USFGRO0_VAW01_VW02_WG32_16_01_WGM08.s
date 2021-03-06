
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
.amdgpu_hsa_kernel Cijk_Ailk_Bjlk_DB_MT192x096x08_APM01_AF0EM02_AF1EM02_ASEM02_BL1_DTL0_EPS1_FL1_GRVW02_GSU01_ISA906_IU01_K1_KLA_LPA00_LPB00_LDL01_MGWVW01_NLCA01_NLCB01_PGR1_PLR0_SNLL1_TT06_06_USFGRO0_VAW01_VW02_WG32_16_01_WGM08
Cijk_Ailk_Bjlk_DB_MT192x096x08_APM01_AF0EM02_AF1EM02_ASEM02_BL1_DTL0_EPS1_FL1_GRVW02_GSU01_ISA906_IU01_K1_KLA_LPA00_LPB00_LDL01_MGWVW01_NLCA01_NLCB01_PGR1_PLR0_SNLL1_TT06_06_USFGRO0_VAW01_VW02_WG32_16_01_WGM08:
.amd_kernel_code_t
  is_ptr64 = 1
  enable_sgpr_kernarg_segment_ptr = 1
  kernarg_segment_byte_size = 92 // bytes of kern args
  workitem_vgpr_count = 117 // vgprs
  wavefront_sgpr_count = 80 // sgprs
  compute_pgm_rsrc1_vgprs = 29 // floor((117-1)/4)
  compute_pgm_rsrc1_sgprs = 10 // floor((80-1)/8)
  compute_pgm_rsrc2_tidig_comp_cnt = 0 // 1D wg
  compute_pgm_rsrc2_tgid_x_en = 1 // wg.x
  compute_pgm_rsrc2_tgid_y_en = 1 // wg.y
  compute_pgm_rsrc2_tgid_z_en = 1 // wg.z
  workgroup_group_segment_byte_size = 51200 // lds bytes
  compute_pgm_rsrc2_user_sgpr = 2 // vcc
  kernarg_segment_alignment = 4
  group_segment_alignment = 4
  private_segment_alignment = 4
.end_amd_kernel_code_t

/******************************************/
/* Optimizations and Config:              */
/******************************************/
/* ThreadTile= 6 x 6 */
/* SubGroup= 32 x 16 */
/* VectorWidth=2 */
/* GlobalLoadVectorWidthA=2, GlobalLoadVectorWidthB=2 */
/* DirectToLdsA=False */
/* DirectToLdsB=False */
/* UseSgprForGRO=False */

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
.set vgprValuA_X0_I0, 72
.set vgprG2LA, 84
.set vgprValuB_X0_I0, 92
.set vgprG2LB, 104
.set vgprLocalReadAddrA, 108
.set vgprLocalReadAddrB, 109
.set vgprLocalWriteAddrA, 110
.set vgprLocalWriteAddrB, 111
.set vgprGlobalReadOffsetA, 112
.set vgprGlobalReadOffsetB, 114
.set vgprSerial, 115
/* max VGPR=117 */

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
.set sgprPerpOverhangVccA, 50
.set sgprSrdShadowLimitA, 52
.set sgprSrdShadowLimitB, 54
.set sgprOffsetC, 56
.set sgprOffsetA, 57
.set sgprOffsetB, 58
.set sgprGlobalReadIncsA, 59
.set sgprGlobalReadIncsB, 60
/* max SGPR=80 */

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
/* 6x6 thread-tile                        */
/******************************************/
.macro MAC_6x6_X0
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
v_fma_f64 v[vgprValuC+(0+4*6)*2:(vgprValuC+0+4*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(0+4*6)*2:(vgprValuC+0+4*6)*2+1]
v_fma_f64 v[vgprValuC+(1+4*6)*2:(vgprValuC+1+4*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(1+4*6)*2:(vgprValuC+1+4*6)*2+1]
v_fma_f64 v[vgprValuC+(2+4*6)*2:(vgprValuC+2+4*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(2+4*6)*2:(vgprValuC+2+4*6)*2+1]
v_fma_f64 v[vgprValuC+(3+4*6)*2:(vgprValuC+3+4*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(3+4*6)*2:(vgprValuC+3+4*6)*2+1]
v_fma_f64 v[vgprValuC+(4+4*6)*2:(vgprValuC+4+4*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(4+4*6)*2:(vgprValuC+4+4*6)*2+1]
v_fma_f64 v[vgprValuC+(5+4*6)*2:(vgprValuC+5+4*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(5+4*6)*2:(vgprValuC+5+4*6)*2+1]
v_fma_f64 v[vgprValuC+(0+5*6)*2:(vgprValuC+0+5*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(0+5*6)*2:(vgprValuC+0+5*6)*2+1]
v_fma_f64 v[vgprValuC+(1+5*6)*2:(vgprValuC+1+5*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(1+5*6)*2:(vgprValuC+1+5*6)*2+1]
v_fma_f64 v[vgprValuC+(2+5*6)*2:(vgprValuC+2+5*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(2+5*6)*2:(vgprValuC+2+5*6)*2+1]
v_fma_f64 v[vgprValuC+(3+5*6)*2:(vgprValuC+3+5*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(3+5*6)*2:(vgprValuC+3+5*6)*2+1]
v_fma_f64 v[vgprValuC+(4+5*6)*2:(vgprValuC+4+5*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(4+5*6)*2:(vgprValuC+4+5*6)*2+1]
v_fma_f64 v[vgprValuC+(5+5*6)*2:(vgprValuC+5+5*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(5+5*6)*2:(vgprValuC+5+5*6)*2+1]
s_setprio 0 // Reset priority after macs 
.endm

.macro MAC_6x6_X0_9_0
v_fma_f64 v[vgprValuC+(0+0*6)*2:(vgprValuC+0+0*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(0+0*6)*2:(vgprValuC+0+0*6)*2+1]
v_fma_f64 v[vgprValuC+(1+0*6)*2:(vgprValuC+1+0*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(1+0*6)*2:(vgprValuC+1+0*6)*2+1]
v_fma_f64 v[vgprValuC+(0+1*6)*2:(vgprValuC+0+1*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(0+1*6)*2:(vgprValuC+0+1*6)*2+1]
v_fma_f64 v[vgprValuC+(1+1*6)*2:(vgprValuC+1+1*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(1+1*6)*2:(vgprValuC+1+1*6)*2+1]
.endm
.macro MAC_6x6_X0_9_1
v_fma_f64 v[vgprValuC+(2+0*6)*2:(vgprValuC+2+0*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(2+0*6)*2:(vgprValuC+2+0*6)*2+1]
v_fma_f64 v[vgprValuC+(3+0*6)*2:(vgprValuC+3+0*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(3+0*6)*2:(vgprValuC+3+0*6)*2+1]
v_fma_f64 v[vgprValuC+(2+1*6)*2:(vgprValuC+2+1*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(2+1*6)*2:(vgprValuC+2+1*6)*2+1]
v_fma_f64 v[vgprValuC+(3+1*6)*2:(vgprValuC+3+1*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(3+1*6)*2:(vgprValuC+3+1*6)*2+1]
.endm
.macro MAC_6x6_X0_9_2
v_fma_f64 v[vgprValuC+(0+2*6)*2:(vgprValuC+0+2*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(0+2*6)*2:(vgprValuC+0+2*6)*2+1]
v_fma_f64 v[vgprValuC+(0+3*6)*2:(vgprValuC+0+3*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(0+3*6)*2:(vgprValuC+0+3*6)*2+1]
v_fma_f64 v[vgprValuC+(1+2*6)*2:(vgprValuC+1+2*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(1+2*6)*2:(vgprValuC+1+2*6)*2+1]
v_fma_f64 v[vgprValuC+(1+3*6)*2:(vgprValuC+1+3*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(1+3*6)*2:(vgprValuC+1+3*6)*2+1]
.endm
.macro MAC_6x6_X0_9_3
v_fma_f64 v[vgprValuC+(4+0*6)*2:(vgprValuC+4+0*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(4+0*6)*2:(vgprValuC+4+0*6)*2+1]
v_fma_f64 v[vgprValuC+(5+0*6)*2:(vgprValuC+5+0*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+0*2:vgprValuB_X0_I0+0*2+1], v[vgprValuC+(5+0*6)*2:(vgprValuC+5+0*6)*2+1]
v_fma_f64 v[vgprValuC+(4+1*6)*2:(vgprValuC+4+1*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(4+1*6)*2:(vgprValuC+4+1*6)*2+1]
v_fma_f64 v[vgprValuC+(5+1*6)*2:(vgprValuC+5+1*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+1*2:vgprValuB_X0_I0+1*2+1], v[vgprValuC+(5+1*6)*2:(vgprValuC+5+1*6)*2+1]
.endm
.macro MAC_6x6_X0_9_4
v_fma_f64 v[vgprValuC+(0+4*6)*2:(vgprValuC+0+4*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(0+4*6)*2:(vgprValuC+0+4*6)*2+1]
v_fma_f64 v[vgprValuC+(1+4*6)*2:(vgprValuC+1+4*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(1+4*6)*2:(vgprValuC+1+4*6)*2+1]
v_fma_f64 v[vgprValuC+(0+5*6)*2:(vgprValuC+0+5*6)*2+1], v[vgprValuA_X0_I0+0*2:vgprValuA_X0_I0+0*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(0+5*6)*2:(vgprValuC+0+5*6)*2+1]
v_fma_f64 v[vgprValuC+(1+5*6)*2:(vgprValuC+1+5*6)*2+1], v[vgprValuA_X0_I0+1*2:vgprValuA_X0_I0+1*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(1+5*6)*2:(vgprValuC+1+5*6)*2+1]
.endm
.macro MAC_6x6_X0_9_5
v_fma_f64 v[vgprValuC+(2+2*6)*2:(vgprValuC+2+2*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(2+2*6)*2:(vgprValuC+2+2*6)*2+1]
v_fma_f64 v[vgprValuC+(3+2*6)*2:(vgprValuC+3+2*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(3+2*6)*2:(vgprValuC+3+2*6)*2+1]
v_fma_f64 v[vgprValuC+(2+3*6)*2:(vgprValuC+2+3*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(2+3*6)*2:(vgprValuC+2+3*6)*2+1]
v_fma_f64 v[vgprValuC+(3+3*6)*2:(vgprValuC+3+3*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(3+3*6)*2:(vgprValuC+3+3*6)*2+1]
.endm
.macro MAC_6x6_X0_9_6
v_fma_f64 v[vgprValuC+(2+4*6)*2:(vgprValuC+2+4*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(2+4*6)*2:(vgprValuC+2+4*6)*2+1]
v_fma_f64 v[vgprValuC+(3+4*6)*2:(vgprValuC+3+4*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(3+4*6)*2:(vgprValuC+3+4*6)*2+1]
v_fma_f64 v[vgprValuC+(2+5*6)*2:(vgprValuC+2+5*6)*2+1], v[vgprValuA_X0_I0+2*2:vgprValuA_X0_I0+2*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(2+5*6)*2:(vgprValuC+2+5*6)*2+1]
v_fma_f64 v[vgprValuC+(3+5*6)*2:(vgprValuC+3+5*6)*2+1], v[vgprValuA_X0_I0+3*2:vgprValuA_X0_I0+3*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(3+5*6)*2:(vgprValuC+3+5*6)*2+1]
.endm
.macro MAC_6x6_X0_9_7
v_fma_f64 v[vgprValuC+(4+2*6)*2:(vgprValuC+4+2*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(4+2*6)*2:(vgprValuC+4+2*6)*2+1]
v_fma_f64 v[vgprValuC+(5+2*6)*2:(vgprValuC+5+2*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+2*2:vgprValuB_X0_I0+2*2+1], v[vgprValuC+(5+2*6)*2:(vgprValuC+5+2*6)*2+1]
v_fma_f64 v[vgprValuC+(4+3*6)*2:(vgprValuC+4+3*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(4+3*6)*2:(vgprValuC+4+3*6)*2+1]
v_fma_f64 v[vgprValuC+(5+3*6)*2:(vgprValuC+5+3*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+3*2:vgprValuB_X0_I0+3*2+1], v[vgprValuC+(5+3*6)*2:(vgprValuC+5+3*6)*2+1]
.endm
.macro MAC_6x6_X0_9_8
v_fma_f64 v[vgprValuC+(4+4*6)*2:(vgprValuC+4+4*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(4+4*6)*2:(vgprValuC+4+4*6)*2+1]
v_fma_f64 v[vgprValuC+(5+4*6)*2:(vgprValuC+5+4*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+4*2:vgprValuB_X0_I0+4*2+1], v[vgprValuC+(5+4*6)*2:(vgprValuC+5+4*6)*2+1]
v_fma_f64 v[vgprValuC+(4+5*6)*2:(vgprValuC+4+5*6)*2+1], v[vgprValuA_X0_I0+4*2:vgprValuA_X0_I0+4*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(4+5*6)*2:(vgprValuC+4+5*6)*2+1]
v_fma_f64 v[vgprValuC+(5+5*6)*2:(vgprValuC+5+5*6)*2+1], v[vgprValuA_X0_I0+5*2:vgprValuA_X0_I0+5*2+1], v[vgprValuB_X0_I0+5*2:vgprValuB_X0_I0+5*2+1], v[vgprValuC+(5+5*6)*2:(vgprValuC+5+5*6)*2+1]
.endm

/******************************************/
/* Allocate Resources                     */
/******************************************/
s_mov_b32 m0, 0xc800                               // LDS clamp at 51200 bytes
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
s_mov_b32 s61, 0xbf                                // 
_v_add_co_u32 v0, vcc, s61, v0                     // v0 = size0+MT0-1
s_mov_b32 s61, 0x2aaaaab                           // 
v_mul_hi_u32 v2, v0, s61                           // 
v_mul_lo_u32 v1, v0, s61                           // 
s_mov_b32 s61, 0x21                                // 
v_lshrrev_b64 v[1:2], s61, v[1:2]                  // 
v_mov_b32 v3, v1                                   // vectorStaticDiv: quotient
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
s_mov_b32 s62, 0xbf                                // 
_v_add_co_u32 v2, vcc, s62, v2                     // v2 = size0+MT0-1
s_mov_b32 s62, 0x2aaaaab                           // 
v_mul_hi_u32 v1, v2, s62                           // 
v_mul_lo_u32 v0, v2, s62                           // 
s_mov_b32 s62, 0x21                                // 
v_lshrrev_b64 v[0:1], s62, v[0:1]                  // 
v_mov_b32 v2, v0                                   // vectorStaticDiv: quotient
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
/* LVCA = 96 */
/* v0 = (local)groA-tile = serial%LVCA (note (wgA*MTA) will be added to SRD) */
/* v1 = groA-unroll = serial/LVCA */
s_mov_b32 s61, 0x5555556                           // 
v_mul_hi_u32 v3, v[vgprSerial], s61                // 
v_mul_lo_u32 v2, v[vgprSerial], s61                // 
s_mov_b32 s61, 0x21                                // 
v_lshrrev_b64 v[2:3], s61, v[2:3]                  // 
v_mov_b32 v1, v2                                   // vectorStaticDiv: quotient
s_mov_b32 s61, 0x60                                // divisor
v_mul_lo_u32 v2, v1, s61                           // vectorStaticDiv: product = quotient * divisor
_v_sub_co_u32 v0, vcc, v[vgprSerial], v2           // vectorStaticDiv: remainder = dividend - product
/* gro-tile *= glvw */
v_lshlrev_b32 v0, 1, v0                            // staticMultiply: v0 = v0 * 2

/* global read addresses: tile offset assignment b */
/* LVCB = 48 */
/* v2 = (local)groB-tile = serial%LVCB (note (wgB*MTB) will be added to SRD) */
/* v3 = groB-unroll = serial/LVCB */
s_mov_b32 s61, 0xaaaaaab                           // 
v_mul_hi_u32 v5, v[vgprSerial], s61                // 
v_mul_lo_u32 v4, v[vgprSerial], s61                // 
s_mov_b32 s61, 0x21                                // 
v_lshrrev_b64 v[4:5], s61, v[4:5]                  // 
v_mov_b32 v3, v4                                   // vectorStaticDiv: quotient
s_mov_b32 s61, 0x30                                // divisor
v_mul_lo_u32 v4, v3, s61                           // vectorStaticDiv: product = quotient * divisor
_v_sub_co_u32 v2, vcc, v[vgprSerial], v4           // vectorStaticDiv: remainder = dividend - product
/* gro-tile *= glvw */
v_lshlrev_b32 v2, 1, v2                            // staticMultiply: v2 = v2 * 2

/* global read addresses: unroll assignment a */
/* v1 */

/* global read addresses: unroll assignment b */
/* v3 */

/* global read addresses: other free assignments */
/* s[sgprWorkGroup2] */

/* global read addresses: tile offsets a */
v_mov_b32 v4, v0                                   // groA0I_0

/* global read addresses: tile offsets b */
v_mov_b32 v5, v2                                   // groB1J_0

/* global read addresses: unroll offsets a */
v_mov_b32 v6, v1                                   // groAL_0
_v_add_co_u32 v7, vcc, 5, v6                       // groAL_1 + LSPA

/* global read addresses: unroll offsets b */
v_mov_b32 v8, v3                                   // groBL_0

/* global read addresses: shift a */
s_mul_i32 s61, s[sgprWorkGroup0], 192              // WorkGroup[01] * MT
s_sub_u32 s61, s[sgprSizesFree+0], s61             // edge = Size0I - WG*MT
s_sub_u32 s61, s61, 2                              // edge -= margin
v_mov_b32 v9, s61                                  // edge vgpr = Size0I-2
_v_add_co_u32 v10, vcc, v9, 2                      // add srdShiftLift
_v_add_co_u32 v11, vcc, v4, 2                      // 
v_cmp_lt_u32 s[62:63], v11, v10                    // offset < edge
v_cndmask_b32 v4, v9, v4, s[62:63]                 // offset = (offset < edge) ? offset : edge

/* global read addresses: shift b */
s_mul_i32 s61, s[sgprWorkGroup1], 96               // WorkGroup[01] * MT
s_sub_u32 s61, s[sgprSizesFree+1], s61             // edge = Size1J - WG*MT
s_sub_u32 s61, s61, 2                              // edge -= margin
v_mov_b32 v9, s61                                  // edge vgpr = Size1J-2
_v_add_co_u32 v10, vcc, v9, 2                      // add srdShiftLift
_v_add_co_u32 v11, vcc, v5, 2                      // 
v_cmp_lt_u32 s[62:63], v11, v10                    // offset < edge
v_cndmask_b32 v5, v9, v5, s[62:63]                 // offset = (offset < edge) ? offset : edge

/* global read addresses: final offsets a */
GLOBAL_OFFSET_A vgprGlobalReadOffsetA+0,  4,  6, 9 // gROA_0_0_0_0
// Offset only valid for 480/512 threads inside the PerLoadTile
s_mov_b32 s62, 480                                 // 
v_cmp_lt_u32 vcc, v[vgprSerial], s62               // tid < valid-tid
s_mov_b32 s62, BufferOOB                           // 
v_mov_b32 v12, s62                                 // 
v_cndmask_b32 v[vgprGlobalReadOffsetA+0], v12, v[vgprGlobalReadOffsetA+0], vcc // Mask load so OOB will return 0
GLOBAL_OFFSET_A vgprGlobalReadOffsetA+1,  4,  7, 9 // gROA_0_0_1_0
// Offset only valid for 480/512 threads inside the PerLoadTile
s_mov_b32 s62, 480                                 // 
v_cmp_lt_u32 vcc, v[vgprSerial], s62               // tid < valid-tid
s_mov_b32 s62, BufferOOB                           // 
v_mov_b32 v12, s62                                 // 
v_cndmask_b32 v[vgprGlobalReadOffsetA+1], v12, v[vgprGlobalReadOffsetA+1], vcc // Mask load so OOB will return 0
s_mov_b32 s[sgprPerpOverhangVccA], 288             // overhang=3, validWI=288
v_cmp_lt_u32 s[sgprPerpOverhangVccA:sgprPerpOverhangVccA+1], v[vgprSerial], s[sgprPerpOverhangVccA] // fractional-overhang: some wi write to harmless LDS location

/* global read addresses: final offsets b */
GLOBAL_OFFSET_B vgprGlobalReadOffsetB+0,  5,  8, 9 // gROB_0_0_0_0
// Offset only valid for 384/512 threads inside the PerLoadTile
s_mov_b32 s62, 384                                 // 
v_cmp_lt_u32 vcc, v[vgprSerial], s62               // tid < valid-tid
s_mov_b32 s62, BufferOOB                           // 
v_mov_b32 v12, s62                                 // 
v_cndmask_b32 v[vgprGlobalReadOffsetB+0], v12, v[vgprGlobalReadOffsetB+0], vcc // Mask load so OOB will return 0

/* global read addresses: apply user offsets */
/* moved earlier */

/* global read addresses: addresses a */
/* max read offset = size[n] * stride[n-1] */
s_mul_hi_u32 s67, s[sgprWorkGroup0], 192           // WorkGroup[01] * MT
s_mul_i32 s66, s[sgprWorkGroup0], 192              // WorkGroup[01] * MT
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
v_mul_u32_u24 v[vgprLocalWriteAddrA], 0xc0, v1     // lwAL**(MTA + PAD)
_v_add_lshl_u32 v[vgprLocalWriteAddrA], v0, v[vgprLocalWriteAddrA], 0x3 // lwFOA = (lwAA + lwAL*(MT0I+PAD))*bpe
s_mov_b32 s61, 480                                 // lsc*lsp=192*5
v_cmp_lt_u32 vcc, v[vgprSerial], s61               // fractional: ensure tid < global read tile elements
v_mov_b32 v0, 0xf00000                             // 
v_cndmask_b32 v[vgprLocalWriteAddrA], v0, v[vgprLocalWriteAddrA], vcc // Mask load so out-of-gr-tile bounds returns 0

/* local write addresses: first offset b */
v_mul_u32_u24 v[vgprLocalWriteAddrB], 0x60, v3     // lwBL**(MTB + PAD)
_v_add_lshl_u32 v[vgprLocalWriteAddrB], v2, v[vgprLocalWriteAddrB], 0x3 // lwFOB = (lwBB + lwBL*(MT1J+PAD))*bpe
_v_add_co_u32 v[vgprLocalWriteAddrB], vcc, 0x3000, v[vgprLocalWriteAddrB] // lwFOB = lwB1J + lwBL*MT1J + LDS_OFFSET_B=1536*8
s_mov_b32 s61, 384                                 // lsc*lsp=96*8
v_cmp_lt_u32 vcc, v[vgprSerial], s61               // fractional: ensure tid < global read tile elements
v_mov_b32 v0, 0xf00000                             // 
v_cndmask_b32 v[vgprLocalWriteAddrB], v0, v[vgprLocalWriteAddrB], vcc // Mask load so out-of-gr-tile bounds returns 0

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
v_lshrrev_b32 v0, 5, v[vgprSerial]                 // vectorStaticDiv: v0 = v[vgprSerial] / 32
v_and_b32 v1, 31, v[vgprSerial]                    // vectorStaticDiv: v1 = v[vgprSerial] % 32

/* local read addresses: tile assignments b */
/*lr1J = (serial / SG1J) % SG1J*/
v_lshrrev_b32 v2, 4, v0                            // vectorStaticDiv: v2 = v0 / 16
v_and_b32 v3, 15, v0                               // vectorStaticDiv: v3 = v0 % 16

/* local read addresses: final offsets a */
v_lshrrev_b32 v0, 9, v[vgprSerial]                 // vectorStaticDiv: v0 = v[vgprSerial] / 512
v_and_b32 v2, 511, v[vgprSerial]                   // vectorStaticDiv: v2 = v[vgprSerial] % 512
s_mov_b32 s61, 0xc0                                // MT0+PAD
v_mul_lo_u32 v0, s61, v0                           // sgid=sgid*(MT0+PAD)
v_lshlrev_b32 v1, 1, v1                            // staticMultiply: v1 = v1 * 2
_v_add_lshl_u32 v[vgprLocalReadAddrA], v0, v1, 0x3 // o = (lroA*VW+sgid*MT0)*bpe

/* local read addresses: final offsets b */
v_lshrrev_b32 v0, 9, v[vgprSerial]                 // vectorStaticDiv: v0 = v[vgprSerial] / 512
v_and_b32 v1, 511, v[vgprSerial]                   // vectorStaticDiv: v1 = v[vgprSerial] % 512
s_mov_b32 s61, 0x60                                // MT1+PAD
v_mul_lo_u32 v0, s61, v0                           // sgid=sgid*(MT1+PAD)
v_lshlrev_b32 v3, 1, v3                            // staticMultiply: v3 = v3 * 2
_v_add_lshl_u32 v[vgprLocalReadAddrB], v0, v3, 0x3 // o = (lroB*VW+sgid*MT1)*bpe

/* local read addresses: declare addresses a */
/* N/A */

/* local read addresses: declare addresses b */
_v_add_co_u32 v[vgprLocalReadAddrB+0], vcc, 0x3000, v[vgprLocalReadAddrB+0] //  += LdsOffsetB (lower)

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
v_mov_b32 v[vgprValuC+64], 0x0                     // initC
v_mov_b32 v[vgprValuC+65], 0x0                     // initC
v_mov_b32 v[vgprValuC+66], 0x0                     // initC
v_mov_b32 v[vgprValuC+67], 0x0                     // initC
v_mov_b32 v[vgprValuC+68], 0x0                     // initC
v_mov_b32 v[vgprValuC+69], 0x0                     // initC
v_mov_b32 v[vgprValuC+70], 0x0                     // initC
v_mov_b32 v[vgprValuC+71], 0x0                     // initC
s_lshr_b32 s[sgprLoopCounters+0], s[sgprSizesSum+0], 3 // s[sgprLoopCounters+0] = s[sgprSizesSum+0] / 8
//raman debug
//s_mov_b32 s[sgprLoopCounters+0] , 32 
s_sub_u32 s[sgprLoopCounters+0], 0x0, s[sgprLoopCounters+0] // counterL = -sizeL

/* local read addresses: init pointers a */

/* local read addresses: init pointers b */

/* prefetch: global -> local */
s_cmp_eq_u32 s[sgprLoopCounters+0], 0x0            // numIter0I == 0
s_cbranch_scc1 label_0002                          // skip to end of prefetch last iter b/c numIter==0

/* global read a */
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_0_0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+4+3], v[vgprGlobalReadOffsetA+1], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_1_0

/* global read b */
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // G -> Reg 0_0_0_0

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
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 0 #1
/* LastPerp.  overhang=3, mask WI>288 */
v_cndmask_b32 v116, 1.0, v[vgprLocalWriteAddrA], s[sgprPerpOverhangVccA:sgprPerpOverhangVccA+1] // Mask load so out-of-gr-tile bounds returns 0. Note 1.0f=0x3f80000 which is large non-neg int
ds_write_b128 v116, v[vgprG2LA+4:vgprG2LA+4+3] offset:7680 // lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 7680 #1

/* local write b */
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 0 #2
s_cmp_ge_i32 s[sgprLoopCounters+0], 0x0            // LoopCounterL < EndCounter
s_cbranch_scc1 label_0002                          // don't enter LoopL
s_barrier

/* local write swap a */

/* local write swap b */

/* local write init pointers a */
/* N/A */

/* local write init pointers b */
/* N/A */
v_mov_b32 v[vgprValuC+0], 0x0                      // initC
v_mov_b32 v[vgprValuC+1], 0x0                      // initC
v_mov_b32 v[vgprValuC+2], 0x0                      // initC
v_mov_b32 v[vgprValuC+3], 0x0                      // initC
v_mov_b32 v[vgprValuC+4], 0x0                      // initC
v_mov_b32 v[vgprValuC+5], 0x0                      // initC
v_mov_b32 v[vgprValuC+6], 0x0                      // initC
v_mov_b32 v[vgprValuC+7], 0x0                      // initC

s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 4


v_mov_b32 v[vgprValuC+8], 0x0                      // initC
v_mov_b32 v[vgprValuC+9], 0x0                      // initC
v_mov_b32 v[vgprValuC+10], 0x0                     // initC
v_mov_b32 v[vgprValuC+11], 0x0                     // initC
v_mov_b32 v[vgprValuC+12], 0x0                     // initC
v_mov_b32 v[vgprValuC+13], 0x0                     // initC
v_mov_b32 v[vgprValuC+14], 0x0                     // initC
v_mov_b32 v[vgprValuC+15], 0x0                     // initC

s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 4

v_mov_b32 v[vgprValuC+16], 0x0                     // initC
v_mov_b32 v[vgprValuC+17], 0x0                     // initC
v_mov_b32 v[vgprValuC+18], 0x0                     // initC
v_mov_b32 v[vgprValuC+19], 0x0                     // initC
v_mov_b32 v[vgprValuC+20], 0x0                     // initC
v_mov_b32 v[vgprValuC+21], 0x0                     // initC
v_mov_b32 v[vgprValuC+22], 0x0                     // initC
v_mov_b32 v[vgprValuC+23], 0x0                     // initC

s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:512 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 4

v_mov_b32 v[vgprValuC+24], 0x0                     // initC
v_mov_b32 v[vgprValuC+25], 0x0                     // initC
v_mov_b32 v[vgprValuC+26], 0x0                     // initC
v_mov_b32 v[vgprValuC+27], 0x0                     // initC
v_mov_b32 v[vgprValuC+28], 0x0                     // initC
v_mov_b32 v[vgprValuC+29], 0x0                     // initC
v_mov_b32 v[vgprValuC+30], 0x0                     // initC
v_mov_b32 v[vgprValuC+31], 0x0                     // initC

s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 4

v_mov_b32 v[vgprValuC+32], 0x0                     // initC
v_mov_b32 v[vgprValuC+33], 0x0                     // initC
v_mov_b32 v[vgprValuC+34], 0x0                     // initC
v_mov_b32 v[vgprValuC+35], 0x0                     // initC
v_mov_b32 v[vgprValuC+36], 0x0                     // initC
v_mov_b32 v[vgprValuC+37], 0x0                     // initC
v_mov_b32 v[vgprValuC+38], 0x0                     // initC
v_mov_b32 v[vgprValuC+39], 0x0                     // initC

s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:1024 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 4

v_mov_b32 v[vgprValuC+40], 0x0                     // initC
v_mov_b32 v[vgprValuC+41], 0x0                     // initC
v_mov_b32 v[vgprValuC+42], 0x0                     // initC
v_mov_b32 v[vgprValuC+43], 0x0                     // initC
v_mov_b32 v[vgprValuC+44], 0x0                     // initC
v_mov_b32 v[vgprValuC+45], 0x0                     // initC
v_mov_b32 v[vgprValuC+46], 0x0                     // initC
v_mov_b32 v[vgprValuC+47], 0x0                     // initC

s_nop 7

v_mov_b32 v[vgprValuC+48], 0x0                     // initC
v_mov_b32 v[vgprValuC+49], 0x0                     // initC
v_mov_b32 v[vgprValuC+50], 0x0                     // initC
v_mov_b32 v[vgprValuC+51], 0x0                     // initC
v_mov_b32 v[vgprValuC+52], 0x0                     // initC
v_mov_b32 v[vgprValuC+53], 0x0                     // initC
v_mov_b32 v[vgprValuC+54], 0x0                     // initC
v_mov_b32 v[vgprValuC+55], 0x0                     // initC

s_nop 7

v_mov_b32 v[vgprValuC+56], 0x0                     // initC
v_mov_b32 v[vgprValuC+57], 0x0                     // initC
v_mov_b32 v[vgprValuC+58], 0x0                     // initC
v_mov_b32 v[vgprValuC+59], 0x0                     // initC
v_mov_b32 v[vgprValuC+60], 0x0                     // initC
v_mov_b32 v[vgprValuC+61], 0x0                     // initC
v_mov_b32 v[vgprValuC+62], 0x0                     // initC
v_mov_b32 v[vgprValuC+63], 0x0                     // initC

s_nop 7

v_mov_b32 v[vgprValuC+64], 0x0                     // initC
v_mov_b32 v[vgprValuC+65], 0x0                     // initC
v_mov_b32 v[vgprValuC+66], 0x0                     // initC
v_mov_b32 v[vgprValuC+67], 0x0                     // initC
v_mov_b32 v[vgprValuC+68], 0x0                     // initC
v_mov_b32 v[vgprValuC+69], 0x0                     // initC
v_mov_b32 v[vgprValuC+70], 0x0                     // initC
v_mov_b32 v[vgprValuC+71], 0x0                     // initC

s_nop 6
s_waitcnt lgkmcnt(3) // wait for prior local read

/******************************************/
/* Unrolled Loop(s) - Begin               */
/******************************************/
label_0001:

/******************************************/
/* Unroll Loop 1/2 - Begin                */
/******************************************/

MAC_6x6_X0_9_0
/* global read a */
s_cmp_eq_i32 s[sgprLoopCounters+0], -1             // is this the last iteration
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:512 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_cmov_b32 s[sgprGlobalReadIncsA], 0               // Set inc to 0 for last iteration
s_cmov_b32 s[sgprSrdA+2], 0                        // Set limit to 0 for last iteration
s_cmov_b32 s[sgprGlobalReadIncsB], 0               // Set inc to 0 for last iteration
s_cmov_b32 s[sgprSrdB+2], 0                        // Set limit to 0 for last iteration
s_waitcnt lgkmcnt(3) // wait for prior local read

MAC_6x6_X0_9_1
s_nop 0
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_0_0
s_nop 1
s_waitcnt lgkmcnt(2) // wait for prior local read


MAC_6x6_X0_9_2
s_nop 6
s_waitcnt lgkmcnt(1) // wait for prior local read

MAC_6x6_X0_9_3
s_nop 0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+4+3], v[vgprGlobalReadOffsetA+1], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_1_0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:768 // L -> Reg lro=96 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 2
s_waitcnt lgkmcnt(1) // wait for prior local read


MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:1536 // L -> Reg lro=96 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // wait for prior local read

MAC_6x6_X0_9_5
s_nop 0
/* global read b */
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // G -> Reg 0_0_0_0
s_nop 3
s_waitcnt lgkmcnt(2) // wait for prior local read

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:2048 // L -> Reg lro=96 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // wait for prior local read


MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1024 // L -> Reg lro=96 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // wait for prior local read

MAC_6x6_X0_9_8
/* global read inc a */
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s[sgprGlobalReadIncsA+0] // gra SRD += inc(lower)
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:2560 // L -> Reg lro=96 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprSrdShadowLimitA+0], s[sgprSrdShadowLimitA+0], s[sgprGlobalReadIncsA+0] // limit -= inc)
s_subb_u32 s[sgprSrdShadowLimitA+1], s[sgprSrdShadowLimitA+1], 0 // limit -= inc)
s_nop 0
s_waitcnt lgkmcnt(3) // wait for prior local read


/* iter 1 */

/* local read increment a */
/* N/A, lro->192 */

/* local read increment b */
/* N/A, lro->96 */
/* iter 1 */

MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:1280 // L -> Reg lro=96 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_cmp_eq_u32 s[sgprSrdShadowLimitA+1], 0           // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprSrdShadowLimitA+0] // Move shadow to real if we are within 2^32
/* global read inc b */
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s[sgprGlobalReadIncsB+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0        // gra SRD += inc(upper)
s_waitcnt lgkmcnt(3) // wait for prior local read


MAC_6x6_X0_9_1
s_sub_u32 s[sgprSrdShadowLimitB+0], s[sgprSrdShadowLimitB+0], s[sgprGlobalReadIncsB+0] // limit -= inc)
s_subb_u32 s[sgprSrdShadowLimitB+1], s[sgprSrdShadowLimitB+1], 0 // limit -= inc)
s_nop 4
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_2
s_cmp_eq_u32 s[sgprSrdShadowLimitB+1], 0           // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprSrdShadowLimitB+0] // Move shadow to real if we are within 2^32
s_nop 4
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:1536 // L -> Reg lro=192 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(1) // 1wait for local write
/* local read increment a */
/* N/A, lro->96 */

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:3072 // L -> Reg lro=384 swapByteOffset=0 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:3584 // L -> Reg lro=384 swapByteOffset=0 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:1792 // L -> Reg lro=192 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:4096 // L -> Reg lro=384 swapByteOffset=0 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write


/* iter 2 */
MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:2048 // L -> Reg lro=192 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write


MAC_6x6_X0_9_1
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 6
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:2304 // L -> Reg lro=288 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:4608 // L -> Reg lro=576 swapByteOffset=0 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:5120 // L -> Reg lro=576 swapByteOffset=0 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:2560 // L -> Reg lro=288 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:5632 // L -> Reg lro=576 swapByteOffset=0 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

/* iter 3 */

MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:2816 // L -> Reg lro=288 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_1
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 6
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:3072 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:6144 // L -> Reg lro=768 swapByteOffset=0 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:6656 // L -> Reg lro=768 swapByteOffset=0 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:3328 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:7168 // L -> Reg lro=768 swapByteOffset=0 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

/* iter 4 */
MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:3584 // L -> Reg lro=384 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_1
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_2
//s_nop 0
//s_waitcnt vmcnt(2) // 1wait for global read
//ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+1] offset:32768 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 32768 #3
s_nop 6
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:3840 // L -> Reg lro=480 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:7680 // L -> Reg lro=960 swapByteOffset=0 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

/* local write a */
MAC_6x6_X0_9_5
s_nop 0
s_waitcnt vmcnt(2) // 1wait for global read
ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+1] offset:32768 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 32768 #3
s_nop 1
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:8192 // L -> Reg lro=960 swapByteOffset=0 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:4096 // L -> Reg lro=480 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(5) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:8704 // L -> Reg lro=960 swapByteOffset=0 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

/* iter 5 */

MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:4352 // L -> Reg lro=480 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_1
s_nop 1
//s_waitcnt vmcnt(1) // 1wait for global read
//ds_write_b64 v116, v[vgprG2LA+4:vgprG2LA+4+1] offset:40448 // lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 40448 #3
ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+2:vgprG2LA+0+3] offset:32776 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 32768 #3
s_nop 1
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 0
s_waitcnt vmcnt(1) // 1wait for global read
ds_write_b64 v116, v[vgprG2LA+4+0:vgprG2LA+4+1] offset:40448 // lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 40448 #3
s_nop 1
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:4608 // L -> Reg lro=576 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:9216 // L -> Reg lro=1152 swapByteOffset=0 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 1
ds_write_b64 v116, v[vgprG2LA+4+2:vgprG2LA+4+3] offset:40456 // lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 40448 #3
s_nop 1
s_waitcnt lgkmcnt(5) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:9728 // L -> Reg lro=1152 swapByteOffset=0 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(6) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:4864 // L -> Reg lro=576 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(7) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:10240 // L -> Reg lro=1152 swapByteOffset=0 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

/* iter 6 */
MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:5120 // L -> Reg lro=576 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write
/* local read increment a */
/* N/A, lro->480 */
MAC_6x6_X0_9_1
s_nop 0
s_waitcnt vmcnt(0) // 1wait for global read
ds_write_b64 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+1] offset:32768 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 32768 #4
s_nop 1
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 1
ds_write_b64 v[vgprLocalWriteAddrB], v[vgprG2LB+2:vgprG2LB+0+3] offset:32776 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 32768 #4
s_nop 1
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:5376 // L -> Reg lro=672 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:10752 // L -> Reg lro=1344 swapByteOffset=0 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 6
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:11264 // L -> Reg lro=1344 swapByteOffset=0 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(5) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:5632 // L -> Reg lro=672 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(6) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:11776 // L -> Reg lro=1344 swapByteOffset=0 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write


/* iter 7 (last) */
MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:5888 // L -> Reg lro=672 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write
/* local read increment a */
/* N/A, lro->480 */
MAC_6x6_X0_9_1
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 6
s_waitcnt lgkmcnt(1) // 1wait for local write

s_barrier //4sync for global read
MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:32768 // L -> Reg lro=0 swapByteOffset=32768 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:32768 // L -> Reg lro=0 swapByteOffset=32768 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:33280 // L -> Reg lro=0 swapByteOffset=32768 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 2
s_add_u32 s[sgprLoopCounters+0], s[sgprLoopCounters+0], 0x1 // inc counterL
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:33024 // L -> Reg lro=0 swapByteOffset=32768 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 2
s_cmp_eq_i32 s[sgprLoopCounters+0], 0x0            // counterL==0
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:33792 // L -> Reg lro=0 swapByteOffset=32768 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_cbranch_scc1 label_0003                          // exit LoopL
s_nop 2
s_waitcnt lgkmcnt(3) // 1wait for local write

/******************************************/
/* Unrolled Loop - End 1/2                */
/******************************************/

/******************************************/
/* Unroll Loop 2/2 - Begin                */
/******************************************/


MAC_6x6_X0_9_0
/* global read a */
s_cmp_eq_i32 s[sgprLoopCounters+0], -1             // is this the last iteration
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:33280 // L -> Reg lro=0 swapByteOffset=32768 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_cmov_b32 s[sgprGlobalReadIncsA], 0               // Set inc to 0 for last iteration
s_cmov_b32 s[sgprSrdA+2], 0                        // Set limit to 0 for last iteration
s_cmov_b32 s[sgprGlobalReadIncsB], 0               // Set inc to 0 for last iteration
s_cmov_b32 s[sgprSrdB+2], 0                        // Set limit to 0 for last iteration
s_waitcnt lgkmcnt(3) // wait for prior local read

MAC_6x6_X0_9_1
s_nop 0
buffer_load_dwordx4 v[vgprG2LA+0:vgprG2LA+0+3], v[vgprGlobalReadOffsetA+0], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_0_0
s_nop 1
s_waitcnt lgkmcnt(2) // wait for prior local read


MAC_6x6_X0_9_2
s_nop 6
s_waitcnt lgkmcnt(1) // wait for prior local read

MAC_6x6_X0_9_3
s_nop 0
buffer_load_dwordx4 v[vgprG2LA+4:vgprG2LA+4+3], v[vgprGlobalReadOffsetA+1], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // G -> Reg 0_0_1_0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:33536 // L -> Reg lro=96 swapByteOffset=32768 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 1
s_waitcnt lgkmcnt(1) // wait for prior local read


MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:34304 // L -> Reg lro=192 swapByteOffset=32768 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // wait for prior local read

MAC_6x6_X0_9_5
s_nop 0
/* global read b */
buffer_load_dwordx4 v[vgprG2LB+0:vgprG2LB+0+3], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // G -> Reg 0_0_0_0
s_nop 3
s_waitcnt lgkmcnt(2) // wait for prior local read

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:34816 // L -> Reg lro=192 swapByteOffset=32768 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // wait for prior local read


MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:33792 // L -> Reg lro=96 swapByteOffset=32768 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // wait for prior local read

MAC_6x6_X0_9_8
/* global read inc a */
s_add_u32  s[sgprSrdA+0], s[sgprSrdA+0], s[sgprGlobalReadIncsA+0] // gra SRD += inc(lower)
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:35328 // L -> Reg lro=192 swapByteOffset=32768 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_addc_u32  s[sgprSrdA+1], s[sgprSrdA+1], 0        // gra SRD += inc(upper)
s_sub_u32 s[sgprSrdShadowLimitA+0], s[sgprSrdShadowLimitA+0], s[sgprGlobalReadIncsA+0] // limit -= inc)
s_subb_u32 s[sgprSrdShadowLimitA+1], s[sgprSrdShadowLimitA+1], 0 // limit -= inc)
s_nop 0
s_waitcnt lgkmcnt(3) // wait for prior local read


/* iter 1 */

/* local read increment a */
/* N/A, lro->192 */

/* local read increment b */
/* N/A, lro->96 */
/* iter 1 */

MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:34048 // L -> Reg lro=96 swapByteOffset=32768 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_cmp_eq_u32 s[sgprSrdShadowLimitA+1], 0           // are we within 2^32?
s_cmov_b32 s[sgprSrdA+2], s[sgprSrdShadowLimitA+0] // Move shadow to real if we are within 2^32
/* global read inc b */
s_add_u32  s[sgprSrdB+0], s[sgprSrdB+0], s[sgprGlobalReadIncsB+0] // gra SRD += inc(lower)
s_addc_u32  s[sgprSrdB+1], s[sgprSrdB+1], 0        // gra SRD += inc(upper)
s_waitcnt lgkmcnt(3) // wait for prior local read


MAC_6x6_X0_9_1
s_sub_u32 s[sgprSrdShadowLimitB+0], s[sgprSrdShadowLimitB+0], s[sgprGlobalReadIncsB+0] // limit -= inc)
s_subb_u32 s[sgprSrdShadowLimitB+1], s[sgprSrdShadowLimitB+1], 0 // limit -= inc)
s_nop 4
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_2
s_cmp_eq_u32 s[sgprSrdShadowLimitB+1], 0           // are we within 2^32?
s_cmov_b32 s[sgprSrdB+2], s[sgprSrdShadowLimitB+0] // Move shadow to real if we are within 2^32
s_nop 4
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:34304 // L -> Reg lro=192 swapByteOffset=32768 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(1) // 1wait for local write
/* local read increment a */
/* N/A, lro->96 */

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:35840 // L -> Reg lro=384 swapByteOffset=32768 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:36352 // L -> Reg lro=384 swapByteOffset=32768 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:34560 // L -> Reg lro=192 swapByteOffset=32768 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:36864 // L -> Reg lro=384 swapByteOffset=32768 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write


/* iter 2 */
MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:34816 // L -> Reg lro=192 swapByteOffset=32768 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write


MAC_6x6_X0_9_1
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 6
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:35072 // L -> Reg lro=288 swapByteOffset=32768 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:37376 // L -> Reg lro=576 swapByteOffset=32768 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:37888 // L -> Reg lro=576 swapByteOffset=32768 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:35328 // L -> Reg lro=288 swapByteOffset=32768 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:38400 // L -> Reg lro=576 swapByteOffset=32768 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

/* iter 3 */

MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:35584 // L -> Reg lro=288 swapByteOffset=32768 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_1
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 6
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:35840 // L -> Reg lro=384 swapByteOffset=32768 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:38912 // L -> Reg lro=768 swapByteOffset=32768 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:39424 // L -> Reg lro=768 swapByteOffset=32768 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:36096 // L -> Reg lro=384 swapByteOffset=32768 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:39936 // L -> Reg lro=768 swapByteOffset=32768 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

/* iter 4 */
MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:36352 // L -> Reg lro=384 swapByteOffset=32768 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_1
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 6
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:36608 // L -> Reg lro=480 swapByteOffset=32768 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:40448 // L -> Reg lro=960 swapByteOffset=32768 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 0
s_waitcnt vmcnt(2)
ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+1] offset:0 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 32768 #3
s_nop 1
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:40960 // L -> Reg lro=960 swapByteOffset=32768 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:36864 // L -> Reg lro=480 swapByteOffset=32768 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(5) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:41472 // L -> Reg lro=960 swapByteOffset=32768 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

/* iter 5 */

MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:37120 // L -> Reg lro=480 swapByteOffset=32768 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_1
s_nop 1
ds_write_b64 v[vgprLocalWriteAddrA], v[vgprG2LA+2:vgprG2LA+0+3] offset:8 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 32768 #3
s_nop 1
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 0
s_waitcnt vmcnt(1) // 1wait for global read
ds_write_b64 v116, v[vgprG2LA+4+0:vgprG2LA+4+1] offset:7680 // lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 40448 #3
s_nop 1
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:37376 // L -> Reg lro=576 swapByteOffset=32768 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:41984 // L -> Reg lro=1152 swapByteOffset=32768 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 1
ds_write_b64 v116, v[vgprG2LA+4+2:vgprG2LA+4+3] offset:7688// lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 40448 #3
s_nop 1
s_waitcnt lgkmcnt(5) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:42496 // L -> Reg lro=1152 swapByteOffset=32768 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(6) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:37632 // L -> Reg lro=576 swapByteOffset=32768 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(7) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:43008 // L -> Reg lro=1152 swapByteOffset=32768 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

/* iter 6 */
MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:37888 // L -> Reg lro=576 swapByteOffset=32768 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write
/* local read increment a */
/* N/A, lro->480 */
MAC_6x6_X0_9_1
s_nop 0
s_waitcnt vmcnt(0) // 1wait for global read
ds_write_b64 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+1] offset:0 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 32768 #4
s_nop 1
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 1
ds_write_b64 v[vgprLocalWriteAddrB], v[vgprG2LB+2:vgprG2LB+0+3] offset:8 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 32768 #4
s_nop 1
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:38144 // L -> Reg lro=672 swapByteOffset=32768 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:43520 // L -> Reg lro=1344 swapByteOffset=32768 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 6
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:44032 // L -> Reg lro=1344 swapByteOffset=32768 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(5) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:38400 // L -> Reg lro=672 swapByteOffset=32768 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(6) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:44544 // L -> Reg lro=1344 swapByteOffset=32768 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write

/* iter 7 (last) */
MAC_6x6_X0_9_0
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:38656 // L -> Reg lro=672 swapByteOffset=32768 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(3) // 1wait for local write
/* local read increment a */
/* N/A, lro->480 */
MAC_6x6_X0_9_1
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_2
s_nop 6
s_waitcnt lgkmcnt(1) // 1wait for local write

s_barrier //4sync for global read
MAC_6x6_X0_9_3
s_nop 0
/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0 // L -> Reg lro=0 swapByteOffset=32768 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(1) // 1wait for local write

MAC_6x6_X0_9_4
s_nop 0
/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0 // L -> Reg lro=0 swapByteOffset=32768 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 3
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_5
s_nop 6
s_waitcnt lgkmcnt(2) // 1wait for local write

MAC_6x6_X0_9_6
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:512 // L -> Reg lro=0 swapByteOffset=32768 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 2
s_add_u32 s[sgprLoopCounters+0], s[sgprLoopCounters+0], 0x1 // inc counterL
s_waitcnt lgkmcnt(3) // 1wait for local write

MAC_6x6_X0_9_7
s_nop 0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256 // L -> Reg lro=0 swapByteOffset=32768 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
s_nop 2
s_cmp_eq_i32 s[sgprLoopCounters+0], 0x0            // counterL==0
s_waitcnt lgkmcnt(4) // 1wait for local write

MAC_6x6_X0_9_8
s_nop 0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:1024 // L -> Reg lro=0 swapByteOffset=32768 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0
s_cbranch_scc0 label_0001                          // exit LoopL
s_cbranch_scc1 label_0002                          // exit LoopL
s_waitcnt lgkmcnt(3) // 1wait for local write

/******************************************/
/* Unrolled Loop - End 2/2 (final)        */
/******************************************/
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
_v_add_co_u32 v[vgprGlobalReadOffsetA+0], vcc, v[vgprGlobalReadOffsetA+0], 8 // graOffset += 1 * bpe
/* g2l=4, load component 0 */
buffer_load_dwordx2 v[vgprG2LA+4+0:vgprG2LA+4+0+1], v[vgprGlobalReadOffsetA+1], s[sgprSrdA:sgprSrdA+3], 0, offen offset:0 // load one buffer value
/* g2l=4, load component 1 */
buffer_load_dwordx2 v[vgprG2LA+4+2:vgprG2LA+4+2+1], v[vgprGlobalReadOffsetA+1], s[sgprSrdA:sgprSrdA+3], 0, offen offset:8 // load one buffer value
_v_add_co_u32 v[vgprGlobalReadOffsetA+1], vcc, v[vgprGlobalReadOffsetA+1], 8 // graOffset += 1 * bpe

/* global read b */
/* g2l=0, load component 0 */
buffer_load_dwordx2 v[vgprG2LB+0+0:vgprG2LB+0+0+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:0 // load one buffer value
/* g2l=0, load component 1 */
buffer_load_dwordx2 v[vgprG2LB+0+2:vgprG2LB+0+2+1], v[vgprGlobalReadOffsetB+0], s[sgprSrdB:sgprSrdB+3], 0, offen offset:8 // load one buffer value
_v_add_co_u32 v[vgprGlobalReadOffsetB+0], vcc, v[vgprGlobalReadOffsetB+0], 8 // graOffset += 1 * bpe
s_waitcnt vmcnt(0) // 2wait for global read
s_barrier //

/* local write init pointers a */
/* N/A */

/* local write init pointers b */
/* N/A */

/* local write a */
ds_write_b128 v[vgprLocalWriteAddrA], v[vgprG2LA+0:vgprG2LA+0+3] offset:0 // lwoA_0_0_0_0 = (0*LSCA) + (0*LSPA)(*MT0I+PAD) = 0 #7
/* LastPerp.  overhang=3, mask WI>288 */
v_cndmask_b32 v116, 1.0, v[vgprLocalWriteAddrA], s[sgprPerpOverhangVccA:sgprPerpOverhangVccA+1] // Mask load so out-of-gr-tile bounds returns 0. Note 1.0f=0x3f80000 which is large non-neg int
ds_write_b128 v116, v[vgprG2LA+4:vgprG2LA+4+3] offset:7680 // lwoA_0_0_1_0 = (0*LSCA) + (1*LSPA)(*MT0I+PAD) = 7680 #7

/* local write b */
ds_write_b128 v[vgprLocalWriteAddrB], v[vgprG2LB+0:vgprG2LB+0+3] offset:0 // lwoB_0_0_0_0 = (0*LSCB) + (0*LSPB)(*MT1J+PAD) = 0 #8
s_waitcnt lgkmcnt(0) // 5wait for local write
s_barrier //

/* local read reset offsets a */
/* handled internally */
v_and_b32 v[vgprLocalReadAddrA], 0x7fff, v[vgprLocalReadAddrA] // reset Red,Blk -> Red

/* local read reset offsets b */
/* handled internally */
v_and_b32 v[vgprLocalReadAddrB], 0x7fff, v[vgprLocalReadAddrB] // reset Red,Blk -> Red

/* local read init pointers a */

/* local read init pointers b */

/* tail loop: macs */
s_cmp_ge_i32 s[sgprLoopCounters+0], 0x0            // LoopCounterL < EndCounter
s_cbranch_scc1 label_0006                          // don't enter LoopL
label_0005:

/* local read a */
ds_read_b128 v[vgprValuA_X0_I0+0:vgprValuA_X0_I0+0+3], v[vgprLocalReadAddrA] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+4:vgprValuA_X0_I0+4+3], v[vgprLocalReadAddrA] offset:512 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuA_X0_I0+8:vgprValuA_X0_I0+8+3], v[vgprLocalReadAddrA] offset:1024 // L -> Reg lro=0 swapByteOffset=0 ti=32 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read b */
ds_read_b128 v[vgprValuB_X0_I0+0:vgprValuB_X0_I0+0+3], v[vgprLocalReadAddrB] offset:0 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=0 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+4:vgprValuB_X0_I0+4+3], v[vgprLocalReadAddrB] offset:256 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=1 rIdx=0 oIdx=0 buffer=0 iui=0
ds_read_b128 v[vgprValuB_X0_I0+8:vgprValuB_X0_I0+8+3], v[vgprLocalReadAddrB] offset:512 // L -> Reg lro=0 swapByteOffset=0 ti=16 vIdx=2 rIdx=0 oIdx=0 buffer=0 iui=0

/* local read inc a */
s_mov_b32 s61, 0x600                               // inc
_v_add_co_u32 v[vgprLocalReadAddrA], vcc, s61, v[vgprLocalReadAddrA] // lrA += 1536 (LSU*(MT+PAD)*bpe)

/* local read inc b */
s_mov_b32 s61, 0x300                               // inc
_v_add_co_u32 v[vgprLocalReadAddrB], vcc, s61, v[vgprLocalReadAddrB] // lrB += 768 (LSU*(MT+PAD)*bpe)
s_waitcnt lgkmcnt(0) // 4wait for local read
MAC_6x6_X0
s_add_u32 s[sgprLoopCounters+0], s[sgprLoopCounters+0], 0x1 // inc counterL
s_cmp_eq_i32 s[sgprLoopCounters+0], 0x0            // counterL==0
s_cbranch_scc1 label_0006                          // exit LoopL
s_branch label_0005                                // restart tailLoop LoopL
label_0007: // unroll loop odditer exit
label_0006:
s_waitcnt lgkmcnt(0) & vmcnt(0)                    // wait for all summation activity

/* shift vector components d0 */
v_mov_b32 v74, s[sgprWorkGroup0]                   // 
v_mul_i32_i24 v74, -0xc0, v74                      // wg*MT
_v_add_co_u32 v74, vcc, s[sgprSizesFree+0], v74    // wgMT = Size - wg*MT
v_mov_b32 v72, 0xc0                                // MT
v_cmp_lt_u32 s[56:57], v74, v72                    // wgMT < MT
v_cndmask_b32 v74, v72, v74, s[56:57]              // wgMT = (wgMT < MT) ? wgMT : MT
v_lshrrev_b32 v76, 1, v74                          // vectorStaticDiv: v76 = v74 / 2
v_and_b32 v77, 1, v74                              // vectorStaticDiv: v77 = v74 % 2
v_lshrrev_b32 v78, 5, v76                          // vectorStaticDiv: v78 = v76 / 32
v_and_b32 v79, 31, v76                             // vectorStaticDiv: v79 = v76 % 32
v_and_b32 v80, 31, v[vgprSerial]                   // vectorStaticDiv: v80 = v[vgprSerial] % 32
v_lshrrev_b32 v81, 6, v74                          // vectorStaticDiv: v81 = v74 / 64
v_and_b32 v82, 1, v74                              // vectorStaticDiv: v82 = v74 % 2
v_mov_b32 v83, v82                                 // duplicate
v_lshrrev_b32 v82, 1, v83                          // vectorStaticDiv: v82 = v83 / 2
_v_add_co_u32 v82, vcc, v81, v82                   // vId = 2 components
v_cmp_eq_u32 s[56:57], v80, v79                    // mask
v_mov_b32 v72, s56                                 // 
v_mov_b32 v73, s57                                 // 
v_cmp_eq_u32 vcc, v77, 0x1                         // wgMT%VW == 1
s_cbranch_vccnz label_0008                         // shift d0 r=1
s_branch label_0012                                // no shifting

/******************************************/
/* shift d0 r=1                           */
/******************************************/
label_0008:
v_cmp_eq_u32 vcc, v82, 0x0                         // wgMT/(SG*VW) == 0
s_cbranch_vccnz label_0009                         // shift d0, r=1, v=0
v_cmp_eq_u32 vcc, v82, 0x1                         // wgMT/(SG*VW) == 1
s_cbranch_vccnz label_0010                         // shift d0, r=1, v=1
v_cmp_eq_u32 vcc, v82, 0x2                         // wgMT/(SG*VW) == 2
s_cbranch_vccnz label_0011                         // shift d0, r=1, v=2

/* shift d0 r=1 v=0 */
label_0009:
v_cmpx_eq_u32 s[56:57], v80, v79                   // serial % SG == (wgMT/VECTOR_WIDTH)%SG
// src=1, dst=0
v_mov_b32 v0, v2                                   // rC[0+0*VW+0*TT0I] = rC[1+0*VW+0*TT0I]
v_mov_b32 v1, v3                                   // rC[0+0*VW+0*TT0I] = rC[1+0*VW+0*TT0I]
// src=7, dst=6
v_mov_b32 v12, v14                                 // rC[0+0*VW+1*TT0I] = rC[1+0*VW+1*TT0I]
v_mov_b32 v13, v15                                 // rC[0+0*VW+1*TT0I] = rC[1+0*VW+1*TT0I]
// src=13, dst=12
v_mov_b32 v24, v26                                 // rC[0+0*VW+2*TT0I] = rC[1+0*VW+2*TT0I]
v_mov_b32 v25, v27                                 // rC[0+0*VW+2*TT0I] = rC[1+0*VW+2*TT0I]
// src=19, dst=18
v_mov_b32 v36, v38                                 // rC[0+0*VW+3*TT0I] = rC[1+0*VW+3*TT0I]
v_mov_b32 v37, v39                                 // rC[0+0*VW+3*TT0I] = rC[1+0*VW+3*TT0I]
// src=25, dst=24
v_mov_b32 v48, v50                                 // rC[0+0*VW+4*TT0I] = rC[1+0*VW+4*TT0I]
v_mov_b32 v49, v51                                 // rC[0+0*VW+4*TT0I] = rC[1+0*VW+4*TT0I]
// src=31, dst=30
v_mov_b32 v60, v62                                 // rC[0+0*VW+5*TT0I] = rC[1+0*VW+5*TT0I]
v_mov_b32 v61, v63                                 // rC[0+0*VW+5*TT0I] = rC[1+0*VW+5*TT0I]
s_mov_b64 s[56:57], 0xFFFFFFFFFFFFFFFF             // to restore all threads active
s_or_saveexec_b64 vcc, s[56:57]                    // all threads active
s_branch label_0012                                // done shifting

/* shift d0 r=1 v=1 */
label_0010:
v_cmpx_eq_u32 s[56:57], v80, v79                   // serial % SG == (wgMT/VECTOR_WIDTH)%SG
// src=3, dst=2
v_mov_b32 v4, v6                                   // rC[0+1*VW+0*TT0I] = rC[1+1*VW+0*TT0I]
v_mov_b32 v5, v7                                   // rC[0+1*VW+0*TT0I] = rC[1+1*VW+0*TT0I]
// src=9, dst=8
v_mov_b32 v16, v18                                 // rC[0+1*VW+1*TT0I] = rC[1+1*VW+1*TT0I]
v_mov_b32 v17, v19                                 // rC[0+1*VW+1*TT0I] = rC[1+1*VW+1*TT0I]
// src=15, dst=14
v_mov_b32 v28, v30                                 // rC[0+1*VW+2*TT0I] = rC[1+1*VW+2*TT0I]
v_mov_b32 v29, v31                                 // rC[0+1*VW+2*TT0I] = rC[1+1*VW+2*TT0I]
// src=21, dst=20
v_mov_b32 v40, v42                                 // rC[0+1*VW+3*TT0I] = rC[1+1*VW+3*TT0I]
v_mov_b32 v41, v43                                 // rC[0+1*VW+3*TT0I] = rC[1+1*VW+3*TT0I]
// src=27, dst=26
v_mov_b32 v52, v54                                 // rC[0+1*VW+4*TT0I] = rC[1+1*VW+4*TT0I]
v_mov_b32 v53, v55                                 // rC[0+1*VW+4*TT0I] = rC[1+1*VW+4*TT0I]
// src=33, dst=32
v_mov_b32 v64, v66                                 // rC[0+1*VW+5*TT0I] = rC[1+1*VW+5*TT0I]
v_mov_b32 v65, v67                                 // rC[0+1*VW+5*TT0I] = rC[1+1*VW+5*TT0I]
s_mov_b64 s[56:57], 0xFFFFFFFFFFFFFFFF             // to restore all threads active
s_or_saveexec_b64 vcc, s[56:57]                    // all threads active
s_branch label_0012                                // done shifting

/* shift d0 r=1 v=2 */
label_0011:
v_cmpx_eq_u32 s[56:57], v80, v79                   // serial % SG == (wgMT/VECTOR_WIDTH)%SG
// src=5, dst=4
v_mov_b32 v8, v10                                  // rC[0+2*VW+0*TT0I] = rC[1+2*VW+0*TT0I]
v_mov_b32 v9, v11                                  // rC[0+2*VW+0*TT0I] = rC[1+2*VW+0*TT0I]
// src=11, dst=10
v_mov_b32 v20, v22                                 // rC[0+2*VW+1*TT0I] = rC[1+2*VW+1*TT0I]
v_mov_b32 v21, v23                                 // rC[0+2*VW+1*TT0I] = rC[1+2*VW+1*TT0I]
// src=17, dst=16
v_mov_b32 v32, v34                                 // rC[0+2*VW+2*TT0I] = rC[1+2*VW+2*TT0I]
v_mov_b32 v33, v35                                 // rC[0+2*VW+2*TT0I] = rC[1+2*VW+2*TT0I]
// src=23, dst=22
v_mov_b32 v44, v46                                 // rC[0+2*VW+3*TT0I] = rC[1+2*VW+3*TT0I]
v_mov_b32 v45, v47                                 // rC[0+2*VW+3*TT0I] = rC[1+2*VW+3*TT0I]
// src=29, dst=28
v_mov_b32 v56, v58                                 // rC[0+2*VW+4*TT0I] = rC[1+2*VW+4*TT0I]
v_mov_b32 v57, v59                                 // rC[0+2*VW+4*TT0I] = rC[1+2*VW+4*TT0I]
// src=35, dst=34
v_mov_b32 v68, v70                                 // rC[0+2*VW+5*TT0I] = rC[1+2*VW+5*TT0I]
v_mov_b32 v69, v71                                 // rC[0+2*VW+5*TT0I] = rC[1+2*VW+5*TT0I]
s_mov_b64 s[56:57], 0xFFFFFFFFFFFFFFFF             // to restore all threads active
s_or_saveexec_b64 vcc, s[56:57]                    // all threads active
s_branch label_0012                                // done shifting
label_0012: // end shift0

/* shift vector components d1 */
v_mov_b32 v74, s[sgprWorkGroup1]                   // 
v_mul_i32_i24 v74, -0x60, v74                      // wg*MT
_v_add_co_u32 v74, vcc, s[sgprSizesFree+1], v74    // wgMT = Size - wg*MT
v_mov_b32 v72, 0x60                                // MT
v_cmp_lt_u32 s[56:57], v74, v72                    // wgMT < MT
v_cndmask_b32 v74, v72, v74, s[56:57]              // wgMT = (wgMT < MT) ? wgMT : MT
v_lshrrev_b32 v76, 1, v74                          // vectorStaticDiv: v76 = v74 / 2
v_and_b32 v77, 1, v74                              // vectorStaticDiv: v77 = v74 % 2
v_lshrrev_b32 v78, 4, v76                          // vectorStaticDiv: v78 = v76 / 16
v_and_b32 v79, 15, v76                             // vectorStaticDiv: v79 = v76 % 16
v_lshrrev_b32 v80, 5, v[vgprSerial]                // vectorStaticDiv: v80 = v[vgprSerial] / 32
v_and_b32 v81, 15, v80                             // vectorStaticDiv: v81 = v80 % 16
v_lshrrev_b32 v80, 5, v74                          // vectorStaticDiv: v80 = v74 / 32
v_and_b32 v82, 1, v74                              // vectorStaticDiv: v82 = v74 % 2
v_mov_b32 v83, v82                                 // duplicate
v_lshrrev_b32 v82, 1, v83                          // vectorStaticDiv: v82 = v83 / 2
_v_add_co_u32 v82, vcc, v80, v82                   // vId = 2 components
v_cmp_eq_u32 s[56:57], v81, v79                    // mask
v_mov_b32 v72, s56                                 // 
v_mov_b32 v73, s57                                 // 
v_cmp_eq_u32 vcc, v77, 0x1                         // wgMT%VW == 1
s_cbranch_vccnz label_0016                         // shift d1 r=1
s_branch label_0020                                // no shifting

/******************************************/
/* shift d1 r=1                           */
/******************************************/
label_0016:
v_cmp_eq_u32 vcc, v82, 0x0                         // wgMT/(SG*VW) == 0
s_cbranch_vccnz label_0017                         // shift d1, r=1, v=0
v_cmp_eq_u32 vcc, v82, 0x1                         // wgMT/(SG*VW) == 1
s_cbranch_vccnz label_0018                         // shift d1, r=1, v=1
v_cmp_eq_u32 vcc, v82, 0x2                         // wgMT/(SG*VW) == 2
s_cbranch_vccnz label_0019                         // shift d1, r=1, v=2

/* shift d1 r=1 v=0 */
label_0017:
v_cmpx_eq_u32 s[56:57], v81, v79                   // serial % SG == (wgMT/VECTOR_WIDTH)%SG
// src=6, dst=0
v_mov_b32 v0, v12                                  // rC[0+0*TT0I*VW+0*TT0I] = rC[0+0*TT0I*VW+1*TT0I]
v_mov_b32 v1, v13                                  // rC[0+0*TT0I*VW+0*TT0I] = rC[0+0*TT0I*VW+1*TT0I]
// src=7, dst=1
v_mov_b32 v2, v14                                  // rC[1+0*TT0I*VW+0*TT0I] = rC[1+0*TT0I*VW+1*TT0I]
v_mov_b32 v3, v15                                  // rC[1+0*TT0I*VW+0*TT0I] = rC[1+0*TT0I*VW+1*TT0I]
// src=8, dst=2
v_mov_b32 v4, v16                                  // rC[2+0*TT0I*VW+0*TT0I] = rC[2+0*TT0I*VW+1*TT0I]
v_mov_b32 v5, v17                                  // rC[2+0*TT0I*VW+0*TT0I] = rC[2+0*TT0I*VW+1*TT0I]
// src=9, dst=3
v_mov_b32 v6, v18                                  // rC[3+0*TT0I*VW+0*TT0I] = rC[3+0*TT0I*VW+1*TT0I]
v_mov_b32 v7, v19                                  // rC[3+0*TT0I*VW+0*TT0I] = rC[3+0*TT0I*VW+1*TT0I]
// src=10, dst=4
v_mov_b32 v8, v20                                  // rC[4+0*TT0I*VW+0*TT0I] = rC[4+0*TT0I*VW+1*TT0I]
v_mov_b32 v9, v21                                  // rC[4+0*TT0I*VW+0*TT0I] = rC[4+0*TT0I*VW+1*TT0I]
// src=11, dst=5
v_mov_b32 v10, v22                                 // rC[5+0*TT0I*VW+0*TT0I] = rC[5+0*TT0I*VW+1*TT0I]
v_mov_b32 v11, v23                                 // rC[5+0*TT0I*VW+0*TT0I] = rC[5+0*TT0I*VW+1*TT0I]
s_mov_b64 s[56:57], 0xFFFFFFFFFFFFFFFF             // to restore all threads active
s_or_saveexec_b64 vcc, s[56:57]                    // all threads active
s_branch label_0020                                // done shifting

/* shift d1 r=1 v=1 */
label_0018:
v_cmpx_eq_u32 s[56:57], v81, v79                   // serial % SG == (wgMT/VECTOR_WIDTH)%SG
// src=18, dst=12
v_mov_b32 v24, v36                                 // rC[0+1*TT0I*VW+0*TT0I] = rC[0+1*TT0I*VW+1*TT0I]
v_mov_b32 v25, v37                                 // rC[0+1*TT0I*VW+0*TT0I] = rC[0+1*TT0I*VW+1*TT0I]
// src=19, dst=13
v_mov_b32 v26, v38                                 // rC[1+1*TT0I*VW+0*TT0I] = rC[1+1*TT0I*VW+1*TT0I]
v_mov_b32 v27, v39                                 // rC[1+1*TT0I*VW+0*TT0I] = rC[1+1*TT0I*VW+1*TT0I]
// src=20, dst=14
v_mov_b32 v28, v40                                 // rC[2+1*TT0I*VW+0*TT0I] = rC[2+1*TT0I*VW+1*TT0I]
v_mov_b32 v29, v41                                 // rC[2+1*TT0I*VW+0*TT0I] = rC[2+1*TT0I*VW+1*TT0I]
// src=21, dst=15
v_mov_b32 v30, v42                                 // rC[3+1*TT0I*VW+0*TT0I] = rC[3+1*TT0I*VW+1*TT0I]
v_mov_b32 v31, v43                                 // rC[3+1*TT0I*VW+0*TT0I] = rC[3+1*TT0I*VW+1*TT0I]
// src=22, dst=16
v_mov_b32 v32, v44                                 // rC[4+1*TT0I*VW+0*TT0I] = rC[4+1*TT0I*VW+1*TT0I]
v_mov_b32 v33, v45                                 // rC[4+1*TT0I*VW+0*TT0I] = rC[4+1*TT0I*VW+1*TT0I]
// src=23, dst=17
v_mov_b32 v34, v46                                 // rC[5+1*TT0I*VW+0*TT0I] = rC[5+1*TT0I*VW+1*TT0I]
v_mov_b32 v35, v47                                 // rC[5+1*TT0I*VW+0*TT0I] = rC[5+1*TT0I*VW+1*TT0I]
s_mov_b64 s[56:57], 0xFFFFFFFFFFFFFFFF             // to restore all threads active
s_or_saveexec_b64 vcc, s[56:57]                    // all threads active
s_branch label_0020                                // done shifting

/* shift d1 r=1 v=2 */
label_0019:
v_cmpx_eq_u32 s[56:57], v81, v79                   // serial % SG == (wgMT/VECTOR_WIDTH)%SG
// src=30, dst=24
v_mov_b32 v48, v60                                 // rC[0+2*TT0I*VW+0*TT0I] = rC[0+2*TT0I*VW+1*TT0I]
v_mov_b32 v49, v61                                 // rC[0+2*TT0I*VW+0*TT0I] = rC[0+2*TT0I*VW+1*TT0I]
// src=31, dst=25
v_mov_b32 v50, v62                                 // rC[1+2*TT0I*VW+0*TT0I] = rC[1+2*TT0I*VW+1*TT0I]
v_mov_b32 v51, v63                                 // rC[1+2*TT0I*VW+0*TT0I] = rC[1+2*TT0I*VW+1*TT0I]
// src=32, dst=26
v_mov_b32 v52, v64                                 // rC[2+2*TT0I*VW+0*TT0I] = rC[2+2*TT0I*VW+1*TT0I]
v_mov_b32 v53, v65                                 // rC[2+2*TT0I*VW+0*TT0I] = rC[2+2*TT0I*VW+1*TT0I]
// src=33, dst=27
v_mov_b32 v54, v66                                 // rC[3+2*TT0I*VW+0*TT0I] = rC[3+2*TT0I*VW+1*TT0I]
v_mov_b32 v55, v67                                 // rC[3+2*TT0I*VW+0*TT0I] = rC[3+2*TT0I*VW+1*TT0I]
// src=34, dst=28
v_mov_b32 v56, v68                                 // rC[4+2*TT0I*VW+0*TT0I] = rC[4+2*TT0I*VW+1*TT0I]
v_mov_b32 v57, v69                                 // rC[4+2*TT0I*VW+0*TT0I] = rC[4+2*TT0I*VW+1*TT0I]
// src=35, dst=29
v_mov_b32 v58, v70                                 // rC[5+2*TT0I*VW+0*TT0I] = rC[5+2*TT0I*VW+1*TT0I]
v_mov_b32 v59, v71                                 // rC[5+2*TT0I*VW+0*TT0I] = rC[5+2*TT0I*VW+1*TT0I]
s_mov_b64 s[56:57], 0xFFFFFFFFFFFFFFFF             // to restore all threads active
s_or_saveexec_b64 vcc, s[56:57]                    // all threads active
s_branch label_0020                                // done shifting
label_0020: // end shift0

/* not-LocalSplitU: global write indices */
s_mov_b32 s[sgprSrdC+0], s[sgprAddressC+0]         // init SRD base address (lower)
s_mov_b32 s[sgprSrdC+1], s[sgprAddressC+1]         // init SRD base address (upper) + other fields
s_mov_b32 s[sgprSrdC+2], 0x80000000                // 
s_mov_b32 s[sgprSrdC+3], Srd127_96                 // Set bits 127_96 in SRD
v_lshrrev_b32 v73, 5, v[vgprSerial]                // vectorStaticDiv: v73 = v[vgprSerial] / 32
v_and_b32 v72, 31, v[vgprSerial]                   // vectorStaticDiv: v72 = v[vgprSerial] % 32
v_lshlrev_b32 v72, 1, v72                          // staticMultiply: v72 = v72 * 2
v_lshlrev_b32 v73, 1, v73                          // staticMultiply: v73 = v73 * 2

s_mul_i32 s58, 0x60, s[sgprWorkGroup1]             // <- wg1*MT1
s_mul_hi_u32 s57, s58, s[sgprStridesC+0]           // Scale s58 by Stride
s_mul_i32 s56, s58, s[sgprStridesC+0]              // Scale s58 by Stride
s_lshl_b64 s[56:57], s[56:57], 3                   // scale by bpe
s_add_u32 s[sgprSrdC+0], s[sgprSrdC+0], s56        // add lo to SRD
s_addc_u32 s[sgprSrdC+1], s[sgprSrdC+1], s57       // add hi to SRD

s_mul_hi_u32 s57, s[sgprWorkGroup2], s[sgprStridesC+1] // Scale s[sgprWorkGroup2] by Stride
s_mul_i32 s56, s[sgprWorkGroup2], s[sgprStridesC+1] // Scale s[sgprWorkGroup2] by Stride
s_lshl_b64 s[56:57], s[56:57], 3                   // scale by bpe
s_add_u32 s[sgprSrdC+0], s[sgprSrdC+0], s56        // add lo to SRD
s_addc_u32 s[sgprSrdC+1], s[sgprSrdC+1], s57       // add hi to SRD

v_mul_lo_u32 v74, v73, s[sgprStridesC+0]           // rowStart vgpr

s_mul_i32 s56, 0xc0, s[sgprWorkGroup0]             // s56 = wg0*MT0
_v_add_co_u32 v72, vcc, s56, v72                   // coord0 = tid0*VW + wg0*MT0
_v_add_co_u32 v73, vcc, s58, v73                   // coord1 = tid1*VW + wg1*MT1

/* not-LocalSplitU: global write */
s_mov_b32 s56, s[sgprBeta+0]                       // tmp = Beta[0]
s_or_b32 s56, s[sgprBeta+1], s56                   // tmp |= Beta[1] 
s_cmpk_eq_u32 s56, 0x0                             // Beta == 0
s_cbranch_scc0 label_0030                          // Beta is not zero; so jump to B nonzero

s_mov_b32 s56, 0x0                                 // rMT0=0
s_add_u32 s58, -0x1, s[sgprNumWorkGroups0]         // 
s_cmp_lt_u32 s[sgprWorkGroup0], s58                // wg0 < nwg0-1
s_cbranch_scc1 label_0027                          // wg0 < nwg0-1 so skip rMT0 = Size0 % MT0
/* TODO-packed- compare against product of all packed C0 sizes not just SizesFree+0 */
s_mov_b32 s61, 0x0                                 // STATIC_DIV: divisior=192
s_mul_i32 s60, 0x2aa, s[sgprSizesFree+0]           // tmp1 = dividend * magic hi
s_lshl_b64 s[60:61], s[60:61], 0x10                // left shift 16 bits
s_mul_i32 s58, s[sgprSizesFree+0], 0xaaab          // tmp0 = dividend * magic lo
s_add_u32 s60, s58, s60                            // add lo
s_addc_u32 s61, s61, 0x0                           // add hi
s_lshr_b64 s[60:61], s[60:61], 0x21                // tmp1 = (dividend * magic) << shift
s_mov_b32 s58, s60                                 // quotient
s_mul_i32 s60, s58, 0xc0                           // quotient*divisor
s_sub_u32 s56, s[sgprSizesFree+0], s60             // rReg = dividend - quotient*divisor
label_0027:
s_cmpk_gt_u32 s56, 0x0                             // rMT0 > 0
s_cbranch_scc1 label_0029                          // edges required so jump to E1
s_mov_b32 s56, 0x0                                 // rMT1=0
s_add_u32 s58, -0x1, s[sgprNumWorkGroups1]         // 
s_cmp_lt_u32 s[sgprWorkGroup1], s58                // wg1 < nwg1-1
s_cbranch_scc1 label_0028                          // wg1 < nwg1-1 so skip rMT1 = Size1 % MT1
s_mov_b32 s61, 0x0                                 // STATIC_DIV: divisior=96
s_mul_i32 s60, 0x555, s[sgprSizesFree+1]           // tmp1 = dividend * magic hi
s_lshl_b64 s[60:61], s[60:61], 0x10                // left shift 16 bits
s_mul_i32 s58, s[sgprSizesFree+1], 0x5556          // tmp0 = dividend * magic lo
s_add_u32 s60, s58, s60                            // add lo
s_addc_u32 s61, s61, 0x0                           // add hi
s_lshr_b64 s[60:61], s[60:61], 0x21                // tmp1 = (dividend * magic) << shift
s_mov_b32 s58, s60                                 // quotient
s_mul_i32 s60, s58, 0x60                           // quotient*divisor
s_sub_u32 s56, s[sgprSizesFree+1], s60             // rReg = dividend - quotient*divisor
label_0028:
s_cmpk_gt_u32 s56, 0x0                             // rMT1 > 0
s_cbranch_scc1 label_0029                          // edges required so jump to E1
label_0026:

/******************************************/
/* Global Write Batch:(0,0,0,0:vw2); (0,0,1,0:vw2); (0,1,0,0:vw2); (0,1,1,0:vw2); (0,2,0,0:vw2); (0,2,1,0:vw2); (1,0,0,0:vw2); (1,0,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v78, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v79, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v80, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,0,2,0) coordOffset1=0 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v82, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(0,1,2,0) coordOffset1=1 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v83, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v84, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v85, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 1, 0), (0, 1, 0, 0), (0, 1, 1, 0), (0, 2, 0, 0), (0, 2, 1, 0), (1, 0, 0, 0), (1, 0, 1, 0)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[0:3], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[12:15], v79, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[4:7], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[16:19], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[8:11], v82, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[20:23], v83, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[24:27], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[36:39], v85, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Batch:(1,1,0,0:vw2); (1,1,1,0:vw2); (1,2,0,0:vw2); (1,2,1,0:vw2); (2,0,0,0:vw2); (2,0,1,0:vw2); (2,1,0,0:vw2); (2,1,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v78, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v79, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,0,2,0) coordOffset1=32 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v80, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(1,1,2,0) coordOffset1=33 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(2,0,0,0) coordOffset1=64 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=64: d1=2 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v82, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(2,1,0,0) coordOffset1=65 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=65: d1=2 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v83, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(2,0,1,0) coordOffset1=64 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v84, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(2,1,1,0) coordOffset1=65 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v85, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr

/* rC *= alpha batchEements=[(1, 1, 0, 0), (1, 1, 1, 0), (1, 2, 0, 0), (1, 2, 1, 0), (2, 0, 0, 0), (2, 0, 1, 0), (2, 1, 0, 0), (2, 1, 1, 0)] */
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha
v_mul_f64 v[vgprValuC+48:vgprValuC+48+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+48:vgprValuC+48+1] // *= alpha
v_mul_f64 v[vgprValuC+50:vgprValuC+50+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+50:vgprValuC+50+1] // *= alpha
v_mul_f64 v[vgprValuC+60:vgprValuC+60+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+60:vgprValuC+60+1] // *= alpha
v_mul_f64 v[vgprValuC+62:vgprValuC+62+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+62:vgprValuC+62+1] // *= alpha
v_mul_f64 v[vgprValuC+52:vgprValuC+52+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+52:vgprValuC+52+1] // *= alpha
v_mul_f64 v[vgprValuC+54:vgprValuC+54+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+54:vgprValuC+54+1] // *= alpha
v_mul_f64 v[vgprValuC+64:vgprValuC+64+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+64:vgprValuC+64+1] // *= alpha
v_mul_f64 v[vgprValuC+66:vgprValuC+66+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+66:vgprValuC+66+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[28:31], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[40:43], v79, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[32:35], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[44:47], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[48:51], v82, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[60:63], v83, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[52:55], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[64:67], v85, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Batch:(2,2,0,0:vw2); (2,2,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(2,0,2,0) coordOffset1=64 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v78, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* (d1,vc1,d0,vc0)=(2,1,2,0) coordOffset1=65 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v79, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr

/* rC *= alpha batchEements=[(2, 2, 0, 0), (2, 2, 1, 0)] */
v_mul_f64 v[vgprValuC+56:vgprValuC+56+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+56:vgprValuC+56+1] // *= alpha
v_mul_f64 v[vgprValuC+58:vgprValuC+58+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+58:vgprValuC+58+1] // *= alpha
v_mul_f64 v[vgprValuC+68:vgprValuC+68+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+68:vgprValuC+68+1] // *= alpha
v_mul_f64 v[vgprValuC+70:vgprValuC+70+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+70:vgprValuC+70+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx4 v[56:59], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx4 v[68:71], v79, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0037                                // jump to end
label_0029:

/******************************************/
/* Global Write Edge Batch:(0,0,0,0:vw1); (0,0,0,1:vw1); (0,0,1,0:vw1); (0,0,1,1:vw1); (0,1,0,0:vw1); (0,1,0,1:vw1); (0,1,1,0:vw1); (0,1,1,1:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v73 directly */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v78, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v78, -1, v78, s[62:63]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,0,1) coordOffset1=0 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v79, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v79, -1, v79, s[64:65]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v80, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v80, -1, v80, s[66:67]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,0,1) coordOffset1=1 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v81, -1, v81, s[68:69]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v73 directly */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v82, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v82, -1, v82, s[70:71]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,1,1) coordOffset1=0 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v83, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[72:73], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v83, -1, v83, s[72:73]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v84, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[74:75], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v84, -1, v84, s[74:75]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,1,1) coordOffset1=1 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v85, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[76:77], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v85, -1, v85, s[76:77]               // clip if OOB. offset

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 0, 1), (0, 0, 1, 0), (0, 0, 1, 1), (0, 1, 0, 0), (0, 1, 0, 1), (0, 1, 1, 0), (0, 1, 1, 1)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx2 v[0:1], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[2:3], v79, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[12:13], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[14:15], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[4:5], v82, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[6:7], v83, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[16:17], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[18:19], v85, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Edge Batch:(0,2,0,0:vw1); (0,2,0,1:vw1); (0,2,1,0:vw1); (0,2,1,1:vw1); (1,0,0,0:vw1); (1,0,0,1:vw1); (1,0,1,0:vw1); (1,0,1,1:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,2,0) coordOffset1=0 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v73 directly */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v78, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v78, -1, v78, s[62:63]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,0,2,1) coordOffset1=0 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v79, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v79, -1, v79, s[64:65]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,2,0) coordOffset1=1 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v80, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v80, -1, v80, s[66:67]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(0,1,2,1) coordOffset1=1 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v81, -1, v81, s[68:69]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v82, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v82, -1, v82, s[70:71]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,0,0,1) coordOffset1=32 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v83, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[72:73], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v83, -1, v83, s[72:73]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v84, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[74:75], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v84, -1, v84, s[74:75]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,0,1) coordOffset1=33 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v85, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[76:77], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v85, -1, v85, s[76:77]               // clip if OOB. offset

/* rC *= alpha batchEements=[(0, 2, 0, 0), (0, 2, 0, 1), (0, 2, 1, 0), (0, 2, 1, 1), (1, 0, 0, 0), (1, 0, 0, 1), (1, 0, 1, 0), (1, 0, 1, 1)] */
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx2 v[8:9], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[10:11], v79, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[20:21], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[22:23], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[24:25], v82, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[26:27], v83, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[36:37], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[38:39], v85, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Edge Batch:(1,1,0,0:vw1); (1,1,0,1:vw1); (1,1,1,0:vw1); (1,1,1,1:vw1); (1,2,0,0:vw1); (1,2,0,1:vw1); (1,2,1,0:vw1); (1,2,1,1:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v78, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v78, -1, v78, s[62:63]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,0,1,1) coordOffset1=32 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v79, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v79, -1, v79, s[64:65]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v80, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v80, -1, v80, s[66:67]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,1,1) coordOffset1=33 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v81, -1, v81, s[68:69]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,0,2,0) coordOffset1=32 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v82, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v82, -1, v82, s[70:71]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,0,2,1) coordOffset1=32 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v83, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[72:73], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v83, -1, v83, s[72:73]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,2,0) coordOffset1=33 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v84, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[74:75], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v84, -1, v84, s[74:75]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(1,1,2,1) coordOffset1=33 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v85, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[76:77], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v85, -1, v85, s[76:77]               // clip if OOB. offset

/* rC *= alpha batchEements=[(1, 1, 0, 0), (1, 1, 0, 1), (1, 1, 1, 0), (1, 1, 1, 1), (1, 2, 0, 0), (1, 2, 0, 1), (1, 2, 1, 0), (1, 2, 1, 1)] */
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx2 v[28:29], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[30:31], v79, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[40:41], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[42:43], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[32:33], v82, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[34:35], v83, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[44:45], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[46:47], v85, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Edge Batch:(2,0,0,0:vw1); (2,0,0,1:vw1); (2,0,1,0:vw1); (2,0,1,1:vw1); (2,1,0,0:vw1); (2,1,0,1:vw1); (2,1,1,0:vw1); (2,1,1,1:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(2,0,0,0) coordOffset1=64 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=64: d1=2 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 64                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v78, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v78, -1, v78, s[62:63]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,0,0,1) coordOffset1=64 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v79, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v79, -1, v79, s[64:65]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,1,0,0) coordOffset1=65 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=65: d1=2 vc1=1 */
s_mov_b32 s56, 65                                  // coordOffset1 d1=0 vc1=0
_v_add_co_u32 v77, vcc, v73, s56                   // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v80, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v80, -1, v80, s[66:67]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,1,0,1) coordOffset1=65 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v81, -1, v81, s[68:69]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,0,1,0) coordOffset1=64 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 64                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v82, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v82, -1, v82, s[70:71]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,0,1,1) coordOffset1=64 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v83, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[72:73], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v83, -1, v83, s[72:73]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,1,1,0) coordOffset1=65 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
s_mov_b32 s56, 65                                  // coordOffset1 d1=1 vc1=0
_v_add_co_u32 v77, vcc, v73, s56                   // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v84, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[74:75], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v84, -1, v84, s[74:75]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,1,1,1) coordOffset1=65 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v85, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[76:77], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v85, -1, v85, s[76:77]               // clip if OOB. offset

/* rC *= alpha batchEements=[(2, 0, 0, 0), (2, 0, 0, 1), (2, 0, 1, 0), (2, 0, 1, 1), (2, 1, 0, 0), (2, 1, 0, 1), (2, 1, 1, 0), (2, 1, 1, 1)] */
v_mul_f64 v[vgprValuC+48:vgprValuC+48+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+48:vgprValuC+48+1] // *= alpha
v_mul_f64 v[vgprValuC+50:vgprValuC+50+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+50:vgprValuC+50+1] // *= alpha
v_mul_f64 v[vgprValuC+60:vgprValuC+60+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+60:vgprValuC+60+1] // *= alpha
v_mul_f64 v[vgprValuC+62:vgprValuC+62+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+62:vgprValuC+62+1] // *= alpha
v_mul_f64 v[vgprValuC+52:vgprValuC+52+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+52:vgprValuC+52+1] // *= alpha
v_mul_f64 v[vgprValuC+54:vgprValuC+54+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+54:vgprValuC+54+1] // *= alpha
v_mul_f64 v[vgprValuC+64:vgprValuC+64+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+64:vgprValuC+64+1] // *= alpha
v_mul_f64 v[vgprValuC+66:vgprValuC+66+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+66:vgprValuC+66+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx2 v[48:49], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[50:51], v79, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[60:61], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[62:63], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[52:53], v82, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[54:55], v83, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[64:65], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[66:67], v85, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Edge Batch:(2,2,0,0:vw1); (2,2,0,1:vw1); (2,2,1,0:vw1); (2,2,1,1:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(2,0,2,0) coordOffset1=64 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 64                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v78, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v78, -1, v78, s[62:63]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,0,2,1) coordOffset1=64 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v79, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v79, -1, v79, s[64:65]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,1,2,0) coordOffset1=65 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
s_mov_b32 s56, 65                                  // coordOffset1 d1=2 vc1=0
_v_add_co_u32 v77, vcc, v73, s56                   // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v80, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v80, -1, v80, s[66:67]               // clip if OOB. offset
/* (d1,vc1,d0,vc0)=(2,1,2,1) coordOffset1=65 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v81, -1, v81, s[68:69]               // clip if OOB. offset

/* rC *= alpha batchEements=[(2, 2, 0, 0), (2, 2, 0, 1), (2, 2, 1, 0), (2, 2, 1, 1)] */
v_mul_f64 v[vgprValuC+56:vgprValuC+56+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+56:vgprValuC+56+1] // *= alpha
v_mul_f64 v[vgprValuC+58:vgprValuC+58+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+58:vgprValuC+58+1] // *= alpha
v_mul_f64 v[vgprValuC+68:vgprValuC+68+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+68:vgprValuC+68+1] // *= alpha
v_mul_f64 v[vgprValuC+70:vgprValuC+70+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+70:vgprValuC+70+1] // *= alpha

/* apply mask, calc new C and issue write */
buffer_store_dwordx2 v[56:57], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[58:59], v79, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[68:69], v80, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
buffer_store_dwordx2 v[70:71], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0037                                // jump to end
label_0030:
s_mov_b32 s56, 0x0                                 // rMT0=0
s_add_u32 s58, -0x1, s[sgprNumWorkGroups0]         // 
s_cmp_lt_u32 s[sgprWorkGroup0], s58                // wg0 < nwg0-1
s_cbranch_scc1 label_0034                          // wg0 < nwg0-1 so skip rMT0 = Size0 % MT0
/* TODO-packed- compare against product of all packed C0 sizes not just SizesFree+0 */
s_mov_b32 s61, 0x0                                 // STATIC_DIV: divisior=192
s_mul_i32 s60, 0x2aa, s[sgprSizesFree+0]           // tmp1 = dividend * magic hi
s_lshl_b64 s[60:61], s[60:61], 0x10                // left shift 16 bits
s_mul_i32 s58, s[sgprSizesFree+0], 0xaaab          // tmp0 = dividend * magic lo
s_add_u32 s60, s58, s60                            // add lo
s_addc_u32 s61, s61, 0x0                           // add hi
s_lshr_b64 s[60:61], s[60:61], 0x21                // tmp1 = (dividend * magic) << shift
s_mov_b32 s58, s60                                 // quotient
s_mul_i32 s60, s58, 0xc0                           // quotient*divisor
s_sub_u32 s56, s[sgprSizesFree+0], s60             // rReg = dividend - quotient*divisor
label_0034:
s_cmpk_gt_u32 s56, 0x0                             // rMT0 > 0
s_cbranch_scc1 label_0036                          // edges required so jump to E1
s_mov_b32 s56, 0x0                                 // rMT1=0
s_add_u32 s58, -0x1, s[sgprNumWorkGroups1]         // 
s_cmp_lt_u32 s[sgprWorkGroup1], s58                // wg1 < nwg1-1
s_cbranch_scc1 label_0035                          // wg1 < nwg1-1 so skip rMT1 = Size1 % MT1
s_mov_b32 s61, 0x0                                 // STATIC_DIV: divisior=96
s_mul_i32 s60, 0x555, s[sgprSizesFree+1]           // tmp1 = dividend * magic hi
s_lshl_b64 s[60:61], s[60:61], 0x10                // left shift 16 bits
s_mul_i32 s58, s[sgprSizesFree+1], 0x5556          // tmp0 = dividend * magic lo
s_add_u32 s60, s58, s60                            // add lo
s_addc_u32 s61, s61, 0x0                           // add hi
s_lshr_b64 s[60:61], s[60:61], 0x21                // tmp1 = (dividend * magic) << shift
s_mov_b32 s58, s60                                 // quotient
s_mul_i32 s60, s58, 0x60                           // quotient*divisor
s_sub_u32 s56, s[sgprSizesFree+1], s60             // rReg = dividend - quotient*divisor
label_0035:
s_cmpk_gt_u32 s56, 0x0                             // rMT1 > 0
s_cbranch_scc1 label_0036                          // edges required so jump to E1
label_0033:

/******************************************/
/* Global Write Beta Batch:(0,0,0,0:vw2); (0,0,1,0:vw2); (0,1,0,0:vw2); (0,1,1,0:vw2); (0,2,0,0:vw2); (0,2,1,0:vw2); (1,0,0,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v78, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[79:82], v78, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v83, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[84:87], v83, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v88, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[89:92], v88, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v93, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[94:97], v93, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,2,0) coordOffset1=0 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v98, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[99:102], v98, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,2,0) coordOffset1=1 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v103, v75, v76, 0x3                // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[104:107], v103, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v108, v75, v72, 0x3                // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[109:112], v108, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 1, 0), (0, 1, 0, 0), (0, 1, 1, 0), (0, 2, 0, 0), (0, 2, 1, 0), (1, 0, 0, 0)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+0:vgprValuC+0+1], v[79:80], s[sgprBeta:sgprBeta+1], v[vgprValuC+0:vgprValuC+0+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+2:vgprValuC+2+1], v[81:82], s[sgprBeta:sgprBeta+1], v[vgprValuC+2:vgprValuC+2+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[0:3], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+12:vgprValuC+12+1], v[84:85], s[sgprBeta:sgprBeta+1], v[vgprValuC+12:vgprValuC+12+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+14:vgprValuC+14+1], v[86:87], s[sgprBeta:sgprBeta+1], v[vgprValuC+14:vgprValuC+14+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[12:15], v83, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+4:vgprValuC+4+1], v[89:90], s[sgprBeta:sgprBeta+1], v[vgprValuC+4:vgprValuC+4+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+6:vgprValuC+6+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+6:vgprValuC+6+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[4:7], v88, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+16:vgprValuC+16+1], v[94:95], s[sgprBeta:sgprBeta+1], v[vgprValuC+16:vgprValuC+16+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+18:vgprValuC+18+1], v[96:97], s[sgprBeta:sgprBeta+1], v[vgprValuC+18:vgprValuC+18+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[16:19], v93, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+8:vgprValuC+8+1], v[99:100], s[sgprBeta:sgprBeta+1], v[vgprValuC+8:vgprValuC+8+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+10:vgprValuC+10+1], v[101:102], s[sgprBeta:sgprBeta+1], v[vgprValuC+10:vgprValuC+10+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[8:11], v98, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+20:vgprValuC+20+1], v[104:105], s[sgprBeta:sgprBeta+1], v[vgprValuC+20:vgprValuC+20+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+22:vgprValuC+22+1], v[106:107], s[sgprBeta:sgprBeta+1], v[vgprValuC+22:vgprValuC+22+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[20:23], v103, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+24:vgprValuC+24+1], v[109:110], s[sgprBeta:sgprBeta+1], v[vgprValuC+24:vgprValuC+24+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+26:vgprValuC+26+1], v[111:112], s[sgprBeta:sgprBeta+1], v[vgprValuC+26:vgprValuC+26+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[24:27], v108, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Batch:(1,0,1,0:vw2); (1,1,0,0:vw2); (1,1,1,0:vw2); (1,2,0,0:vw2); (1,2,1,0:vw2); (2,0,0,0:vw2); (2,0,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v78, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[79:82], v78, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v83, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[84:87], v83, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v88, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[89:92], v88, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,2,0) coordOffset1=32 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v93, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[94:97], v93, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,2,0) coordOffset1=33 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v98, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[99:102], v98, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,0,0,0) coordOffset1=64 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=64: d1=2 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v103, v75, v72, 0x3                // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[104:107], v103, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,0,0) coordOffset1=65 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=65: d1=2 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v108, v75, v72, 0x3                // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[109:112], v108, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(1, 0, 1, 0), (1, 1, 0, 0), (1, 1, 1, 0), (1, 2, 0, 0), (1, 2, 1, 0), (2, 0, 0, 0), (2, 0, 1, 0)] */
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha
v_mul_f64 v[vgprValuC+48:vgprValuC+48+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+48:vgprValuC+48+1] // *= alpha
v_mul_f64 v[vgprValuC+50:vgprValuC+50+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+50:vgprValuC+50+1] // *= alpha
v_mul_f64 v[vgprValuC+60:vgprValuC+60+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+60:vgprValuC+60+1] // *= alpha
v_mul_f64 v[vgprValuC+62:vgprValuC+62+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+62:vgprValuC+62+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+36:vgprValuC+36+1], v[79:80], s[sgprBeta:sgprBeta+1], v[vgprValuC+36:vgprValuC+36+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+38:vgprValuC+38+1], v[81:82], s[sgprBeta:sgprBeta+1], v[vgprValuC+38:vgprValuC+38+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[36:39], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+28:vgprValuC+28+1], v[84:85], s[sgprBeta:sgprBeta+1], v[vgprValuC+28:vgprValuC+28+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+30:vgprValuC+30+1], v[86:87], s[sgprBeta:sgprBeta+1], v[vgprValuC+30:vgprValuC+30+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[28:31], v83, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+40:vgprValuC+40+1], v[89:90], s[sgprBeta:sgprBeta+1], v[vgprValuC+40:vgprValuC+40+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+42:vgprValuC+42+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+42:vgprValuC+42+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[40:43], v88, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+32:vgprValuC+32+1], v[94:95], s[sgprBeta:sgprBeta+1], v[vgprValuC+32:vgprValuC+32+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+34:vgprValuC+34+1], v[96:97], s[sgprBeta:sgprBeta+1], v[vgprValuC+34:vgprValuC+34+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[32:35], v93, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+44:vgprValuC+44+1], v[99:100], s[sgprBeta:sgprBeta+1], v[vgprValuC+44:vgprValuC+44+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+46:vgprValuC+46+1], v[101:102], s[sgprBeta:sgprBeta+1], v[vgprValuC+46:vgprValuC+46+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[44:47], v98, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+48:vgprValuC+48+1], v[104:105], s[sgprBeta:sgprBeta+1], v[vgprValuC+48:vgprValuC+48+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+50:vgprValuC+50+1], v[106:107], s[sgprBeta:sgprBeta+1], v[vgprValuC+50:vgprValuC+50+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[48:51], v103, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+60:vgprValuC+60+1], v[109:110], s[sgprBeta:sgprBeta+1], v[vgprValuC+60:vgprValuC+60+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+62:vgprValuC+62+1], v[111:112], s[sgprBeta:sgprBeta+1], v[vgprValuC+62:vgprValuC+62+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[60:63], v108, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Batch:(2,1,0,0:vw2); (2,1,1,0:vw2); (2,2,0,0:vw2); (2,2,1,0:vw2) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(2,0,1,0) coordOffset1=64 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v78, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[79:82], v78, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,1,0) coordOffset1=65 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v83, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[84:87], v83, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,0,2,0) coordOffset1=64 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v88, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[89:92], v88, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,2,0) coordOffset1=65 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v93, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
buffer_load_dwordx4 v[94:97], v93, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(2, 1, 0, 0), (2, 1, 1, 0), (2, 2, 0, 0), (2, 2, 1, 0)] */
v_mul_f64 v[vgprValuC+52:vgprValuC+52+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+52:vgprValuC+52+1] // *= alpha
v_mul_f64 v[vgprValuC+54:vgprValuC+54+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+54:vgprValuC+54+1] // *= alpha
v_mul_f64 v[vgprValuC+64:vgprValuC+64+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+64:vgprValuC+64+1] // *= alpha
v_mul_f64 v[vgprValuC+66:vgprValuC+66+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+66:vgprValuC+66+1] // *= alpha
v_mul_f64 v[vgprValuC+56:vgprValuC+56+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+56:vgprValuC+56+1] // *= alpha
v_mul_f64 v[vgprValuC+58:vgprValuC+58+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+58:vgprValuC+58+1] // *= alpha
v_mul_f64 v[vgprValuC+68:vgprValuC+68+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+68:vgprValuC+68+1] // *= alpha
v_mul_f64 v[vgprValuC+70:vgprValuC+70+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+70:vgprValuC+70+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+52:vgprValuC+52+1], v[79:80], s[sgprBeta:sgprBeta+1], v[vgprValuC+52:vgprValuC+52+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+54:vgprValuC+54+1], v[81:82], s[sgprBeta:sgprBeta+1], v[vgprValuC+54:vgprValuC+54+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[52:55], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+64:vgprValuC+64+1], v[84:85], s[sgprBeta:sgprBeta+1], v[vgprValuC+64:vgprValuC+64+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+66:vgprValuC+66+1], v[86:87], s[sgprBeta:sgprBeta+1], v[vgprValuC+66:vgprValuC+66+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[64:67], v83, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+56:vgprValuC+56+1], v[89:90], s[sgprBeta:sgprBeta+1], v[vgprValuC+56:vgprValuC+56+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+58:vgprValuC+58+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+58:vgprValuC+58+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[56:59], v88, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+68:vgprValuC+68+1], v[94:95], s[sgprBeta:sgprBeta+1], v[vgprValuC+68:vgprValuC+68+1] // finalSum = sum*alpha + C*beta
v_fma_f64 v[vgprValuC+70:vgprValuC+70+1], v[96:97], s[sgprBeta:sgprBeta+1], v[vgprValuC+70:vgprValuC+70+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx4 v[68:71], v93, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0037                                // jump to end
label_0036:

/******************************************/
/* Global Write Beta Edge Batch:(0,0,0,0:vw1); (0,0,0,1:vw1); (0,0,1,0:vw1); (0,0,1,1:vw1); (0,1,0,0:vw1); (0,1,0,1:vw1); (0,1,1,0:vw1); (0,1,1,1:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,0,0) coordOffset1=0 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v73 directly */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v78, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v78, -1, v78, s[62:63]               // clip if OOB. offset
buffer_load_dwordx2 v[79:80], v78, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,0,1) coordOffset1=0 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v81, -1, v81, s[64:65]               // clip if OOB. offset
buffer_load_dwordx2 v[82:83], v81, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,0,0) coordOffset1=1 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v84, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v84, -1, v84, s[66:67]               // clip if OOB. offset
buffer_load_dwordx2 v[85:86], v84, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,0,1) coordOffset1=1 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v87, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v87, -1, v87, s[68:69]               // clip if OOB. offset
buffer_load_dwordx2 v[88:89], v87, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,1,0) coordOffset1=0 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v73 directly */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v90, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v90, -1, v90, s[70:71]               // clip if OOB. offset
buffer_load_dwordx2 v[91:92], v90, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,1,1) coordOffset1=0 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v93, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[72:73], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v93, -1, v93, s[72:73]               // clip if OOB. offset
buffer_load_dwordx2 v[94:95], v93, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,1,0) coordOffset1=1 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v96, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[74:75], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v96, -1, v96, s[74:75]               // clip if OOB. offset
buffer_load_dwordx2 v[97:98], v96, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,1,1) coordOffset1=1 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v99, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[76:77], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v99, -1, v99, s[76:77]               // clip if OOB. offset
buffer_load_dwordx2 v[100:101], v99, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(0, 0, 0, 0), (0, 0, 0, 1), (0, 0, 1, 0), (0, 0, 1, 1), (0, 1, 0, 0), (0, 1, 0, 1), (0, 1, 1, 0), (0, 1, 1, 1)] */
v_mul_f64 v[vgprValuC+0:vgprValuC+0+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+0:vgprValuC+0+1] // *= alpha
v_mul_f64 v[vgprValuC+2:vgprValuC+2+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+2:vgprValuC+2+1] // *= alpha
v_mul_f64 v[vgprValuC+12:vgprValuC+12+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+12:vgprValuC+12+1] // *= alpha
v_mul_f64 v[vgprValuC+14:vgprValuC+14+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+14:vgprValuC+14+1] // *= alpha
v_mul_f64 v[vgprValuC+4:vgprValuC+4+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+4:vgprValuC+4+1] // *= alpha
v_mul_f64 v[vgprValuC+6:vgprValuC+6+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+6:vgprValuC+6+1] // *= alpha
v_mul_f64 v[vgprValuC+16:vgprValuC+16+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+16:vgprValuC+16+1] // *= alpha
v_mul_f64 v[vgprValuC+18:vgprValuC+18+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+18:vgprValuC+18+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+0:vgprValuC+0+1], v[79:80], s[sgprBeta:sgprBeta+1], v[vgprValuC+0:vgprValuC+0+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[0:1], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+2:vgprValuC+2+1], v[82:83], s[sgprBeta:sgprBeta+1], v[vgprValuC+2:vgprValuC+2+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[2:3], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+12:vgprValuC+12+1], v[85:86], s[sgprBeta:sgprBeta+1], v[vgprValuC+12:vgprValuC+12+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[12:13], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+14:vgprValuC+14+1], v[88:89], s[sgprBeta:sgprBeta+1], v[vgprValuC+14:vgprValuC+14+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[14:15], v87, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+4:vgprValuC+4+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+4:vgprValuC+4+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[4:5], v90, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+6:vgprValuC+6+1], v[94:95], s[sgprBeta:sgprBeta+1], v[vgprValuC+6:vgprValuC+6+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[6:7], v93, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+16:vgprValuC+16+1], v[97:98], s[sgprBeta:sgprBeta+1], v[vgprValuC+16:vgprValuC+16+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[16:17], v96, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+18:vgprValuC+18+1], v[100:101], s[sgprBeta:sgprBeta+1], v[vgprValuC+18:vgprValuC+18+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[18:19], v99, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Edge Batch:(0,2,0,0:vw1); (0,2,0,1:vw1); (0,2,1,0:vw1); (0,2,1,1:vw1); (1,0,0,0:vw1); (1,0,0,1:vw1); (1,0,1,0:vw1); (1,0,1,1:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(0,0,2,0) coordOffset1=0 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=0: d1=0 vc1=0 */
/* coordOffset1=0, use coordVgpr1=v73 directly */
v_mov_b32 v75, v74                                 // rowPtr <- rowStart (first row)
_v_add_lshl_u32 v78, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v78, -1, v78, s[62:63]               // clip if OOB. offset
buffer_load_dwordx2 v[79:80], v78, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,0,2,1) coordOffset1=0 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v73, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v81, -1, v81, s[64:65]               // clip if OOB. offset
buffer_load_dwordx2 v[82:83], v81, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,2,0) coordOffset1=1 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=1: d1=0 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 1                     // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v84, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v84, -1, v84, s[66:67]               // clip if OOB. offset
buffer_load_dwordx2 v[85:86], v84, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(0,1,2,1) coordOffset1=1 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v87, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v87, -1, v87, s[68:69]               // clip if OOB. offset
buffer_load_dwordx2 v[88:89], v87, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,0,0) coordOffset1=32 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v90, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v90, -1, v90, s[70:71]               // clip if OOB. offset
buffer_load_dwordx2 v[91:92], v90, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,0,1) coordOffset1=32 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v93, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[72:73], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v93, -1, v93, s[72:73]               // clip if OOB. offset
buffer_load_dwordx2 v[94:95], v93, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,0,0) coordOffset1=33 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v96, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[74:75], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v96, -1, v96, s[74:75]               // clip if OOB. offset
buffer_load_dwordx2 v[97:98], v96, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,0,1) coordOffset1=33 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v99, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[76:77], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v99, -1, v99, s[76:77]               // clip if OOB. offset
buffer_load_dwordx2 v[100:101], v99, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(0, 2, 0, 0), (0, 2, 0, 1), (0, 2, 1, 0), (0, 2, 1, 1), (1, 0, 0, 0), (1, 0, 0, 1), (1, 0, 1, 0), (1, 0, 1, 1)] */
v_mul_f64 v[vgprValuC+8:vgprValuC+8+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+8:vgprValuC+8+1] // *= alpha
v_mul_f64 v[vgprValuC+10:vgprValuC+10+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+10:vgprValuC+10+1] // *= alpha
v_mul_f64 v[vgprValuC+20:vgprValuC+20+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+20:vgprValuC+20+1] // *= alpha
v_mul_f64 v[vgprValuC+22:vgprValuC+22+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+22:vgprValuC+22+1] // *= alpha
v_mul_f64 v[vgprValuC+24:vgprValuC+24+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+24:vgprValuC+24+1] // *= alpha
v_mul_f64 v[vgprValuC+26:vgprValuC+26+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+26:vgprValuC+26+1] // *= alpha
v_mul_f64 v[vgprValuC+36:vgprValuC+36+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+36:vgprValuC+36+1] // *= alpha
v_mul_f64 v[vgprValuC+38:vgprValuC+38+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+38:vgprValuC+38+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+8:vgprValuC+8+1], v[79:80], s[sgprBeta:sgprBeta+1], v[vgprValuC+8:vgprValuC+8+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[8:9], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+10:vgprValuC+10+1], v[82:83], s[sgprBeta:sgprBeta+1], v[vgprValuC+10:vgprValuC+10+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[10:11], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+20:vgprValuC+20+1], v[85:86], s[sgprBeta:sgprBeta+1], v[vgprValuC+20:vgprValuC+20+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[20:21], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+22:vgprValuC+22+1], v[88:89], s[sgprBeta:sgprBeta+1], v[vgprValuC+22:vgprValuC+22+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[22:23], v87, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+24:vgprValuC+24+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+24:vgprValuC+24+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[24:25], v90, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+26:vgprValuC+26+1], v[94:95], s[sgprBeta:sgprBeta+1], v[vgprValuC+26:vgprValuC+26+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[26:27], v93, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+36:vgprValuC+36+1], v[97:98], s[sgprBeta:sgprBeta+1], v[vgprValuC+36:vgprValuC+36+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[36:37], v96, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+38:vgprValuC+38+1], v[100:101], s[sgprBeta:sgprBeta+1], v[vgprValuC+38:vgprValuC+38+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[38:39], v99, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Edge Batch:(1,1,0,0:vw1); (1,1,0,1:vw1); (1,1,1,0:vw1); (1,1,1,1:vw1); (1,2,0,0:vw1); (1,2,0,1:vw1); (1,2,1,0:vw1); (1,2,1,1:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(1,0,1,0) coordOffset1=32 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v78, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v78, -1, v78, s[62:63]               // clip if OOB. offset
buffer_load_dwordx2 v[79:80], v78, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,1,1) coordOffset1=32 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v81, -1, v81, s[64:65]               // clip if OOB. offset
buffer_load_dwordx2 v[82:83], v81, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,1,0) coordOffset1=33 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v84, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v84, -1, v84, s[66:67]               // clip if OOB. offset
buffer_load_dwordx2 v[85:86], v84, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,1,1) coordOffset1=33 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v87, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v87, -1, v87, s[68:69]               // clip if OOB. offset
buffer_load_dwordx2 v[88:89], v87, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,2,0) coordOffset1=32 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=32: d1=1 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 32                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 32               // scale StrideC *= coordOffset1(32)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v90, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v90, -1, v90, s[70:71]               // clip if OOB. offset
buffer_load_dwordx2 v[91:92], v90, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,0,2,1) coordOffset1=32 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v93, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[72:73], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v93, -1, v93, s[72:73]               // clip if OOB. offset
buffer_load_dwordx2 v[94:95], v93, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,2,0) coordOffset1=33 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=33: d1=1 vc1=1 */
_v_add_co_u32 v77, vcc, v73, 33                    // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v96, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[74:75], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v96, -1, v96, s[74:75]               // clip if OOB. offset
buffer_load_dwordx2 v[97:98], v96, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(1,1,2,1) coordOffset1=33 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v99, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[76:77], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v99, -1, v99, s[76:77]               // clip if OOB. offset
buffer_load_dwordx2 v[100:101], v99, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(1, 1, 0, 0), (1, 1, 0, 1), (1, 1, 1, 0), (1, 1, 1, 1), (1, 2, 0, 0), (1, 2, 0, 1), (1, 2, 1, 0), (1, 2, 1, 1)] */
v_mul_f64 v[vgprValuC+28:vgprValuC+28+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+28:vgprValuC+28+1] // *= alpha
v_mul_f64 v[vgprValuC+30:vgprValuC+30+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+30:vgprValuC+30+1] // *= alpha
v_mul_f64 v[vgprValuC+40:vgprValuC+40+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+40:vgprValuC+40+1] // *= alpha
v_mul_f64 v[vgprValuC+42:vgprValuC+42+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+42:vgprValuC+42+1] // *= alpha
v_mul_f64 v[vgprValuC+32:vgprValuC+32+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+32:vgprValuC+32+1] // *= alpha
v_mul_f64 v[vgprValuC+34:vgprValuC+34+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+34:vgprValuC+34+1] // *= alpha
v_mul_f64 v[vgprValuC+44:vgprValuC+44+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+44:vgprValuC+44+1] // *= alpha
v_mul_f64 v[vgprValuC+46:vgprValuC+46+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+46:vgprValuC+46+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+28:vgprValuC+28+1], v[79:80], s[sgprBeta:sgprBeta+1], v[vgprValuC+28:vgprValuC+28+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[28:29], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+30:vgprValuC+30+1], v[82:83], s[sgprBeta:sgprBeta+1], v[vgprValuC+30:vgprValuC+30+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[30:31], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+40:vgprValuC+40+1], v[85:86], s[sgprBeta:sgprBeta+1], v[vgprValuC+40:vgprValuC+40+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[40:41], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+42:vgprValuC+42+1], v[88:89], s[sgprBeta:sgprBeta+1], v[vgprValuC+42:vgprValuC+42+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[42:43], v87, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+32:vgprValuC+32+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+32:vgprValuC+32+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[32:33], v90, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+34:vgprValuC+34+1], v[94:95], s[sgprBeta:sgprBeta+1], v[vgprValuC+34:vgprValuC+34+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[34:35], v93, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+44:vgprValuC+44+1], v[97:98], s[sgprBeta:sgprBeta+1], v[vgprValuC+44:vgprValuC+44+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[44:45], v96, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+46:vgprValuC+46+1], v[100:101], s[sgprBeta:sgprBeta+1], v[vgprValuC+46:vgprValuC+46+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[46:47], v99, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Edge Batch:(2,0,0,0:vw1); (2,0,0,1:vw1); (2,0,1,0:vw1); (2,0,1,1:vw1); (2,1,0,0:vw1); (2,1,0,1:vw1); (2,1,1,0:vw1); (2,1,1,1:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(2,0,0,0) coordOffset1=64 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=64: d1=2 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 64                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v78, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v78, -1, v78, s[62:63]               // clip if OOB. offset
buffer_load_dwordx2 v[79:80], v78, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,0,0,1) coordOffset1=64 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v81, -1, v81, s[64:65]               // clip if OOB. offset
buffer_load_dwordx2 v[82:83], v81, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,0,0) coordOffset1=65 coordOffset0=0 */
/*   coordOffset=0, use coord0=v72 directly */
/*   new coordOffset1=65: d1=2 vc1=1 */
s_mov_b32 s56, 65                                  // coordOffset1 d1=0 vc1=0
_v_add_co_u32 v77, vcc, v73, s56                   // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v84, v75, v72, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v72, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v84, -1, v84, s[66:67]               // clip if OOB. offset
buffer_load_dwordx2 v[85:86], v84, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,0,1) coordOffset1=65 coordOffset0=1 */
_v_add_co_u32 v76, vcc, v72, 1                     // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v87, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v87, -1, v87, s[68:69]               // clip if OOB. offset
buffer_load_dwordx2 v[88:89], v87, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,0,1,0) coordOffset1=64 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 64                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v90, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[70:71], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v90, -1, v90, s[70:71]               // clip if OOB. offset
buffer_load_dwordx2 v[91:92], v90, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,0,1,1) coordOffset1=64 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v93, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[72:73], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v93, -1, v93, s[72:73]               // clip if OOB. offset
buffer_load_dwordx2 v[94:95], v93, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,1,0) coordOffset1=65 coordOffset0=64 */
_v_add_co_u32 v76, vcc, v72, 64                    // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
s_mov_b32 s56, 65                                  // coordOffset1 d1=1 vc1=0
_v_add_co_u32 v77, vcc, v73, s56                   // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v96, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[74:75], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v96, -1, v96, s[74:75]               // clip if OOB. offset
buffer_load_dwordx2 v[97:98], v96, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,1,1) coordOffset1=65 coordOffset0=65 */
s_mov_b32 s56, 65                                  // coord0Offset d0=1 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v99, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[76:77], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v99, -1, v99, s[76:77]               // clip if OOB. offset
buffer_load_dwordx2 v[100:101], v99, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(2, 0, 0, 0), (2, 0, 0, 1), (2, 0, 1, 0), (2, 0, 1, 1), (2, 1, 0, 0), (2, 1, 0, 1), (2, 1, 1, 0), (2, 1, 1, 1)] */
v_mul_f64 v[vgprValuC+48:vgprValuC+48+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+48:vgprValuC+48+1] // *= alpha
v_mul_f64 v[vgprValuC+50:vgprValuC+50+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+50:vgprValuC+50+1] // *= alpha
v_mul_f64 v[vgprValuC+60:vgprValuC+60+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+60:vgprValuC+60+1] // *= alpha
v_mul_f64 v[vgprValuC+62:vgprValuC+62+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+62:vgprValuC+62+1] // *= alpha
v_mul_f64 v[vgprValuC+52:vgprValuC+52+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+52:vgprValuC+52+1] // *= alpha
v_mul_f64 v[vgprValuC+54:vgprValuC+54+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+54:vgprValuC+54+1] // *= alpha
v_mul_f64 v[vgprValuC+64:vgprValuC+64+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+64:vgprValuC+64+1] // *= alpha
v_mul_f64 v[vgprValuC+66:vgprValuC+66+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+66:vgprValuC+66+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+48:vgprValuC+48+1], v[79:80], s[sgprBeta:sgprBeta+1], v[vgprValuC+48:vgprValuC+48+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[48:49], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+50:vgprValuC+50+1], v[82:83], s[sgprBeta:sgprBeta+1], v[vgprValuC+50:vgprValuC+50+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[50:51], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+60:vgprValuC+60+1], v[85:86], s[sgprBeta:sgprBeta+1], v[vgprValuC+60:vgprValuC+60+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[60:61], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+62:vgprValuC+62+1], v[88:89], s[sgprBeta:sgprBeta+1], v[vgprValuC+62:vgprValuC+62+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[62:63], v87, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+52:vgprValuC+52+1], v[91:92], s[sgprBeta:sgprBeta+1], v[vgprValuC+52:vgprValuC+52+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[52:53], v90, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+54:vgprValuC+54+1], v[94:95], s[sgprBeta:sgprBeta+1], v[vgprValuC+54:vgprValuC+54+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[54:55], v93, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+64:vgprValuC+64+1], v[97:98], s[sgprBeta:sgprBeta+1], v[vgprValuC+64:vgprValuC+64+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[64:65], v96, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+66:vgprValuC+66+1], v[100:101], s[sgprBeta:sgprBeta+1], v[vgprValuC+66:vgprValuC+66+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[66:67], v99, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C

/******************************************/
/* Global Write Beta Edge Batch:(2,2,0,0:vw1); (2,2,0,1:vw1); (2,2,1,0:vw1); (2,2,1,1:vw1) */
/******************************************/

/* calc coords, apply mask, and issue loads (if necessary) */
/* (d1,vc1,d0,vc0)=(2,0,2,0) coordOffset1=64 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=64: d1=2 vc1=0 */
_v_add_co_u32 v77, vcc, v73, 64                    // coord1 += d1*sg1*VW + vc1
s_mul_i32 s56, s[sgprStridesC+0], 64               // scale StrideC *= coordOffset1(64)
_v_add_co_u32 v75, vcc, v74, s56                   // rowPtr <- inc for non-0 (tt1+vc1))
_v_add_lshl_u32 v78, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[62:63], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v78, -1, v78, s[62:63]               // clip if OOB. offset
buffer_load_dwordx2 v[79:80], v78, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,0,2,1) coordOffset1=64 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v81, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[64:65], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v81, -1, v81, s[64:65]               // clip if OOB. offset
buffer_load_dwordx2 v[82:83], v81, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,2,0) coordOffset1=65 coordOffset0=128 */
s_mov_b32 s56, 128                                 // coord0Offset d0=2 vc0=0
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
/*   new coordOffset1=65: d1=2 vc1=1 */
s_mov_b32 s56, 65                                  // coordOffset1 d1=2 vc1=0
_v_add_co_u32 v77, vcc, v73, s56                   // coord1 += d1*sg1*VW + vc1
_v_add_co_u32 v75, vcc, v75, s[sgprStridesC+0]     // rowPtr <- move to start of new row
_v_add_lshl_u32 v84, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[66:67], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v84, -1, v84, s[66:67]               // clip if OOB. offset
buffer_load_dwordx2 v[85:86], v84, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc
/* (d1,vc1,d0,vc0)=(2,1,2,1) coordOffset1=65 coordOffset0=129 */
s_mov_b32 s56, 129                                 // coord0Offset d0=2 vc0=1
_v_add_co_u32 v76, vcc, v72, s56                   // coord0 += d0*sg0*VW + vc0
_v_add_lshl_u32 v87, v75, v76, 0x3                 // accumulate d0 lower and *= bpe into addr
/* TODO-packed: compare against product of packed sizes */
v_cmp_lt_u32 s[56:57], v76, s[sgprSizesFree+0]     // coord0 < size0
v_cmp_lt_u32 s[58:59], v77, s[sgprSizesFree+1]     // coord1 < size1
s_and_b64 s[68:69], s[56:57], s[58:59]             // in0 && in1
v_cndmask_b32 v87, -1, v87, s[68:69]               // clip if OOB. offset
buffer_load_dwordx2 v[88:89], v87, s[sgprSrdC:sgprSrdC+3], 0, offen offset:0 // load C for beta calc

/* rC *= alpha batchEements=[(2, 2, 0, 0), (2, 2, 0, 1), (2, 2, 1, 0), (2, 2, 1, 1)] */
v_mul_f64 v[vgprValuC+56:vgprValuC+56+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+56:vgprValuC+56+1] // *= alpha
v_mul_f64 v[vgprValuC+58:vgprValuC+58+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+58:vgprValuC+58+1] // *= alpha
v_mul_f64 v[vgprValuC+68:vgprValuC+68+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+68:vgprValuC+68+1] // *= alpha
v_mul_f64 v[vgprValuC+70:vgprValuC+70+1], s[sgprAlpha:sgprAlpha+1], v[vgprValuC+70:vgprValuC+70+1] // *= alpha
s_waitcnt vmcnt(0)                                 // wait C

/* apply mask, calc new C and issue write */
v_fma_f64 v[vgprValuC+56:vgprValuC+56+1], v[79:80], s[sgprBeta:sgprBeta+1], v[vgprValuC+56:vgprValuC+56+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[56:57], v78, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+58:vgprValuC+58+1], v[82:83], s[sgprBeta:sgprBeta+1], v[vgprValuC+58:vgprValuC+58+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[58:59], v81, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+68:vgprValuC+68+1], v[85:86], s[sgprBeta:sgprBeta+1], v[vgprValuC+68:vgprValuC+68+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[68:69], v84, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
v_fma_f64 v[vgprValuC+70:vgprValuC+70+1], v[88:89], s[sgprBeta:sgprBeta+1], v[vgprValuC+70:vgprValuC+70+1] // finalSum = sum*alpha + C*beta
buffer_store_dwordx2 v[70:71], v87, s[sgprSrdC:sgprSrdC+3], 0, offen, offset:0,  // store C
s_branch label_0037                                // jump to end
label_0037:
s_endpgm                                           // End Kernel
