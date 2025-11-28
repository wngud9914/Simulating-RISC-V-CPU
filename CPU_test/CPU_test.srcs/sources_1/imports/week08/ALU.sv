`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: National University of Singapore
// Engineer: Neil Banerjee
// 
// Create Date: 22.02.2025 23:59:46
// Design Name: RISCV-MMC
// Module Name: ALU
// Project Name: CS2100DE Labs
// Target Devices: Nexys 4/Nexys 4 DDR
// Tool Versions: Vivado 2023.2
// Description: ALU for the RISC-V CPU
// 
// Dependencies: Nil
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(
    input  logic [31:0] src_a,
    input  logic [31:0] src_b,
    input  logic [5:0]  control,
    output logic [31:0] result,
    output logic [2:0]  flags
);
    // Flags: drive every cycle from operands
    always @(src_a, src_b, control) begin
        flags = {(src_a == src_b), ($signed(src_a) < $signed(src_b)), (src_a < src_b)};
    end

    // Result: pure combinational select by control
    always_comb begin
        result = 32'b0;

        unique case (control)
            // ADD / ADDI
            6'b000000, 6'b010000: result = src_a + src_b;

            // SUB
            6'b001000:            result = src_a - src_b;

            // SLL / SLLI
            6'b000001, 6'b010001: result = src_a << (src_b[4:0]);

            // SLT / SLTI
            6'b000010, 6'b010010: result = ($signed(src_a) < $signed(src_b)) ? 32'd1 : 32'd0;

            // SLTU / SLTIU
            6'b000011, 6'b010011: result = (src_a < src_b) ? 32'd1 : 32'd0;

            // XOR / XORI
            6'b000100, 6'b010100: result = src_a ^ src_b;

            // SRL / SRLI
            6'b000101, 6'b010101: result = src_a >> (src_b[4:0]);

            // SRA  (add a code for SRAI if you use one)
            6'b001101:            result = $signed(src_a) >>> (src_b[4:0]);

            // OR / ORI
            6'b000110, 6'b010110: result = src_a | src_b;

            // AND / ANDI
            6'b000111, 6'b010111: result = src_a & src_b;

            // LOADs & STOREs: effective address = rs1 + imm (full 32-bit add)
            6'b011000, 6'b011001, 6'b011010, 6'b011100, 6'b011101, // loads: LB/LH/LW/LBU/LHU
            6'b100000, 6'b100001, 6'b100010:                        // stores: SB/SH/SW
                                 result = src_a + src_b;

            // U/J helpers if your decoder maps them here (PASS_B)
            6'b101000, 6'b110000: result = src_b;

            default: result = 0;
        endcase
    end
endmodule


//module ALU(
//    input logic [31:0] src_a,
//    input logic [31:0] src_b,
//    input logic [5:0] control,
//    output logic [31:0] result, 
//    output logic [2:0] flags
//    );
    
//    always @(src_a, src_b, control) begin
//        case (control)
//            6'b000000 , 6'b010000 : begin //ADD, ADDI
//                result = src_a + src_b;
//            end
//            6'b001000 : begin
//                result = src_a - src_b;//SUB
//            end
//            6'b000001 , 6'b010001: begin
//                result = src_a << (src_b[4:0]);//SLL, SLLI
//            end
//            6'b000010 , 6'b010010: begin
//                result = ($signed(src_a) < $signed(src_b)) ? 32'd1 : 32'd0;//SLT,SLTI
//            end
//            6'b000011 , 6'b010011: begin
//                result = ($unsigned(src_a) < $unsigned(src_b)) ? 32'd1 : 32'd0;//SLTU,STLIU
//            end
//            6'b000100 , 6'b010100: begin
//                result = src_a ^ src_b;//XOR, XORI
//            end
//            6'b000101 , 6'b010101: begin
//                result = src_a >> (src_b[4:0]); //SRL,SRLI
//            end
//            6'b001101 : begin
//                result = $signed(src_a) >>> (src_b[4:0]); //SRA
//            end
//            6'b000110 , 6'b010110: begin
//                result = src_a | src_b; //OR,ORI
//            end
//            6'b000111 , 6'b010111: begin
//                result = src_a & src_b;//AND, ANDI
//            end
//            6'b011000 ,6'b100000: begin
//                result = src_a[7:0] + src_b[7:0];//src is memory LB load byte, SB
//            end
//            6'b011001 ,6'b100001: begin
//                result = src_a[15:0] + src_b[15:0];//LH load half ,SH
//            end
//            6'b011010 ,6'b100010: begin
//                result = src_a + src_b;//LW load half, SW
//            end
//            6'b011100: begin
//                result = $unsigned(src_a[7:0] + src_b[7:0]);//LBU load byte unsigned
//            end
//            6'b011101: begin
//                result = $unsigned(src_a[15:0] + src_b[15:0]);//LBU load half unsigned
//            end
//            6'b101000: begin
//                result = src_b;//Upper-Immediate-Type
//            end
//            6'b110000: begin
//                result = src_b;//Jump-Type
//            end
//            default : result = 0;
//    endcase
//    case (control)
//            6'b100000: begin
//                if (src_a ==src_b) begin //BEQ
//                    flags =3'b001;
//                end
//            end
//            6'b100001: begin
//                if (src_a !=src_b) begin //BNE
//                    flags =3'b110;
//                end
//            end
//            6'b100100: begin
//                if ($signed(src_a) < $signed(src_b)) begin //BLT
//                    flags =3'b010;
//                end
//            end
//            6'b100101: begin
//                if ($signed(src_a) >= $signed(src_b)) begin //BGE
//                    flags =3'b101;
//                end
//            end
//            6'b100110: begin
//                if (src_a <src_b) begin //BLTU
//                    flags =3'b100;
//                end
//            end
//            6'b100111: begin
//                if (src_a >=src_b) begin //BLGEU
//                    flags =3'b011;
//                end
//            end
//            default : begin
//                flags =3'b000;
//            end
//    endcase
//    end
//endmodule
