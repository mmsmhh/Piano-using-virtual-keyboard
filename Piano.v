module Piano
(
	input wire [7:0] in,
	input wire clk,
	input wire clr,
	output wire speaker,	speaker2,
	output wire [3:0] red,
	output wire [3:0] green,
	output wire [3:0] blue,
	output wire hsync,
	output wire vsync
);


VGA(
	.in(~in),
	.clk(clk),
	.clr(clr),
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.green(green),
	.blue(blue)
	);


	SensorAndSound(
.clk(clk),
.speaker(speaker),
.speaker2(speaker2),
.inp(in)
);

endmodule



module VGA(
	input wire [8:0] in,
	input wire clk,			//master clock = 50MHz
	input wire clr,
	output wire [3:0] red,	//red vga output - 4 bits
	output wire [3:0] green,//green vga output - 4 bits
	output wire [3:0] blue,	//blue vga output - 4 bits
	output wire hsync,		//horizontal sync out
	output wire vsync			//vertical sync out
	);

// VGA display clock interconnect
wire dclk;


// generate display clock
clockdiv U1(
	.clk(clk),
	.clr(clr),
	.dclk(dclk)
	);


// VGA controller
vga640x480 U3(
	.in(in),
	.dclk(dclk),
	.clr(clr),
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.green(green),
	.blue(blue)
	);

endmodule






module clockdiv(
	input wire clk,		//master clock: 50MHz
	input wire clr,		//asynchronous reset
	output wire dclk	//pixel clock: 25MHz
	);

// 17-bit counter variable
reg [16:0] q;

// Clock divider --
// Each bit in q is a clock signal that is
// only a fraction of the master clock.
always @(posedge clk or negedge clr)
begin
	// reset condition
	if (clr == 0)
		q <= 0;
	// increment counter by one
	else
		q <= q + 1;
end

// 50Mhz รท 2^1 = 25MHz
assign dclk = q[0];

endmodule


module vga640x480(
	input wire [7:0] in,
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [3:0] red,	//red vga output
	output reg [3:0] green, //green vga output
	output reg [3:0] blue	//blue vga output
	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 195; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 350; 		// end of vertical back porch
parameter vfp = 521; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------

always @(posedge dclk or negedge clr )
begin
	// reset condition
	if (clr == 0)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end

	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

always @(*)
begin

if(in[0])
	begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		// now display different colors every 80 pixels
		// while we're within the active horizontal range
		// -----------------


		if (hc >= hbp && hc < (hbp+70))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+70) && hc < (hbp+140))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+140) && hc < (hbp+210))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+210) && hc < (hbp+280))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+280) && hc < (hbp+350))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+350) && hc < (hbp+420))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end
		else if (hc >= (hbp+420) && hc < (hbp+490))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+490) && hc < (hbp+560))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else
		begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
	end
end

else if(in[1])
	begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin


		if (hc >= hbp && hc < (hbp+70))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+70) && hc < (hbp+140))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+140) && hc < (hbp+210))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+210) && hc < (hbp+280))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+280) && hc < (hbp+350))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+350) && hc < (hbp+420))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+420) && hc < (hbp+490))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+490) && hc < (hbp+560))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else
		begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
	end
end


else if(in[2])
	begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin



		if (hc >= hbp && hc < (hbp+70))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+70) && hc < (hbp+140))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+140) && hc < (hbp+210))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+210) && hc < (hbp+280))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+280) && hc < (hbp+350))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+350) && hc < (hbp+420))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+420) && hc < (hbp+490))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+490) && hc < (hbp+560))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else
		begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
	end
end

else if(in[3])
	begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin



		if (hc >= hbp && hc < (hbp+70))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+70) && hc < (hbp+140))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+140) && hc < (hbp+210))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+210) && hc < (hbp+280))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+280) && hc < (hbp+350))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+350) && hc < (hbp+420))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+420) && hc < (hbp+490))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+490) && hc < (hbp+560))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else
		begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
	end
end

else if(in[4])
	begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin



		if (hc >= hbp && hc < (hbp+70))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+70) && hc < (hbp+140))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+140) && hc < (hbp+210))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+210) && hc < (hbp+280))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+280) && hc < (hbp+350))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+350) && hc < (hbp+420))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+420) && hc < (hbp+490))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+490) && hc < (hbp+560))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else
		begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
	end
end

else if(in[5])
	begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin



		if (hc >= hbp && hc < (hbp+70))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+70) && hc < (hbp+140))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+140) && hc < (hbp+210))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+210) && hc < (hbp+280))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+280) && hc < (hbp+350))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+350) && hc < (hbp+420))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+420) && hc < (hbp+490))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+490) && hc < (hbp+560))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else
		begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
	end
end

else if(in[6])
	begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin



		if (hc >= hbp && hc < (hbp+70))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+70) && hc < (hbp+140))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+140) && hc < (hbp+210))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+210) && hc < (hbp+280))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+280) && hc < (hbp+350))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+350) && hc < (hbp+420))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+420) && hc < (hbp+490))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+490) && hc < (hbp+560))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else
		begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
	end
end

else if(in[7])
	begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin



		if (hc >= hbp && hc < (hbp+70))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+70) && hc < (hbp+140))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+140) && hc < (hbp+210))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+210) && hc < (hbp+280))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+280) && hc < (hbp+350))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+350) && hc < (hbp+420))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+420) && hc < (hbp+490))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+490) && hc < (hbp+560))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b0000;
		end

		else
		begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
		end
	end
	//we're outside active vertical range so display black
	else
	begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
	end
end
else
	begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin

		if (hc >= hbp && hc < (hbp+70))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+70) && hc < (hbp+140))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+140) && hc < (hbp+210))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+210) && hc < (hbp+280))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+280) && hc < (hbp+350))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+350) && hc < (hbp+420))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else if (hc >= (hbp+420) && hc < (hbp+490))
		begin
			red = 4'b1111;
			green = 4'b1111;
			blue = 4'b1111;
		end

		else if (hc >= (hbp+490) && hc < (hbp+560))
		begin
			red = 4'b1111;
			green = 4'b0000;
			blue = 4'b0000;
		end

		else
		begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
		end
	end
	else
	begin
		red = 4'b0000;
		green = 4'b0000;
		blue = 4'b0000;
	end
	end
end

endmodule

module SensorAndSound(clk, speaker,speaker2,inp);
input clk;
input [7:0] inp;
output speaker,speaker2;

 reg [25:0] count1;
 reg [25:0] count2;
 reg [25:0] count3;
 reg [25:0] count4;
 reg [25:0] count5;
 reg [25:0] count6;
 reg [25:0] count7;
 reg [25:0] count8;

 reg clk1=0;
 reg clk2=0;
 reg clk3=0;
 reg clk4=0;
 reg clk5=0;
 reg clk6=0;
 reg clk7=0;
 reg clk8=0;

 always @ (posedge clk)
    begin
           if(count1==47778) begin
              count1 <= 0;
              clk1 = ~clk1 ;
           end else begin
              count1 <= count1 + 1;

           end

			  if(count2==42565) begin
              count2 <= 0;
              clk2 = ~clk2 ;
           end else begin
              count2 <= count2 + 1;

           end

			   if(count3==37921) begin
              count3 <= 0;
              clk3 = ~clk3 ;
           end else begin
              count3 <= count3 + 1;

           end

			   if(count4==35793) begin
              count4 <= 0;
              clk4 = ~clk4 ;
           end else begin
              count4 <= count4 + 1;

           end

			  if(count5==31888) begin
              count5 <= 0;
              clk5 = ~clk5 ;
           end else begin
              count5 <= count5 + 1;

           end

			  if(count6==28409) begin
              count6 <= 0;
              clk6 = ~clk6 ;
           end else begin
              count6 <= count6 + 1;

           end

			  if(count7==25310) begin
              count7 <= 0;
              clk7 = ~clk7 ;
           end else begin
              count7 <= count7 + 1;

           end

			  if(count8==23889) begin
              count8 <= 0;
              clk8 = ~clk8 ;
           end else begin
              count8 <= count8 + 1;

           end
    end

		assign speaker =(inp[0])? ((inp[1])? ((inp[2])? ((inp[3])? ((inp[4])? ((inp[5])? ((inp[6])? ((inp[7])? 0:clk8):clk7):clk6 ):clk5):clk4):clk3):clk2):clk1 ;
		assign speaker2 =(inp[0])? ((inp[1])? ((inp[2])? ((inp[3])? ((inp[4])? ((inp[5])? ((inp[6])? ((inp[7])? 0:clk8):clk7):clk6 ):clk5):clk4):clk3):clk2):clk1 ;

		//  assign speaker =(inp[1])? 0:clk2 ;
	//	assign speaker =(inp[2])? 0:clk3 ;
	//	assign speaker =(inp[3])? 0:clk4 ;
	//	assign speaker =(inp[4])? 0:clk5 ;
	//	assign speaker =(inp[5])? 0:clk6 ;
	//	assign speaker =(inp[6])? 0:clk7 ;
	//	assign speaker =(inp[7])? 0:clk8 ;

endmodule



