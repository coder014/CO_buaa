`define ALUOP_ADDU 4'd0
`define ALUOP_ADD 4'd1
`define ALUOP_ORI 4'd2
`define ALUOP_LUI 4'd3
`define ALUOP_AND 4'd4
`define ALUOP_OR 4'd5
`define ALUOP_ANDI 4'd6
`define ALUOP_SLT 4'd7
`define ALUOP_SLTU 4'd8
`define ALUOP_SUB 4'd9
`define ALUOP_ADD_LOAD 4'd10
`define ALUOP_ADD_STORE 4'd11
`define ALUOP_SUBU 4'd12

`define MULDIV_DO_MUL 3'b000
`define MULDIV_DO_MULU 3'b001
`define MULDIV_DO_DIV 3'b010
`define MULDIV_DO_DIVU 3'b011
`define MULDIV_SELECT_LO 3'b000
`define MULDIV_SELECT_HI 3'b001

`define MEM_STORE_WORD 3'd1
`define MEM_STORE_HALF 3'd2
`define MEM_STORE_BYTE 3'd3
`define MEM_LOAD_WORD 3'd1
`define MEM_LOAD_HALF 3'd2
`define MEM_LOAD_BYTE 3'd3

`define JUMP_NONE 4'd0
`define JUMP_BEQ 4'd1
`define JUMP_JAL 4'd2
`define JUMP_JR 4'd3
`define JUMP_BNE 4'd4
`define JUMP_ERET 4'd5

`define E_FW_USE_M 2'b10 //M for Memory stage
`define E_FW_USE_W 2'b01 //W for Writeback stage
`define E_FW_USE_S 2'b00 //S for Self
`define D_FW_USE_M 1'b1 //M for Memory stage
`define D_FW_USE_S 1'b0 //S for Self
`define M_FW_USE_W 1'b1 //W for Write-back stage
`define M_FW_USE_S 1'b0 //S for Self

`define VALUE_USE_NEXT 2'b10
`define VALUE_USE_NOW 2'b01
`define VALUE_USE_NONE 2'b00

`define EXCCODE_ADEL 5'd4
`define EXCCODE_ADES 5'd5
`define EXCCODE_SYSCALL 5'd8
`define EXCCODE_RI 5'd10
`define EXCCODE_OV 5'd12