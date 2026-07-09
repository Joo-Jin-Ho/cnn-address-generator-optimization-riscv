#include "stdio.h"

#define B 1
chess_data_segment(DMb_stat);
unsigned short T_Q = 2; //0x0000_0004
unsigned short T_P = 2; //0x0000_0006
unsigned short M = 2, Q = 6, P = 6, C = 2, S = 3, R = 3; //M:0x0000_0008 Q:0x0000_00010 
//P:0x0000_000C C:0x0000_000E S:0x0000_0010 R:0x0000_0012
chess_segment();

int* const BASE_DRAM_IN  = (int*)0x00100000;
int* const BASE_DRAM_OUT = (int*)0x00200000;
int* const BASE_SRAM_IN  = (int*)0x00300000;
int* const BASE_SRAM_OUT = (int*)0x00400000;
int* const BASE_PE_CSR =   (int*)0x00500000;
int* const BASE_PE_IN =    (int*)0x00510000;
int* const BASE_PE_OUT =   (int*)0x00520000;
int* const BASE_FCHECKER = (int*)0x00600000;

#define USE_ASM_AG_RDMA
#define USE_ASM_AG_RAGU
#define USE_ASM_AG_WAGU
#define USE_ASM_AG_WDMA

void pe_configure();
void pe_go();
int fcheck();
unsigned int cost();

#ifndef DISABLE_AG_CHECK
void load_check(unsigned int n_q, unsigned int n_p);
void store_check(unsigned int n_q, unsigned int n_p);
#else
static inline void load_check(unsigned int n_q, unsigned int n_p) { (void)n_q; (void)n_p; }
static inline void store_check(unsigned int n_q, unsigned int n_p) { (void)n_q; (void)n_p; }
#endif

#ifdef USE_ASM_AG_RDMA
extern "C" void ag_rDMA(unsigned int chess_storage(x10), unsigned int chess_storage(x11));
#else
[[gnu::noinline]] void ag_rDMA(unsigned int n_q, unsigned int n_p);
#endif

#ifdef USE_ASM_AG_RAGU
extern "C" void ag_rAGU(unsigned int chess_storage(x10), unsigned int chess_storage(x11));
#else
[[gnu::noinline]] void ag_rAGU(unsigned int t_q, unsigned int t_p);
#endif

#ifdef USE_ASM_AG_WAGU
extern "C" void ag_wAGU(unsigned int chess_storage(x10), unsigned int chess_storage(x11));
#else
[[gnu::noinline]] void ag_wAGU(unsigned int t_q, unsigned int t_p);
#endif

#ifdef USE_ASM_AG_WDMA
extern "C" void ag_wDMA(unsigned int chess_storage(x10), unsigned int chess_storage(x11));
#else
[[gnu::noinline]] void ag_wDMA(unsigned int n_q, unsigned int n_p);
#endif

int main()
{
    pe_configure();
    for (unsigned int n_q = 0; n_q < Q / T_Q; n_q++) {
        for (unsigned int n_p = 0; n_p < P / T_P; n_p++) {
            ag_rDMA(n_q, n_p);
            load_check(n_q, n_p);
            for (unsigned int t_q = 0; t_q < T_Q; t_q++) {
                for (unsigned int t_p = 0; t_p < T_P; t_p++) {
                    ag_rAGU(t_q, t_p);
                    pe_go();
                    ag_wAGU(t_q, t_p);
                }
            }
            ag_wDMA(n_q, n_p);
            store_check(n_q, n_p);
        }
    }
    printf("Functionality %s\n", fcheck() ? "failed" : "passed");
    printf("Cost: %u\n", cost());
    return 0;
}

#ifndef USE_ASM_AG_RDMA
#ifndef USE_ASM_AG_RDMA
void ag_rDMA(unsigned int n_q, unsigned int n_p)
{
    unsigned int input_w = P + R - 1;
    unsigned int tile_h  = T_Q + S - 1;
    unsigned int tile_w  = T_P + R - 1;

    unsigned int start_q = n_q * T_Q;
    unsigned int start_p = n_p * T_P;

    unsigned int row_len = tile_w * C;      // 한 tile row에서 연속으로 복사할 개수
    unsigned int dram_stride = input_w * C; // DRAM에서 한 row 이동할 때 건너뛸 개수

    volatile int *src_base =
        BASE_DRAM_IN + ((start_q * input_w + start_p) * C);

    volatile int *dst_base = BASE_SRAM_IN;

    for (unsigned int q = 0; q < tile_h; q++) {
        volatile int *src = src_base + q * dram_stride;
        volatile int *dst = dst_base + q * row_len;

        unsigned int k = 0;

        // 4개씩 복사
        for (; k + 3 < row_len; k += 4) {
            dst[k]     = src[k];
            dst[k + 1] = src[k + 1];
            dst[k + 2] = src[k + 2];
            dst[k + 3] = src[k + 3];
        }

        // 남은 것 처리
        for (; k < row_len; k++) {
            dst[k] = src[k];
        }
    }
}
#endif
#endif

#ifndef USE_ASM_AG_RAGU
void ag_rAGU(unsigned int t_q, unsigned int t_p)
{
    unsigned int tile_w = T_P + R - 1;

    unsigned int row_len = R * C;       // kernel 한 row에서 필요한 input 개수
    unsigned int src_stride = tile_w * C;

    volatile int *dst_base = BASE_PE_IN;

    for (unsigned int s = 0; s < S; s++) {
        volatile int *src =
            BASE_SRAM_IN + (((t_q + s) * tile_w + t_p) * C);

        volatile int *dst =
            dst_base + s * row_len;

        unsigned int k = 0;

        // 4개씩 복사
        for (; k + 3 < row_len; k += 4) {
            dst[k]     = src[k];
            dst[k + 1] = src[k + 1];
            dst[k + 2] = src[k + 2];
            dst[k + 3] = src[k + 3];
        }

        // 남은 것 처리
        for (; k < row_len; k++) {
            dst[k] = src[k];
        }
    }
}

#endif

#ifndef USE_ASM_AG_WAGU
void ag_wAGU(unsigned int t_q, unsigned int t_p)
{
    volatile int *src = BASE_PE_OUT;
    volatile int *dst = BASE_SRAM_OUT + ((t_q * T_P + t_p) * M);

    unsigned int k = 0;

    // 4개씩 복사
    for (; k + 3 < M; k += 4) {
        dst[k]     = src[k];
        dst[k + 1] = src[k + 1];
        dst[k + 2] = src[k + 2];
        dst[k + 3] = src[k + 3];
    }

    // 남은 것 처리
    for (; k < M; k++) {
        dst[k] = src[k];
    }
}
#endif

#ifndef USE_ASM_AG_WDMA
#ifndef USE_ASM_AG_WDMA
void ag_wDMA(unsigned int n_q, unsigned int n_p)
{
    unsigned int start_q = n_q * T_Q;
    unsigned int start_p = n_p * T_P;

    unsigned int row_len = T_P * M;  // tile output 한 row의 연속 데이터 개수
    unsigned int dram_stride = P * M;

    volatile int *src_base = BASE_SRAM_OUT;

    volatile int *dst_base =
        BASE_DRAM_OUT + ((start_q * P + start_p) * M);

    for (unsigned int q = 0; q < T_Q; q++) {
        volatile int *src = src_base + q * row_len;
        volatile int *dst = dst_base + q * dram_stride;

        unsigned int k = 0;

        // 4개씩 복사
        for (; k + 3 < row_len; k += 4) {
            dst[k]     = src[k];
            dst[k + 1] = src[k + 1];
            dst[k + 2] = src[k + 2];
            dst[k + 3] = src[k + 3];
        }

        // 남은 것 처리
        for (; k < row_len; k++) {
            dst[k] = src[k];
        }
    }
}
#endif

#endif

void pe_configure()
{
    short* ptr_csr = (short*)BASE_PE_CSR;
    *(ptr_csr++) = T_Q;
    *(ptr_csr++) = T_P;
    *(ptr_csr++) = B;
    *(ptr_csr++) = M;
    *(ptr_csr++) = Q;
    *(ptr_csr++) = P;
    *(ptr_csr++) = C;
    *(ptr_csr++) = S;
    *(ptr_csr++) = R;
    *ptr_csr = 0x01; // {config_done=1}
}

void pe_go()
{
    ((short*)BASE_PE_CSR)[0x12 / 2] = 0x02; // {go=1}
}

void load_check(unsigned int n_q, unsigned int n_p)
{
    int mismatch_count = BASE_FCHECKER[2];
    if (mismatch_count != 0) {
        printf("Load mismatch count: %d\n", mismatch_count);
    } else {
        printf("Load tile (%u, %u) passed\n", n_q, n_p);
    }
}

void store_check(unsigned int n_q, unsigned int n_p)
{
    int mismatch_count = BASE_FCHECKER[3];
    if (mismatch_count != 0) {
        printf("Store mismatch count: %d\n", mismatch_count);
    } else {
        printf("Store tile (%u, %u) passed\n", n_q, n_p);
    }
}

int fcheck()
{
    int mismatch_count = *BASE_FCHECKER;
    if (mismatch_count != 0) {
        printf("Mismatch count: %d\n", mismatch_count);
    }
    return mismatch_count;
}

unsigned int cost()
{
    return (unsigned int)(BASE_FCHECKER[1]);
}
