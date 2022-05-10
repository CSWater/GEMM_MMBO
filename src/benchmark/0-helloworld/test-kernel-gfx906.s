	.text
	.amdgcn_target "amdgcn-amd-amdhsa--gfx906"
	.p2align	2                               ; -- Begin function __ockl_hostcall_internal
	.type	__ockl_hostcall_internal,@function
__ockl_hostcall_internal:               ; @__ockl_hostcall_internal
; %bb.0:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	buffer_store_dword v1, off, s[0:3], s32 offset:4
	buffer_store_dword v0, off, s[0:3], s32
	v_mov_b32_e32 v0, 2
	buffer_store_dword v0, off, s[0:3], s32 offset:8
	buffer_store_dword v3, off, s[0:3], s32 offset:20
	buffer_store_dword v2, off, s[0:3], s32 offset:16
	buffer_store_dword v5, off, s[0:3], s32 offset:28
	buffer_store_dword v4, off, s[0:3], s32 offset:24
	buffer_store_dword v7, off, s[0:3], s32 offset:36
	buffer_store_dword v6, off, s[0:3], s32 offset:32
	buffer_store_dword v9, off, s[0:3], s32 offset:44
	buffer_store_dword v8, off, s[0:3], s32 offset:40
	buffer_store_dword v11, off, s[0:3], s32 offset:52
	buffer_store_dword v10, off, s[0:3], s32 offset:48
	buffer_store_dword v13, off, s[0:3], s32 offset:60
	buffer_store_dword v12, off, s[0:3], s32 offset:56
	buffer_store_dword v15, off, s[0:3], s32 offset:68
	buffer_store_dword v14, off, s[0:3], s32 offset:64
	buffer_store_dword v17, off, s[0:3], s32 offset:76
	buffer_store_dword v16, off, s[0:3], s32 offset:72
	s_mov_b32 s4, 0
	s_mov_b32 s5, -1
	v_mov_b32_e32 v0, s4
	v_mbcnt_lo_u32_b32 v0, s5, v0
	v_mbcnt_hi_u32_b32 v0, s5, v0
	buffer_store_dword v0, off, s[0:3], s32 offset:80
	buffer_load_dword v0, off, s[0:3], s32 offset:80
	s_waitcnt vmcnt(0)
	;;#ASMSTART
	; ockl readfirstlane hoisting hack v0
	;;#ASMEND
	buffer_store_dword v0, off, s[0:3], s32 offset:80
	buffer_load_dword v0, off, s[0:3], s32 offset:80
	s_waitcnt vmcnt(0)
	v_readfirstlane_b32 s4, v0
	v_mov_b32_e32 v0, s4
	buffer_store_dword v0, off, s[0:3], s32 offset:84
	buffer_load_dword v0, off, s[0:3], s32
	buffer_load_dword v1, off, s[0:3], s32 offset:4
	s_waitcnt vmcnt(0)
	buffer_store_dword v1, off, s[0:3], s32 offset:92
	buffer_store_dword v0, off, s[0:3], s32 offset:88
	buffer_load_dword v0, off, s[0:3], s32 offset:80
	buffer_load_dword v1, off, s[0:3], s32 offset:84
	s_waitcnt vmcnt(0)
	v_cmp_eq_u32_e64 s[6:7], v0, v1
	s_mov_b64 s[4:5], 0
	v_mov_b32_e32 v4, s4
	v_mov_b32_e32 v5, s5
	s_mov_b64 s[4:5], exec
	s_and_b64 s[6:7], s[4:5], s[6:7]
	s_mov_b64 exec, s[6:7]
	s_cbranch_execz BB0_6
; %bb.1:
	buffer_load_dword v0, off, s[0:3], s32 offset:88
	buffer_load_dword v1, off, s[0:3], s32 offset:92
	s_mov_b64 s[8:9], 24
	s_waitcnt vmcnt(1)
	v_add_co_u32_e64 v6, s[6:7], v0, s8
	v_mov_b32_e32 v2, s9
	s_waitcnt vmcnt(0)
	v_addc_co_u32_e64 v7, s[6:7], v1, v2, s[6:7]
	global_load_dwordx2 v[4:5], v[0:1], off offset:24 glc
	s_waitcnt vmcnt(0)
	buffer_wbinvl1_vol
	global_load_dwordx2 v[2:3], v[0:1], off
	s_mov_b64 s[8:9], 40
	v_add_co_u32_e64 v8, s[6:7], v0, s8
	v_mov_b32_e32 v9, s9
	v_addc_co_u32_e64 v9, s[6:7], v1, v9, s[6:7]
	global_load_dwordx2 v[10:11], v[0:1], off offset:40
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v11, v11, v5
	v_and_b32_e32 v10, v10, v4
	s_mov_b32 s6, 24
	v_mul_hi_u32 v13, v10, s6
	s_mov_b32 s7, 32
	v_lshrrev_b64 v[11:12], s7, v[10:11]
	v_mul_lo_u32 v11, v11, s6
	v_add_u32_e64 v11, v13, v11
	v_lshlrev_b64 v[11:12], s7, v[11:12]
	v_mul_lo_u32 v10, v10, s6
	s_mov_b32 s6, 0
	v_mov_b32_e32 v13, 0
	v_or_b32_e32 v12, v13, v12
	v_or_b32_e32 v10, v10, v11
	v_add_co_u32_e64 v2, s[6:7], v2, v10
	v_addc_co_u32_e64 v3, s[6:7], v3, v12, s[6:7]
	global_load_dwordx2 v[2:3], v[2:3], off glc
	s_waitcnt vmcnt(0)
	global_atomic_cmpswap_x2 v[12:13], v[0:1], v[2:5], off offset:24 glc
	s_waitcnt vmcnt(0)
	buffer_wbinvl1_vol
	v_cmp_eq_u64_e64 s[6:7], v[12:13], v[4:5]
	v_cmp_ne_u64_e64 s[8:9], v[12:13], v[4:5]
	s_mov_b64 s[6:7], exec
	s_and_b64 s[8:9], s[6:7], s[8:9]
	s_mov_b64 exec, s[8:9]
; %bb.2:                                ; %.preheader6
	s_mov_b64 s[8:9], 0
	s_branch BB0_4
BB0_3:                                  ; %Flow14
	s_or_b64 exec, exec, s[6:7]
	s_branch BB0_6
BB0_4:                                  ; =>This Inner Loop Header: Depth=1
                                        ; implicit-def: $sgpr10_sgpr11
	v_mov_b32_e32 v4, v12
	v_mov_b32_e32 v5, v13
	s_sleep 1
	global_load_dwordx2 v[2:3], v[0:1], off
	global_load_dwordx2 v[10:11], v[8:9], off
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v11, v11, v13
	v_and_b32_e32 v10, v10, v12
	s_mov_b32 s10, 24
	v_mul_hi_u32 v16, v10, s10
	s_mov_b32 s11, 32
	v_lshrrev_b64 v[14:15], s11, v[10:11]
	v_mul_lo_u32 v11, v14, s10
	v_add_u32_e64 v11, v16, v11
	v_lshlrev_b64 v[14:15], s11, v[11:12]
	v_mul_lo_u32 v10, v10, s10
	s_mov_b32 s10, 0
	v_mov_b32_e32 v11, 0
	v_or_b32_e32 v11, v11, v15
	v_or_b32_e32 v10, v10, v14
	v_add_co_u32_e64 v2, s[10:11], v2, v10
	v_addc_co_u32_e64 v3, s[10:11], v3, v11, s[10:11]
	global_load_dwordx2 v[10:11], v[2:3], off glc
	s_waitcnt vmcnt(0)
	global_atomic_cmpswap_x2 v[2:3], v[6:7], v[10:13], off glc
	s_waitcnt vmcnt(0)
	buffer_wbinvl1_vol
	v_cmp_eq_u64_e64 s[10:11], v[2:3], v[12:13]
	s_or_b64 s[8:9], s[10:11], s[8:9]
	v_mov_b32_e32 v13, v3
	v_mov_b32_e32 v12, v2
	s_andn2_b64 exec, exec, s[8:9]
	s_cbranch_execnz BB0_4
; %bb.5:                                ; %.exit4.loopexit
	s_or_b64 exec, exec, s[8:9]
	s_branch BB0_3
BB0_6:                                  ; %.exit4
	s_or_b64 exec, exec, s[4:5]
	s_mov_b32 s8, 32
	v_lshrrev_b64 v[0:1], s8, v[4:5]
	v_readfirstlane_b32 s4, v4
	v_readfirstlane_b32 s6, v0
	s_lshl_b64 s[6:7], s[6:7], s8
	s_mov_b32 s5, 0
	s_or_b64 s[6:7], s[6:7], s[4:5]
	v_mov_b32_e32 v0, s7
	buffer_store_dword v0, off, s[0:3], s32 offset:100
	v_mov_b32_e32 v0, s6
	buffer_store_dword v0, off, s[0:3], s32 offset:96
	buffer_load_dword v0, off, s[0:3], s32 offset:88
	buffer_load_dword v1, off, s[0:3], s32 offset:92
	buffer_load_dword v2, off, s[0:3], s32 offset:96
	buffer_load_dword v3, off, s[0:3], s32 offset:100
	s_waitcnt vmcnt(2)
	global_load_dwordx2 v[4:5], v[0:1], off
	global_load_dwordx2 v[0:1], v[0:1], off offset:40
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v1, v3, v1
	v_and_b32_e32 v0, v2, v0
	s_mov_b32 s4, 24
	v_mul_hi_u32 v3, v0, s4
	v_lshrrev_b64 v[1:2], s8, v[0:1]
	v_mul_lo_u32 v1, v1, s4
	v_add_u32_e64 v1, v3, v1
	v_lshlrev_b64 v[1:2], s8, v[1:2]
	v_mul_lo_u32 v0, v0, s4
	v_mov_b32_e32 v3, s5
	v_or_b32_e32 v2, v3, v2
	v_or_b32_e32 v0, v0, v1
	v_add_co_u32_e64 v0, s[4:5], v4, v0
	v_addc_co_u32_e64 v1, s[4:5], v5, v2, s[4:5]
	buffer_store_dword v1, off, s[0:3], s32 offset:108
	buffer_store_dword v0, off, s[0:3], s32 offset:104
	buffer_load_dword v0, off, s[0:3], s32 offset:88
	buffer_load_dword v1, off, s[0:3], s32 offset:92
	buffer_load_dword v2, off, s[0:3], s32 offset:96
	buffer_load_dword v3, off, s[0:3], s32 offset:100
	s_waitcnt vmcnt(2)
	global_load_dwordx2 v[4:5], v[0:1], off offset:8
	global_load_dwordx2 v[0:1], v[0:1], off offset:40
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v1, v3, v1
	v_and_b32_e32 v0, v2, v0
	s_mov_b32 s4, 12
	v_lshlrev_b64 v[0:1], s4, v[0:1]
	v_add_co_u32_e64 v0, s[4:5], v4, v0
	v_addc_co_u32_e64 v1, s[4:5], v5, v1, s[4:5]
	buffer_store_dword v1, off, s[0:3], s32 offset:116
	buffer_store_dword v0, off, s[0:3], s32 offset:112
	buffer_load_dword v0, off, s[0:3], s32 offset:112
	buffer_load_dword v1, off, s[0:3], s32 offset:116
	buffer_load_dword v2, off, s[0:3], s32 offset:16
	buffer_load_dword v3, off, s[0:3], s32 offset:20
	buffer_load_dword v4, off, s[0:3], s32 offset:24
	buffer_load_dword v5, off, s[0:3], s32 offset:28
	buffer_load_dword v6, off, s[0:3], s32 offset:32
	buffer_load_dword v7, off, s[0:3], s32 offset:36
	buffer_load_dword v8, off, s[0:3], s32 offset:40
	buffer_load_dword v9, off, s[0:3], s32 offset:44
	buffer_load_dword v10, off, s[0:3], s32 offset:48
	buffer_load_dword v11, off, s[0:3], s32 offset:52
	buffer_load_dword v12, off, s[0:3], s32 offset:56
	buffer_load_dword v13, off, s[0:3], s32 offset:60
	buffer_load_dword v14, off, s[0:3], s32 offset:64
	buffer_load_dword v15, off, s[0:3], s32 offset:68
	buffer_load_dword v16, off, s[0:3], s32 offset:72
	buffer_load_dword v17, off, s[0:3], s32 offset:76
	buffer_load_dword v18, off, s[0:3], s32 offset:80
	buffer_load_dword v19, off, s[0:3], s32 offset:84
	s_mov_b64 s[6:7], exec
	s_waitcnt vmcnt(0)
	v_cmp_eq_u32_e64 s[8:9], v18, v19
	s_mov_b64 s[4:5], exec
	s_and_b64 s[8:9], s[4:5], s[8:9]
	s_mov_b64 exec, s[8:9]
	s_cbranch_execz BB0_8
; %bb.7:
	buffer_load_dword v19, off, s[0:3], s32 offset:104
	buffer_load_dword v20, off, s[0:3], s32 offset:108
	buffer_load_dword v21, off, s[0:3], s32 offset:8
	s_waitcnt vmcnt(0)
	global_store_dword v[19:20], v21, off offset:16
	v_mov_b32_e32 v22, s7
	v_mov_b32_e32 v21, s6
	global_store_dwordx2 v[19:20], v[21:22], off offset:8
	v_mov_b32_e32 v21, 1
	global_store_dword v[19:20], v21, off offset:20
BB0_8:                                  ; %.exit3
	s_or_b64 exec, exec, s[4:5]
	s_mov_b32 s4, 0
	v_mov_b32_e32 v19, 0
	s_mov_b32 s4, 6
	v_lshlrev_b64 v[18:19], s4, v[18:19]
	v_add_co_u32_e64 v0, s[4:5], v0, v18
	v_addc_co_u32_e64 v1, s[4:5], v1, v19, s[4:5]
	global_store_dwordx2 v[0:1], v[2:3], off
	global_store_dwordx2 v[0:1], v[4:5], off offset:8
	global_store_dwordx2 v[0:1], v[6:7], off offset:16
	global_store_dwordx2 v[0:1], v[8:9], off offset:24
	global_store_dwordx2 v[0:1], v[10:11], off offset:32
	global_store_dwordx2 v[0:1], v[12:13], off offset:40
	global_store_dwordx2 v[0:1], v[14:15], off offset:48
	global_store_dwordx2 v[0:1], v[16:17], off offset:56
	buffer_load_dword v0, off, s[0:3], s32 offset:80
	buffer_load_dword v1, off, s[0:3], s32 offset:84
	s_waitcnt vmcnt(0)
	v_cmp_eq_u32_e64 s[6:7], v0, v1
	s_mov_b64 s[4:5], exec
	s_and_b64 s[6:7], s[4:5], s[6:7]
	s_mov_b64 exec, s[6:7]
	s_cbranch_execz BB0_14
; %bb.9:
	buffer_load_dword v0, off, s[0:3], s32 offset:88
	buffer_load_dword v1, off, s[0:3], s32 offset:92
	buffer_load_dword v2, off, s[0:3], s32 offset:96
	buffer_load_dword v3, off, s[0:3], s32 offset:100
	s_mov_b64 s[8:9], 32
	s_waitcnt vmcnt(3)
	v_add_co_u32_e64 v6, s[6:7], v0, s8
	v_mov_b32_e32 v4, s9
	s_waitcnt vmcnt(2)
	v_addc_co_u32_e64 v7, s[6:7], v1, v4, s[6:7]
	global_load_dwordx2 v[4:5], v[0:1], off offset:32 glc
	global_load_dwordx2 v[8:9], v[0:1], off
	global_load_dwordx2 v[10:11], v[0:1], off offset:40
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v11, v11, v3
	v_and_b32_e32 v10, v10, v2
	s_mov_b32 s6, 24
	v_mul_hi_u32 v13, v10, s6
	s_mov_b32 s7, 32
	v_lshrrev_b64 v[11:12], s7, v[10:11]
	v_mul_lo_u32 v11, v11, s6
	v_add_u32_e64 v11, v13, v11
	v_lshlrev_b64 v[11:12], s7, v[11:12]
	v_mul_lo_u32 v10, v10, s6
	s_mov_b32 s6, 0
	v_mov_b32_e32 v13, 0
	v_or_b32_e32 v12, v13, v12
	v_or_b32_e32 v10, v10, v11
	v_add_co_u32_e64 v8, s[6:7], v8, v10
	v_addc_co_u32_e64 v9, s[6:7], v9, v12, s[6:7]
	global_store_dwordx2 v[8:9], v[4:5], off
	s_waitcnt vmcnt(0)
	global_atomic_cmpswap_x2 v[10:11], v[0:1], v[2:5], off offset:32 glc
	s_waitcnt vmcnt(0)
	v_cmp_eq_u64_e64 s[6:7], v[10:11], v[4:5]
	v_cmp_ne_u64_e64 s[8:9], v[10:11], v[4:5]
	s_mov_b64 s[6:7], exec
	s_and_b64 s[8:9], s[6:7], s[8:9]
	s_mov_b64 exec, s[8:9]
; %bb.10:                               ; %.preheader5
	s_mov_b64 s[8:9], 0
	s_branch BB0_12
BB0_11:                                 ; %Flow11
	s_or_b64 exec, exec, s[6:7]
	s_branch BB0_15
BB0_12:                                 ; =>This Inner Loop Header: Depth=1
                                        ; implicit-def: $sgpr10_sgpr11
	s_sleep 1
	global_store_dwordx2 v[8:9], v[10:11], off
	v_mov_b32_e32 v4, v10
	v_mov_b32_e32 v5, v11
	s_waitcnt vmcnt(0)
	global_atomic_cmpswap_x2 v[4:5], v[6:7], v[2:5], off glc
	s_waitcnt vmcnt(0)
	v_cmp_eq_u64_e64 s[10:11], v[4:5], v[10:11]
	s_or_b64 s[8:9], s[10:11], s[8:9]
	v_mov_b32_e32 v11, v5
	v_mov_b32_e32 v10, v4
	s_andn2_b64 exec, exec, s[8:9]
	s_cbranch_execnz BB0_12
; %bb.13:                               ; %.loopexit
	s_branch BB0_11
BB0_14:                                 ; %Flow12
	s_or_b64 exec, exec, s[4:5]
	s_branch BB0_18
BB0_15:
	global_load_dwordx2 v[2:3], v[0:1], off offset:16
	s_mov_b64 s[6:7], 1
	v_mov_b32_e32 v0, s6
	v_mov_b32_e32 v1, s7
	s_waitcnt vmcnt(0)
	global_atomic_add_x2 v[2:3], v[0:1], off offset:8
	global_load_dwordx2 v[0:1], v[2:3], off offset:16
	s_mov_b64 s[6:7], 0
	s_waitcnt vmcnt(0)
	v_cmp_ne_u64_e64 s[6:7], v[0:1], s[6:7]
	s_mov_b64 s[8:9], exec
	s_and_b64 s[6:7], s[8:9], s[6:7]
	s_mov_b64 exec, s[6:7]
	s_cbranch_execz BB0_17
; %bb.16:
	global_load_dword v2, v[2:3], off offset:24
	s_mov_b32 s6, 0
	v_mov_b32_e32 v3, 0
	s_waitcnt vmcnt(0)
	global_store_dwordx2 v[0:1], v[2:3], off
	v_readfirstlane_b32 s6, v2
	s_mov_b32 s7, 0xff
	s_and_b32 m0, s6, s7
	s_nop 0
	s_sendmsg sendmsg(MSG_INTERRUPT)
BB0_17:                                 ; %__ockl_hsa_signal_add.exit.i
	s_branch BB0_14
BB0_18:                                 ; %.exit2
	buffer_load_dword v3, off, s[0:3], s32 offset:104
	buffer_load_dword v4, off, s[0:3], s32 offset:108
	buffer_load_dword v0, off, s[0:3], s32 offset:112
	buffer_load_dword v1, off, s[0:3], s32 offset:116
	buffer_load_dword v2, off, s[0:3], s32 offset:80
	buffer_load_dword v5, off, s[0:3], s32 offset:84
	s_waitcnt vmcnt(0)
	v_cmp_eq_u32_e64 s[4:5], v2, v5
	s_mov_b64 s[8:9], 20
	v_add_co_u32_e64 v3, s[6:7], v3, s8
	v_mov_b32_e32 v5, s9
	v_addc_co_u32_e64 v4, s[6:7], v4, v5, s[6:7]
BB0_19:                                 ; =>This Inner Loop Header: Depth=1
	s_mov_b32 s6, 1
	v_mov_b32_e32 v5, 1
	s_mov_b64 s[6:7], exec
	s_and_b64 s[8:9], s[6:7], s[4:5]
	s_mov_b64 exec, s[8:9]
	s_cbranch_execz BB0_21
; %bb.20:                               ;   in Loop: Header=BB0_19 Depth=1
	global_load_dword v5, v[3:4], off glc
	s_waitcnt vmcnt(0)
	buffer_wbinvl1_vol
	s_mov_b32 s8, 1
	v_mov_b32_e32 v6, s8
	v_and_b32_e32 v5, v5, v6
BB0_21:                                 ;   in Loop: Header=BB0_19 Depth=1
	s_or_b64 exec, exec, s[6:7]
	v_readfirstlane_b32 s6, v5
	s_mov_b32 s7, 0
	v_mov_b32_e32 v5, s7
	v_cmp_eq_u32_e64 s[8:9], s6, v5
	s_mov_b64 s[6:7], -1
	s_and_b64 vcc, exec, s[8:9]
	s_cbranch_vccnz BB0_23
; %bb.22:                               ;   in Loop: Header=BB0_19 Depth=1
	s_sleep 1
	s_mov_b64 s[6:7], 0
BB0_23:                                 ; %Flow8
                                        ;   in Loop: Header=BB0_19 Depth=1
	v_cndmask_b32_e64 v5, 0, 1, s[6:7]
	s_mov_b32 s6, 1
	v_cmp_ne_u32_e64 s[6:7], v5, s6
	s_and_b64 vcc, exec, s[6:7]
	s_cbranch_vccnz BB0_19
; %bb.24:                               ; %.exit1
	s_mov_b32 s4, 0
	v_mov_b32_e32 v3, 0
	s_mov_b32 s4, 6
	v_lshlrev_b64 v[2:3], s4, v[2:3]
	v_add_co_u32_e64 v0, s[4:5], v0, v2
	v_addc_co_u32_e64 v1, s[4:5], v1, v3, s[4:5]
	global_load_dwordx4 v[0:3], v[0:1], off
	s_waitcnt vmcnt(0)
	buffer_store_dword v3, off, s[0:3], s32 offset:140
	buffer_store_dword v2, off, s[0:3], s32 offset:136
	buffer_store_dword v1, off, s[0:3], s32 offset:132
	buffer_store_dword v0, off, s[0:3], s32 offset:128
	buffer_load_dword v0, off, s[0:3], s32 offset:80
	buffer_load_dword v1, off, s[0:3], s32 offset:84
	s_waitcnt vmcnt(0)
	v_cmp_eq_u32_e64 s[6:7], v0, v1
	s_mov_b64 s[4:5], exec
	s_and_b64 s[6:7], s[4:5], s[6:7]
	s_mov_b64 exec, s[6:7]
	s_cbranch_execz BB0_30
; %bb.25:
	buffer_load_dword v8, off, s[0:3], s32 offset:88
	buffer_load_dword v9, off, s[0:3], s32 offset:92
	buffer_load_dword v0, off, s[0:3], s32 offset:96
	buffer_load_dword v1, off, s[0:3], s32 offset:100
	s_waitcnt vmcnt(2)
	global_load_dwordx2 v[6:7], v[8:9], off offset:40
	s_mov_b64 s[8:9], 1
	s_waitcnt vmcnt(0)
	v_add_co_u32_e64 v2, s[6:7], v6, s8
	v_mov_b32_e32 v3, s9
	v_addc_co_u32_e64 v3, s[6:7], v7, v3, s[6:7]
	v_add_co_u32_e64 v0, s[6:7], v2, v0
	v_addc_co_u32_e64 v1, s[6:7], v3, v1, s[6:7]
	s_mov_b64 s[6:7], 0
	v_cmp_eq_u64_e64 s[6:7], v[0:1], s[6:7]
	v_cndmask_b32_e64 v1, v1, v3, s[6:7]
	v_cndmask_b32_e64 v0, v0, v2, s[6:7]
	s_mov_b64 s[8:9], 24
	v_add_co_u32_e64 v4, s[6:7], v8, s8
	v_mov_b32_e32 v2, s9
	v_addc_co_u32_e64 v5, s[6:7], v9, v2, s[6:7]
	global_load_dwordx2 v[2:3], v[8:9], off offset:24 glc
	global_load_dwordx2 v[10:11], v[8:9], off
	v_and_b32_e32 v7, v1, v7
	v_and_b32_e32 v6, v0, v6
	s_mov_b32 s6, 24
	v_mul_hi_u32 v14, v6, s6
	s_mov_b32 s7, 32
	v_lshrrev_b64 v[12:13], s7, v[6:7]
	v_mul_lo_u32 v7, v12, s6
	v_add_u32_e64 v7, v14, v7
	v_lshlrev_b64 v[12:13], s7, v[7:8]
	v_mul_lo_u32 v6, v6, s6
	s_mov_b32 s6, 0
	v_mov_b32_e32 v7, 0
	v_or_b32_e32 v7, v7, v13
	v_or_b32_e32 v6, v6, v12
	s_waitcnt vmcnt(0)
	v_add_co_u32_e64 v6, s[6:7], v10, v6
	v_addc_co_u32_e64 v7, s[6:7], v11, v7, s[6:7]
	global_store_dwordx2 v[6:7], v[2:3], off
	s_waitcnt vmcnt(0)
	global_atomic_cmpswap_x2 v[8:9], v[8:9], v[0:3], off offset:24 glc
	s_waitcnt vmcnt(0)
	v_cmp_eq_u64_e64 s[6:7], v[8:9], v[2:3]
	v_cmp_ne_u64_e64 s[6:7], v[8:9], v[2:3]
	s_mov_b64 s[8:9], exec
	s_and_b64 s[6:7], s[8:9], s[6:7]
	s_mov_b64 exec, s[6:7]
; %bb.26:                               ; %.preheader
	s_mov_b64 s[6:7], 0
	s_branch BB0_28
BB0_27:                                 ; %Flow
	s_branch BB0_30
BB0_28:                                 ; =>This Inner Loop Header: Depth=1
                                        ; implicit-def: $sgpr8_sgpr9
	s_sleep 1
	global_store_dwordx2 v[6:7], v[8:9], off
	v_mov_b32_e32 v2, v8
	v_mov_b32_e32 v3, v9
	s_waitcnt vmcnt(0)
	global_atomic_cmpswap_x2 v[2:3], v[4:5], v[0:3], off glc
	s_waitcnt vmcnt(0)
	v_cmp_eq_u64_e64 s[8:9], v[2:3], v[8:9]
	s_or_b64 s[6:7], s[8:9], s[6:7]
	v_mov_b32_e32 v9, v3
	v_mov_b32_e32 v8, v2
	s_andn2_b64 exec, exec, s[6:7]
	s_cbranch_execnz BB0_28
; %bb.29:                               ; %.exit.loopexit
	s_branch BB0_27
BB0_30:                                 ; %.exit
	s_or_b64 exec, exec, s[4:5]
	buffer_load_dword v0, off, s[0:3], s32 offset:128
	buffer_load_dword v1, off, s[0:3], s32 offset:132
	buffer_load_dword v2, off, s[0:3], s32 offset:136
	buffer_load_dword v3, off, s[0:3], s32 offset:140
	s_waitcnt vmcnt(0) lgkmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end0:
	.size	__ockl_hostcall_internal, .Lfunc_end0-__ockl_hostcall_internal
                                        ; -- End function
	.section	.AMDGPU.csdata
; Function info:
; codeLenInByte = 2776
; NumSgprs: 35
; NumVgprs: 23
; ScratchSize: 160
; MemoryBound: 0
	.text
	.protected	hello_world             ; -- Begin function hello_world
	.globl	hello_world
	.p2align	8
	.type	hello_world,@function
hello_world:                            ; @hello_world
hello_world$local:
; %bb.0:                                ; %entry
	s_load_dword s4, s[4:5], 0x4
	s_add_u32 flat_scratch_lo, s8, s11
	s_addc_u32 flat_scratch_hi, s9, 0
	s_add_u32 s0, s0, s11
	s_addc_u32 s1, s1, 0
	v_mov_b32_e32 v1, 0
	s_waitcnt lgkmcnt(0)
	s_and_b32 s4, s4, 0xffff
	v_mov_b32_e32 v2, s10
	v_mad_u64_u32 v[0:1], s[4:5], s4, v2, v[0:1]
	s_mov_b32 s32, 0
	v_cmp_gt_i32_e32 vcc, 64, v0
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz BB1_2
; %bb.1:                                ; %if.then
	s_load_dwordx4 s[8:11], s[6:7], 0x0
	v_mov_b32_e32 v1, 0
	v_mov_b32_e32 v2, v0
	v_ashrrev_i64 v[0:1], 30, v[1:2]
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v3, s11
	v_add_co_u32_e32 v2, vcc, s10, v0
	v_addc_co_u32_e32 v3, vcc, v3, v1, vcc
	v_mov_b32_e32 v4, s9
	v_add_co_u32_e32 v0, vcc, s8, v0
	v_addc_co_u32_e32 v1, vcc, v4, v1, vcc
	global_load_dword v0, v[0:1], off
	s_waitcnt vmcnt(0)
	global_store_dword v[2:3], v0, off
BB1_2:                                  ; %if.end
	s_or_b64 exec, exec, s[4:5]
	s_load_dwordx2 s[14:15], s[6:7], 0x28
	v_mov_b32_e32 v3, 0
	v_mov_b32_e32 v2, 33
	v_mov_b32_e32 v4, v3
	v_mov_b32_e32 v5, v3
	s_waitcnt lgkmcnt(0)
	v_mov_b32_e32 v0, s14
	v_mov_b32_e32 v1, s15
	v_mov_b32_e32 v6, v3
	v_mov_b32_e32 v7, v3
	v_mov_b32_e32 v8, v3
	v_mov_b32_e32 v9, v3
	v_mov_b32_e32 v10, v3
	v_mov_b32_e32 v11, v3
	v_mov_b32_e32 v12, v3
	v_mov_b32_e32 v13, v3
	v_mov_b32_e32 v14, v3
	v_mov_b32_e32 v15, v3
	v_mov_b32_e32 v16, v3
	v_mov_b32_e32 v17, v3
	s_getpc_b64 s[12:13]
	s_add_u32 s12, s12, __ockl_hostcall_internal@rel32@lo+4
	s_addc_u32 s13, s13, __ockl_hostcall_internal@rel32@hi+4
	s_swappc_b64 s[30:31], s[12:13]
	s_getpc_b64 s[4:5]
	s_add_u32 s4, s4, .str.1@rel32@lo+4
	s_addc_u32 s5, s5, .str.1@rel32@hi+4
	v_mov_b32_e32 v25, v0
	v_mov_b32_e32 v24, v1
	s_cmp_lg_u64 s[4:5], 0
	s_mov_b64 s[6:7], -1
	s_cbranch_scc1 BB1_5
; %bb.3:                                ; %Flow183
	s_and_b64 vcc, exec, s[6:7]
	s_cbranch_vccnz BB1_57
BB1_4:                                  ; %__ockl_printf_append_string_n.exit
	s_endpgm
BB1_5:
	v_mov_b32_e32 v27, s5
	v_and_b32_e32 v23, -3, v25
	s_mov_b32 s7, 0
	s_cselect_b32 s6, 13, 0
	v_mov_b32_e32 v26, s4
	v_mov_b32_e32 v0, v23
	v_mov_b32_e32 v29, s7
	v_mov_b32_e32 v28, s6
	s_mov_b32 s16, 0xffff
	s_movk_i32 s17, 0xff
	v_mov_b32_e32 v1, v24
	v_mov_b32_e32 v2, v25
	v_mov_b32_e32 v3, v26
	s_branch BB1_13
BB1_6:                                  ; %Flow164
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v60, 0
	s_waitcnt vmcnt(6)
	v_and_b32_e32 v59, s17, v59
	v_lshlrev_b64 v[61:62], 8, v[59:60]
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v59, s17, v58
	v_lshlrev_b64 v[63:64], 16, v[59:60]
	v_or_b32_sdwa v57, v61, v57 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v59, s17, v14
	v_or_b32_e32 v61, v57, v63
	v_lshlrev_b64 v[57:58], 24, v[59:60]
	v_or_b32_e32 v59, v62, v64
	v_or_b32_e32 v14, v61, v57
	v_or_b32_e32 v57, v59, v58
	s_waitcnt vmcnt(3)
	v_or_b32_sdwa v56, v57, v56 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	v_mov_b32_e32 v57, 8
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_sdwa v55, v57, v55 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v54, s17, v54
	v_or_b32_e32 v55, v56, v55
	v_lshlrev_b32_e32 v54, 16, v54
	v_or_b32_e32 v54, v55, v54
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v15, 24, v15
	v_or_b32_e32 v15, v54, v15
BB1_7:                                  ; %Flow167
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v54, 0
	s_waitcnt vmcnt(6)
	v_and_b32_e32 v53, s17, v53
	v_lshlrev_b64 v[55:56], 8, v[53:54]
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v53, s17, v52
	v_lshlrev_b64 v[57:58], 16, v[53:54]
	v_or_b32_sdwa v51, v55, v51 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v53, s17, v12
	v_or_b32_e32 v55, v51, v57
	v_lshlrev_b64 v[51:52], 24, v[53:54]
	v_or_b32_e32 v53, v56, v58
	v_or_b32_e32 v12, v55, v51
	v_or_b32_e32 v51, v53, v52
	s_waitcnt vmcnt(3)
	v_or_b32_sdwa v50, v51, v50 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	v_mov_b32_e32 v51, 8
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_sdwa v49, v51, v49 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v48, s17, v48
	v_or_b32_e32 v49, v50, v49
	v_lshlrev_b32_e32 v48, 16, v48
	v_or_b32_e32 v48, v49, v48
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v13, 24, v13
	v_or_b32_e32 v13, v48, v13
BB1_8:                                  ; %Flow170
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v48, 0
	s_waitcnt vmcnt(6)
	v_and_b32_e32 v47, s17, v47
	v_lshlrev_b64 v[49:50], 8, v[47:48]
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v47, s17, v46
	v_lshlrev_b64 v[51:52], 16, v[47:48]
	v_or_b32_sdwa v45, v49, v45 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v47, s17, v10
	v_or_b32_e32 v49, v45, v51
	v_lshlrev_b64 v[45:46], 24, v[47:48]
	v_or_b32_e32 v47, v50, v52
	v_or_b32_e32 v10, v49, v45
	v_or_b32_e32 v45, v47, v46
	s_waitcnt vmcnt(3)
	v_or_b32_sdwa v44, v45, v44 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	v_mov_b32_e32 v45, 8
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_sdwa v43, v45, v43 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v42, s17, v42
	v_or_b32_e32 v43, v44, v43
	v_lshlrev_b32_e32 v42, 16, v42
	v_or_b32_e32 v42, v43, v42
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v11, 24, v11
	v_or_b32_e32 v11, v42, v11
BB1_9:                                  ; %Flow173
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v42, 0
	s_waitcnt vmcnt(6)
	v_and_b32_e32 v41, s17, v41
	v_lshlrev_b64 v[43:44], 8, v[41:42]
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v41, s17, v40
	v_lshlrev_b64 v[45:46], 16, v[41:42]
	v_or_b32_sdwa v39, v43, v39 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v41, s17, v8
	v_or_b32_e32 v43, v39, v45
	v_lshlrev_b64 v[39:40], 24, v[41:42]
	v_or_b32_e32 v41, v44, v46
	v_or_b32_e32 v8, v43, v39
	v_or_b32_e32 v39, v41, v40
	s_waitcnt vmcnt(3)
	v_or_b32_sdwa v38, v39, v38 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	v_mov_b32_e32 v39, 8
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_sdwa v37, v39, v37 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v36, s17, v36
	v_or_b32_e32 v37, v38, v37
	v_lshlrev_b32_e32 v36, 16, v36
	v_or_b32_e32 v36, v37, v36
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v9, 24, v9
	v_or_b32_e32 v9, v36, v9
BB1_10:                                 ; %Flow176
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v36, 0
	s_waitcnt vmcnt(6)
	v_and_b32_e32 v35, s17, v35
	v_lshlrev_b64 v[37:38], 8, v[35:36]
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v35, s17, v34
	v_lshlrev_b64 v[39:40], 16, v[35:36]
	v_or_b32_sdwa v33, v37, v33 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v35, s17, v6
	v_or_b32_e32 v37, v33, v39
	v_lshlrev_b64 v[33:34], 24, v[35:36]
	v_or_b32_e32 v35, v38, v40
	v_or_b32_e32 v6, v37, v33
	v_or_b32_e32 v33, v35, v34
	s_waitcnt vmcnt(3)
	v_or_b32_sdwa v32, v33, v32 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	v_mov_b32_e32 v33, 8
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_sdwa v23, v33, v23 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v22, s17, v22
	v_or_b32_e32 v23, v32, v23
	v_lshlrev_b32_e32 v22, 16, v22
	v_or_b32_e32 v22, v23, v22
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v7, 24, v7
	v_or_b32_e32 v7, v22, v7
BB1_11:                                 ; %Flow179
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v22, 0
	s_waitcnt vmcnt(6)
	v_and_b32_e32 v21, s17, v21
	v_lshlrev_b64 v[32:33], 8, v[21:22]
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v21, s17, v20
	v_lshlrev_b64 v[34:35], 16, v[21:22]
	v_or_b32_sdwa v19, v32, v19 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v21, s17, v4
	v_or_b32_e32 v23, v19, v34
	v_lshlrev_b64 v[19:20], 24, v[21:22]
	v_or_b32_e32 v21, v33, v35
	v_or_b32_e32 v4, v23, v19
	v_or_b32_e32 v19, v21, v20
	s_waitcnt vmcnt(3)
	v_or_b32_sdwa v18, v19, v18 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	v_mov_b32_e32 v19, 8
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_sdwa v5, v19, v5 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:BYTE_0
	s_waitcnt vmcnt(1)
	v_and_b32_e32 v3, s17, v3
	v_or_b32_e32 v5, v18, v5
	v_lshlrev_b32_e32 v3, 16, v3
	v_or_b32_e32 v3, v5, v3
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v2, 24, v2
	v_or_b32_e32 v5, v3, v2
BB1_12:                                 ; %.loopexit
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_lshlrev_b64 v[2:3], 2, v[30:31]
	v_or_b32_e32 v18, 2, v0
	v_add_co_u32_e32 v2, vcc, 28, v2
	v_addc_co_u32_e32 v3, vcc, 0, v3, vcc
	v_cmp_lt_u64_e32 vcc, 56, v[28:29]
	v_or_b32_e32 v3, v1, v3
	v_cndmask_b32_e32 v0, v18, v0, vcc
	v_and_b32_e32 v1, 0xffffffe0, v2
	v_and_b32_e32 v0, 0xffffff1f, v0
	v_or_b32_e32 v2, v0, v1
	v_mov_b32_e32 v0, s14
	v_mov_b32_e32 v1, s15
	s_swappc_b64 s[30:31], s[12:13]
	v_sub_co_u32_e32 v28, vcc, v28, v30
	v_subb_co_u32_e32 v29, vcc, v29, v31, vcc
	v_cmp_ne_u64_e32 vcc, 0, v[28:29]
	v_add_co_u32_e64 v26, s[4:5], v26, v30
	s_and_b64 vcc, exec, vcc
	v_addc_co_u32_e64 v27, s[4:5], v27, v31, s[4:5]
	s_cbranch_vccz BB1_56
BB1_13:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB1_16 Depth 2
                                        ;     Child Loop BB1_22 Depth 2
                                        ;     Child Loop BB1_28 Depth 2
                                        ;     Child Loop BB1_34 Depth 2
                                        ;     Child Loop BB1_40 Depth 2
                                        ;     Child Loop BB1_46 Depth 2
                                        ;     Child Loop BB1_52 Depth 2
	v_cmp_gt_u64_e32 vcc, 56, v[28:29]
	v_cndmask_b32_e32 v30, 56, v28, vcc
	v_cndmask_b32_e32 v31, 0, v29, vcc
	v_cmp_lt_u32_e32 vcc, 7, v30
	s_and_b64 vcc, exec, vcc
	s_cbranch_vccnz BB1_17
; %bb.14:                               ;   in Loop: Header=BB1_13 Depth=1
	v_cmp_eq_u32_e32 vcc, 0, v30
	v_mov_b32_e32 v4, 0
	s_mov_b64 s[4:5], 0
	s_and_b64 vcc, exec, vcc
	v_mov_b32_e32 v5, 0
	s_cbranch_vccnz BB1_18
; %bb.15:                               ; %.preheader22.preheader
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v4, 0
	v_mov_b32_e32 v6, v26
	v_lshlrev_b32_e32 v2, 3, v30
	s_mov_b32 s6, 0
	v_mov_b32_e32 v5, 0
	v_mov_b32_e32 v7, v27
BB1_16:                                 ; %.preheader22
                                        ;   Parent Loop BB1_13 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	global_load_ubyte v3, v[6:7], off
	v_add_co_u32_e32 v6, vcc, 1, v6
	s_and_b32 s7, s6, 56
	v_mov_b32_e32 v9, 0
	s_add_i32 s6, s6, 8
	v_addc_co_u32_e32 v7, vcc, 0, v7, vcc
	v_cmp_eq_u32_e32 vcc, s6, v2
	s_and_b64 vcc, exec, vcc
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v8, s16, v3
	v_lshlrev_b64 v[8:9], s7, v[8:9]
	v_or_b32_e32 v4, v8, v4
	v_or_b32_e32 v5, v9, v5
	s_cbranch_vccz BB1_16
	s_branch BB1_18
BB1_17:                                 ;   in Loop: Header=BB1_13 Depth=1
	s_mov_b64 s[4:5], -1
                                        ; implicit-def: $vgpr4_vgpr5
BB1_18:                                 ; %Flow181
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v14, 0
	v_mov_b32_e32 v15, 0
	v_mov_b32_e32 v10, v14
	v_mov_b32_e32 v6, v14
	v_mov_b32_e32 v8, v14
	v_mov_b32_e32 v12, v14
	v_mov_b32_e32 v17, v15
	s_andn2_b64 vcc, exec, s[4:5]
	v_mov_b32_e32 v11, v15
	v_mov_b32_e32 v7, v15
	v_mov_b32_e32 v9, v15
	v_mov_b32_e32 v13, v15
	v_mov_b32_e32 v16, v14
	s_cbranch_vccnz BB1_12
; %bb.19:                               ;   in Loop: Header=BB1_13 Depth=1
	global_load_ubyte v19, v[26:27], off
	global_load_ubyte v21, v[26:27], off offset:1
	global_load_ubyte v20, v[26:27], off offset:2
	global_load_ubyte v4, v[26:27], off offset:3
	global_load_ubyte v18, v[26:27], off offset:4
	global_load_ubyte v5, v[26:27], off offset:5
	global_load_ubyte v3, v[26:27], off offset:6
	global_load_ubyte v2, v[26:27], off offset:7
	v_add_u32_e32 v8, -8, v30
	v_cmp_lt_u32_e32 vcc, 7, v8
	s_and_b64 vcc, exec, vcc
	s_cbranch_vccnz BB1_23
; %bb.20:                               ;   in Loop: Header=BB1_13 Depth=1
	v_cmp_eq_u32_e32 vcc, 0, v8
	v_mov_b32_e32 v6, 0
	s_mov_b64 s[4:5], 0
	s_and_b64 vcc, exec, vcc
	v_mov_b32_e32 v7, 0
	s_cbranch_vccnz BB1_24
; %bb.21:                               ; %.preheader20.preheader
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_add_co_u32_e32 v9, vcc, 8, v26
	v_mov_b32_e32 v6, 0
	v_addc_co_u32_e32 v10, vcc, 0, v27, vcc
	s_mov_b32 s6, 0
	v_mov_b32_e32 v7, 0
BB1_22:                                 ; %.preheader20
                                        ;   Parent Loop BB1_13 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	global_load_ubyte v11, v[9:10], off
	v_add_co_u32_e32 v9, vcc, 1, v9
	s_and_b32 s7, s6, 56
	v_mov_b32_e32 v12, 0
	v_add_u32_e32 v8, -1, v8
	v_addc_co_u32_e32 v10, vcc, 0, v10, vcc
	v_cmp_eq_u32_e32 vcc, 0, v8
	s_add_i32 s6, s6, 8
	s_and_b64 vcc, exec, vcc
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v11, s16, v11
	v_lshlrev_b64 v[11:12], s7, v[11:12]
	v_or_b32_e32 v6, v11, v6
	v_or_b32_e32 v7, v12, v7
	s_cbranch_vccz BB1_22
	s_branch BB1_24
BB1_23:                                 ;   in Loop: Header=BB1_13 Depth=1
	s_mov_b64 s[4:5], -1
                                        ; implicit-def: $vgpr6_vgpr7
BB1_24:                                 ; %Flow178
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	v_mov_b32_e32 v12, v16
	v_mov_b32_e32 v8, v16
	v_mov_b32_e32 v10, v16
	v_mov_b32_e32 v14, v16
	s_andn2_b64 vcc, exec, s[4:5]
	v_mov_b32_e32 v13, v17
	v_mov_b32_e32 v9, v17
	v_mov_b32_e32 v11, v17
	v_mov_b32_e32 v15, v17
	s_cbranch_vccnz BB1_11
; %bb.25:                               ;   in Loop: Header=BB1_13 Depth=1
	global_load_ubyte v33, v[26:27], off offset:8
	global_load_ubyte v35, v[26:27], off offset:9
	global_load_ubyte v34, v[26:27], off offset:10
	global_load_ubyte v6, v[26:27], off offset:11
	global_load_ubyte v32, v[26:27], off offset:12
	global_load_ubyte v23, v[26:27], off offset:13
	global_load_ubyte v22, v[26:27], off offset:14
	global_load_ubyte v7, v[26:27], off offset:15
	v_add_u32_e32 v10, -16, v30
	v_cmp_lt_u32_e32 vcc, 7, v10
	s_and_b64 vcc, exec, vcc
	s_cbranch_vccnz BB1_29
; %bb.26:                               ;   in Loop: Header=BB1_13 Depth=1
	v_cmp_eq_u32_e32 vcc, 0, v10
	v_mov_b32_e32 v8, 0
	s_mov_b64 s[4:5], 0
	s_and_b64 vcc, exec, vcc
	v_mov_b32_e32 v9, 0
	s_cbranch_vccnz BB1_30
; %bb.27:                               ; %.preheader18.preheader
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_add_co_u32_e32 v11, vcc, 16, v26
	v_mov_b32_e32 v8, 0
	v_addc_co_u32_e32 v12, vcc, 0, v27, vcc
	s_mov_b32 s6, 0
	v_mov_b32_e32 v9, 0
BB1_28:                                 ; %.preheader18
                                        ;   Parent Loop BB1_13 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	global_load_ubyte v13, v[11:12], off
	v_add_co_u32_e32 v11, vcc, 1, v11
	s_and_b32 s7, s6, 56
	v_mov_b32_e32 v14, 0
	v_add_u32_e32 v10, -1, v10
	v_addc_co_u32_e32 v12, vcc, 0, v12, vcc
	v_cmp_eq_u32_e32 vcc, 0, v10
	s_add_i32 s6, s6, 8
	s_and_b64 vcc, exec, vcc
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v13, s16, v13
	v_lshlrev_b64 v[13:14], s7, v[13:14]
	v_or_b32_e32 v8, v13, v8
	v_or_b32_e32 v9, v14, v9
	s_cbranch_vccz BB1_28
	s_branch BB1_30
BB1_29:                                 ;   in Loop: Header=BB1_13 Depth=1
	s_mov_b64 s[4:5], -1
                                        ; implicit-def: $vgpr8_vgpr9
BB1_30:                                 ; %Flow175
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	v_mov_b32_e32 v12, v16
	v_mov_b32_e32 v10, v16
	v_mov_b32_e32 v14, v16
	s_andn2_b64 vcc, exec, s[4:5]
	v_mov_b32_e32 v13, v17
	v_mov_b32_e32 v11, v17
	v_mov_b32_e32 v15, v17
	s_cbranch_vccnz BB1_10
; %bb.31:                               ;   in Loop: Header=BB1_13 Depth=1
	global_load_ubyte v39, v[26:27], off offset:16
	global_load_ubyte v41, v[26:27], off offset:17
	global_load_ubyte v40, v[26:27], off offset:18
	global_load_ubyte v8, v[26:27], off offset:19
	global_load_ubyte v38, v[26:27], off offset:20
	global_load_ubyte v37, v[26:27], off offset:21
	global_load_ubyte v36, v[26:27], off offset:22
	global_load_ubyte v9, v[26:27], off offset:23
	v_subrev_u32_e32 v12, 24, v30
	v_cmp_lt_u32_e32 vcc, 7, v12
	s_and_b64 vcc, exec, vcc
	s_cbranch_vccnz BB1_35
; %bb.32:                               ;   in Loop: Header=BB1_13 Depth=1
	v_cmp_eq_u32_e32 vcc, 0, v12
	v_mov_b32_e32 v10, 0
	s_mov_b64 s[4:5], 0
	s_and_b64 vcc, exec, vcc
	v_mov_b32_e32 v11, 0
	s_cbranch_vccnz BB1_36
; %bb.33:                               ; %.preheader16.preheader
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_add_co_u32_e32 v13, vcc, 24, v26
	v_mov_b32_e32 v10, 0
	v_addc_co_u32_e32 v14, vcc, 0, v27, vcc
	s_mov_b32 s6, 0
	v_mov_b32_e32 v11, 0
BB1_34:                                 ; %.preheader16
                                        ;   Parent Loop BB1_13 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	global_load_ubyte v15, v[13:14], off
	v_add_co_u32_e32 v13, vcc, 1, v13
	s_and_b32 s7, s6, 56
	v_mov_b32_e32 v16, 0
	v_add_u32_e32 v12, -1, v12
	v_addc_co_u32_e32 v14, vcc, 0, v14, vcc
	v_cmp_eq_u32_e32 vcc, 0, v12
	s_add_i32 s6, s6, 8
	s_and_b64 vcc, exec, vcc
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v15, s16, v15
	v_lshlrev_b64 v[15:16], s7, v[15:16]
	v_or_b32_e32 v10, v15, v10
	v_or_b32_e32 v11, v16, v11
	s_cbranch_vccz BB1_34
	s_branch BB1_36
BB1_35:                                 ;   in Loop: Header=BB1_13 Depth=1
	s_mov_b64 s[4:5], -1
                                        ; implicit-def: $vgpr10_vgpr11
BB1_36:                                 ; %Flow172
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	v_mov_b32_e32 v12, v16
	v_mov_b32_e32 v14, v16
	s_andn2_b64 vcc, exec, s[4:5]
	v_mov_b32_e32 v13, v17
	v_mov_b32_e32 v15, v17
	s_cbranch_vccnz BB1_9
; %bb.37:                               ;   in Loop: Header=BB1_13 Depth=1
	global_load_ubyte v45, v[26:27], off offset:24
	global_load_ubyte v47, v[26:27], off offset:25
	global_load_ubyte v46, v[26:27], off offset:26
	global_load_ubyte v10, v[26:27], off offset:27
	global_load_ubyte v44, v[26:27], off offset:28
	global_load_ubyte v43, v[26:27], off offset:29
	global_load_ubyte v42, v[26:27], off offset:30
	global_load_ubyte v11, v[26:27], off offset:31
	v_subrev_u32_e32 v14, 32, v30
	v_cmp_lt_u32_e32 vcc, 7, v14
	s_and_b64 vcc, exec, vcc
	s_cbranch_vccnz BB1_41
; %bb.38:                               ;   in Loop: Header=BB1_13 Depth=1
	v_cmp_eq_u32_e32 vcc, 0, v14
	v_mov_b32_e32 v12, 0
	s_mov_b64 s[4:5], 0
	s_and_b64 vcc, exec, vcc
	v_mov_b32_e32 v13, 0
	s_cbranch_vccnz BB1_42
; %bb.39:                               ; %.preheader14.preheader
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_add_co_u32_e32 v15, vcc, 32, v26
	v_mov_b32_e32 v12, 0
	v_addc_co_u32_e32 v16, vcc, 0, v27, vcc
	s_mov_b32 s6, 0
	v_mov_b32_e32 v13, 0
BB1_40:                                 ; %.preheader14
                                        ;   Parent Loop BB1_13 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	global_load_ubyte v17, v[15:16], off
	v_add_co_u32_e32 v15, vcc, 1, v15
	s_and_b32 s7, s6, 56
	v_mov_b32_e32 v49, 0
	v_add_u32_e32 v14, -1, v14
	v_addc_co_u32_e32 v16, vcc, 0, v16, vcc
	v_cmp_eq_u32_e32 vcc, 0, v14
	s_add_i32 s6, s6, 8
	s_and_b64 vcc, exec, vcc
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v48, s16, v17
	v_lshlrev_b64 v[48:49], s7, v[48:49]
	v_or_b32_e32 v12, v48, v12
	v_or_b32_e32 v13, v49, v13
	s_cbranch_vccz BB1_40
	s_branch BB1_42
BB1_41:                                 ;   in Loop: Header=BB1_13 Depth=1
	s_mov_b64 s[4:5], -1
                                        ; implicit-def: $vgpr12_vgpr13
BB1_42:                                 ; %Flow169
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v16, 0
	v_mov_b32_e32 v17, 0
	v_mov_b32_e32 v14, v16
	s_andn2_b64 vcc, exec, s[4:5]
	v_mov_b32_e32 v15, v17
	s_cbranch_vccnz BB1_8
; %bb.43:                               ;   in Loop: Header=BB1_13 Depth=1
	global_load_ubyte v51, v[26:27], off offset:32
	global_load_ubyte v53, v[26:27], off offset:33
	global_load_ubyte v52, v[26:27], off offset:34
	global_load_ubyte v12, v[26:27], off offset:35
	global_load_ubyte v50, v[26:27], off offset:36
	global_load_ubyte v49, v[26:27], off offset:37
	global_load_ubyte v48, v[26:27], off offset:38
	global_load_ubyte v13, v[26:27], off offset:39
	v_subrev_u32_e32 v16, 40, v30
	v_cmp_lt_u32_e32 vcc, 7, v16
	s_and_b64 vcc, exec, vcc
	s_cbranch_vccnz BB1_47
; %bb.44:                               ;   in Loop: Header=BB1_13 Depth=1
	v_cmp_eq_u32_e32 vcc, 0, v16
	v_mov_b32_e32 v14, 0
	s_mov_b64 s[4:5], 0
	s_and_b64 vcc, exec, vcc
	v_mov_b32_e32 v15, 0
	s_cbranch_vccnz BB1_48
; %bb.45:                               ; %.preheader12.preheader
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_add_co_u32_e32 v54, vcc, 40, v26
	v_mov_b32_e32 v14, 0
	v_addc_co_u32_e32 v55, vcc, 0, v27, vcc
	s_mov_b32 s6, 0
	v_mov_b32_e32 v15, 0
BB1_46:                                 ; %.preheader12
                                        ;   Parent Loop BB1_13 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	global_load_ubyte v17, v[54:55], off
	v_add_co_u32_e32 v54, vcc, 1, v54
	s_and_b32 s7, s6, 56
	v_mov_b32_e32 v57, 0
	v_add_u32_e32 v16, -1, v16
	v_addc_co_u32_e32 v55, vcc, 0, v55, vcc
	v_cmp_eq_u32_e32 vcc, 0, v16
	s_add_i32 s6, s6, 8
	s_and_b64 vcc, exec, vcc
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v56, s16, v17
	v_lshlrev_b64 v[56:57], s7, v[56:57]
	v_or_b32_e32 v14, v56, v14
	v_or_b32_e32 v15, v57, v15
	s_cbranch_vccz BB1_46
	s_branch BB1_48
BB1_47:                                 ;   in Loop: Header=BB1_13 Depth=1
	s_mov_b64 s[4:5], -1
                                        ; implicit-def: $vgpr14_vgpr15
BB1_48:                                 ; %Flow166
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_mov_b32_e32 v16, 0
	s_andn2_b64 vcc, exec, s[4:5]
	v_mov_b32_e32 v17, 0
	s_cbranch_vccnz BB1_7
; %bb.49:                               ;   in Loop: Header=BB1_13 Depth=1
	global_load_ubyte v57, v[26:27], off offset:40
	global_load_ubyte v59, v[26:27], off offset:41
	global_load_ubyte v58, v[26:27], off offset:42
	global_load_ubyte v14, v[26:27], off offset:43
	global_load_ubyte v56, v[26:27], off offset:44
	global_load_ubyte v55, v[26:27], off offset:45
	global_load_ubyte v54, v[26:27], off offset:46
	global_load_ubyte v15, v[26:27], off offset:47
	v_subrev_u32_e32 v60, 48, v30
	v_cmp_lt_u32_e32 vcc, 7, v60
	s_and_b64 vcc, exec, vcc
	s_cbranch_vccnz BB1_53
; %bb.50:                               ;   in Loop: Header=BB1_13 Depth=1
	v_cmp_eq_u32_e32 vcc, 0, v60
	v_mov_b32_e32 v16, 0
	s_mov_b64 s[4:5], 0
	s_and_b64 vcc, exec, vcc
	v_mov_b32_e32 v17, 0
	s_cbranch_vccnz BB1_54
; %bb.51:                               ; %.preheader.preheader
                                        ;   in Loop: Header=BB1_13 Depth=1
	v_add_co_u32_e32 v61, vcc, 48, v26
	v_mov_b32_e32 v16, 0
	v_addc_co_u32_e32 v62, vcc, 0, v27, vcc
	s_mov_b32 s6, 0
	v_mov_b32_e32 v17, 0
BB1_52:                                 ; %.preheader
                                        ;   Parent Loop BB1_13 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	global_load_ubyte v63, v[61:62], off
	v_add_co_u32_e32 v61, vcc, 1, v61
	s_and_b32 s7, s6, 56
	v_mov_b32_e32 v64, 0
	v_add_u32_e32 v60, -1, v60
	v_addc_co_u32_e32 v62, vcc, 0, v62, vcc
	v_cmp_eq_u32_e32 vcc, 0, v60
	s_add_i32 s6, s6, 8
	s_and_b64 vcc, exec, vcc
	s_waitcnt vmcnt(0)
	v_and_b32_e32 v63, s16, v63
	v_lshlrev_b64 v[63:64], s7, v[63:64]
	v_or_b32_e32 v16, v63, v16
	v_or_b32_e32 v17, v64, v17
	s_cbranch_vccz BB1_52
	s_branch BB1_54
BB1_53:                                 ;   in Loop: Header=BB1_13 Depth=1
	s_mov_b64 s[4:5], -1
                                        ; implicit-def: $vgpr16_vgpr17
BB1_54:                                 ; %Flow163
                                        ;   in Loop: Header=BB1_13 Depth=1
	s_andn2_b64 vcc, exec, s[4:5]
	s_cbranch_vccnz BB1_6
; %bb.55:                               ;   in Loop: Header=BB1_13 Depth=1
	global_load_ubyte v60, v[26:27], off offset:48
	global_load_ubyte v16, v[26:27], off offset:49
	global_load_ubyte v61, v[26:27], off offset:50
	global_load_ubyte v62, v[26:27], off offset:51
	global_load_ubyte v63, v[26:27], off offset:52
	global_load_ubyte v64, v[26:27], off offset:53
	global_load_ubyte v65, v[26:27], off offset:54
	global_load_ubyte v66, v[26:27], off offset:55
	v_mov_b32_e32 v17, 0
	s_waitcnt vmcnt(6)
	v_lshlrev_b16_e32 v67, 8, v16
	s_waitcnt vmcnt(5)
	v_and_b32_e32 v16, s16, v61
	v_or_b32_e32 v67, v67, v60
	v_lshlrev_b64 v[60:61], 16, v[16:17]
	s_waitcnt vmcnt(4)
	v_and_b32_e32 v16, s16, v62
	v_lshlrev_b64 v[16:17], 24, v[16:17]
	s_waitcnt vmcnt(2)
	v_lshlrev_b32_e32 v64, 8, v64
	v_or_b32_e32 v17, v61, v17
	v_or_b32_e32 v17, v17, v63
	v_or_b32_sdwa v60, v67, v60 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_0 src1_sel:DWORD
	s_waitcnt vmcnt(1)
	v_lshlrev_b32_e32 v65, 16, v65
	v_or_b32_e32 v17, v17, v64
	v_or_b32_e32 v16, v60, v16
	v_or_b32_e32 v17, v17, v65
	s_waitcnt vmcnt(0)
	v_lshlrev_b32_e32 v60, 24, v66
	v_or_b32_e32 v17, v17, v60
	s_branch BB1_6
BB1_56:                                 ; %Flow182
	s_branch BB1_4
BB1_57:
	v_mov_b32_e32 v4, 0
	s_movk_i32 s4, 0xff1d
	v_and_or_b32 v2, v25, s4, 34
	v_mov_b32_e32 v0, s14
	v_mov_b32_e32 v1, s15
	v_mov_b32_e32 v3, v24
	v_mov_b32_e32 v5, v4
	v_mov_b32_e32 v6, v4
	v_mov_b32_e32 v7, v4
	v_mov_b32_e32 v8, v4
	v_mov_b32_e32 v9, v4
	v_mov_b32_e32 v10, v4
	v_mov_b32_e32 v11, v4
	v_mov_b32_e32 v12, v4
	v_mov_b32_e32 v13, v4
	v_mov_b32_e32 v14, v4
	v_mov_b32_e32 v15, v4
	v_mov_b32_e32 v16, v4
	v_mov_b32_e32 v17, v4
	s_swappc_b64 s[30:31], s[12:13]
	s_endpgm
	.section	.rodata,#alloc
	.p2align	6
	.amdhsa_kernel hello_world
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 160
		.amdhsa_user_sgpr_private_segment_buffer 1
		.amdhsa_user_sgpr_dispatch_ptr 1
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_flat_scratch_init 1
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_system_sgpr_private_segment_wavefront_offset 1
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 0
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 68
		.amdhsa_next_free_sgpr 33
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end1:
	.size	hello_world, .Lfunc_end1-hello_world
                                        ; -- End function
	.section	.AMDGPU.csdata
; Kernel info:
; codeLenInByte = 3112
; NumSgprs: 39
; NumVgprs: 68
; ScratchSize: 160
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 4
; VGPRBlocks: 16
; NumSGPRsForWavesPerEU: 39
; NumVGPRsForWavesPerEU: 68
; Occupancy: 3
; WaveLimiterHint : 1
; COMPUTE_PGM_RSRC2:USER_SGPR: 10
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 0
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 0
	.type	.str.1,@object                  ; @.str.1
	.section	.rodata.str1.1,"aMS",@progbits,1
.str.1:
	.asciz	"hello world\n"
	.size	.str.1, 13

	.ident	"clang version 12.0.0 (git@172.18.220.101:zifang/radeonopencompute/llvm-project.git 2e7dd60abfdc4b6df36e9210612649a36d5d4d68)"
	.section	".note.GNU-stack"
	.addrsig
	.amdgpu_metadata
---
amdhsa.kernels:
  - .args:
      - .address_space:  global
        .name:           a.coerce
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .name:           b.coerce
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .offset:         16
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         24
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         32
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .address_space:  global
        .offset:         40
        .size:           8
        .value_kind:     hidden_hostcall_buffer
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     hidden_none
      - .address_space:  global
        .offset:         56
        .size:           8
        .value_kind:     hidden_none
      - .address_space:  global
        .offset:         64
        .size:           8
        .value_kind:     hidden_multigrid_sync_arg
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 72
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 256
    .name:           hello_world
    .private_segment_fixed_size: 160
    .sgpr_count:     39
    .sgpr_spill_count: 0
    .symbol:         hello_world.kd
    .vgpr_count:     68
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.version:
  - 1
  - 0
...

	.end_amdgpu_metadata
