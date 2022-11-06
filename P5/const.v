`define ALUOP_ADD 4'd0
`define ALUOP_SUB 4'd1
`define ALUOP_ORI 4'd2
`define ALUOP_LUI 4'd3

`define JUMP_NONE 4'd0
`define JUMP_BEQ 4'd1
`define JUMP_JAL 4'd2
`define JUMP_JR 4'd3

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