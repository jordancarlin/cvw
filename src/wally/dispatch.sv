///////////////////////////////////////////
// dispatch.sv
//
// Written: Jordan Carlin jcarlin@hmc.edu
// Created: 24 January 2025
//
// Purpose: Dispatch instructions to appropriate execution unit
// 
// Documentation: RISC-V System on Chip Design
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwgroup/cvw
// 
// Copyright (C) 2021-25 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file 
// except in compliance with the License, or, at your option, the Apache License version 2.0. You 
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the 
// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

module dispatch import cvw::*;  #(parameter cvw_t P) (
  input  logic        clk, reset,
  input  logic [31:0] InstrD,                  // Instruction in Decode stage
  output FpuOp, MduOp, AluOp, MemOp
);

  logic [6:0] OpD;
  logic [6:0] funct7;
  logic [2:0] funct3;

  assign OpD = InstrD[6:0];
  assign funct7 = InstrD[31:25];
  assign funct3 = InstrD[14:12];

  always_comb begin
    {FpuOp, MduOp, AluOp, MemOp} = '0;
    /* verilator lint_off CASEINCOMPLETE */
    casez (OpD)
      7'b0?00011: MemOp = 1'b1; // load/store
      7'b0?00111: FpuOp = 1'b1; // FP load/store
      7'b0?10?11: if (funct7 == 7'b0000001 & P.ZMMUL_SUPPORTED) // mul/div
                    if (funct3[2] == 1'b1 & P.F_SUPPORTED & P.IDIV_ON_FPU) FpuOp = 1'b1; // div uses FPU
                    else MduOp = 1'b1;
                  else AluOp = 1'b1; // ALU I, R, or U type
      7'b1100011: AluOp = 1'b1; // ALU B type
      7'b110?111: AluOp = 1'b1; // ALU J type
      7'b0?11011: if (P.XLEN == 64) // RV64 ALU and MDU
                    if (funct7 == 7'b0000001 & P.ZMMUL_SUPPORTED) // mul/div
                      if (funct3[2] == 1'b1 & P.M_SUPPORTED & P.IDIV_ON_FPU) FpuOp = 1'b1; // div uses FPU
                      else MduOp = 1'b1;
                    else AluOp = 1'b1; // ALU I, R, or U type
      7'b100??11: if (P.F_SUPPORTED) FpuOp = 1'b1; // fma
      7'b1010011: if (P.F_SUPPORTED) FpuOp = 1'b1; // FP ALU
      7'b0001111: MemOp = 1'b1; // fence and CMO
      7'b0101111: MemOp = 1'b1; // AMO
      // 7'b1110011: // privileged
    endcase
    /* verilator lint_on CASEINCOMPLETE */
  end


endmodule
