
module uart (
    input clk,
    input rstn,
    
    input rxd,
    output txd,
    output irq,
    
    input [31:0] Addr,
    input WE,
    input [31:0] Din,
    output reg [31:0] Dout
);

    reg [15:0] DIVT, DIVR;
    wire [7:0] rx_data;
    wire tx_avai, rx_ready;
    wire rx_clear = (!WE) && ((Addr>>2) == (32'h7f30>>2));
    wire tx_start = WE && ((Addr>>2) == (32'h7f30>>2));
    wire [7:0] tx_data = Din[7:0];
    assign irq = rx_ready;
    
    always@(posedge clk) begin
        if(~rstn) begin
            DIVT <= 16'hFFFF;
            DIVR <= 16'hFFFF;
        end else if(WE) begin
            if((Addr>>2) == (32'h7f38>>2)) DIVR <= Din[15:0];
            else if((Addr>>2) == (32'h7f3c>>2)) DIVT <= Din[15:0];
        end
    end
    
    always@(*) begin
        if((Addr>>2) == (32'h7f30>>2)) Dout = {24'b0, rx_data}; //DATA
        else if((Addr>>2) == (32'h7f34>>2)) Dout = {26'b0, tx_avai, 4'b0, rx_ready}; //LSR
        else if((Addr>>2) == (32'h7f38>>2)) Dout = {16'b0, DIVR}; //DIVR
        else if((Addr>>2) == (32'h7f3c>>2)) Dout = {16'b0, DIVT}; //DIVT
        else Dout = 0;
    end
    
    uart_tx uart_tx(
        .clk(clk), .rstn(rstn), .period(DIVT),
        .txd(txd), .tx_start(tx_start),
        .tx_data(tx_data), .tx_avai(tx_avai)
    );
    uart_rx uart_rx(
        .clk(clk), .rstn(rstn), .period(DIVR),
        .rxd(rxd), .rx_clear(rx_clear),
        .rx_data(rx_data), .rx_ready(rx_ready)
    );

endmodule

/*
 * uart_count is used to indicate the sample point of the receiver and transmitter
 *      when they are working(not idle)
 * 'period' represents the number of clock cycles of a sample cycle
 * 'preset' means the value of 'count' starts as it for the first sample cycle
 *      but the second and subsequent start as 0. Thus,'preset' play a role in 
 *      lagging the sample point for a while, which will be helpful for the receiver
 * 'q' is the signal to indicate the sample point which will be SET(high level) 
 *      for only one clock cycle
 */
module uart_count (
    input wire clk,
    input wire rstn,
    input wire en,
    input wire [15:0] period,
    input wire [15:0] preset,   // preset value
    output wire q
);

    reg [15:0] count;

    always @(posedge clk) begin
        if (~rstn) begin
            count <= 0;
        end
        else begin
            if (en) begin
                if (count + 16'd1 == period) begin
                    count <= 16'd0;
                end
                else begin
                    count <= count + 16'd1;
                end
            end
            else begin
                count <= preset;
            end
        end
    end

    assign q = count + 16'd1 == period;

endmodule


module uart_tx (
    input wire clk,
    input wire rstn,
    input wire [15:0] period,
    input wire tx_start,        // 1 if outside wants to send data
    input wire [7:0] tx_data,   // data to be sent
    output wire txd,
    output wire tx_avai         // 1 if uart can send data
);
    localparam IDLE = 0, START = 1, WORK = 2, STOP = 3;

    reg [1:0] state;
    reg [7:0] data;         // a copy of 'tx_data', modified(right shift) at each sample point
    reg [2:0] bit_count;    // number of bits which is not sent

    wire count_en = state != IDLE;
    wire count_q;

    uart_count count (
        .clk(clk), .rstn(rstn), .period(period), .en(count_en), .q(count_q),
        .preset(16'b0) // no offset
    );

    // transmit
    always @(posedge clk) begin
        if (~rstn) begin
            state <= IDLE;
            data <= 0;
            bit_count <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (tx_start) begin
                        state <= START;
                        data <= tx_data;
                    end
                end
                START: begin
                    if (count_q) begin
                        state <= WORK;
                        bit_count <= 3'd7;
                    end
                end
                WORK: begin
                    if (count_q) begin
                        data <= {1'b0, data[7:1]}; // right shift
                        if (bit_count == 0) begin
                            state <= STOP;
                        end
                        else begin
                            bit_count <= bit_count - 3'd1;
                        end
                    end
                end
                STOP: begin
                    if (count_q) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    assign tx_avai = state == IDLE;
    assign txd = (state == IDLE || state == STOP) ? 1'b1 :
                 (state == START) ? 1'b0 : data[0];

endmodule

module uart_rx (
    input wire clk,
    input wire rstn,
    input wire [15:0] period,
    input wire rxd,
    input wire rx_clear,        // 1 if outside took or discarded the received data
    output reg [7:0] rx_data,   // data has been read
    output reg rx_ready         // 1 if 'uart_rx' has read complete data(a byte)
);
    localparam IDLE = 0, START = 1, WORK = 2, STOP = 3;

    wire count_en = state != IDLE;
    wire count_q;

    uart_count count (
        .clk(clk), .rstn(rstn), .period(period), .en(count_en), 
        .q(count_q), .preset(period >> 1) // half sample cycle offset
    );

    reg [1:0] state;
    reg [7:0] buffer;       // buffer for received bits
    reg [2:0] bit_count;    // number of bits which need to receive

    always @(posedge clk) begin
        if (~rstn) begin
            state <= 0;
            buffer <= 0;
            bit_count <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (~rxd) begin
                        state <= START;
                        buffer <= 0;
                    end
                end
                START: begin
                    if (count_q) begin
                        state <= WORK;
                        bit_count <= 3'd7;
                    end
                end
                WORK: begin
                    if (count_q) begin
                        if (bit_count == 0) begin
                            state <= STOP;
                        end
                        else begin
                            bit_count <= bit_count - 3'd1;
                        end
                        buffer <= {rxd, buffer[7:1]};   // take received bit
                    end
                end
                STOP: begin
                    if (count_q) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            rx_data <= 0;
            rx_ready <= 0;
        end
        else begin
            if (rx_clear) begin
                rx_data <= 0;
                rx_ready <= 0;
            end
            else if (state == STOP && count_q) begin    // complete receiving
                rx_data <= buffer;
                rx_ready <= 1;
            end
        end
    end


endmodule
