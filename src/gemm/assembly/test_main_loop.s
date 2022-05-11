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
.amdgpu_hsa_kernel test_main_loop
test_main_loop:
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
/* VGPR Assignments                       */
/******************************************/
.set vgprValuC, 0                         ;72
.set vgprValuA_X0_I0, 72                  ;6
.set vgprValuA_X1_I0, 78                  ;6
.set vgprG2L, 84                          ;12
.set vgprValuB_X0_I0, 96                  ;12
.set vgprValuB_X1_I0, 108                 ;12
.set vgprLocalReadAddrA, 120              ;vgprLocalReadAddrA
.set vgprLocalReadAddrB, 121
.set vgprLocalWriteAddr, 122
.set vgprSerial, 123
.set vgprGRInc, 123
.set vgprGRO, 124                         ;vgprGlobalReadOffset
.set vgprGRWOC_0_0, 126                   ;vgprGlobalReadWriteOffset_C_0_0_0_0
.set vgprGRWOC_0_1, 127                   ;vgprGlobalReadWriteOffset_C_0_0_0_1
.set vtmp1, 96
.set vtmp2, 97
.set vgprSerialMod16, 98
.set vgprSerialDiv16, 99
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
.set sgprSrd, 8
.set sgprGRI, 12
.set sgprStableOffset, 13
.set sgprLD, 14
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
.set sgprMT0I, 58
.set sgprMT1J, 58
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
/* thread [0,127]:    each thread load 6 A
/* thread [128, 255]: each thread load 6 B
/*******************************************/
.macro GLOBAL_LOAD
buffer_load_dwordx4 v[vgprG2L+0:vgprG2L+3],  v[vgprGRO], s[sgprSrd:sgprSrd+3], 0, offen, offset:0 
buffer_load_dwordx4 v[vgprG2L+4:vgprG2L+7],  v[vgprGRO], s[sgprSrd:sgprSrd+3], 0, offen, offset:256
buffer_load_dwordx4 v[vgprG2L+8:vgprG2L+11], v[vgprGRO], s[sgprSrd:sgprSrd+3], 0, offen, offset:512
.endm

.macro DS_WRITE base
ds_write_b128 v[vgprLocalWriteAddr], v[vgprG2L+0:vgprG2L+3] offset:\base+0 
ds_write_b128 v[vgprLocalWriteAddr], v[vgprG2L+4:vgprG2L+7] offset:\base+0x100
ds_write_b128 v[vgprLocalWriteAddr], v[vgprG2L+8:vgprG2L+11] offset:\base+0x200      ;
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

/******************************************/
/* 6x6 thread-tile                        */
/******************************************/
.macro MAC_6x6_X0_FMA_F64 i,j
v_fma_f64 v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1], v[vgprValuA_X0_I0+\i*2:vgprValuA_X0_I0+\i*2+1], v[vgprValuB_X0_I0+\j*2:vgprValuB_X0_I0+\j*2+1], v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1]
.endm

.macro MAC_6x6_X1_FMA_F64 i,j
v_fma_f64 v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1], v[vgprValuA_X0_I0+\i*2:vgprValuA_X0_I0+\i*2+1], v[vgprValuB_X1_I0+\j*2:vgprValuB_X1_I0+\j*2+1], v[vgprValuC+(\i+\j*6)*2:(vgprValuC+\i+\j*6)*2+1]
.endm

.macro MAC_X0_6x6_UP
MAC_6x6_X0_FMA_F64 0, 0
s_setprio 1
MAC_6x6_X0_FMA_F64 1, 0
MAC_6x6_X0_FMA_F64 2, 0
MAC_6x6_X0_FMA_F64 0, 1
MAC_6x6_X0_FMA_F64 1, 1
MAC_6x6_X0_FMA_F64 2, 1
MAC_6x6_X0_FMA_F64 0, 2
MAC_6x6_X0_FMA_F64 1, 2
MAC_6x6_X0_FMA_F64 2, 2
MAC_6x6_X0_FMA_F64 0, 3
MAC_6x6_X0_FMA_F64 1, 3
MAC_6x6_X0_FMA_F64 2, 3
MAC_6x6_X0_FMA_F64 0, 4
MAC_6x6_X0_FMA_F64 1, 4
MAC_6x6_X0_FMA_F64 2, 4
MAC_6x6_X0_FMA_F64 0, 5
MAC_6x6_X0_FMA_F64 1, 5
MAC_6x6_X0_FMA_F64 2, 5
.endm

.macro MAC_X0_6x6_LOW
MAC_6x6_X0_FMA_F64 3, 0
s_setprio 1
MAC_6x6_X0_FMA_F64 4, 0
MAC_6x6_X0_FMA_F64 5, 0
MAC_6x6_X0_FMA_F64 3, 1
MAC_6x6_X0_FMA_F64 4, 1
MAC_6x6_X0_FMA_F64 5, 1
MAC_6x6_X0_FMA_F64 3, 2
MAC_6x6_X0_FMA_F64 4, 2
MAC_6x6_X0_FMA_F64 5, 2
MAC_6x6_X0_FMA_F64 3, 3
MAC_6x6_X0_FMA_F64 4, 3
MAC_6x6_X0_FMA_F64 5, 3
MAC_6x6_X0_FMA_F64 3, 4
MAC_6x6_X0_FMA_F64 4, 4
MAC_6x6_X0_FMA_F64 5, 4
MAC_6x6_X0_FMA_F64 3, 5
MAC_6x6_X0_FMA_F64 4, 5
MAC_6x6_X0_FMA_F64 5, 5
.endm

.macro MAC_X1_6x6_UP
MAC_6x6_X1_FMA_F64 0, 0
s_setprio 1
MAC_6x6_X1_FMA_F64 1, 0
MAC_6x6_X1_FMA_F64 2, 0
MAC_6x6_X1_FMA_F64 0, 1
MAC_6x6_X1_FMA_F64 1, 1
MAC_6x6_X1_FMA_F64 2, 1
MAC_6x6_X1_FMA_F64 0, 2
MAC_6x6_X1_FMA_F64 1, 2
MAC_6x6_X1_FMA_F64 2, 2
MAC_6x6_X1_FMA_F64 0, 3
MAC_6x6_X1_FMA_F64 1, 3
MAC_6x6_X1_FMA_F64 2, 3
MAC_6x6_X1_FMA_F64 0, 4
MAC_6x6_X1_FMA_F64 1, 4
MAC_6x6_X1_FMA_F64 2, 4
MAC_6x6_X1_FMA_F64 0, 5
MAC_6x6_X1_FMA_F64 1, 5
MAC_6x6_X1_FMA_F64 2, 5
s_setprio 0
.endm

.macro MAC_X1_6x6_LOW
MAC_6x6_X1_FMA_F64 3, 0
s_setprio 1
MAC_6x6_X1_FMA_F64 4, 0
MAC_6x6_X1_FMA_F64 5, 0
MAC_6x6_X1_FMA_F64 3, 1
MAC_6x6_X1_FMA_F64 4, 1
MAC_6x6_X1_FMA_F64 5, 1
MAC_6x6_X1_FMA_F64 3, 2
MAC_6x6_X1_FMA_F64 4, 2
MAC_6x6_X1_FMA_F64 5, 2
MAC_6x6_X1_FMA_F64 3, 3
MAC_6x6_X1_FMA_F64 4, 3
MAC_6x6_X1_FMA_F64 5, 3
MAC_6x6_X1_FMA_F64 3, 4
MAC_6x6_X1_FMA_F64 4, 4
MAC_6x6_X1_FMA_F64 5, 4
MAC_6x6_X1_FMA_F64 3, 5
MAC_6x6_X1_FMA_F64 4, 5
MAC_6x6_X1_FMA_F64 5, 5
s_setprio 0
.endm


/* global read inc address */
.macro GLOBAL_READ_INC_ADDRESS
s_add_u32 s[sgprSrd+0], s[sgprSrd+0], s[sgprGRI]
s_addc_u32 s[sgprSrd+1], s[sgprSrd+1], 0
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
s_mov_b32 m0, 0x6000                               // LDS clamp at 24576 bytes
s_mov_b32 s[sgprStableOffset], 0                   //init lds stable offset as 0
s_mov_b32 s[sgprMT0I], 0x60
v_mov_b32 v[vgprSerial], v0
v_lshrrev_b32 v[vgprSerialDiv16], 0x4, v0
v_and_b32 v[vgprSerialMod16], 0xf, v0
s_nop 0
s_waitcnt lgkmcnt(0)                               // wait for 88 bytes of kern args  
/* instruction alignment: 8 bytes

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
/* SOP2 instructions(32bits), instruction alignment: 8 bytes */


/**************************************************************/
/* local read address of a:
/*   lr0I = (serial % SG0I) 
/**************************************************************/
v_and_b32 v[vtmp1], 0xf, v[vgprSerial]                             // serial % 16
v_lshlrev_b32 v[vgprLocalReadAddrA], 0x4, v[vtmp1]                 // * 2 * BPE

/**************************************************************/
/* local read address of b:
/*   lr1J = (serial / SG0I) % SG1J
/*   localReadOffsetB = lr1J*VECTOR_WIDTH
/**************************************************************/
v_lshlrev_b32 v[vgprLocalReadAddrB], 0x4, v[vgprSerialDiv16]                 // * 2 * BPE
v_add_u32 v[vgprLocalReadAddrB], 0x1800, v[vgprLocalReadAddrB]               
v_cmp_gt_u32 vcc, 128, v[vgprSerial]                  //thread < 128, vcc[threadId] = 1
v_and_b32 v[vgprSerial], 0x7f, v[vgprSerial]              //serial -= 128
v_lshrrev_b32 v[vgprSerialDiv16], 0x4, v[vgprSerial]                    //serial / 16
v_and_b32 v[vgprSerialMod16], 0xf, v[vgprSerial]                        //serial % 16


/**************************************************************/
/* thread [0,127] work in one path
/* thread [128, 255] work in another path
/**************************************************************/
s_cbranch_vccz label_thread_128_255
/**************************************************************/
/* load A
/**************************************************************/
label_thread_0_127:     
s_mov_b32 s[sgprLD], s[sgprLda]
/**************************************************************/
/* SRD_base_A:the address of the block to be read in A
/*   sgprSrdA = sgprAddressA + wg0I * MT0I
/**************************************************************/
s_mul_i32 s[sLow], s[sgprBlockIdX], 0x300
s_add_u32 s[sgprSrd+0], s[sgprAddressA+0], s[sLow]
s_addc_u32 s[sgprSrd+1], s[sgprAddressA+1], 0
s_mov_b32 s[sgprSrd+2], BufferLimit
s_mov_b32 s[sgprSrd+3], Srd127_96
/* join thread_128_255 */
s_branch label_thread_join

/**************************************************************/
/* load B
/**************************************************************/
label_thread_128_255:
s_mov_b32 s[sgprLD], s[sgprLdb]
s_mov_b32 s[sgprStableOffset], 0x1800                     //lds offset for B
/**************************************************************/
/* SRD_base_B:the address of the block to be read in B
/*   sgprSrdB = sgprAddressB + wg1J * MT1J
/**************************************************************/
s_mul_i32 s[sLow], s[sgprBlockIdY], 0x300
s_add_u32 s[sgprSrd+0], s[sgprAddressB+0], s[sLow]
s_addc_u32 s[sgprSrd+1], s[sgprAddressB+1], 0
s_mov_b32 s[sgprSrd+2], BufferLimit
s_mov_b32 s[sgprSrd+3], Srd127_96

label_thread_join:
/**************************************************************/
/* global read address: increments a and b
/*   UNROLL * LDA(LDB) * BPE
/**************************************************************/
s_mul_i32 s[sgprGRI], 0x40, s[sgprLD]

/****************************************************************
/* local write address of a and b:
/*   serial = serial - 128(for b)
/*   x = (serial%16) * 2
/*   y = (serial/16)
/*   localWriteAddr = x + y*MT0I(MT1J)
/*   localWriteAddr += 0x1800(for b)
/****************************************************************/
v_mul_u32_u24 v[vtmp1], s[sgprMT0I], v[vgprSerialDiv16]                 //1wAL * MT0I
v_lshlrev_b32 v[vtmp2], 0x1, v[vgprSerialMod16]                         //(serial % 16) * 2
v_add_lshl_u32 v[vgprLocalWriteAddr], v[vtmp1], v[vtmp2], 0x3 //offset in bytes
v_add_u32 v[vgprLocalWriteAddr], s[sgprStableOffset], v[vgprLocalWriteAddr]
v_mul_lo_u32 v[vgprGRO], s[sgprLD], v[vgprSerialDiv16]   // * LDA (*LDB)
v_lshlrev_b32 v[vtmp2], 0x1, v[vgprSerialMod16]                    // * 2
s_waitcnt vmcnt(12)
v_add_lshl_u32 v[vgprGRO], v[vgprGRO], v[vtmp2], 0x3         //globalReadOffsetB_0_0_0_0, in bytes
s_waitcnt vmcnt(0)
GLOBAL_LOAD
GLOBAL_READ_INC_ADDRESS
s_waitcnt vmcnt(0)

/****************************************************************
/* local write
/****************************************************************/
DS_WRITE 0x0
/*****************************************************************
/* calculate loop counters
/*****************************************************************/
s_lshr_b32 s[sgprLoopCounters], s[sgprSizesL], 0x3          //sizeL / 8
s_sub_u32 s[sgprLoopCounters], 0x2, s[sgprLoopCounters]     //sgprLoopCounters = -sgprLoopCounters

s_waitcnt lgkmcnt(0)
s_barrier

/*****************************************************************

/*****************************************************************/
DS_READ_B0 0,0                          //ds_read B0 into register
DS_READ_0A 0,0                          //ds_read 0A into registers
/*****************************************************************
/* main unroll loops
/*****************************************************************/
unroll_loop_start:
/*****************************************************************
/* 1/2 unroll loop
/*****************************************************************/
GLOBAL_LOAD

//iter 0
DS_READ_1A 0,0
GLOBAL_READ_INC_ADDRESS
s_waitcnt lgkmcnt(2)
MAC_X0_6x6_UP
DS_READ_B1 0,1
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
DS_WRITE 0x3000
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
GLOBAL_LOAD

//iter 0
DS_READ_1A 0x3000,0
DS_READ_B1 0x3000,1
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
GLOBAL_READ_INC_ADDRESS
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
s_setprio 0
DS_READ_0A 0x3000,7
s_waitcnt vmcnt(0)            // wait for global read
DS_WRITE 0
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
GLOBAL_LOAD
//iter 0
DS_READ_1A 0,0
DS_READ_B1 0,1
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_UP
s_setprio 0
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
s_setprio 0
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
s_setprio 0
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
s_setprio 0
DS_READ_0A 0,7
s_waitcnt vmcnt(0)                    // wait for global read
DS_WRITE 0x3000
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
s_setprio 0
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
s_setprio 0
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
s_setprio 0
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
s_setprio 0
DS_READ_0A 0x3000,7
s_waitcnt lgkmcnt(5)
MAC_X0_6x6_LOW

//iter 7
DS_READ_1A 0x3000,7
s_waitcnt lgkmcnt(2)
MAC_X1_6x6_UP
s_waitcnt lgkmcnt(0)
MAC_X1_6x6_LOW

label_end:
s_endpgm                                           // End Kernel


