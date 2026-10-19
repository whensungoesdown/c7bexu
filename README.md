# c7bexu — Execution Unit of cpu7b

c7bexu executes instructions for the cpu7b LA32R core. It takes one
decoded instruction per cycle from the IFU at D, reads the register
file, and runs the instruction through three stages (E, M, W) on the
ALU, branch unit, multiplier, divider, CSR file or LSU. It forwards
results, stalls the IFU for multi-cycle operations, merges IFU, LSU and
interrupt exceptions, and sends branch, exception and ertn redirects to
the IFU from W.

```
                  IFU (ifu_exu_*_d)            ext_intr
                        |                         |
                        v                         v
  +-----------+   +-----------+             +-----------+   +-------+
  | c7bexu_rf |-->| E regs    |<-- issue ---| pic       |<--| intr_ |
  | (D read)  |   | (_e)      |  good_to_   | (intr_    |   | sync  |
  +-----------+   +-----------+  issue      |  pulse)   |   +-------+
        ^               |                   +-----------+
        |               v
        |         +-----------+   +-----+ +--------+ +-----+ +-----+ +-----+ +--------+
        |         | c7bexu_   |-->| alu | | branch | | mul | | div | | csr | | c7blsu |<--> BIU
        |         | byp       |   +-----+ +--------+ +-----+ +-----+ +-----+ +--------+
        |         +-----------+      |        |        |       |       |        |
        |               ^            v        v        v       v       v        v
        |               |         +----------------------------------------------+
        |               +---------| rd_data_m (M)  +  exception merge (M)        |
        |               |         +----------------------------------------------+
        |               |                              |
        |         +-----------+                        v
        +---------| W regs    |----> exu_ifu_branch / except / ertn, CSR commit
                  | (_w)      |
                  +-----------+
              c7bexu_ecl: stall_ifu (to IFU), stall_reg_mw (M/W hold)
```

## Files

| File | Module | Purpose |
|---|---|---|
| `rtl/c7bexu.v` | `c7bexu` | Top: pipeline registers, issue, flush, exception merge, result mux, TLB op decode |
| `rtl/c7bexu_ecl.v` | `c7bexu_ecl` | Stall control: LSU, DIV, CSR, TLB stalls |
| `rtl/c7bexu_byp.v` | `c7bexu_byp` | Operand bypass muxes for rs1 and rs2 |
| `rtl/c7bexu_byplog.v` | `c7bexu_byplog` | Bypass select for one operand |
| `rtl/c7bexu_rf.v` | `c7bexu_rf` | 32 x 32-bit register file (port 0 reads, write port 1 used) |
| `rtl/pic.v` | `pic` | Interrupt insertion, one pulse per interrupt until ertn |
| `rtl/intr_sync.v` | `intr_sync` | 2-stage synchronizer for `ext_intr` |
| `rtl/intr_sync_delay.v` | `intr_sync_delay` | Alternative synchronizer; in the filelist, not instantiated |
| `rtl/random.v` | `random` | 5-bit free-running counter, TLBFILL index |
| `../alu.v`, `../branch.v` | `alu`, `branch` | Combinational ALU and branch unit |
| `../mul64x64.v`, `../div.v` | `mul64x64`, `div` | Multiplier (result at M), iterative divider |

The LSU (`c7blsu`, with the DTLB) and the CSR file (`c7bcsr`) are
instantiated inside c7bexu.

## Pipeline stages

| Stage | Where | What happens |
|---|---|---|
| D | `ifu_exu_*_d` | RF read, CSR read (`csr_raddr_d`), issue decision, interrupt insertion |
| E | `*_e` | Bypass, ALU, branch resolve, MUL/DIV start, LSU ls1, TLB op decode |
| M | `*_m` | Result mux `rd_data_m`, CSR write, MUL result, DIV result, LSU data, LSU exception merge |
| W | `*_w` | RF write, exception/ertn commit to CSR, redirect to IFU |

The LSU has its own stages:

| LSU stage | Relative to EXU | Seen by EXU |
|---|---|---|
| ls1 | same cycle as E | `lsu_except_ale_ls1`, `lsu_ecl_ibar_fin`, `lsu_ecl_dbar_fin`, `lsu_ecl_sc_fin_ls1` |
| ls2 | E+1 on; BIU request from `lsu_valid_ls2_dly1`, so `lsu_biu_rd/wr_req` at E+3 at the earliest | `lsu_except_{tlbr,pil,pis,ppi,pme}_ls2` |
| ls3 | BIU response | `lsu_data_vld_ls3`, `lsu_wr_fin_ls3`, `lsu_except_buserr_ls3` |

While the LSU works, the load/store waits in M with M/W held, and
`rd_data_m` takes `lsu_data_ls3` in the ls3 cycle.

Only the common registers are held by `stall_reg_mw`: `pc_m` (also
needs `vld_e`), `rd_m`, `wen_m`, `rd_w`, `wen_w`, `rd_data_w`,
`div_vld_m`, `div_mod_m`. All other registers (unit valids, `exc_*`,
`bru_*`, `ertn_*`, `csr_*`, `pc_e`, `pc_w`) load every cycle. `pc_w`
loads from `pc_m` every cycle, so during an LSU stall `pc_w` is the LSU
instruction's PC, which is written to ERA if it faults.

## Issue

```verilog
good_to_issue = ifu_exu_vld_d & ~ifu_exu_exc_vld_d & ~flush & ~intr_pulse;
vld_e = exc_vld_e | alu_vld_e | lsu_vld_e | bru_vld_e | mul_vld_e
      | div_vld_e | csr_vld_e | ertn_vld_e | tlb_vld_e;
```

Each unit valid (`*_vld_e`), `wen_e` and `csr_wen_e` is the decoded D
valid AND `good_to_issue`. An instruction with an IFU exception, or one
taken for an interrupt, goes only into the exception pipeline
(`exc_vld_e`). `stall_ifu` is not checked here; the IFU already gates
`ifu_exu_vld_d` with `exu_ifu_stall`.

Operands:

| Unit | Operands |
|---|---|
| ALU | a = `alu_a_pc_e ? pc_e : rs1`, b = `alu_b_imm_e ? imm_shifted_e : rs2` |
| BRU | rs1, rs2, `pc_e`, `bru_offset_e` |
| MUL | `{32'b0, rs1}`, `{32'b0, rs2}` |
| DIV | x = rs1, y = rs2 (latched by `div` on start) |
| LSU | base = rs1, offset = `lsu_double_read_e ? rs2 : imm_shifted_e`, wdata = rs2 |
| CSR | wdata = rs2, mask = `csr_xchg_e ? rs1 : 32'hFFFFFFFF` |
| INVTLB | op = `rd_e`, asid = `rs1[9:0]`, vppn = `rs2[31:13]` |

(rs1/rs2 = `rs1_data_byp_e` / `rs2_data_byp_e`.)

## Bypass (c7bexu_byp)

```verilog
use_m  = (rs_e == rd_m) & wen_m & (rs_e != 0);
use_w  = (rs_e == rd_w) & wen_w & (rs_e != 0) & ~use_m;
use_rf = ~use_m & ~use_w;
```

Priority is M, then W, then the value read at D. The RF read port
forwards its own write port (`wen1 && raddr == waddr1`), which covers a
producer in W and a consumer in D. So any result can be used by the
next instruction without an interlock. Loads and DIV do not need one
because the IFU is stalled until their result is in M.

`rd_m` and `wen_m` have a reset because the bypass compare uses them.
`exc_vld_e` forces `rd_m` and `wen_m` to 0.

## Result and register write

```verilog
// AND-OR mux, no priority
rd_data_m = ({32{alu_vld_m}}               & alu_res_m)
          | ({32{lsu_data_vld_ls3}}        & lsu_data_ls3)
          | ({32{bru_vld_m}}               & bru_link_pc_m)   // PC+4
          | ({32{mul_vld_m}}               & mul_res_m)
          | ({32{csr_vld_m}}               & csr_rdata_m)     // read at D
          | ({32{div_vld_m &  div_mod_m}}  & div_r_m)
          | ({32{div_vld_m & ~div_mod_m}}  & div_s_m)
          | ({32{lsu_sc_fin_m}}            & 32'b0)           // SC failed at ls1
          | ({32{lsu_wr_fin_ls3 & lsu_sc}} & 32'b1);          // SC succeeded

wen_e <= ifu_exu_wen_d & good_to_issue;
wen_m <= wen_e & ~exc_vld_e;                         // en = ~stall_reg_mw
wen_w <= wen_m & ~exc_vld_merge_m & ~exc_vld_w;      // en = ~stall_reg_mw
```

The RF is written from W: `waddr1 = rd_w`, `wen1 = wen_w`,
`wdata1 = rd_data_w`. The `~exc_vld_w` term kills the write of an LSU
instruction whose exception was merged while M/W were held (TLB
exception case). Reads of r0 return 0.

## Stall control (c7bexu_ecl)

- `stall_ifu` (to the IFU as `exu_ifu_stall`) stops new instructions at D.
- `stall_reg_mw` holds the common M/W registers.

| Source | Begin | End | stall_ifu | stall_reg_mw |
|---|---|---|---|---|
| LSU | `lsu_vld_e` | `lsu_end` | `~lsu_end & (lsu_vld_e \| lsu_stall_q)` | `lsu_stall_q & ~lsu_end` |
| DIV | `div_vld_e` | `div_complete_m` | `~div_end & (div_vld_e \| div_stall_q)` | `div_stall_q & ~div_end` |
| CSR | `csr_vld_e` | fixed | `csr_vld_e \| csr_stall_q` (2 cycles) | - |
| TLB | `tlb_vld_e` | fixed | `tlb_vld_e` (1 cycle) | - |

```verilog
lsu_end = lsu_except_ale_ls1 | lsu_data_valid_ls3 | lsu_wr_fin_ls3
        | lsu_except_buserr_ls3 | lsu_except_tlb_related_ls2
        | lsu_ecl_ibar_fin | lsu_ecl_dbar_fin | lsu_ecl_sc_fin;
```

The `lsu_except_tlb_related_ls2` input of `c7bexu_ecl` is connected to
`exc_vld_w` in c7bexu, so a TLB exception at ls2 ends the stall one
cycle later, when it commits.

```
bgn            : _-______
end            : ______-_
stall_ifu      : _------_      (= stall_in)
stall_q        : __-----_
stall_reg_mw   : __-----_      (= stall_q & ~end)
```

- In the begin cycle `stall_reg_mw` is still 0, so the LSU/DIV
  instruction moves to M and the older one to W.
- In the end cycle both stalls are 0: M/W move and the IFU may present
  the next instruction.
- An LSU op that ends at ls1 (ALE, ibar, dbar, failed SC) does not stall.
- CSR: there is no CSR bypass. The write is at M (E+1), and the IFU is
  held for E and E+1, so the next instruction reads CSRs at D in E+2 at
  the earliest. CSR updates themselves are not held.
- TLB: one cycle, so TLBSRCH can use the TLB search port.

## Flush

```verilog
flush = lsu_except_ale_ls1 | exc_vld_e | exc_vld_m | exc_vld_w
      | ertn_vld_e | ertn_vld_m | ertn_vld_w
      | bru_branch_e | bru_branch_m | bru_branch_w;
```

`flush` is internal. It blocks the D instruction (`good_to_issue`,
`exc_vld_e`, `pic` `vld_d`), but never cancels anything already in
E/M/W. A redirecting instruction in E, M or W keeps all younger
instructions out of E. The IFU flushes on the W signals only
(`exu_ifu_except | exu_ifu_branch | exu_ifu_ertn`).

Not in `flush`: `lsu_except_tlb_related_ls2` (removed for timing; the
IFU is stalled anyway), `lsu_except_ale_m`, `lsu_except_buserr_ls3`.

## Exceptions

```verilog
exc_vld_e  <= (ifu_exu_exc_vld_d & ifu_exu_vld_d & ~flush)
            | (ifu_exu_vld_d & ~ifu_exu_exc_vld_d & ~flush & intr_pulse);
exc_code_e <= intr_pulse ? 6'h00 : ifu_exu_exc_code_d;     // INT
exc_*_m    <= exc_*_e;
exc_vld_merge_m = exc_vld_m | lsu_except_ale_m | lsu_except_buserr_ls3
                | lsu_except_tlb_related_ls2;
exc_*_w    <= *_merge_m;
```

LSU exceptions join at M. `lsu_except_ale_m` is `lsu_except_ale_ls1`
one cycle later; the others are used in the cycle they occur.

| Priority | Condition | exc_code | BADV |
|---|---|---|---|
| 1 | `lsu_except_buserr_ls3` | 0x08 ADEM | `lsu_except_buserr_badv_ls3` |
| 2 | `lsu_except_ale_m` | 0x09 ALE | `lsu_except_ale_badv_m` |
| 3 | `lsu_except_tlbr_ls2` | 0x3F TLBR | `lsu_except_tlbr_badv_ls2` |
| 4 | `lsu_except_pil_ls2` | 0x01 PIL | `lsu_except_pil_badv_ls2` |
| 5 | `lsu_except_pis_ls2` | 0x02 PIS | `lsu_except_pis_badv_ls2` |
| 6 | `lsu_except_ppi_ls2` | 0x07 PPI | `lsu_except_ppi_badv_ls2` |
| 7 | `lsu_except_pme_ls2` | 0x04 PME | `lsu_except_pme_badv_ls2` |
| 8 | otherwise | `exc_code_m` | `exc_badv_m` |

The subcode is 1 for any TLB-related LSU exception or bus error,
otherwise `exc_subcode_m`.

At W, `exc_vld_w`, `exc_code_w`, `exc_subcode_w`, `exc_badv_w` and
`pc_w` (ERA) go to `c7bcsr`. The IFU gets `exu_ifu_except = exc_vld_w`
and `exu_ifu_isr_addr = (exc_code_w == 6'h3f) ? tlbrentry : eentry`.

## Interrupts (pic)

`ext_intr` passes through `intr_sync` (2 flip-flops) and becomes
`ext_intr_sync`, which also goes to `c7bcsr` directly. `pic` inputs are
`ext_intr_sync & crmd_ie`, `csr_timer_intr & crmd_ie`,
`vld_d = ifu_exu_vld_d & ~ifu_exu_exc_vld_d & ~flush`, and
`ertn_w = ertn_vld_w`. Each source has an in-progress flag:

```verilog
bgn        = src & vld_d & ~inprog_q;
inprog_in  = ~ertn_w & (bgn | inprog_q);
pulse      = inprog_in & ~inprog_q;
intr_pulse = ext_pulse | timer_pulse;
```

A source waits for a valid, non-exception, non-flushed instruction at D,
gives one `intr_pulse` in that cycle, and stays in progress until the
next `ertn_w`. The pulse takes that instruction out of normal issue and
sends it down as `exc_vld_e` with code 0x00, so ERA is its PC.

## ertn

`ertn_vld_e <= ifu_exu_ertn_vld_d & good_to_issue`, then `_m` and `_w`.
All three are in `flush`. At W: `exu_ifu_ertn = ertn_vld_w`,
`exu_ifu_ert_addr = csr_era`, `c7bcsr` gets `ecl_csr_ertn_w`, and `pic`
clears both in-progress flags. `exu_csr_last_inst_ertn` loads
`ertn_vld_e` whenever a non-exception instruction is in E.

## Branch

`branch` is combinational at E. `bru_taken = take & branch_valid`.
JIRL target is rs1 + offset; the others use pc + offset. Ops without a
condition (B, BL, JIRL) are always taken. `bru_branch` and
`bru_brn_addr` are piped to W:
`exu_ifu_branch = bru_branch_w`, `exu_ifu_brn_addr = bru_brn_addr_w`.
A taken branch blocks D for three cycles (its E, M, W). There is no
prediction. Not-taken branches do not flush. The link value (PC+4) goes
through `rd_data_m`.

## TLB instructions

| Signal | `tlb_vld_e &` | To |
|---|---|---|
| `tlbfill_vld_e` | `tlb_op_e == LTLB_TLBWR` | ITLB, DTLB |
| `tlbwr_vld_e` | `tlb_op_e == LTLB_TLBWI` | ITLB, DTLB |
| `tlbrd_vld_e` | `tlb_op_e == LTLB_TLBR` | CSR |
| `tlbsrch_vld_e` | `tlb_op_e == LTLB_TLBP` | ITLB, DTLB |
| `tlbsrch_vld_m` | `tlbsrch_vld_e` one cycle later | CSR, DTLB |
| `invtlb_vld_e` | `tlb_op_e == LTLB_INVTLB` | ITLB, DTLB (op, asid, vppn) |

The `LTLB_*` codes are defined in `c7bifu/rtl/dec_defs.v`. The random
index for TLBFILL is the `random` counter. CSR TLB fields go to the ITLB
unchanged (`csr_itlb_*`); ITLB and DTLB results return to `c7bcsr`.

## Timelines

`D` is the instruction offered by the IFU (`ifu_exu_vld_d`=1).

### Timeline: ALU back-to-back

I1 writes r1; I2, I3, I4 read r1.

```
cycle        0      1      2      3      4
D            I1     I2     I3     I4     -
E                   I1     I2     I3     I4
M                          I1     I2     I3
W                                 I1     I2
I2 rs1                     use_m
I3 rs1                            use_w
I4 rs1                            (RF fwd at D)  use_rf
```

- 2: I1 in M, `rd_m` = r1, I2 takes `rd_data_m`.
- 3: I1 in W, I3 takes `rd_data_w`; I4 reads the RF at D and the RF
  forwards the W write. The RF is written at the end of cycle 3.

### Timeline: load with LSU stall

I0 older ALU op, LD writes r1, I2 reads r1. Example BIU timing: ack in
3, data in 5.

```
cycle          0      1      2      3      4      5      6      7
D              -      -      -      -      -      I2
E / ls1        LD                                        I2
LSU            ls1    ls2    dly1   req    wait   ls3
M              I0     LD     LD     LD     LD     LD            I2
W                     I0     I0     I0     I0     I0     LD
stall_ifu      1      1      1      1      1      0      0
lsu_stall_q    0      1      1      1      1      1      0
stall_reg_mw   0      1      1      1      1      0      0
data_vld_ls3   0      0      0      0      0      1      0
```

- 0: LD in E; `stall_ifu`=1, `stall_reg_mw`=0, so LD moves to M and I0
  to W.
- 1-4: M/W held. W keeps I0 and writes the same value again each cycle.
- 5: data valid, `lsu_end`; `rd_data_m` = `lsu_data_ls3`, M/W move, I2
  is issued.
- 6: LD in W, I2 in E takes `rd_data_w`.

A TLB exception at ls2 in cycle k gives `exc_vld_w` in k+1, which also
ends the stall in k+1 and clears `wen_w` through `~exc_vld_w`.

### Timeline: branch taken

BR is taken; X1 and X2 are the next sequential instructions.

```
cycle            0      1      2      3      4
D                BR     X1     X2     -      target (IFU latency)
E                       BR
M                              BR
W                                     BR
flush            0      1      1      1      0
good_to_issue    1      0      0      0      1
exu_ifu_branch   0      0      0      1      0
```

- 1, 2: `bru_branch_e` / `_m` keep X1 and X2 out of E.
- 3: `exu_ifu_branch` with `bru_brn_addr_w`; the IFU flushes and fetches
  the target.

### Timeline: exception taken

SYS has `ifu_exu_exc_vld_d`=1 (e.g. SYSCALL).

```
cycle            0      1      2      3      4
D                SYS    Y1     Y2     -      handler (IFU latency)
exc_vld_e/m/w           e      m      w
flush            0      1      1      1      0
pc_e/m/w                SYS    SYS    SYS
exu_ifu_except   0      0      0      1      0
```

- 0: no unit valid for SYS, only `exc_vld_e` loads.
- 3: CSR gets except, code, subcode, BADV, ERA = `pc_w`; the IFU goes
  to `isr_addr`.

LSU exceptions enter at M instead: ALE at ls1 (with `flush` at E) is
merged one cycle later as `lsu_except_ale_m`; bus error and TLB
exceptions are merged in the cycle they occur. All reach W one cycle
after the merge.

### Timeline: interrupt insertion

`ext_intr` rises in cycle 0, `crmd.ie`=1, Ix is at D in cycle 2.

```
cycle            0      1      2      3      4      5      6
ext_intr         1      1      1      1
sync_out[0]      0      1      1      1
ext_intr_sync    0      0      1      1
D                              Ix                   -      handler
intr_pulse                     1      0
inprog_q         0      0      0      1      1      1      1 (until ertn_w)
good_to_issue                  0
exc_vld_e/m/w                         e      m      w
exu_ifu_except                                      1
```

- 2: `bgn` and `intr_pulse`; Ix is not issued, `exc_vld_e` loads with
  code 0x00.
- 5: committed at W, ERA = PC of Ix.

If D has no valid instruction in cycle 2, `bgn` waits until it does.

### Timeline: DIV

DIV writes r1, I2 reads r1. From `div.v`: operands are latched at the
end of E, `count` goes from 32 down to -1 in cycles 1-34, and
`complete` is 1 in cycle 35.

```
cycle            0      1      2..33  34     35     36     37
D                -      -      -      -      I2
E                DIV                                I2
M                       DIV    DIV    DIV    DIV           I2
W                                                   DIV
count            32     32     31..0  -1     0xF0
div_complete_m   0      0      0      0      1      0
stall_ifu        1      1      1      1      0
stall_reg_mw     0      1      1      1      0
```

- 35: `rd_data_m` = `div_s_m` or `div_r_m`, M/W move, I2 is issued.
- 36: I2 in E takes `rd_data_w`.

`stall_ifu` is 1 for 35 cycles (0-34).

## Notes / limitations

- **Bus error.** `lsu_except_buserr_ls3` ends the LSU stall in the same
  cycle (c7bexu_ecl.v:38, 50, 59) but is not in `flush`
  (c7bexu.v:966). It reaches `flush` only as `exc_vld_w` one cycle
  later. An instruction at D in the bus-error cycle is issued, enters E
  together with `exc_vld_w` and is not cancelled. `wen_m` only checks
  `exc_vld_e`, and `exc_vld_merge_m` / `exc_vld_w` are 0 when it
  reaches M. So it writes the RF and performs its LSU/CSR/branch
  action.
- **ALE.** `lsu_except_ale_ls1` is in `flush` at E, but
  `lsu_except_ale_m` is not (c7bexu.v:966), and the stall ends at ls1.
  In E+1 nothing blocks issue, and `exc_vld_w` comes only in E+2. An
  instruction at D in E+1 behaves as in the bus-error case. Whether the
  IFU can present one then depends on `stall_iq`
  (c7bifu/rtl/c7bifu.v:243).
- **ecl TLB input.** The `lsu_except_tlb_related_ls2` input of
  `c7bexu_ecl` is driven by `exc_vld_w` (c7bexu.v:983, `// uty: test`).
  Any W exception ends an LSU stall.
- **pic and ertn.** `pic` clears both in-progress flags on any `ertn_w`
  (pic.v:145, 178), whatever exception the ertn returns from. While a
  flag is set, the same source cannot give a new pulse even if it falls
  and rises again.
- **Interrupt and stall.** The interrupt term of `exc_vld_e`
  (c7bexu.v:1045) and `pic` `vld_d` (c7bexu.v:300) do not check
  `stall_ifu`. They rely on `ifu_exu_vld_d = inst_vld_d & ~stall &
  ~flush` in the IFU (c7bifu/rtl/c7bifu_dec.v:265).
- **pc_w.** `pc_w` is not held by `stall_reg_mw` (c7bexu.v:1171-1176,
  `// uty: test`). During a stall it shows the M instruction, not the
  held W instruction.
- **Subcode.** The subcode is set to 1 for TLB-related LSU exceptions
  as well as bus error (c7bexu.v:1127); the comment there mentions only
  ADEM.
- **DIV cycle count.** The DIV stall is 35 cycles; the comments say 32
  (c7bexu_ecl.v:85) and 34 (div.v:1).
- **MUL.** The `mul64x64` handshake is not used: `ex2_allowin` and
  `ex1/ex2_readygo` are 1, `mul_validout` and `mul_ready` are open, and
  the operands are zero-extended to 64 bits (c7bexu.v:652-675). The
  result is always taken at M.
- **Unused.** `lsu_except_ecc_ls3` is not used in `c7bexu_ecl`
  (c7bexu_ecl.v:11). `pic` outputs `intr_sync` and `pic_csr_ext_intr`
  and `intr_sync` output `intr_pulse` are not used. `intr_sync_delay` is
  not instantiated.
- **Reset.** `exc_*`, `ertn_vld_*`, `bru_branch_*` and most unit valids
  are `dff_ns` without reset. They settle from the reset upstream
  valids.

## Interface summary

| Signal | Dir | Description |
|---|---|---|
| `ext_intr` | in | External interrupt, asynchronous |
| `exu_ifu_branch` / `exu_ifu_brn_addr` | out | Branch redirect (W) |
| `exu_ifu_except` / `exu_ifu_isr_addr` | out | Exception redirect (W); TLBR uses `tlbrentry` |
| `exu_ifu_ertn` / `exu_ifu_ert_addr` | out | ertn redirect (W), ERA |
| `exu_ifu_stall` | out | Hold decode (`stall_ifu`) |
| `ifu_exu_vld_d`, `ifu_exu_pc_d`, `_rs1_d`, `_rs2_d`, `_rd_d`, `_wen_d`, `_imm_shifted_d` | in | Decoded instruction |
| `ifu_exu_{alu,lsu,bru,mul,div,csr,ertn,tlb}_*_d` | in | Per-unit valid and controls |
| `ifu_exu_exc_vld_d` / `_code_d` / `_subcode_d` / `_badv_d` | in | Exception carried by the instruction in D |
| `lsu_biu_rd_req` / `lsu_biu_rd_addr` | out | Data read request (from `c7blsu`) |
| `biu_lsu_rd_ack`, `biu_lsu_data_vld`, `biu_lsu_data`, `biu_lsu_fault`, `_fault_code` | in | Read ack, 64-bit data, bus fault |
| `lsu_biu_wr_req` / `_addr` / `_data` / `_strb` | out | Data write request, 64-bit data, 8-bit strobe |
| `biu_lsu_wr_ack`, `biu_lsu_wr_fin`, `biu_lsu_wr_fault`, `_fault_code` | in | Write ack, finish, bus fault |
| `csr_ifu_ic_en`, `csr_ifu_ic_en_pls` | out | Icache enable and enable pulse |
| `csr_ifu_crmd_da` / `_pg`, `csr_ifu_dmw{0,1}_{pseg,vseg}` | out | Translation mode and DMW for fetch |
| `csr_itlb_*` | out | TLB CSR fields, ASID, PLV, TLBR context to ITLB |
| `exu_itlb_random_index`, `exu_itlb_{tlbfill,tlbwr,tlbsrch,invtlb}_vld_e`, `exu_itlb_invtlb_{op,asid,vppn}_e` | out | TLB instructions to ITLB (E) |
| `itlb_csr_*` | in | ITLB read and TLBSRCH results to CSR |
