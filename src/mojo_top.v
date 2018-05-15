module mojo_top(
    input clk,              	// 50MHz clock input
    input rst_n,			// Input from reset button (active low)
    input cclk,			// cclk input from AVR, high when AVR is ready
    output[7:0]led,			// Outputs to the 8 onboard LEDs
    
    input joystick_x,
    input joystick_y,
    input joystick_button,	
    input uart_rx,
	
	output red_out,
	output green_out,
	output blue_out,
	output hsync_out,
    output vsync_out
    );

wire rst = ~rst_n; // make reset active high
reg [10:0] ctr_d, ctr_q;
reg hsync, vsync;
reg [9:0] countx_d, countx_q;
reg r,g,b;
reg [1:0] mode_d, mode_q;
wire stick;

assign red_out = r;
assign green_out = g;
assign blue_out = b;
assign hsync_out = ~hsync;
assign vsync_out = ~vsync;
assign led[7:0] = 8'b1000_0001;

initial begin
countx_q = 10'b0;
mode_q   = 2'b0;
end

button my_button (
    .clk(clk),
    .btn(~joystick_y),
    .out(stick)
  );
/////////////////////////////////////////////////////////////////
always @(posedge stick) begin 
	mode_d = mode_q + 1;
end

always @(*) begin 			
	if (joystick_button == 1'b0) begin
				r = ctr_q[10] | ctr_q[9] | ctr_q[8];
				g = ctr_q[10] | ctr_q[9] | ctr_q[8];
				b = ctr_q[10] | ctr_q[9] | ctr_q[8];	
				end	
	else begin 
	case(mode_q)
		2'b00 : begin
				r = ctr_q[10];
				g = ctr_q[9];
				b = ctr_q[8];
				end
		
		2'b01 : begin
				r = ctr_q[10] | ctr_q[9] | ctr_q[8];
				g = 1'b0;
				b = 1'b0;	
				end
		
		2'b10 : begin
				r = 1'b0;
				g = ctr_q[10] | ctr_q[9] | ctr_q[8];
				b = 1'b0;	
				end
				
		2'b11 : begin
				r = 1'b0;
				g = 1'b0;
				b = ctr_q[10] | ctr_q[9] | ctr_q[8];	
				end
		
		default : begin
				r = ctr_q[10];
				g = ctr_q[9];
				b = ctr_q[8];
				  end
	endcase
	end
end
//////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
always @(*) begin                              // hsync 출력, Hsync는 50MHz clock에 동기화
	if (ctr_q[10:0] < 11'd160) hsync = 1'b1;   // Hsync pulse = 3.2us = 160 clk x 20ns(50MHz)
	else hsync = 1'b0;
end
always @(*) begin           // vsync 출력, , Vsync는 Hsync에 동기화
	if (ctr_q[10:0] < 11'd1320) countx_d = countx_q;   // 
	else if (countx_q < 3'd4) vsync = 1'b1;            // sync pulse = 4 H-lines 
	else vsync = 1'b0;
end
////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////
always @(posedge clk) begin
	if (rst || ctr_d[10:0] == 11'd1320) begin
	countx_q <= countx_d + 1;
	if (countx_d == 10'd628) countx_q <= 10'b0;  // Vsync cycle = 628 H-lines
	end
	else countx_q <= countx_d;
	
	mode_q <= mode_d;
end
/////////////////////////////////////////////////////

/////////////////////////////////////////////////////
always @(ctr_q) begin
	ctr_d = ctr_q + 1;
end
always @(posedge clk) begin
	if (rst || ctr_d[10:0] > 11'd1320) ctr_q <= 11'b0;
	else ctr_q <= ctr_d;
end
/////////////////////////////////////////////////////

endmodule













