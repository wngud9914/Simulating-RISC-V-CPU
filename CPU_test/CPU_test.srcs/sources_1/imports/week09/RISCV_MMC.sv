`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National University of Singapore
// Engineer: Neil Banerjee
// 
// Create Date: 22.02.2025 21:29:09
// Design Name: RISCV-MMC
// Module Name: RISCV_MMC
// Project Name: CS2100DE Labs
// Target Devices: Nexys 4/Nexys 4 DDR
// Tool Versions: Vivado 2023.2
// Description: The main RISC-V CPU 
// 
// Dependencies: Nil
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RISCV_MMC(
    input clk,
    input rst,
    //input Interrupt,      // for optional future use.
    input [31:0] instr,
    input [31:0] mem_read_data,       // v2: Renamed to support lb/lbu/lh/lhu
    output mem_read,
    output reg mem_write,  // Delete reg for release. v2: Changed to column-wise write enable to support sb/sw. Each column is a byte.
    output [31:0] PC,
    output [31:0] alu_result,
    output reg [31:0] mem_write_data  // Delete reg for release. v2: Renamed to support sb/sw
    );
    

	// Create all the wires/logic signals you need here
    logic reg_write, PC_src, alu_src_b, MemtoReg;
    logic [1:0] PCS, alu_src_a;
    logic [2:0] imm_src, alu_flags;
    logic [5:0] alu_control;
    logic [31:0] Aa,Ab,ext_imm, src_b, RD1E, RD2E, pc_in, pc_4, pc_imm, pc_jalr, Result;
    
    assign mem_write_data = RD2E;
    assign mem_read = MemtoReg; // This is needed for the proper functionality of some devices such as UART CONSOLE
 
	// Instantiate your extender module here
    Extend extender_instant (
        .instr_imm(instr[31:7]),
        .imm_src(imm_src),
        .ext_imm(ext_imm)
    );
	// Instantiate your instruction decoder here
    Decoder decoder_instant (
        .instr(instr),
        .PCS(PCS),
        .imm_src(imm_src),
        .mem_to_reg(MemtoReg),
        .mem_write(mem_write),
        .alu_control(alu_control),
        .alu_src_b(alu_src_b),
        .reg_write(reg_write),
        .alu_src_a(alu_src_a)
    );
    always_comb begin
        Aa = alu_src_a[1] ? PC : 0;
        Ab = alu_src_a[0] ? Aa : RD1E;
        src_b = alu_src_b ? ext_imm : RD2E;
    end
	// Instantiate your ALU here
    ALU alu_instant (
        .src_a(Ab),
        .src_b(src_b),
        .control(alu_control),
        .result(alu_result),
        .flags(alu_flags)
    );
	// Instantiate the Register File
    RegFile regfile_instant(
        .clk(clk),
        .we(reg_write),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .WD(Result),
        .RD1(RD1E),
        .RD2(RD2E)
    );
    
    
    always_comb begin
    if (PCS == 2'b10)                  // JAL
        Result = PC + 32'd4;             // link value
    else
        Result = MemtoReg ? mem_read_data : alu_result;
    end
	// Instantiate the PC Logic
    PC_Logic pc_logic_instant (
    	.PCS(PCS),	// 00 for non-control, 01 for conditional branch, 10 for jal, 11 for jalr
        .funct3(instr[14:12]),	// condition specified in the instruction (eq / ne / lt / ge / ltu / geu)
        .alu_flags(alu_flags), 	// {eq, lt, ltu}
        .PC_src(PC_src)
    );
	// Instantiate the Program Counter
	assign pc_4 = PC +32'd4;
	assign pc_imm = PC +ext_imm;
	
	always_comb begin
	   pc_in = PC_src ? pc_imm : pc_4;
	end
	ProgramCounter programcounter_instant(
        .clk(clk),
        .rst(rst),
        .pc_in(pc_in),
        .pc(PC)
    );

endmodule
