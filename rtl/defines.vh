`define LA32

`define AXI64

`define ADDR_WIDTH     32

`ifdef AXI128
`define DATA_WIDTH     128
`elsif AXI64
`define DATA_WIDTH     64
`else
`define DATA_WIDTH     32
`endif


// It is a 32-bit core project for sure
//`define GRLEN          32



//CPUNUM
`define COREID_WIDTH        9
`define CPU_COREID          9'h0

// TLB parameters
`define TLB_ENTRIES_DEC     10'd544

// Modified begin
`define VADDR_EXTEND_BITS   63:48



// Status (12, 0)
`define STATUS_CU1          29
`define STATUS_RW           28
`define STATUS_BEV          22
`define STATUS_IM           15:8
`define STATUS_UM           4
`define STATUS_ERL          2
`define STATUS_EXL          1
`define STATUS_IE           0

// Cause (13, 0)
`define CAUSE_BD            31
`define CAUSE_TI            30
`define CAUSE_CE            29:28
`define CAUSE_IV            23
`define CAUSE_IP            15:8
`define CAUSE_IP7_2         15:10
`define CAUSE_IP1_0         9:8
`define CAUSE_EXCCODE       6:2

// TagLo0(28,0)
`define TAGLO0_PTAGLO       31:8
`define TAGLO0_PSTATE       7:6
`define TAGLO0_L            5
`define TAGLO0_P            0

// TagHi0(29,0)
`define TAGHI0_PTAGLO       31:8
`define TAGHI0_PSTATE       7:6
`define TAGHI0_L            5
`define TAGHI0_P            0

// EXCCODE
`define EXC_INT         6'h00
`define EXC_PIL         6'h01
`define EXC_PIS         6'h02
`define EXC_PIF         6'h03
`define EXC_PWE         6'h04
`define EXC_PNR         6'h05
`define EXC_PNE         6'h06
`define EXC_PPI         6'h07
`define EXC_ADEF        6'h08
`define EXC_ADEM        6'h08
`define EXC_ALE         6'h09
`define EXC_BCE         6'h0a
`define EXC_SYS         6'h0b
`define EXC_BRK         6'h0c
`define EXC_INE         6'h0d
`define EXC_IPE         6'h0e
`define EXC_FPD         6'h0f
`define EXC_SXD         6'h10
`define EXC_ASXD        6'd11
`define EXC_FPE         6'd12
`define EXC_VFPE        6'd12
`define EXC_WPEF        6'h13
`define EXC_WPEM        6'h13
`define EXC_BTD         6'h14
`define EXC_BTE         6'h15
`define EXC_GSPR        6'h16
`define EXC_HYP         6'h17
`define EXC_GCSC        6'h18
`define EXC_GCHC        6'h18

`define EXC_CACHEERR    6'h1e

`define EXC_ERROR       6'h3e
`define EXC_TLBR        6'h3f

`define EXC_NONE        6'h30

// instruction encoding
`define GET_RK(x)       x[14:10]
`define GET_RJ(x)       x[ 9: 5]
`define GET_RD(x)       x[ 4: 0]
`define GET_SA(x)       x[17:15]
`define GET_MSLSBD(x)   x[21:10]
`define GET_I5(x)       x[14:10]
`define GET_I6(x)       x[15:10]
`define GET_I12(x)      x[21:10]
`define GET_I14(x)      x[23:10]
`define GET_I16(x)      x[25:10]
`define GET_I20(x)      x[24: 5]
`define GET_OFFSET16(x) x[25:10]
`define GET_OFFSET21(x) {x[4:0],x[25:10]}
`define GET_OFFSET26(x) {x[9:0],x[25:10]}
`define GET_CSR(x)      x[23:10] // TO CHECK!!!!!!!!!!!!!!!!!!!!!!!!!!!

//write back source;  // TODO!!
`define EX_SR          9
`define EX_ALU0        9'd1
`define EX_ALU1        9'd2
`define EX_BRU         9'd3
`define EX_LSU         9'd4
`define EX_MUL         9'd5
`define EX_DIV         9'd6
`define EX_NONE0       9'd7
`define EX_NONE1       9'd8

// LSUop encoding
`define LSU_NUM         10
`define LSU_LW          0
`define LSU_SW          1
`define LSU_LB          2
`define LSU_LBU         3
`define LSU_LH          4
`define LSU_LHU         5
`define LSU_SB          6
`define LSU_SH          7
`define LSU_LL          8
`define LSU_SC          9

// EXCEPT encoding
`define EXCPT_CAUSE     7
`define EXCPT_SYSCALL   0
`define EXCPT_BREAK     1
`define EXCPT_OV        2
`define EXCPT_ADEL      3
`define EXCPT_ADES      4
`define EXCPT_RESERVE   5
`define EXCPT_INT       6

// SWITCH
`define SWITCH_NUM      2
`define SWITCH_INT_E    0
`define SWITCH_INT_D    1

// MODE
`define MODE_NUM        4
`define USER_MODE       0
`define DEBUG_MODE      1
`define KERNEL_MODE     2
`define SUPERVISOR_MODE 3

// cache
//`include "./cache.vh"

// CACHEop encoding
`define CACHE_OPNUM    2
`define CACHE_TAG      0
`define CACHE_DATA     1

`define CACHE_RELATED  3
`define CACHE_CACHE    0
`define CACHE_PREF     1
`define CACHE_SYNCI    2

//
`define LSOC1K_NONE_INFO_BIT 4
`define LSOC1K_CSR_ROLL_BACK 0
`define LSOC1K_CSR_EXCPT     2:1
`define LSOC1K_CSR_EXCPT_BIT 2
`define LSOC1K_CSR_DBCALL    `LSOC1K_CSR_EXCPT_BIT'b01
`define LSOC1K_CSR_ERET      `LSOC1K_CSR_EXCPT_BIT'b10
`define LSOC1K_MICROOP       3

// csr output
`define LSOC1K_CSR_OUTPUT_BIT  13

`define LSOC1K_CSR_OUTPUT_CRMD_PLV    1:0
`define LSOC1K_CSR_OUTPUT_EUEN_FPE      2
`define LSOC1K_CSR_OUTPUT_EUEN_SXE      3
`define LSOC1K_CSR_OUTPUT_EUEN_ASXE     4
`define LSOC1K_CSR_OUTPUT_EUEN_BTE      5
`define LSOC1K_CSR_OUTPUT_MISC_DRDTL1   6
`define LSOC1K_CSR_OUTPUT_MISC_DRDTL2   7
`define LSOC1K_CSR_OUTPUT_MISC_DRDTL3   8
`define LSOC1K_CSR_OUTPUT_MISC_ALCL0    9
`define LSOC1K_CSR_OUTPUT_MISC_ALCL1   10
`define LSOC1K_CSR_OUTPUT_MISC_ALCL2   11
`define LSOC1K_CSR_OUTPUT_MISC_ALCL3   12


// Predictor Info
`define LSOC1K_PRU_HINT  4

// Front End RAMs
//`include "frontend_rams.vh"



