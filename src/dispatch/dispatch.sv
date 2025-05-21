///////////////////////////////////////////
// dispatch.sv
//
// Written: Jordan Carlin jcarlin@hmc.edu
// Created: 24 January 2025
//
// Purpose: Arbitrate between execution units for instruction dispatch
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
  input  logic [31:0] Instr0D, Instr1D,
  output logic        IEU0Valid, IEU1Valid, MDUValid, CryptoValid, FPUValid, MemValid, PrivValid,
  output logic        IEU0Order, IEU1Order, MDUOrder, CryptoOrder, FPUOrder, MemOrder, PrivOrder,
  output logic        IEU0Instr, IEU1Instr, MDUInstr, CryptoInstr, FPUInstr, MemInstr, PrivInstr
);

  logic IEUOp0, MDUOp0, CryptoOp0, FPUOp0, MemOp0, PrivOp0;
  logic IEUOp1, MDUOp1, CryptoOp1, FPUOp1, MemOp1, PrivOp1;

  typeDecoder #(.P) typeDecoder1 (.InstrD(Instr0D), .IEUOp(IEUOp0), .MDUOp(MDUOp0), .CryptoOp(CryptoOp0),
                                  .FPUOp(FPUOp0), .MemOp(MemOp0), .PrivOp(PrivOp0));
  typeDecoder #(.P) typeDecoder2 (.InstrD(Instr1D), .IEUOp(IEUOp1), .MDUOp(MDUOp1), .CryptoOp(CryptoOp1),
                                  .FPUOp(FPUOp1), .MemOp(MemOp1), .PrivOp(PrivOp1));

  // Arbitrate between execution units
  always_comb begin
    // Default to no valid signals
    {IEU0Valid, IEU1Valid, MDUValid, CryptoValid, FPUValid, MemValid, PrivValid} = '0;
    {IEU0Order, IEU1Order, MDUOrder, CryptoOrder, FPUOrder, MemOrder, PrivOrder} = '0;
    {IEU0Instr, IEU1Instr, MDUInstr, CryptoInstr, FPUInstr, MemInstr, PrivInstr} = '0;

    if (MemOp0) begin
      MemValid = 1'b1;
      MemOrder = 1'b0;
      MemInstr = Instr0D;
    end else if (MemOp1) begin
      MemValid = 1'b1;
      MemOrder = 1'b1;
      MemInstr = Instr1D;
    end

    if (FPUOp0) begin
      FPUValid = 1'b1;
      FPUOrder = 1'b0;
      FPUInstr = Instr0D;
    end else if (FPUOp1) begin
      FPUValid = 1'b1;
      FPUOrder = 1'b1;
      FPUInstr = Instr1D;
    end

    if (CryptoOp0) begin
      CryptoValid = 1'b1;
      CryptoOrder = 1'b0;
      CryptoInstr = Instr0D;
    end else if (CryptoOp1) begin
      CryptoValid = 1'b1;
      CryptoOrder = 1'b1;
      CryptoInstr = Instr1D;
    end

    if (MDUOp0) begin
      MDUValid = 1'b1;
      MDUOrder = 1'b0;
      MDUInstr = Instr0D;
    end else if (MDUOp1) begin
      MDUValid = 1'b1;
      MDUOrder = 1'b1;
      MDUInstr = Instr1D;
    end

    if (PrivOp0) begin
      PrivValid = 1'b1;
      PrivOrder = 1'b0;
      PrivInstr = Instr0D;
    end else if (PrivOp1) begin
      PrivValid = 1'b1;
      PrivOrder = 1'b1;
      PrivInstr = Instr1D;
    end

    if (IEUOp0) begin
      IEU0Valid = 1'b1;
      IEU0Order = 1'b0;
      IEU0Instr = Instr0D;
    end else if (IEUOp1) begin
      IEU0Valid = 1'b1;
      IEU0Order = 1'b1;
      IEU0Instr = Instr1D;
    end
    
    if (IEUOp1 & IEU0Order != 1'b1 & ~MemValid) begin
      IEU1Valid = 1'b1;
      IEU1Order = 1'b1;
      IEU1Instr = Instr1D;
    end
  end

endmodule
