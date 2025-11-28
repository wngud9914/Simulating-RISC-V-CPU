`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National University of Singapore
// Engineer: Neil Banerjee
// 
// Create Date: 22.02.2025 20:37:13
// Design Name: RISCV-MMC
// Module Name: Decoder 
// Project Name: CS2100DE Labs
// Target Devices: Nexys 4/Nexys 4 DDR
// Tool Versions: Vivado 2023.2
// Description: Instruction decoder and Control Unit for the RISC-V CPU we are building
// 
// Dependencies: Nil
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Decoder(
    input  logic [31:0] instr,
    output logic        mem_to_reg, mem_write, alu_src_b, reg_write,
    output logic [1:0]  PCS,alu_src_a,
    output logic [2:0]  imm_src,
    output logic [5:0]  alu_control
    );
    
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    
    always @(instr) begin
    case(opcode)
        7'b0110011 : begin //R
            mem_to_reg <= 1'b0; //1 ? write data memory read data (loads). 0 ? write ALU result 
            mem_write <= 1'b0; //Write enable for data memory. 1 for stores (SB/SH/SW). 0 otherwise.
            alu_src_b <= 1'b0; //Selects ALU operand B. 0 ? rs2 1 ? extended immediate
            reg_write <= 1'b1; //Write enable for the register file (rd).
            PCS <= 2'b0; //Tells the PC mux to take a target instead of PC+4.
            if (funct7==7'b0) begin
                alu_control <= {3'b000, funct3};//
            end
            else begin
                alu_control <= {3'b001, funct3};
            end
        end
        7'b0010011 : begin //I ali
            mem_to_reg <= 1'b0;
            mem_write <= 1'b0;
            alu_src_b <= 1'b1;
            reg_write <= 1'b1;
            PCS <= 2'b0;
            alu_control <= {3'b010, funct3};//ADDI, SLTI, SLTIU...
            imm_src <= 3'b000;
            alu_src_a <= 2'b00;
        end
        7'b0000011 : begin // I ld
            mem_to_reg <= 1'b1;
            mem_write <= 1'b0;
            alu_src_b <= 1'b1;
            reg_write <= 1'b1;
            PCS <= 2'b0;
            alu_control <= {3'b011, funct3};//LB, LH, LW,LBU, LHU
            imm_src <= 3'b000;
            alu_src_a <= 2'b00;
        end
        7'b0100011: begin // S
            mem_to_reg <= 1'b0;
            mem_write <= 1'b1;
            alu_src_b <= 1'b1;
            reg_write <= 1'b0;
            PCS <= 2'b0;
            alu_control <= {3'b011, funct3};// SB, SH, SW
            imm_src <= 3'b001;
            alu_src_a <= 2'b00;
        end
        7'b1100011: begin // B
            mem_to_reg <= 1'b0;
            mem_write <= 1'b0;
            alu_src_b <= 1'b0;
            reg_write <= 1'b0;
            PCS <= 2'b01;
            alu_control <= {3'b100, funct3};// BEQ,BNE,BLT,BGE,BLTU,BGEU
            imm_src <= 3'b010;
            alu_src_a <= 2'b00;
        end
        7'b0110111: begin // U
            mem_to_reg <= 1'b0;
            mem_write <= 1'b0;
            alu_src_b <= 1'b1;
            reg_write <= 1'b1;
            PCS <= 2'b00;
            alu_control <= 6'b101000;// store the value to rd
            imm_src <= 3'b011;
            alu_src_a <= 2'b01;
        end
        7'b0010111: begin // auipc
            mem_to_reg <= 1'b0;
            mem_write <= 1'b0;
            alu_src_b <= 1'b1;
            reg_write <= 1'b1;
            PCS <= 2'b00;
            alu_control <= 6'b101000;// store the value to rd
            imm_src <= 3'b011;
            alu_src_a <= 2'b11;
        end
        7'b1101111: begin // J/UJ
            mem_to_reg <= 1'b0;
            mem_write <= 1'b0;
            alu_src_b <= 1'b1;
            reg_write <= 1'b1;
            PCS <= 2'b10;
            alu_control <= 6'b110000;// store the PC+4 address value to rd
            imm_src <= 3'b100;
            alu_src_a <= 2'b01;
        end
    endcase
    
    end

endmodule
