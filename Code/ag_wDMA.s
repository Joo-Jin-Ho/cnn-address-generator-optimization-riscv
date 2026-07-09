.text
global 0 ag_wDMA

    lhu     x3, 4(x0)
    lhu     x4, 6(x0)

    mul     x5, x10, x3

    lhu     x10, 12(x0)

    mul     x11, x4, x11
    mul     x6, x10, x5

    lhu     x5, 8(x0)

    add     x11, x6, x11

    // ------------------------------------------------------------
    // Hot path: M == 8
    // M==8이면 branch not taken으로 바로 wdma_shift8 실행.
    // M!=8이면 wdma_not_m8로 분기.
    // ------------------------------------------------------------
    addi    x7, x5, -8
    bnez    x7, wdma_not_m8


wdma_shift8:
    slli    x4, x4, 3
    slli    x10, x10, 3
    slli    x11, x11, 3
    beq     x4, x10, wdma_contiguous_prepare
    j       wdma_prepare8


wdma_not_m8:
    addi    x7, x5, -4
    beqz    x7, wdma_shift4

    addi    x7, x5, -16
    beqz    x7, wdma_shift16

    addi    x7, x5, -32
    beqz    x7, wdma_shift32

    j       wdma_shift64


wdma_shift4:
    slli    x4, x4, 2
    slli    x10, x10, 2
    slli    x11, x11, 2
    beq     x4, x10, wdma_contiguous_prepare
    j       wdma_prepare4


wdma_shift16:
    slli    x4, x4, 4
    slli    x10, x10, 4
    slli    x11, x11, 4
    beq     x4, x10, wdma_contiguous_prepare
    j       wdma_prepare16


wdma_shift32:
    slli    x4, x4, 5
    slli    x10, x10, 5
    slli    x11, x11, 5
    beq     x4, x10, wdma_contiguous_prepare
    j       wdma_prepare16


wdma_shift64:
    slli    x4, x4, 6
    slli    x10, x10, 6
    slli    x11, x11, 6
    beq     x4, x10, wdma_contiguous_prepare
    j       wdma_prepare16


// T_P == P: SRAM_OUT and DRAM_OUT tile rows are both contiguous.
// x3  = T_Q
// x4  = T_P * M       (words)
// x10 = P * M         (words), equal to x4 on this path
// x11 = DRAM_OUT word offset
wdma_contiguous_prepare:
    mul     x4, x4, x3              // total_words = T_Q * T_P * M

    lui     x5, 512                 // BASE_DRAM_OUT = 0x00200000
    sh2add  x14, x11, x5           // dst pointer
    lui     x15, 1024               // BASE_SRAM_OUT = 0x00400000

    li      x7, 32

wdma_contiguous_check32:
    bltu    x4, x7, wdma_contiguous_check16

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

    addi    x15, x15, 128
    addi    x14, x14, 128
    addi    x4, x4, -32
    j       wdma_contiguous_check32

wdma_contiguous_check16:
    li      x7, 16
    bltu    x4, x7, wdma_contiguous_check8

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

    addi    x15, x15, 64
    addi    x14, x14, 64
    addi    x4, x4, -16

wdma_contiguous_check8:
    li      x7, 8
    bltu    x4, x7, wdma_contiguous_check4

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
    addi    x4, x4, -8

wdma_contiguous_check4:
    beqz    x4, wdma_contiguous_done

    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)

    sw      x16, 0(x14)
    sw      x17, 4(x14)
    sw      x18, 8(x14)
    sw      x19, 12(x14)

wdma_contiguous_done:
    ret


wdma_prepare4:
    lui     x5, 512
    sh2add  x11, x11, x5

    slli    x9, x4, 2
    slli    x10, x10, 2
    lui     x6, 1024

    // row_len exact fast paths: x4 = T_P * M in words

    addi    x7, x4, -8
    beqz    x7, wdma_p4_w8

    addi    x7, x4, -16
    beqz    x7, wdma_p4_w16

    addi    x7, x4, -28
    beqz    x7, wdma_p4_w28

    addi    x7, x4, -32
    beqz    x7, wdma_p4_w32

    addi    x7, x4, -56
    bnez    x7, wdma_p4_check112
    j       wdma_rowlen56_fast

wdma_p4_check112:
    addi    x7, x4, -112
    bnez    x7, wdma_p4_check224
    j       wdma_rowlen112_fast

wdma_p4_check224:
    addi    x7, x4, -224
    bnez    x7, wdma_p4_normal
    j       wdma_rowlen224_fast

wdma_p4_w8:
    li      x12, 0

wdma_p4_w8_loop:
    mv      x14, x11
    mv      x15, x6

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p4_w8_loop

    ret


wdma_p4_w16:
    li      x12, 0

wdma_p4_w16_loop:
    mv      x14, x11
    mv      x15, x6

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p4_w16_loop

    ret


wdma_p4_w28:
    li      x12, 0

wdma_p4_w28_loop:
    mv      x14, x11
    mv      x15, x6

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

    lw      x16, 56(x15)
    lw      x17, 60(x15)
    lw      x18, 64(x15)
    lw      x19, 68(x15)
    lw      x20, 72(x15)
    lw      x21, 76(x15)
    lw      x22, 80(x15)
    lw      x23, 84(x15)
    lw      x24, 88(x15)
    lw      x25, 92(x15)
    lw      x26, 96(x15)
    lw      x27, 100(x15)
    lw      x28, 104(x15)
    lw      x29, 108(x15)

    sw      x16, 56(x14)
    sw      x17, 60(x14)
    sw      x18, 64(x14)
    sw      x19, 68(x14)
    sw      x20, 72(x14)
    sw      x21, 76(x14)
    sw      x22, 80(x14)
    sw      x23, 84(x14)
    sw      x24, 88(x14)
    sw      x25, 92(x14)
    sw      x26, 96(x14)
    sw      x27, 100(x14)
    sw      x28, 104(x14)
    sw      x29, 108(x14)

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p4_w28_loop

    ret


wdma_p4_w32:
    li      x12, 0

wdma_p4_w32_loop:
    mv      x14, x11
    mv      x15, x6

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p4_w32_loop

    ret

wdma_p4_normal:
    addi    x8, x4, -4

    lui     x6, 1024
    li      x12, 0

wdma_row_loop4:
    mv      x14, x11
    mv      x15, x6
    li      x13, 0

wdma_copy_loop4_check:
    bltu    x13, x8, wdma_copy_loop4_2x
    bltu    x13, x4, wdma_copy_loop4_tail
    j       wdma_next_row4

wdma_copy_loop4_2x:
    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)

    sw      x16, 0(x14)
    sw      x17, 4(x14)
    sw      x18, 8(x14)
    sw      x19, 12(x14)

    lw      x16, 16(x15)
    lw      x17, 20(x15)
    lw      x18, 24(x15)
    lw      x19, 28(x15)

    sw      x16, 16(x14)
    sw      x17, 20(x14)
    sw      x18, 24(x14)
    sw      x19, 28(x14)

    addi    x15, x15, 32
    addi    x14, x14, 32
    addi    x13, x13, 8
    j       wdma_copy_loop4_check

wdma_copy_loop4_tail:
    lw      x16, 0(x15)
    lw      x17, 4(x15)
    lw      x18, 8(x15)
    lw      x19, 12(x15)

    sw      x16, 0(x14)
    sw      x17, 4(x14)
    sw      x18, 8(x14)
    sw      x19, 12(x14)

wdma_next_row4:
    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_row_loop4

    ret


wdma_prepare8:
    lui     x5, 512
    sh2add  x11, x11, x5

    slli    x9, x4, 2              // SRAM_OUT row stride in bytes
    slli    x10, x10, 2            // DRAM_OUT row stride in bytes

    lui     x6, 1024               // BASE_SRAM_OUT = 0x00400000

    // -------------------------------------------------------------------------
    // Hot path: M=8, row_len=16 words
    //   row_len = T_P * M = 2 * 8 = 16
    // This is the important Layer 2 / T_P=2 path.
    //
    // Original path initialized x12 and checked row_len=8 before row_len=16.
    // Original wdma_p8_w16 also used one loop branch per output row.
    // Here row_len=16 is checked first, and T_Q=2/4 are fully unrolled.
    // No mul-to-shift address rewrite is used here.
    // -------------------------------------------------------------------------
    addi    x7, x4, -16
    bnez    x7, wdma_p8_not_w16


wdma_p8_w16:
    // T_Q == 2: 2 rows x 16 words, no row loop
    addi    x7, x3, -2
    beqz    x7, wdma_p8_w16_h2

    // T_Q == 4: 4 rows x 16 words, no row loop
    addi    x7, x3, -4
    beqz    x7, wdma_p8_w16_h4

    // T_Q == 8: 8 rows x 16 words, no row loop
    addi    x7, x3, -8
    beqz    x7, wdma_p8_w16_h8

    // T_Q == 7: 7 rows x 16 words, no row loop
    addi    x7, x3, -7
    beqz    x7, wdma_p8_w16_h7

    // Other T_Q values: use original row loop
    li      x12, 0

wdma_p8_w16_loop:
    mv      x14, x11
    mv      x15, x6

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p8_w16_loop

    ret


// -----------------------------------------------------------------------------
// M=8, row_len=16, T_Q=2
// x11 = DRAM_OUT row0 pointer
// x6  = SRAM_OUT row0 pointer
// x10 = DRAM_OUT row stride in bytes
// x9  = SRAM_OUT row stride in bytes (=64 for row_len=16)
// -----------------------------------------------------------------------------
wdma_p8_w16_h2:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    // row 1
    add     x15, x15, x9
    add     x14, x14, x10

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

    ret


// -----------------------------------------------------------------------------
// M=8, row_len=16, T_Q=4
// 4 rows x 16 words, no row loop
// -----------------------------------------------------------------------------
wdma_p8_w16_h4:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    // row 1
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 2
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 3
    add     x15, x15, x9
    add     x14, x14, x10

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

    ret

// -----------------------------------------------------------------------------
// M=8, row_len=16, T_Q=8
// 8 rows x 16 words, no row loop
// x11 = DRAM_OUT row0 pointer
// x6  = SRAM_OUT row0 pointer
// x10 = DRAM_OUT row stride in bytes
// x9  = SRAM_OUT row stride in bytes (=64 for row_len=16)
// -----------------------------------------------------------------------------
wdma_p8_w16_h8:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    // row 1
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 2
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 3
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 4
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 5
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 6
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 7
    add     x15, x15, x9
    add     x14, x14, x10

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

    ret

// -----------------------------------------------------------------------------
// M=8, row_len=16, T_Q=7
// 7 rows x 16 words, no row loop
// x11 = DRAM_OUT row0 pointer
// x6  = SRAM_OUT row0 pointer
// x10 = DRAM_OUT row stride in bytes
// x9  = SRAM_OUT row stride in bytes (=64 for row_len=16)
// -----------------------------------------------------------------------------
wdma_p8_w16_h7:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    // row 1
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 2
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 3
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 4
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 5
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 6
    add     x15, x15, x9
    add     x14, x14, x10

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

    ret



// -----------------------------------------------------------------------------
// M=8, row_len != 16 paths
// x12 init is kept out of the row_len=16 hot path.
// -----------------------------------------------------------------------------
wdma_p8_not_w16:
    addi    x7, x4, -8
    bnez    x7, wdma_p8_check_w32
    j       wdma_p8_w8

wdma_p8_check_w32:
    addi    x7, x4, -32
    bnez    x7, wdma_p8_check_w56
    j       wdma_p8_w32

wdma_p8_check_w56:
    addi    x7, x4, -56
    bnez    x7, wdma_p8_check_w64
    j       wdma_p8_w56

wdma_p8_check_w64:
    addi    x7, x4, -64
    bnez    x7, wdma_p8_check112
    j       wdma_p8_w64

wdma_p8_check112:
    addi    x7, x4, -112
    bnez    x7, wdma_p8_check224
    j       wdma_rowlen112_fast

wdma_p8_check224:
    addi    x7, x4, -224
    bnez    x7, wdma_p8_check448
    j       wdma_rowlen224_fast

wdma_p8_check448:
    addi    x7, x4, -448
    bnez    x7, wdma_p8_go_generic
    j       wdma_rowlen448_fast

wdma_p8_go_generic:
    j       wdma_p8_generic

wdma_p8_w8:
    li      x12, 0
wdma_p8_w8_loop:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p8_w8_loop

    ret

wdma_p8_w32:
    addi    x7, x3, -2
    beqz    x7, wdma_p8_w32_h2

    addi    x7, x3, -4
    beqz    x7, wdma_p8_w32_h4

    li      x12, 0
wdma_p8_w32_loop:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p8_w32_loop

    ret

wdma_p8_w32_h2:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    // row 1
    add     x15, x15, x9
    add     x14, x14, x10

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

    ret

wdma_p8_w32_h4:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    // row 1
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 2
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 3
    add     x15, x15, x9
    add     x14, x14, x10

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

    ret

wdma_p8_w56:
    addi    x7, x3, -2
    beqz    x7, wdma_p8_w56_h2

    addi    x7, x3, -4
    beqz    x7, wdma_p8_w56_h4

    li      x12, 0
wdma_p8_w56_loop:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    sw      x16, 192(x14)
    sw      x17, 196(x14)
    sw      x18, 200(x14)
    sw      x19, 204(x14)
    sw      x20, 208(x14)
    sw      x21, 212(x14)
    sw      x22, 216(x14)
    sw      x23, 220(x14)

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p8_w56_loop

    ret

wdma_p8_w56_h2:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    sw      x16, 192(x14)
    sw      x17, 196(x14)
    sw      x18, 200(x14)
    sw      x19, 204(x14)
    sw      x20, 208(x14)
    sw      x21, 212(x14)
    sw      x22, 216(x14)
    sw      x23, 220(x14)

    // row 1
    add     x15, x15, x9
    add     x14, x14, x10

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

    sw      x16, 192(x14)
    sw      x17, 196(x14)
    sw      x18, 200(x14)
    sw      x19, 204(x14)
    sw      x20, 208(x14)
    sw      x21, 212(x14)
    sw      x22, 216(x14)
    sw      x23, 220(x14)

    ret

wdma_p8_w56_h4:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    sw      x16, 192(x14)
    sw      x17, 196(x14)
    sw      x18, 200(x14)
    sw      x19, 204(x14)
    sw      x20, 208(x14)
    sw      x21, 212(x14)
    sw      x22, 216(x14)
    sw      x23, 220(x14)

    // row 1
    add     x15, x15, x9
    add     x14, x14, x10

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

    sw      x16, 192(x14)
    sw      x17, 196(x14)
    sw      x18, 200(x14)
    sw      x19, 204(x14)
    sw      x20, 208(x14)
    sw      x21, 212(x14)
    sw      x22, 216(x14)
    sw      x23, 220(x14)

    // row 2
    add     x15, x15, x9
    add     x14, x14, x10

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

    sw      x16, 192(x14)
    sw      x17, 196(x14)
    sw      x18, 200(x14)
    sw      x19, 204(x14)
    sw      x20, 208(x14)
    sw      x21, 212(x14)
    sw      x22, 216(x14)
    sw      x23, 220(x14)

    // row 3
    add     x15, x15, x9
    add     x14, x14, x10

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

    sw      x16, 192(x14)
    sw      x17, 196(x14)
    sw      x18, 200(x14)
    sw      x19, 204(x14)
    sw      x20, 208(x14)
    sw      x21, 212(x14)
    sw      x22, 216(x14)
    sw      x23, 220(x14)

    ret

wdma_p8_w64:
    addi    x7, x3, -2
    beqz    x7, wdma_p8_w64_h2

    addi    x7, x3, -4
    beqz    x7, wdma_p8_w64_h4

    li      x12, 0
wdma_p8_w64_loop:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p8_w64_loop

    ret

wdma_p8_w64_h2:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    // row 1
    add     x15, x15, x9
    add     x14, x14, x10

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

    ret

wdma_p8_w64_h4:
    // row 0
    mv      x14, x11
    mv      x15, x6

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

    // row 1
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 2
    add     x15, x15, x9
    add     x14, x14, x10

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

    // row 3
    add     x15, x15, x9
    add     x14, x14, x10

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

    ret

wdma_p8_generic:
    li      x12, 0
    addi    x8, x4, -24
    li      x7, 32
    bltu    x4, x7, wdma_p8_generic_no32
    j       wdma_p8_generic_set16

wdma_p8_generic_no32:
    li      x8, 0

wdma_p8_generic_set16:
    addi    x5, x4, -8

wdma_p8_generic_row:
    mv      x14, x11
    mv      x15, x6
    li      x13, 0

wdma_p8_generic_check:
    bltu    x13, x8, wdma_p8_generic_4x
    bltu    x13, x5, wdma_p8_generic_2x
    bltu    x13, x4, wdma_p8_generic_tail
    j       wdma_p8_generic_next

wdma_p8_generic_4x:
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

    lw      x16, 32(x15)
    lw      x17, 36(x15)
    lw      x18, 40(x15)
    lw      x19, 44(x15)
    lw      x20, 48(x15)
    lw      x21, 52(x15)
    lw      x22, 56(x15)
    lw      x23, 60(x15)

    sw      x16, 32(x14)
    sw      x17, 36(x14)
    sw      x18, 40(x14)
    sw      x19, 44(x14)
    sw      x20, 48(x14)
    sw      x21, 52(x14)
    sw      x22, 56(x14)
    sw      x23, 60(x14)

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

    lw      x16, 96(x15)
    lw      x17, 100(x15)
    lw      x18, 104(x15)
    lw      x19, 108(x15)
    lw      x20, 112(x15)
    lw      x21, 116(x15)
    lw      x22, 120(x15)
    lw      x23, 124(x15)

    sw      x16, 96(x14)
    sw      x17, 100(x14)
    sw      x18, 104(x14)
    sw      x19, 108(x14)
    sw      x20, 112(x14)
    sw      x21, 116(x14)
    sw      x22, 120(x14)
    sw      x23, 124(x14)

    addi    x15, x15, 128
    addi    x14, x14, 128
    addi    x13, x13, 32
    j       wdma_p8_generic_check

wdma_p8_generic_2x:
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

    lw      x16, 32(x15)
    lw      x17, 36(x15)
    lw      x18, 40(x15)
    lw      x19, 44(x15)
    lw      x20, 48(x15)
    lw      x21, 52(x15)
    lw      x22, 56(x15)
    lw      x23, 60(x15)

    sw      x16, 32(x14)
    sw      x17, 36(x14)
    sw      x18, 40(x14)
    sw      x19, 44(x14)
    sw      x20, 48(x14)
    sw      x21, 52(x14)
    sw      x22, 56(x14)
    sw      x23, 60(x14)

    addi    x15, x15, 64
    addi    x14, x14, 64
    addi    x13, x13, 16
    j       wdma_p8_generic_check

wdma_p8_generic_tail:
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

wdma_p8_generic_next:
    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p8_generic_row

    ret


wdma_prepare16:
    lui     x5, 512
    sh2add  x11, x11, x5

    slli    x9, x4, 2
    slli    x10, x10, 2

    lui     x6, 1024
    li      x12, 0

    addi    x7, x4, -16
    bnez    x7, wdma_p16_check_w32
    j       wdma_p16_w16

    // ------------------------------------------------------------
    // Layer 4 target: M=16, row_len=32, T_Q=2/4 exact paths
    // row_len = T_P * M = 32  => T_P=2, M=16
    // x3 = T_Q, x4 = row_len words, x9 = row_len bytes
    // x10 = DRAM_OUT row stride bytes, x6 = SRAM_OUT ptr, x11 = DRAM_OUT ptr
    // ------------------------------------------------------------
wdma_p16_check_w32:
    addi    x7, x4, -32
    bnez    x7, wdma_p16_check_w64

    addi    x7, x3, -2
    bnez    x7, wdma_p16_w32_check_tq4
    j       wdma_p16_w32_tq2

wdma_p16_w32_check_tq4:
    addi    x7, x3, -4
    bnez    x7, wdma_p16_w32_check_tq14
    j       wdma_p16_w32_tq4

wdma_p16_w32_check_tq14:
    addi    x7, x3, -14
    bnez    x7, wdma_p16_w32_go_normal
    j       wdma_p16_w32_tq14

wdma_p16_w32_go_normal:
    j       wdma_p16_w32


    // ------------------------------------------------------------
    // Layer 4 target: M=16, row_len=64, T_Q=2/4 exact paths
    // row_len = T_P * M = 64  => T_P=4, M=16
    // ------------------------------------------------------------
wdma_p16_check_w64:
    addi    x7, x4, -64
    bnez    x7, wdma_p16_check112

    addi    x7, x3, -2
    bnez    x7, wdma_p16_w64_check_tq4
    j       wdma_p16_w64_tq2

wdma_p16_w64_check_tq4:
    addi    x7, x3, -4
    bnez    x7, wdma_p16_w64_go_normal
    j       wdma_p16_w64_tq4

wdma_p16_w64_go_normal:
    j       wdma_p16_w64

wdma_p16_check112:
    addi    x7, x4, -112
    bnez    x7, wdma_p16_check224
    j       wdma_rowlen112_fast

wdma_p16_check224:
    addi    x7, x4, -224
    bnez    x7, wdma_p16_check448
    j       wdma_rowlen224_fast

wdma_p16_check448:
    addi    x7, x4, -448
    bnez    x7, wdma_p16_go_generic
    j       wdma_rowlen448_fast

wdma_p16_go_generic:
    j       wdma_p16_generic



// -----------------------------------------------------------------------------
// M=16, row_len=32, exact T_Q=2 path
// Layer 4: T_Q=2, T_P=2, M=16, S=1, R=1
// Copies 2 rows without the row loop counter/branch overhead.
// -----------------------------------------------------------------------------
wdma_p16_w32_tq2:
    // row 0
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)
    add     x6, x6, x9
    add     x11, x10, x11

    // row 1
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)
    ret


// -----------------------------------------------------------------------------
// M=16, row_len=32, exact T_Q=4 path
// Layer 4: T_Q=4, T_P=2, M=16, S=1, R=1
// -----------------------------------------------------------------------------
wdma_p16_w32_tq4:
    // row 0
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)
    add     x6, x6, x9
    add     x11, x10, x11

    // row 1
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)
    add     x6, x6, x9
    add     x11, x10, x11

    // row 2
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)
    add     x6, x6, x9
    add     x11, x10, x11

    // row 3
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)
    ret

// -----------------------------------------------------------------------------
// M=16, row_len=32, exact T_Q=14 path
// Layer 5 target: T_Q=14, T_P=2, M=16
// row_len = 32 words = 128 bytes
// Copies 2 rows per loop, 7 iterations.
// x6  = SRAM_OUT row pointer
// x11 = DRAM_OUT row pointer
// x9  = SRAM_OUT row stride bytes
// x10 = DRAM_OUT row stride bytes
// -----------------------------------------------------------------------------
wdma_p16_w32_tq14:
    li      x12, 7

wdma_p16_w32_tq14_loop:
    // row 0
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)

    add     x6, x6, x9
    add     x11, x10, x11

    // row 1
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)

    add     x6, x6, x9
    add     x11, x10, x11
    addi    x12, x12, -1
    bnez    x12, wdma_p16_w32_tq14_loop

    ret
    
// -----------------------------------------------------------------------------
// M=16, row_len=64, exact T_Q=2 path
// Layer 4: T_Q=2, T_P=4, M=16, S=1, R=1
// -----------------------------------------------------------------------------
wdma_p16_w64_tq2:
    // row 0
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)

    lw      x16, 128(x6)
    lw      x17, 132(x6)
    lw      x18, 136(x6)
    lw      x19, 140(x6)
    lw      x20, 144(x6)
    lw      x21, 148(x6)
    lw      x22, 152(x6)
    lw      x23, 156(x6)
    lw      x24, 160(x6)
    lw      x25, 164(x6)
    lw      x26, 168(x6)
    lw      x27, 172(x6)
    lw      x28, 176(x6)
    lw      x29, 180(x6)
    lw      x30, 184(x6)
    lw      x31, 188(x6)

    sw      x16, 128(x11)
    sw      x17, 132(x11)
    sw      x18, 136(x11)
    sw      x19, 140(x11)
    sw      x20, 144(x11)
    sw      x21, 148(x11)
    sw      x22, 152(x11)
    sw      x23, 156(x11)
    sw      x24, 160(x11)
    sw      x25, 164(x11)
    sw      x26, 168(x11)
    sw      x27, 172(x11)
    sw      x28, 176(x11)
    sw      x29, 180(x11)
    sw      x30, 184(x11)
    sw      x31, 188(x11)

    lw      x16, 192(x6)
    lw      x17, 196(x6)
    lw      x18, 200(x6)
    lw      x19, 204(x6)
    lw      x20, 208(x6)
    lw      x21, 212(x6)
    lw      x22, 216(x6)
    lw      x23, 220(x6)
    lw      x24, 224(x6)
    lw      x25, 228(x6)
    lw      x26, 232(x6)
    lw      x27, 236(x6)
    lw      x28, 240(x6)
    lw      x29, 244(x6)
    lw      x30, 248(x6)
    lw      x31, 252(x6)

    sw      x16, 192(x11)
    sw      x17, 196(x11)
    sw      x18, 200(x11)
    sw      x19, 204(x11)
    sw      x20, 208(x11)
    sw      x21, 212(x11)
    sw      x22, 216(x11)
    sw      x23, 220(x11)
    sw      x24, 224(x11)
    sw      x25, 228(x11)
    sw      x26, 232(x11)
    sw      x27, 236(x11)
    sw      x28, 240(x11)
    sw      x29, 244(x11)
    sw      x30, 248(x11)
    sw      x31, 252(x11)
    add     x6, x6, x9
    add     x11, x10, x11

    // row 1
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)

    lw      x16, 128(x6)
    lw      x17, 132(x6)
    lw      x18, 136(x6)
    lw      x19, 140(x6)
    lw      x20, 144(x6)
    lw      x21, 148(x6)
    lw      x22, 152(x6)
    lw      x23, 156(x6)
    lw      x24, 160(x6)
    lw      x25, 164(x6)
    lw      x26, 168(x6)
    lw      x27, 172(x6)
    lw      x28, 176(x6)
    lw      x29, 180(x6)
    lw      x30, 184(x6)
    lw      x31, 188(x6)

    sw      x16, 128(x11)
    sw      x17, 132(x11)
    sw      x18, 136(x11)
    sw      x19, 140(x11)
    sw      x20, 144(x11)
    sw      x21, 148(x11)
    sw      x22, 152(x11)
    sw      x23, 156(x11)
    sw      x24, 160(x11)
    sw      x25, 164(x11)
    sw      x26, 168(x11)
    sw      x27, 172(x11)
    sw      x28, 176(x11)
    sw      x29, 180(x11)
    sw      x30, 184(x11)
    sw      x31, 188(x11)

    lw      x16, 192(x6)
    lw      x17, 196(x6)
    lw      x18, 200(x6)
    lw      x19, 204(x6)
    lw      x20, 208(x6)
    lw      x21, 212(x6)
    lw      x22, 216(x6)
    lw      x23, 220(x6)
    lw      x24, 224(x6)
    lw      x25, 228(x6)
    lw      x26, 232(x6)
    lw      x27, 236(x6)
    lw      x28, 240(x6)
    lw      x29, 244(x6)
    lw      x30, 248(x6)
    lw      x31, 252(x6)

    sw      x16, 192(x11)
    sw      x17, 196(x11)
    sw      x18, 200(x11)
    sw      x19, 204(x11)
    sw      x20, 208(x11)
    sw      x21, 212(x11)
    sw      x22, 216(x11)
    sw      x23, 220(x11)
    sw      x24, 224(x11)
    sw      x25, 228(x11)
    sw      x26, 232(x11)
    sw      x27, 236(x11)
    sw      x28, 240(x11)
    sw      x29, 244(x11)
    sw      x30, 248(x11)
    sw      x31, 252(x11)
    ret


// -----------------------------------------------------------------------------
// M=16, row_len=64, exact T_Q=4 path
// Layer 4: T_Q=4, T_P=4, M=16, S=1, R=1
// -----------------------------------------------------------------------------
wdma_p16_w64_tq4:
    // row 0
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)

    lw      x16, 128(x6)
    lw      x17, 132(x6)
    lw      x18, 136(x6)
    lw      x19, 140(x6)
    lw      x20, 144(x6)
    lw      x21, 148(x6)
    lw      x22, 152(x6)
    lw      x23, 156(x6)
    lw      x24, 160(x6)
    lw      x25, 164(x6)
    lw      x26, 168(x6)
    lw      x27, 172(x6)
    lw      x28, 176(x6)
    lw      x29, 180(x6)
    lw      x30, 184(x6)
    lw      x31, 188(x6)

    sw      x16, 128(x11)
    sw      x17, 132(x11)
    sw      x18, 136(x11)
    sw      x19, 140(x11)
    sw      x20, 144(x11)
    sw      x21, 148(x11)
    sw      x22, 152(x11)
    sw      x23, 156(x11)
    sw      x24, 160(x11)
    sw      x25, 164(x11)
    sw      x26, 168(x11)
    sw      x27, 172(x11)
    sw      x28, 176(x11)
    sw      x29, 180(x11)
    sw      x30, 184(x11)
    sw      x31, 188(x11)

    lw      x16, 192(x6)
    lw      x17, 196(x6)
    lw      x18, 200(x6)
    lw      x19, 204(x6)
    lw      x20, 208(x6)
    lw      x21, 212(x6)
    lw      x22, 216(x6)
    lw      x23, 220(x6)
    lw      x24, 224(x6)
    lw      x25, 228(x6)
    lw      x26, 232(x6)
    lw      x27, 236(x6)
    lw      x28, 240(x6)
    lw      x29, 244(x6)
    lw      x30, 248(x6)
    lw      x31, 252(x6)

    sw      x16, 192(x11)
    sw      x17, 196(x11)
    sw      x18, 200(x11)
    sw      x19, 204(x11)
    sw      x20, 208(x11)
    sw      x21, 212(x11)
    sw      x22, 216(x11)
    sw      x23, 220(x11)
    sw      x24, 224(x11)
    sw      x25, 228(x11)
    sw      x26, 232(x11)
    sw      x27, 236(x11)
    sw      x28, 240(x11)
    sw      x29, 244(x11)
    sw      x30, 248(x11)
    sw      x31, 252(x11)
    add     x6, x6, x9
    add     x11, x10, x11

    // row 1
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)

    lw      x16, 128(x6)
    lw      x17, 132(x6)
    lw      x18, 136(x6)
    lw      x19, 140(x6)
    lw      x20, 144(x6)
    lw      x21, 148(x6)
    lw      x22, 152(x6)
    lw      x23, 156(x6)
    lw      x24, 160(x6)
    lw      x25, 164(x6)
    lw      x26, 168(x6)
    lw      x27, 172(x6)
    lw      x28, 176(x6)
    lw      x29, 180(x6)
    lw      x30, 184(x6)
    lw      x31, 188(x6)

    sw      x16, 128(x11)
    sw      x17, 132(x11)
    sw      x18, 136(x11)
    sw      x19, 140(x11)
    sw      x20, 144(x11)
    sw      x21, 148(x11)
    sw      x22, 152(x11)
    sw      x23, 156(x11)
    sw      x24, 160(x11)
    sw      x25, 164(x11)
    sw      x26, 168(x11)
    sw      x27, 172(x11)
    sw      x28, 176(x11)
    sw      x29, 180(x11)
    sw      x30, 184(x11)
    sw      x31, 188(x11)

    lw      x16, 192(x6)
    lw      x17, 196(x6)
    lw      x18, 200(x6)
    lw      x19, 204(x6)
    lw      x20, 208(x6)
    lw      x21, 212(x6)
    lw      x22, 216(x6)
    lw      x23, 220(x6)
    lw      x24, 224(x6)
    lw      x25, 228(x6)
    lw      x26, 232(x6)
    lw      x27, 236(x6)
    lw      x28, 240(x6)
    lw      x29, 244(x6)
    lw      x30, 248(x6)
    lw      x31, 252(x6)

    sw      x16, 192(x11)
    sw      x17, 196(x11)
    sw      x18, 200(x11)
    sw      x19, 204(x11)
    sw      x20, 208(x11)
    sw      x21, 212(x11)
    sw      x22, 216(x11)
    sw      x23, 220(x11)
    sw      x24, 224(x11)
    sw      x25, 228(x11)
    sw      x26, 232(x11)
    sw      x27, 236(x11)
    sw      x28, 240(x11)
    sw      x29, 244(x11)
    sw      x30, 248(x11)
    sw      x31, 252(x11)
    add     x6, x6, x9
    add     x11, x10, x11

    // row 2
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)

    lw      x16, 128(x6)
    lw      x17, 132(x6)
    lw      x18, 136(x6)
    lw      x19, 140(x6)
    lw      x20, 144(x6)
    lw      x21, 148(x6)
    lw      x22, 152(x6)
    lw      x23, 156(x6)
    lw      x24, 160(x6)
    lw      x25, 164(x6)
    lw      x26, 168(x6)
    lw      x27, 172(x6)
    lw      x28, 176(x6)
    lw      x29, 180(x6)
    lw      x30, 184(x6)
    lw      x31, 188(x6)

    sw      x16, 128(x11)
    sw      x17, 132(x11)
    sw      x18, 136(x11)
    sw      x19, 140(x11)
    sw      x20, 144(x11)
    sw      x21, 148(x11)
    sw      x22, 152(x11)
    sw      x23, 156(x11)
    sw      x24, 160(x11)
    sw      x25, 164(x11)
    sw      x26, 168(x11)
    sw      x27, 172(x11)
    sw      x28, 176(x11)
    sw      x29, 180(x11)
    sw      x30, 184(x11)
    sw      x31, 188(x11)

    lw      x16, 192(x6)
    lw      x17, 196(x6)
    lw      x18, 200(x6)
    lw      x19, 204(x6)
    lw      x20, 208(x6)
    lw      x21, 212(x6)
    lw      x22, 216(x6)
    lw      x23, 220(x6)
    lw      x24, 224(x6)
    lw      x25, 228(x6)
    lw      x26, 232(x6)
    lw      x27, 236(x6)
    lw      x28, 240(x6)
    lw      x29, 244(x6)
    lw      x30, 248(x6)
    lw      x31, 252(x6)

    sw      x16, 192(x11)
    sw      x17, 196(x11)
    sw      x18, 200(x11)
    sw      x19, 204(x11)
    sw      x20, 208(x11)
    sw      x21, 212(x11)
    sw      x22, 216(x11)
    sw      x23, 220(x11)
    sw      x24, 224(x11)
    sw      x25, 228(x11)
    sw      x26, 232(x11)
    sw      x27, 236(x11)
    sw      x28, 240(x11)
    sw      x29, 244(x11)
    sw      x30, 248(x11)
    sw      x31, 252(x11)
    add     x6, x6, x9
    add     x11, x10, x11

    // row 3
    lw      x16, 0(x6)
    lw      x17, 4(x6)
    lw      x18, 8(x6)
    lw      x19, 12(x6)
    lw      x20, 16(x6)
    lw      x21, 20(x6)
    lw      x22, 24(x6)
    lw      x23, 28(x6)
    lw      x24, 32(x6)
    lw      x25, 36(x6)
    lw      x26, 40(x6)
    lw      x27, 44(x6)
    lw      x28, 48(x6)
    lw      x29, 52(x6)
    lw      x30, 56(x6)
    lw      x31, 60(x6)

    sw      x16, 0(x11)
    sw      x17, 4(x11)
    sw      x18, 8(x11)
    sw      x19, 12(x11)
    sw      x20, 16(x11)
    sw      x21, 20(x11)
    sw      x22, 24(x11)
    sw      x23, 28(x11)
    sw      x24, 32(x11)
    sw      x25, 36(x11)
    sw      x26, 40(x11)
    sw      x27, 44(x11)
    sw      x28, 48(x11)
    sw      x29, 52(x11)
    sw      x30, 56(x11)
    sw      x31, 60(x11)

    lw      x16, 64(x6)
    lw      x17, 68(x6)
    lw      x18, 72(x6)
    lw      x19, 76(x6)
    lw      x20, 80(x6)
    lw      x21, 84(x6)
    lw      x22, 88(x6)
    lw      x23, 92(x6)
    lw      x24, 96(x6)
    lw      x25, 100(x6)
    lw      x26, 104(x6)
    lw      x27, 108(x6)
    lw      x28, 112(x6)
    lw      x29, 116(x6)
    lw      x30, 120(x6)
    lw      x31, 124(x6)

    sw      x16, 64(x11)
    sw      x17, 68(x11)
    sw      x18, 72(x11)
    sw      x19, 76(x11)
    sw      x20, 80(x11)
    sw      x21, 84(x11)
    sw      x22, 88(x11)
    sw      x23, 92(x11)
    sw      x24, 96(x11)
    sw      x25, 100(x11)
    sw      x26, 104(x11)
    sw      x27, 108(x11)
    sw      x28, 112(x11)
    sw      x29, 116(x11)
    sw      x30, 120(x11)
    sw      x31, 124(x11)

    lw      x16, 128(x6)
    lw      x17, 132(x6)
    lw      x18, 136(x6)
    lw      x19, 140(x6)
    lw      x20, 144(x6)
    lw      x21, 148(x6)
    lw      x22, 152(x6)
    lw      x23, 156(x6)
    lw      x24, 160(x6)
    lw      x25, 164(x6)
    lw      x26, 168(x6)
    lw      x27, 172(x6)
    lw      x28, 176(x6)
    lw      x29, 180(x6)
    lw      x30, 184(x6)
    lw      x31, 188(x6)

    sw      x16, 128(x11)
    sw      x17, 132(x11)
    sw      x18, 136(x11)
    sw      x19, 140(x11)
    sw      x20, 144(x11)
    sw      x21, 148(x11)
    sw      x22, 152(x11)
    sw      x23, 156(x11)
    sw      x24, 160(x11)
    sw      x25, 164(x11)
    sw      x26, 168(x11)
    sw      x27, 172(x11)
    sw      x28, 176(x11)
    sw      x29, 180(x11)
    sw      x30, 184(x11)
    sw      x31, 188(x11)

    lw      x16, 192(x6)
    lw      x17, 196(x6)
    lw      x18, 200(x6)
    lw      x19, 204(x6)
    lw      x20, 208(x6)
    lw      x21, 212(x6)
    lw      x22, 216(x6)
    lw      x23, 220(x6)
    lw      x24, 224(x6)
    lw      x25, 228(x6)
    lw      x26, 232(x6)
    lw      x27, 236(x6)
    lw      x28, 240(x6)
    lw      x29, 244(x6)
    lw      x30, 248(x6)
    lw      x31, 252(x6)

    sw      x16, 192(x11)
    sw      x17, 196(x11)
    sw      x18, 200(x11)
    sw      x19, 204(x11)
    sw      x20, 208(x11)
    sw      x21, 212(x11)
    sw      x22, 216(x11)
    sw      x23, 220(x11)
    sw      x24, 224(x11)
    sw      x25, 228(x11)
    sw      x26, 232(x11)
    sw      x27, 236(x11)
    sw      x28, 240(x11)
    sw      x29, 244(x11)
    sw      x30, 248(x11)
    sw      x31, 252(x11)
    ret

wdma_p16_w16:
    mv      x14, x11
    mv      x15, x6

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p16_w16

    ret


wdma_p16_w32:
    mv      x14, x11
    mv      x15, x6

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p16_w32

    ret


wdma_p16_w64:
    mv      x14, x11
    mv      x15, x6

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p16_w64

    ret


wdma_p16_generic:
    addi    x8, x4, -16

wdma_p16_generic_row:
    mv      x14, x11
    mv      x15, x6
    li      x13, 0

wdma_p16_generic_check:
    bltu    x13, x8, wdma_p16_generic_2x
    bltu    x13, x4, wdma_p16_generic_tail
    j       wdma_p16_generic_next

wdma_p16_generic_2x:
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

    addi    x15, x15, 128
    addi    x14, x14, 128
    addi    x13, x13, 32
    j       wdma_p16_generic_check

wdma_p16_generic_tail:
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

wdma_p16_generic_next:
    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_p16_generic_row

    ret


wdma_rowlen56_fast:
    srli    x12, x3, 1             // pair_count = T_Q / 2
    beqz    x12, wdma_rowlen56_tail_check

wdma_rowlen56_2row_loop:
    // row 0
    mv      x14, x11
    mv      x15, x6

    // COPY56_BODY
    // 기존 wdma_rowlen56_fast_row의 56-word copy body
    // lw/sw 0 ~ 220

    add     x6, x6, x9
    add     x11, x10, x11

    // row 1
    mv      x14, x11
    mv      x15, x6

    // COPY56_BODY
    // 기존 wdma_rowlen56_fast_row의 56-word copy body
    // lw/sw 0 ~ 220

    add     x6, x6, x9
    add     x11, x10, x11
    addi    x12, x12, -1
    bnez    x12, wdma_rowlen56_2row_loop

wdma_rowlen56_tail_check:
    andi    x7, x3, 1
    beqz    x7, wdma_rowlen56_done

wdma_rowlen56_tail_row:
    mv      x14, x11
    mv      x15, x6

    // COPY56_BODY
    // 기존 wdma_rowlen56_fast_row의 56-word copy body
    // lw/sw 0 ~ 220

wdma_rowlen56_done:
    ret
    
wdma_rowlen112_fast:
    li      x12, 0

wdma_rowlen112_fast_row:
    mv      x14, x11
    mv      x15, x6

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

    lw      x16, 384(x15)
    lw      x17, 388(x15)
    lw      x18, 392(x15)
    lw      x19, 396(x15)
    lw      x20, 400(x15)
    lw      x21, 404(x15)
    lw      x22, 408(x15)
    lw      x23, 412(x15)
    lw      x24, 416(x15)
    lw      x25, 420(x15)
    lw      x26, 424(x15)
    lw      x27, 428(x15)
    lw      x28, 432(x15)
    lw      x29, 436(x15)
    lw      x30, 440(x15)
    lw      x31, 444(x15)

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

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_rowlen112_fast_row

    ret

wdma_rowlen224_fast:
    srli    x12, x3, 1             // pair_count = T_Q / 2
    beqz    x12, wdma_rowlen224_tail_check

wdma_rowlen224_fast_2row_loop:
    // ---------------- row 0 ----------------
    mv      x14, x11
    mv      x15, x6

    // 여기에는 기존 wdma_rowlen224_fast_row의
    // 224-word copy body를 그대로 넣기
    // 단, 마지막 addi/add/add/bltu/ret는 넣지 말 것

    add     x6, x6, x9
    add     x11, x10, x11

    // ---------------- row 1 ----------------
    mv      x14, x11
    mv      x15, x6

    // 여기도 같은 224-word copy body를 그대로 한 번 더 넣기
    // 단, 마지막 addi/add/add/bltu/ret는 넣지 말 것

    add     x6, x6, x9
    add     x11, x10, x11
    addi    x12, x12, -1
    bnez    x12, wdma_rowlen224_fast_2row_loop

wdma_rowlen224_tail_check:
    andi    x7, x3, 1
    beqz    x7, wdma_rowlen224_done

wdma_rowlen224_tail_row:
    mv      x14, x11
    mv      x15, x6

    // 기존 224-word copy body를 한 번 넣기
    // 단, 마지막 addi/add/add/bltu/ret는 넣지 말 것

wdma_rowlen224_done:
    ret
wdma_rowlen448_fast:
    li      x12, 0
wdma_rowlen448_fast_row:
    mv      x14, x11
    mv      x15, x6
    li      x13, 14
wdma_rowlen448_fast_copy32_loop:
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

    addi    x15, x15, 128
    addi    x14, x14, 128
    addi    x13, x13, -1
    bnez    x13, wdma_rowlen448_fast_copy32_loop

    addi    x12, x12, 1
    add     x6, x6, x9
    add     x11, x10, x11
    bltu    x12, x3, wdma_rowlen448_fast_row
    ret

