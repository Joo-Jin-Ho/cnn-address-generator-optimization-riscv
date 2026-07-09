.text
global 0 ag_rAGU

    lhu     x5, 16(x0)             
    addi    x7, x5, -1

    // ------------------------------------------------------------
    // Hot path: S == 1
    // S==1이면 branch not taken으로 바로 1x1 path 실행.
    // mul/주소 계산 방식은 기존 ragu_1x1_fast와 동일하게 유지.
    // ------------------------------------------------------------
    bnez    x7, ragu_not_1x1

    lhu     x4, 6(x0)              // T_P
    lhu     x6, 14(x0)             // C

    mul     x10, x4, x10           // t_q * T_P
    addi    x7, x6, -4             // C == 4 ?
    add     x11, x10, x11          // t_q*T_P + t_p
    mul     x11, x6, x11           // word offset *= C

    lui     x10, 768               // BASE_SRAM_IN = 0x00300000
    lui     x14, 1296              // BASE_PE_IN   = 0x00510000
    sh2add  x15, x11, x10          // src pointer

    // ------------------------------------------------------------
    // Layer 2 hot path: S=1, C=4
    // C==4이면 branch not taken으로 바로 copy 실행.
    // 기존 ragu_c4_fast와 같은 동작을 inline해서 j를 줄임.
    // ------------------------------------------------------------
    bnez    x7, ragu_1x1_check_c8

    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)

    sw      x8, 0(x14)
    sw      x9, 4(x14)
    sw      x12, 8(x14)
    sw      x13, 12(x14)

    ret

ragu_1x1_check_c8:
    addi    x7, x6, -8
    bnez    x7, ragu_1x1_check_c16
    j       ragu_c8_fast

ragu_1x1_check_c16:
    addi    x7, x6, -16
    bnez    x7, ragu_1x1_go_c32
    j       ragu_c16_fast

ragu_1x1_go_c32:
    j       ragu_c32_fast


// -----------------------------------------------------------------------------
// S != 1 path
// 기존 3x3 / generic dispatch 유지.
// -----------------------------------------------------------------------------
ragu_not_1x1:
    lhu     x3, 18(x0)             // R
    lhu     x4, 6(x0)              // T_P
    lhu     x6, 14(x0)             // C

    addi    x7, x6, -4
    bnez    x7, ragu_check_c8
    j       ragu_3x3_c4_fast

ragu_check_c8:
    addi    x7, x6, -8
    bnez    x7, ragu_check_c16
    j       ragu_3x3_c8_fast

ragu_check_c16:
    addi    x7, x6, -16
    bnez    x7, ragu_check_c32
    j       ragu_3x3_c16_fast

ragu_check_c32:
    addi    x7, x6, -32
    bnez    x7, ragu_check_c2
    j       ragu_3x3_c32_fast

// -----------------------------------------------------------------------------
// Exact path: S=3, R=3, C=2
// Keep existing C=4/8/16/32 dispatch cost unchanged.
// C=2 falls here instead of generic loop.
// -----------------------------------------------------------------------------
ragu_check_c2:
    addi    x7, x6, -2
    bnez    x7, ragu_generic_start

    // Guard exact path: only S==3 and R==3.
    // If another C=2 layer appears, fall back to generic safely.
    addi    x7, x5, -3
    bnez    x7, ragu_generic_start
    addi    x7, x3, -3
    bnez    x7, ragu_generic_start
    j       ragu_3x3_c2_fast

ragu_generic_start:

    add     x4, x4, x3
    addi    x4, x4, -1

    mul     x3, x6, x3
    mul     x10, x4, x10
    mul     x4, x4, x6

    slli    x9, x3, 2
    add     x11, x10, x11
    slli    x4, x4, 2

    mul     x11, x6, x11
    lui     x10, 768
    sh2add  x11, x11, x10

    li      x12, 0
    lui     x6, 1296

ragu_row_loop:
    mv      x14, x6
    mv      x15, x11
    li      x13, 0

ragu_copy_loop:
    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)
    lw      x20, 16(x15)
    lw      x21, 20(x15)
    lw      x22, 24(x15)
    lw      x23, 28(x15)

    sw      x16, 0(x14)
    sw      x17, 4(x14)
    sw      x18, 8(x14)
    sw      x19, 12(x14)
    sw      x20, 16(x14)
    sw      x21, 20(x14)
    sw      x22, 24(x14)
    sw      x23, 28(x14)

    addi    x15, x15, 32
    addi    x14, x14, 32
    addi    x13, x13, 8
    bltu    x13, x3, ragu_copy_loop

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x4, x11
    bltu    x12, x5, ragu_row_loop

    ret

ragu_1x1_fast:
    lhu     x4, 6(x0)
    lhu     x6, 14(x0)

    mul     x10, x4, x10
    addi    x7, x6, -4
    add     x11, x10, x11
    mul     x11, x6, x11

    lui     x10, 768
    lui     x14, 1296
    sh2add  x15, x11, x10

    beqz    x7, ragu_c4_fast

    addi    x7, x6, -8
    beqz    x7, ragu_c8_fast

    addi    x7, x6, -16
    beqz    x7, ragu_c16_fast

    j       ragu_c32_fast

ragu_c4_fast:
    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)

    sw      x8, 0(x14)
    sw      x9, 4(x14)
    sw      x12, 8(x14)
    sw      x13, 12(x14)

    ret

ragu_c8_fast:
    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)
    lw      x16, 16(x15)
    lw      x17, 20(x15)
    lw      x18, 24(x15)
    lw      x19, 28(x15)

    sw      x8, 0(x14)
    sw      x9, 4(x14)
    sw      x12, 8(x14)
    sw      x13, 12(x14)
    sw      x16, 16(x14)
    sw      x17, 20(x14)
    sw      x18, 24(x14)
    sw      x19, 28(x14)

    ret

ragu_c16_fast:
    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)
    lw      x16, 16(x15)
    lw      x17, 20(x15)
    lw      x18, 24(x15)
    lw      x19, 28(x15)
    lw      x20, 32(x15)
    lw      x21, 36(x15)
    lw      x22, 40(x15)
    lw      x23, 44(x15)
    lw      x24, 48(x15)
    lw      x25, 52(x15)
    lw      x26, 56(x15)
    lw      x27, 60(x15)

    sw      x8, 0(x14)
    sw      x9, 4(x14)
    sw      x12, 8(x14)
    sw      x13, 12(x14)
    sw      x16, 16(x14)
    sw      x17, 20(x14)
    sw      x18, 24(x14)
    sw      x19, 28(x14)
    sw      x20, 32(x14)
    sw      x21, 36(x14)
    sw      x22, 40(x14)
    sw      x23, 44(x14)
    sw      x24, 48(x14)
    sw      x25, 52(x14)
    sw      x26, 56(x14)
    sw      x27, 60(x14)

    ret

ragu_c32_fast:
    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)
    lw      x16, 16(x15)
    lw      x17, 20(x15)
    lw      x18, 24(x15)
    lw      x19, 28(x15)
    lw      x20, 32(x15)
    lw      x21, 36(x15)
    lw      x22, 40(x15)
    lw      x23, 44(x15)
    lw      x24, 48(x15)
    lw      x25, 52(x15)
    lw      x26, 56(x15)
    lw      x27, 60(x15)

    sw      x8, 0(x14)
    sw      x9, 4(x14)
    sw      x12, 8(x14)
    sw      x13, 12(x14)
    sw      x16, 16(x14)
    sw      x17, 20(x14)
    sw      x18, 24(x14)
    sw      x19, 28(x14)
    sw      x20, 32(x14)
    sw      x21, 36(x14)
    sw      x22, 40(x14)
    sw      x23, 44(x14)
    sw      x24, 48(x14)
    sw      x25, 52(x14)
    sw      x26, 56(x14)
    sw      x27, 60(x14)

    lw      x8, 64(x15)
    lw      x9, 68(x15)
    lw      x12, 72(x15)
    lw      x13, 76(x15)
    lw      x16, 80(x15)
    lw      x17, 84(x15)
    lw      x18, 88(x15)
    lw      x19, 92(x15)
    lw      x20, 96(x15)
    lw      x21, 100(x15)
    lw      x22, 104(x15)
    lw      x23, 108(x15)
    lw      x24, 112(x15)
    lw      x25, 116(x15)
    lw      x26, 120(x15)
    lw      x27, 124(x15)

    sw      x8, 64(x14)
    sw      x9, 68(x14)
    sw      x12, 72(x14)
    sw      x13, 76(x14)
    sw      x16, 80(x14)
    sw      x17, 84(x14)
    sw      x18, 88(x14)
    sw      x19, 92(x14)
    sw      x20, 96(x14)
    sw      x21, 100(x14)
    sw      x22, 104(x14)
    sw      x23, 108(x14)
    sw      x24, 112(x14)
    sw      x25, 116(x14)
    sw      x26, 120(x14)
    sw      x27, 124(x14)

    ret

ragu_3x3_c2_fast:
    // S=3, R=3, C=2 exact path
    // row_len   = R*C = 6 words = 24 bytes
    // row_stride= (T_P+R-1)*C*4 bytes
    add     x4, x4, x3
    addi    x4, x4, -1

    mul     x10, x4, x10
    mul     x4, x4, x6
    add     x11, x10, x11
    slli    x4, x4, 2

    mul     x11, x6, x11
    lui     x10, 768
    lui     x14, 1296
    sh2add  x15, x11, x10

    // row 0: 6 words
    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)
    lw      x16, 16(x15)
    lw      x17, 20(x15)

    sw      x8, 0(x14)
    sw      x9, 4(x14)
    sw      x12, 8(x14)
    sw      x13, 12(x14)
    sw      x16, 16(x14)
    sw      x17, 20(x14)

    add     x15, x15, x4

    // row 1: 6 words
    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)
    lw      x16, 16(x15)
    lw      x17, 20(x15)

    sw      x8, 24(x14)
    sw      x9, 28(x14)
    sw      x12, 32(x14)
    sw      x13, 36(x14)
    sw      x16, 40(x14)
    sw      x17, 44(x14)

    add     x15, x15, x4

    // row 2: 6 words
    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)
    lw      x16, 16(x15)
    lw      x17, 20(x15)

    sw      x8, 48(x14)
    sw      x9, 52(x14)
    sw      x12, 56(x14)
    sw      x13, 60(x14)
    sw      x16, 64(x14)
    sw      x17, 68(x14)

    ret

ragu_3x3_c8_fast:
    addi    x4, x4, 2
    mul     x10, x4, x10
    slli    x4, x4, 5
    add     x11, x10, x11
    slli    x11, x11, 5
    lui     x10, 768
    add     x15, x10, x11
    lui     x14, 1296

    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)
    lw      x20, 16(x15)
    lw      x21, 20(x15)
    lw      x22, 24(x15)
    lw      x23, 28(x15)
    lw      x24, 32(x15)
    lw      x25, 36(x15)
    lw      x26, 40(x15)
    lw      x27, 44(x15)
    lw      x28, 48(x15)
    lw      x29, 52(x15)
    lw      x30, 56(x15)
    lw      x31, 60(x15)

    sw      x16, 0(x14)
    sw      x17, 4(x14)
    sw      x18, 8(x14)
    sw      x19, 12(x14)
    sw      x20, 16(x14)
    sw      x21, 20(x14)
    sw      x22, 24(x14)
    sw      x23, 28(x14)
    sw      x24, 32(x14)
    sw      x25, 36(x14)
    sw      x26, 40(x14)
    sw      x27, 44(x14)
    sw      x28, 48(x14)
    sw      x29, 52(x14)
    sw      x30, 56(x14)
    sw      x31, 60(x14)

    lw      x16, 64(x15)
    lw      x17, 68(x15)
    lw      x18, 72(x15)
    lw      x19, 76(x15)
    lw      x20, 80(x15)
    lw      x21, 84(x15)
    lw      x22, 88(x15)
    lw      x23, 92(x15)

    sw      x16, 64(x14)
    sw      x17, 68(x14)
    sw      x18, 72(x14)
    sw      x19, 76(x14)
    sw      x20, 80(x14)
    sw      x21, 84(x14)
    sw      x22, 88(x14)
    sw      x23, 92(x14)

    add     x15, x15, x4

    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)
    lw      x20, 16(x15)
    lw      x21, 20(x15)
    lw      x22, 24(x15)
    lw      x23, 28(x15)
    lw      x24, 32(x15)
    lw      x25, 36(x15)
    lw      x26, 40(x15)
    lw      x27, 44(x15)
    lw      x28, 48(x15)
    lw      x29, 52(x15)
    lw      x30, 56(x15)
    lw      x31, 60(x15)

    sw      x16, 96(x14)
    sw      x17, 100(x14)
    sw      x18, 104(x14)
    sw      x19, 108(x14)
    sw      x20, 112(x14)
    sw      x21, 116(x14)
    sw      x22, 120(x14)
    sw      x23, 124(x14)
    sw      x24, 128(x14)
    sw      x25, 132(x14)
    sw      x26, 136(x14)
    sw      x27, 140(x14)
    sw      x28, 144(x14)
    sw      x29, 148(x14)
    sw      x30, 152(x14)
    sw      x31, 156(x14)

    lw      x16, 64(x15)
    lw      x17, 68(x15)
    lw      x18, 72(x15)
    lw      x19, 76(x15)
    lw      x20, 80(x15)
    lw      x21, 84(x15)
    lw      x22, 88(x15)
    lw      x23, 92(x15)

    sw      x16, 160(x14)
    sw      x17, 164(x14)
    sw      x18, 168(x14)
    sw      x19, 172(x14)
    sw      x20, 176(x14)
    sw      x21, 180(x14)
    sw      x22, 184(x14)
    sw      x23, 188(x14)

    add     x15, x15, x4

    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)
    lw      x20, 16(x15)
    lw      x21, 20(x15)
    lw      x22, 24(x15)
    lw      x23, 28(x15)
    lw      x24, 32(x15)
    lw      x25, 36(x15)
    lw      x26, 40(x15)
    lw      x27, 44(x15)
    lw      x28, 48(x15)
    lw      x29, 52(x15)
    lw      x30, 56(x15)
    lw      x31, 60(x15)

    sw      x16, 192(x14)
    sw      x17, 196(x14)
    sw      x18, 200(x14)
    sw      x19, 204(x14)
    sw      x20, 208(x14)
    sw      x21, 212(x14)
    sw      x22, 216(x14)
    sw      x23, 220(x14)
    sw      x24, 224(x14)
    sw      x25, 228(x14)
    sw      x26, 232(x14)
    sw      x27, 236(x14)
    sw      x28, 240(x14)
    sw      x29, 244(x14)
    sw      x30, 248(x14)
    sw      x31, 252(x14)

    lw      x16, 64(x15)
    lw      x17, 68(x15)
    lw      x18, 72(x15)
    lw      x19, 76(x15)
    lw      x20, 80(x15)
    lw      x21, 84(x15)
    lw      x22, 88(x15)
    lw      x23, 92(x15)

    sw      x16, 256(x14)
    sw      x17, 260(x14)
    sw      x18, 264(x14)
    sw      x19, 268(x14)
    sw      x20, 272(x14)
    sw      x21, 276(x14)
    sw      x22, 280(x14)
    sw      x23, 284(x14)

    ret

ragu_3x3_c16_fast:
    addi    x4, x4, 2
    mul     x10, x4, x10
    slli    x4, x4, 6
    add     x11, x10, x11
    slli    x11, x11, 6
    lui     x10, 768
    add     x15, x10, x11
    lui     x14, 1296

    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)
    lw      x20, 16(x15)
    lw      x21, 20(x15)
    lw      x22, 24(x15)
    lw      x23, 28(x15)
    lw      x24, 32(x15)
    lw      x25, 36(x15)
    lw      x26, 40(x15)
    lw      x27, 44(x15)
    lw      x28, 48(x15)
    lw      x29, 52(x15)
    lw      x30, 56(x15)
    lw      x31, 60(x15)

    sw      x16, 0(x14)
    sw      x17, 4(x14)
    sw      x18, 8(x14)
    sw      x19, 12(x14)
    sw      x20, 16(x14)
    sw      x21, 20(x14)
    sw      x22, 24(x14)
    sw      x23, 28(x14)
    sw      x24, 32(x14)
    sw      x25, 36(x14)
    sw      x26, 40(x14)
    sw      x27, 44(x14)
    sw      x28, 48(x14)
    sw      x29, 52(x14)
    sw      x30, 56(x14)
    sw      x31, 60(x14)

    lw      x16, 64(x15)
    lw      x17, 68(x15)
    lw      x18, 72(x15)
    lw      x19, 76(x15)
    lw      x20, 80(x15)
    lw      x21, 84(x15)
    lw      x22, 88(x15)
    lw      x23, 92(x15)
    lw      x24, 96(x15)
    lw      x25, 100(x15)
    lw      x26, 104(x15)
    lw      x27, 108(x15)
    lw      x28, 112(x15)
    lw      x29, 116(x15)
    lw      x30, 120(x15)
    lw      x31, 124(x15)

    sw      x16, 64(x14)
    sw      x17, 68(x14)
    sw      x18, 72(x14)
    sw      x19, 76(x14)
    sw      x20, 80(x14)
    sw      x21, 84(x14)
    sw      x22, 88(x14)
    sw      x23, 92(x14)
    sw      x24, 96(x14)
    sw      x25, 100(x14)
    sw      x26, 104(x14)
    sw      x27, 108(x14)
    sw      x28, 112(x14)
    sw      x29, 116(x14)
    sw      x30, 120(x14)
    sw      x31, 124(x14)

    lw      x16, 128(x15)
    lw      x17, 132(x15)
    lw      x18, 136(x15)
    lw      x19, 140(x15)
    lw      x20, 144(x15)
    lw      x21, 148(x15)
    lw      x22, 152(x15)
    lw      x23, 156(x15)
    lw      x24, 160(x15)
    lw      x25, 164(x15)
    lw      x26, 168(x15)
    lw      x27, 172(x15)
    lw      x28, 176(x15)
    lw      x29, 180(x15)
    lw      x30, 184(x15)
    lw      x31, 188(x15)

    sw      x16, 128(x14)
    sw      x17, 132(x14)
    sw      x18, 136(x14)
    sw      x19, 140(x14)
    sw      x20, 144(x14)
    sw      x21, 148(x14)
    sw      x22, 152(x14)
    sw      x23, 156(x14)
    sw      x24, 160(x14)
    sw      x25, 164(x14)
    sw      x26, 168(x14)
    sw      x27, 172(x14)
    sw      x28, 176(x14)
    sw      x29, 180(x14)
    sw      x30, 184(x14)
    sw      x31, 188(x14)

    add     x15, x15, x4

    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)
    lw      x20, 16(x15)
    lw      x21, 20(x15)
    lw      x22, 24(x15)
    lw      x23, 28(x15)
    lw      x24, 32(x15)
    lw      x25, 36(x15)
    lw      x26, 40(x15)
    lw      x27, 44(x15)
    lw      x28, 48(x15)
    lw      x29, 52(x15)
    lw      x30, 56(x15)
    lw      x31, 60(x15)

    sw      x16, 192(x14)
    sw      x17, 196(x14)
    sw      x18, 200(x14)
    sw      x19, 204(x14)
    sw      x20, 208(x14)
    sw      x21, 212(x14)
    sw      x22, 216(x14)
    sw      x23, 220(x14)
    sw      x24, 224(x14)
    sw      x25, 228(x14)
    sw      x26, 232(x14)
    sw      x27, 236(x14)
    sw      x28, 240(x14)
    sw      x29, 244(x14)
    sw      x30, 248(x14)
    sw      x31, 252(x14)

    lw      x16, 64(x15)
    lw      x17, 68(x15)
    lw      x18, 72(x15)
    lw      x19, 76(x15)
    lw      x20, 80(x15)
    lw      x21, 84(x15)
    lw      x22, 88(x15)
    lw      x23, 92(x15)
    lw      x24, 96(x15)
    lw      x25, 100(x15)
    lw      x26, 104(x15)
    lw      x27, 108(x15)
    lw      x28, 112(x15)
    lw      x29, 116(x15)
    lw      x30, 120(x15)
    lw      x31, 124(x15)

    sw      x16, 256(x14)
    sw      x17, 260(x14)
    sw      x18, 264(x14)
    sw      x19, 268(x14)
    sw      x20, 272(x14)
    sw      x21, 276(x14)
    sw      x22, 280(x14)
    sw      x23, 284(x14)
    sw      x24, 288(x14)
    sw      x25, 292(x14)
    sw      x26, 296(x14)
    sw      x27, 300(x14)
    sw      x28, 304(x14)
    sw      x29, 308(x14)
    sw      x30, 312(x14)
    sw      x31, 316(x14)

    lw      x16, 128(x15)
    lw      x17, 132(x15)
    lw      x18, 136(x15)
    lw      x19, 140(x15)
    lw      x20, 144(x15)
    lw      x21, 148(x15)
    lw      x22, 152(x15)
    lw      x23, 156(x15)
    lw      x24, 160(x15)
    lw      x25, 164(x15)
    lw      x26, 168(x15)
    lw      x27, 172(x15)
    lw      x28, 176(x15)
    lw      x29, 180(x15)
    lw      x30, 184(x15)
    lw      x31, 188(x15)

    sw      x16, 320(x14)
    sw      x17, 324(x14)
    sw      x18, 328(x14)
    sw      x19, 332(x14)
    sw      x20, 336(x14)
    sw      x21, 340(x14)
    sw      x22, 344(x14)
    sw      x23, 348(x14)
    sw      x24, 352(x14)
    sw      x25, 356(x14)
    sw      x26, 360(x14)
    sw      x27, 364(x14)
    sw      x28, 368(x14)
    sw      x29, 372(x14)
    sw      x30, 376(x14)
    sw      x31, 380(x14)

    add     x15, x15, x4

    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)
    lw      x20, 16(x15)
    lw      x21, 20(x15)
    lw      x22, 24(x15)
    lw      x23, 28(x15)
    lw      x24, 32(x15)
    lw      x25, 36(x15)
    lw      x26, 40(x15)
    lw      x27, 44(x15)
    lw      x28, 48(x15)
    lw      x29, 52(x15)
    lw      x30, 56(x15)
    lw      x31, 60(x15)

    sw      x16, 384(x14)
    sw      x17, 388(x14)
    sw      x18, 392(x14)
    sw      x19, 396(x14)
    sw      x20, 400(x14)
    sw      x21, 404(x14)
    sw      x22, 408(x14)
    sw      x23, 412(x14)
    sw      x24, 416(x14)
    sw      x25, 420(x14)
    sw      x26, 424(x14)
    sw      x27, 428(x14)
    sw      x28, 432(x14)
    sw      x29, 436(x14)
    sw      x30, 440(x14)
    sw      x31, 444(x14)

    lw      x16, 64(x15)
    lw      x17, 68(x15)
    lw      x18, 72(x15)
    lw      x19, 76(x15)
    lw      x20, 80(x15)
    lw      x21, 84(x15)
    lw      x22, 88(x15)
    lw      x23, 92(x15)
    lw      x24, 96(x15)
    lw      x25, 100(x15)
    lw      x26, 104(x15)
    lw      x27, 108(x15)
    lw      x28, 112(x15)
    lw      x29, 116(x15)
    lw      x30, 120(x15)
    lw      x31, 124(x15)

    sw      x16, 448(x14)
    sw      x17, 452(x14)
    sw      x18, 456(x14)
    sw      x19, 460(x14)
    sw      x20, 464(x14)
    sw      x21, 468(x14)
    sw      x22, 472(x14)
    sw      x23, 476(x14)
    sw      x24, 480(x14)
    sw      x25, 484(x14)
    sw      x26, 488(x14)
    sw      x27, 492(x14)
    sw      x28, 496(x14)
    sw      x29, 500(x14)
    sw      x30, 504(x14)
    sw      x31, 508(x14)

    lw      x16, 128(x15)
    lw      x17, 132(x15)
    lw      x18, 136(x15)
    lw      x19, 140(x15)
    lw      x20, 144(x15)
    lw      x21, 148(x15)
    lw      x22, 152(x15)
    lw      x23, 156(x15)
    lw      x24, 160(x15)
    lw      x25, 164(x15)
    lw      x26, 168(x15)
    lw      x27, 172(x15)
    lw      x28, 176(x15)
    lw      x29, 180(x15)
    lw      x30, 184(x15)
    lw      x31, 188(x15)

    sw      x16, 512(x14)
    sw      x17, 516(x14)
    sw      x18, 520(x14)
    sw      x19, 524(x14)
    sw      x20, 528(x14)
    sw      x21, 532(x14)
    sw      x22, 536(x14)
    sw      x23, 540(x14)
    sw      x24, 544(x14)
    sw      x25, 548(x14)
    sw      x26, 552(x14)
    sw      x27, 556(x14)
    sw      x28, 560(x14)
    sw      x29, 564(x14)
    sw      x30, 568(x14)
    sw      x31, 572(x14)

    ret

ragu_3x3_c32_fast:
    addi    x4, x4, 2
    mul     x10, x4, x10
    slli    x4, x4, 7
    add     x11, x10, x11
    slli    x11, x11, 7
    lui     x10, 768
    add     x15, x10, x11
    lui     x14, 1296

    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)
    lw      x20, 16(x15)
    lw      x21, 20(x15)
    lw      x22, 24(x15)
    lw      x23, 28(x15)
    lw      x24, 32(x15)
    lw      x25, 36(x15)
    lw      x26, 40(x15)
    lw      x27, 44(x15)
    lw      x28, 48(x15)
    lw      x29, 52(x15)
    lw      x30, 56(x15)
    lw      x31, 60(x15)

    sw      x16, 0(x14)
    sw      x17, 4(x14)
    sw      x18, 8(x14)
    sw      x19, 12(x14)
    sw      x20, 16(x14)
    sw      x21, 20(x14)
    sw      x22, 24(x14)
    sw      x23, 28(x14)
    sw      x24, 32(x14)
    sw      x25, 36(x14)
    sw      x26, 40(x14)
    sw      x27, 44(x14)
    sw      x28, 48(x14)
    sw      x29, 52(x14)
    sw      x30, 56(x14)
    sw      x31, 60(x14)

    lw      x16, 64(x15)
    lw      x17, 68(x15)
    lw      x18, 72(x15)
    lw      x19, 76(x15)
    lw      x20, 80(x15)
    lw      x21, 84(x15)
    lw      x22, 88(x15)
    lw      x23, 92(x15)
    lw      x24, 96(x15)
    lw      x25, 100(x15)
    lw      x26, 104(x15)
    lw      x27, 108(x15)
    lw      x28, 112(x15)
    lw      x29, 116(x15)
    lw      x30, 120(x15)
    lw      x31, 124(x15)

    sw      x16, 64(x14)
    sw      x17, 68(x14)
    sw      x18, 72(x14)
    sw      x19, 76(x14)
    sw      x20, 80(x14)
    sw      x21, 84(x14)
    sw      x22, 88(x14)
    sw      x23, 92(x14)
    sw      x24, 96(x14)
    sw      x25, 100(x14)
    sw      x26, 104(x14)
    sw      x27, 108(x14)
    sw      x28, 112(x14)
    sw      x29, 116(x14)
    sw      x30, 120(x14)
    sw      x31, 124(x14)

    lw      x16, 128(x15)
    lw      x17, 132(x15)
    lw      x18, 136(x15)
    lw      x19, 140(x15)
    lw      x20, 144(x15)
    lw      x21, 148(x15)
    lw      x22, 152(x15)
    lw      x23, 156(x15)
    lw      x24, 160(x15)
    lw      x25, 164(x15)
    lw      x26, 168(x15)
    lw      x27, 172(x15)
    lw      x28, 176(x15)
    lw      x29, 180(x15)
    lw      x30, 184(x15)
    lw      x31, 188(x15)

    sw      x16, 128(x14)
    sw      x17, 132(x14)
    sw      x18, 136(x14)
    sw      x19, 140(x14)
    sw      x20, 144(x14)
    sw      x21, 148(x14)
    sw      x22, 152(x14)
    sw      x23, 156(x14)
    sw      x24, 160(x14)
    sw      x25, 164(x14)
    sw      x26, 168(x14)
    sw      x27, 172(x14)
    sw      x28, 176(x14)
    sw      x29, 180(x14)
    sw      x30, 184(x14)
    sw      x31, 188(x14)

    lw      x16, 192(x15)
    lw      x17, 196(x15)
    lw      x18, 200(x15)
    lw      x19, 204(x15)
    lw      x20, 208(x15)
    lw      x21, 212(x15)
    lw      x22, 216(x15)
    lw      x23, 220(x15)
    lw      x24, 224(x15)
    lw      x25, 228(x15)
    lw      x26, 232(x15)
    lw      x27, 236(x15)
    lw      x28, 240(x15)
    lw      x29, 244(x15)
    lw      x30, 248(x15)
    lw      x31, 252(x15)

    sw      x16, 192(x14)
    sw      x17, 196(x14)
    sw      x18, 200(x14)
    sw      x19, 204(x14)
    sw      x20, 208(x14)
    sw      x21, 212(x14)
    sw      x22, 216(x14)
    sw      x23, 220(x14)
    sw      x24, 224(x14)
    sw      x25, 228(x14)
    sw      x26, 232(x14)
    sw      x27, 236(x14)
    sw      x28, 240(x14)
    sw      x29, 244(x14)
    sw      x30, 248(x14)
    sw      x31, 252(x14)

    lw      x16, 256(x15)
    lw      x17, 260(x15)
    lw      x18, 264(x15)
    lw      x19, 268(x15)
    lw      x20, 272(x15)
    lw      x21, 276(x15)
    lw      x22, 280(x15)
    lw      x23, 284(x15)
    lw      x24, 288(x15)
    lw      x25, 292(x15)
    lw      x26, 296(x15)
    lw      x27, 300(x15)
    lw      x28, 304(x15)
    lw      x29, 308(x15)
    lw      x30, 312(x15)
    lw      x31, 316(x15)

    sw      x16, 256(x14)
    sw      x17, 260(x14)
    sw      x18, 264(x14)
    sw      x19, 268(x14)
    sw      x20, 272(x14)
    sw      x21, 276(x14)
    sw      x22, 280(x14)
    sw      x23, 284(x14)
    sw      x24, 288(x14)
    sw      x25, 292(x14)
    sw      x26, 296(x14)
    sw      x27, 300(x14)
    sw      x28, 304(x14)
    sw      x29, 308(x14)
    sw      x30, 312(x14)
    sw      x31, 316(x14)

    lw      x16, 320(x15)
    lw      x17, 324(x15)
    lw      x18, 328(x15)
    lw      x19, 332(x15)
    lw      x20, 336(x15)
    lw      x21, 340(x15)
    lw      x22, 344(x15)
    lw      x23, 348(x15)
    lw      x24, 352(x15)
    lw      x25, 356(x15)
    lw      x26, 360(x15)
    lw      x27, 364(x15)
    lw      x28, 368(x15)
    lw      x29, 372(x15)
    lw      x30, 376(x15)
    lw      x31, 380(x15)

    sw      x16, 320(x14)
    sw      x17, 324(x14)
    sw      x18, 328(x14)
    sw      x19, 332(x14)
    sw      x20, 336(x14)
    sw      x21, 340(x14)
    sw      x22, 344(x14)
    sw      x23, 348(x14)
    sw      x24, 352(x14)
    sw      x25, 356(x14)
    sw      x26, 360(x14)
    sw      x27, 364(x14)
    sw      x28, 368(x14)
    sw      x29, 372(x14)
    sw      x30, 376(x14)
    sw      x31, 380(x14)

    add     x15, x15, x4

    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)
    lw      x20, 16(x15)
    lw      x21, 20(x15)
    lw      x22, 24(x15)
    lw      x23, 28(x15)
    lw      x24, 32(x15)
    lw      x25, 36(x15)
    lw      x26, 40(x15)
    lw      x27, 44(x15)
    lw      x28, 48(x15)
    lw      x29, 52(x15)
    lw      x30, 56(x15)
    lw      x31, 60(x15)

    sw      x16, 384(x14)
    sw      x17, 388(x14)
    sw      x18, 392(x14)
    sw      x19, 396(x14)
    sw      x20, 400(x14)
    sw      x21, 404(x14)
    sw      x22, 408(x14)
    sw      x23, 412(x14)
    sw      x24, 416(x14)
    sw      x25, 420(x14)
    sw      x26, 424(x14)
    sw      x27, 428(x14)
    sw      x28, 432(x14)
    sw      x29, 436(x14)
    sw      x30, 440(x14)
    sw      x31, 444(x14)

    lw      x16, 64(x15)
    lw      x17, 68(x15)
    lw      x18, 72(x15)
    lw      x19, 76(x15)
    lw      x20, 80(x15)
    lw      x21, 84(x15)
    lw      x22, 88(x15)
    lw      x23, 92(x15)
    lw      x24, 96(x15)
    lw      x25, 100(x15)
    lw      x26, 104(x15)
    lw      x27, 108(x15)
    lw      x28, 112(x15)
    lw      x29, 116(x15)
    lw      x30, 120(x15)
    lw      x31, 124(x15)

    sw      x16, 448(x14)
    sw      x17, 452(x14)
    sw      x18, 456(x14)
    sw      x19, 460(x14)
    sw      x20, 464(x14)
    sw      x21, 468(x14)
    sw      x22, 472(x14)
    sw      x23, 476(x14)
    sw      x24, 480(x14)
    sw      x25, 484(x14)
    sw      x26, 488(x14)
    sw      x27, 492(x14)
    sw      x28, 496(x14)
    sw      x29, 500(x14)
    sw      x30, 504(x14)
    sw      x31, 508(x14)

    lw      x16, 128(x15)
    lw      x17, 132(x15)
    lw      x18, 136(x15)
    lw      x19, 140(x15)
    lw      x20, 144(x15)
    lw      x21, 148(x15)
    lw      x22, 152(x15)
    lw      x23, 156(x15)
    lw      x24, 160(x15)
    lw      x25, 164(x15)
    lw      x26, 168(x15)
    lw      x27, 172(x15)
    lw      x28, 176(x15)
    lw      x29, 180(x15)
    lw      x30, 184(x15)
    lw      x31, 188(x15)

    sw      x16, 512(x14)
    sw      x17, 516(x14)
    sw      x18, 520(x14)
    sw      x19, 524(x14)
    sw      x20, 528(x14)
    sw      x21, 532(x14)
    sw      x22, 536(x14)
    sw      x23, 540(x14)
    sw      x24, 544(x14)
    sw      x25, 548(x14)
    sw      x26, 552(x14)
    sw      x27, 556(x14)
    sw      x28, 560(x14)
    sw      x29, 564(x14)
    sw      x30, 568(x14)
    sw      x31, 572(x14)

    lw      x16, 192(x15)
    lw      x17, 196(x15)
    lw      x18, 200(x15)
    lw      x19, 204(x15)
    lw      x20, 208(x15)
    lw      x21, 212(x15)
    lw      x22, 216(x15)
    lw      x23, 220(x15)
    lw      x24, 224(x15)
    lw      x25, 228(x15)
    lw      x26, 232(x15)
    lw      x27, 236(x15)
    lw      x28, 240(x15)
    lw      x29, 244(x15)
    lw      x30, 248(x15)
    lw      x31, 252(x15)

    sw      x16, 576(x14)
    sw      x17, 580(x14)
    sw      x18, 584(x14)
    sw      x19, 588(x14)
    sw      x20, 592(x14)
    sw      x21, 596(x14)
    sw      x22, 600(x14)
    sw      x23, 604(x14)
    sw      x24, 608(x14)
    sw      x25, 612(x14)
    sw      x26, 616(x14)
    sw      x27, 620(x14)
    sw      x28, 624(x14)
    sw      x29, 628(x14)
    sw      x30, 632(x14)
    sw      x31, 636(x14)

    lw      x16, 256(x15)
    lw      x17, 260(x15)
    lw      x18, 264(x15)
    lw      x19, 268(x15)
    lw      x20, 272(x15)
    lw      x21, 276(x15)
    lw      x22, 280(x15)
    lw      x23, 284(x15)
    lw      x24, 288(x15)
    lw      x25, 292(x15)
    lw      x26, 296(x15)
    lw      x27, 300(x15)
    lw      x28, 304(x15)
    lw      x29, 308(x15)
    lw      x30, 312(x15)
    lw      x31, 316(x15)

    sw      x16, 640(x14)
    sw      x17, 644(x14)
    sw      x18, 648(x14)
    sw      x19, 652(x14)
    sw      x20, 656(x14)
    sw      x21, 660(x14)
    sw      x22, 664(x14)
    sw      x23, 668(x14)
    sw      x24, 672(x14)
    sw      x25, 676(x14)
    sw      x26, 680(x14)
    sw      x27, 684(x14)
    sw      x28, 688(x14)
    sw      x29, 692(x14)
    sw      x30, 696(x14)
    sw      x31, 700(x14)

    lw      x16, 320(x15)
    lw      x17, 324(x15)
    lw      x18, 328(x15)
    lw      x19, 332(x15)
    lw      x20, 336(x15)
    lw      x21, 340(x15)
    lw      x22, 344(x15)
    lw      x23, 348(x15)
    lw      x24, 352(x15)
    lw      x25, 356(x15)
    lw      x26, 360(x15)
    lw      x27, 364(x15)
    lw      x28, 368(x15)
    lw      x29, 372(x15)
    lw      x30, 376(x15)
    lw      x31, 380(x15)

    sw      x16, 704(x14)
    sw      x17, 708(x14)
    sw      x18, 712(x14)
    sw      x19, 716(x14)
    sw      x20, 720(x14)
    sw      x21, 724(x14)
    sw      x22, 728(x14)
    sw      x23, 732(x14)
    sw      x24, 736(x14)
    sw      x25, 740(x14)
    sw      x26, 744(x14)
    sw      x27, 748(x14)
    sw      x28, 752(x14)
    sw      x29, 756(x14)
    sw      x30, 760(x14)
    sw      x31, 764(x14)

    add     x15, x15, x4

    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)
    lw      x20, 16(x15)
    lw      x21, 20(x15)
    lw      x22, 24(x15)
    lw      x23, 28(x15)
    lw      x24, 32(x15)
    lw      x25, 36(x15)
    lw      x26, 40(x15)
    lw      x27, 44(x15)
    lw      x28, 48(x15)
    lw      x29, 52(x15)
    lw      x30, 56(x15)
    lw      x31, 60(x15)

    sw      x16, 768(x14)
    sw      x17, 772(x14)
    sw      x18, 776(x14)
    sw      x19, 780(x14)
    sw      x20, 784(x14)
    sw      x21, 788(x14)
    sw      x22, 792(x14)
    sw      x23, 796(x14)
    sw      x24, 800(x14)
    sw      x25, 804(x14)
    sw      x26, 808(x14)
    sw      x27, 812(x14)
    sw      x28, 816(x14)
    sw      x29, 820(x14)
    sw      x30, 824(x14)
    sw      x31, 828(x14)

    lw      x16, 64(x15)
    lw      x17, 68(x15)
    lw      x18, 72(x15)
    lw      x19, 76(x15)
    lw      x20, 80(x15)
    lw      x21, 84(x15)
    lw      x22, 88(x15)
    lw      x23, 92(x15)
    lw      x24, 96(x15)
    lw      x25, 100(x15)
    lw      x26, 104(x15)
    lw      x27, 108(x15)
    lw      x28, 112(x15)
    lw      x29, 116(x15)
    lw      x30, 120(x15)
    lw      x31, 124(x15)

    sw      x16, 832(x14)
    sw      x17, 836(x14)
    sw      x18, 840(x14)
    sw      x19, 844(x14)
    sw      x20, 848(x14)
    sw      x21, 852(x14)
    sw      x22, 856(x14)
    sw      x23, 860(x14)
    sw      x24, 864(x14)
    sw      x25, 868(x14)
    sw      x26, 872(x14)
    sw      x27, 876(x14)
    sw      x28, 880(x14)
    sw      x29, 884(x14)
    sw      x30, 888(x14)
    sw      x31, 892(x14)

    lw      x16, 128(x15)
    lw      x17, 132(x15)
    lw      x18, 136(x15)
    lw      x19, 140(x15)
    lw      x20, 144(x15)
    lw      x21, 148(x15)
    lw      x22, 152(x15)
    lw      x23, 156(x15)
    lw      x24, 160(x15)
    lw      x25, 164(x15)
    lw      x26, 168(x15)
    lw      x27, 172(x15)
    lw      x28, 176(x15)
    lw      x29, 180(x15)
    lw      x30, 184(x15)
    lw      x31, 188(x15)

    sw      x16, 896(x14)
    sw      x17, 900(x14)
    sw      x18, 904(x14)
    sw      x19, 908(x14)
    sw      x20, 912(x14)
    sw      x21, 916(x14)
    sw      x22, 920(x14)
    sw      x23, 924(x14)
    sw      x24, 928(x14)
    sw      x25, 932(x14)
    sw      x26, 936(x14)
    sw      x27, 940(x14)
    sw      x28, 944(x14)
    sw      x29, 948(x14)
    sw      x30, 952(x14)
    sw      x31, 956(x14)

    lw      x16, 192(x15)
    lw      x17, 196(x15)
    lw      x18, 200(x15)
    lw      x19, 204(x15)
    lw      x20, 208(x15)
    lw      x21, 212(x15)
    lw      x22, 216(x15)
    lw      x23, 220(x15)
    lw      x24, 224(x15)
    lw      x25, 228(x15)
    lw      x26, 232(x15)
    lw      x27, 236(x15)
    lw      x28, 240(x15)
    lw      x29, 244(x15)
    lw      x30, 248(x15)
    lw      x31, 252(x15)

    sw      x16, 960(x14)
    sw      x17, 964(x14)
    sw      x18, 968(x14)
    sw      x19, 972(x14)
    sw      x20, 976(x14)
    sw      x21, 980(x14)
    sw      x22, 984(x14)
    sw      x23, 988(x14)
    sw      x24, 992(x14)
    sw      x25, 996(x14)
    sw      x26, 1000(x14)
    sw      x27, 1004(x14)
    sw      x28, 1008(x14)
    sw      x29, 1012(x14)
    sw      x30, 1016(x14)
    sw      x31, 1020(x14)

    lw      x16, 256(x15)
    lw      x17, 260(x15)
    lw      x18, 264(x15)
    lw      x19, 268(x15)
    lw      x20, 272(x15)
    lw      x21, 276(x15)
    lw      x22, 280(x15)
    lw      x23, 284(x15)
    lw      x24, 288(x15)
    lw      x25, 292(x15)
    lw      x26, 296(x15)
    lw      x27, 300(x15)
    lw      x28, 304(x15)
    lw      x29, 308(x15)
    lw      x30, 312(x15)
    lw      x31, 316(x15)

    sw      x16, 1024(x14)
    sw      x17, 1028(x14)
    sw      x18, 1032(x14)
    sw      x19, 1036(x14)
    sw      x20, 1040(x14)
    sw      x21, 1044(x14)
    sw      x22, 1048(x14)
    sw      x23, 1052(x14)
    sw      x24, 1056(x14)
    sw      x25, 1060(x14)
    sw      x26, 1064(x14)
    sw      x27, 1068(x14)
    sw      x28, 1072(x14)
    sw      x29, 1076(x14)
    sw      x30, 1080(x14)
    sw      x31, 1084(x14)

    lw      x16, 320(x15)
    lw      x17, 324(x15)
    lw      x18, 328(x15)
    lw      x19, 332(x15)
    lw      x20, 336(x15)
    lw      x21, 340(x15)
    lw      x22, 344(x15)
    lw      x23, 348(x15)
    lw      x24, 352(x15)
    lw      x25, 356(x15)
    lw      x26, 360(x15)
    lw      x27, 364(x15)
    lw      x28, 368(x15)
    lw      x29, 372(x15)
    lw      x30, 376(x15)
    lw      x31, 380(x15)

    sw      x16, 1088(x14)
    sw      x17, 1092(x14)
    sw      x18, 1096(x14)
    sw      x19, 1100(x14)
    sw      x20, 1104(x14)
    sw      x21, 1108(x14)
    sw      x22, 1112(x14)
    sw      x23, 1116(x14)
    sw      x24, 1120(x14)
    sw      x25, 1124(x14)
    sw      x26, 1128(x14)
    sw      x27, 1132(x14)
    sw      x28, 1136(x14)
    sw      x29, 1140(x14)
    sw      x30, 1144(x14)
    sw      x31, 1148(x14)

    ret

ragu_3x3_c4_fast:
    add     x4, x4, x3
    addi    x4, x4, -1

    mul     x10, x4, x10
    mul     x4, x4, x6
    add     x11, x10, x11
    slli    x4, x4, 2

    mul     x11, x6, x11
    lui     x10, 768
    lui     x14, 1296
    sh2add  x15, x11, x10

    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)
    lw      x16, 16(x15)
    lw      x17, 20(x15)
    lw      x18, 24(x15)
    lw      x19, 28(x15)
    lw      x20, 32(x15)
    lw      x21, 36(x15)
    lw      x22, 40(x15)
    lw      x23, 44(x15)

    sw      x8, 0(x14)
    sw      x9, 4(x14)
    sw      x12, 8(x14)
    sw      x13, 12(x14)
    sw      x16, 16(x14)
    sw      x17, 20(x14)
    sw      x18, 24(x14)
    sw      x19, 28(x14)
    sw      x20, 32(x14)
    sw      x21, 36(x14)
    sw      x22, 40(x14)
    sw      x23, 44(x14)

    add     x15, x15, x4

    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)
    lw      x16, 16(x15)
    lw      x17, 20(x15)
    lw      x18, 24(x15)
    lw      x19, 28(x15)
    lw      x20, 32(x15)
    lw      x21, 36(x15)
    lw      x22, 40(x15)
    lw      x23, 44(x15)

    sw      x8, 48(x14)
    sw      x9, 52(x14)
    sw      x12, 56(x14)
    sw      x13, 60(x14)
    sw      x16, 64(x14)
    sw      x17, 68(x14)
    sw      x18, 72(x14)
    sw      x19, 76(x14)
    sw      x20, 80(x14)
    sw      x21, 84(x14)
    sw      x22, 88(x14)
    sw      x23, 92(x14)

    add     x15, x15, x4

    lw      x8, 0(x15)
    lw      x9, 4(x15)
    lw      x12, 8(x15)
    lw      x13, 12(x15)
    lw      x16, 16(x15)
    lw      x17, 20(x15)
    lw      x18, 24(x15)
    lw      x19, 28(x15)
    lw      x20, 32(x15)
    lw      x21, 36(x15)
    lw      x22, 40(x15)
    lw      x23, 44(x15)

    sw      x8, 96(x14)
    sw      x9, 100(x14)
    sw      x12, 104(x14)
    sw      x13, 108(x14)
    sw      x16, 112(x14)
    sw      x17, 116(x14)
    sw      x18, 120(x14)
    sw      x19, 124(x14)
    sw      x20, 128(x14)
    sw      x21, 132(x14)
    sw      x22, 136(x14)
    sw      x23, 140(x14)

    ret