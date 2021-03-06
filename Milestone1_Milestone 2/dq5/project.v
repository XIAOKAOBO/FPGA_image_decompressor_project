/*
Copyright by Henry Ko and Nicola Nicolici
Developed for the Digital Systems Design course (COE3DQ4)
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`default_nettype none

`include "define_state.h"

module project(

	
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock

		/////// pushbuttons/switches              ////////////
		input logic[3:0] PUSH_BUTTON_I,           // pushbuttons
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// 7 segment displays/LEDs           ////////////
		output logic[6:0] SEVEN_SEGMENT_N_O[7:0], // 8 seven segment displays
		output logic[8:0] LED_GREEN_O,            // 9 green LEDs
		
		/////// VGA interface                     ////////////
		output logic VGA_CLOCK_O,                 // VGA clock
		output logic VGA_HSYNC_O,                 // VGA H_SYNC
		output logic VGA_VSYNC_O,                 // VGA V_SYNC
		output logic VGA_BLANK_O,                 // VGA BLANK
		output logic VGA_SYNC_O,                  // VGA SYNC
		output logic[9:0] VGA_RED_O,              // VGA red
		output logic[9:0] VGA_GREEN_O,            // VGA green
		output logic[9:0] VGA_BLUE_O,             // VGA blue
		
		/////// SRAM Interface                    ////////////
		inout wire[15:0] SRAM_DATA_IO,            // SRAM data bus 16 bits
		output logic[17:0] SRAM_ADDRESS_O,        // SRAM address bus 18 bits
		output logic SRAM_UB_N_O,                 // SRAM high-byte data mask 
		output logic SRAM_LB_N_O,                 // SRAM low-byte data mask 
		output logic SRAM_WE_N_O,                 // SRAM write enable
		output logic SRAM_CE_N_O,                 // SRAM chip enable
		output logic SRAM_OE_N_O,                 // SRAM output logic enable
		
		/////// UART                              ////////////
		input logic UART_RX_I,                    // UART receive signal
		output logic UART_TX_O,                    // UART transmit signal
		
		////DRAM
		output logic [6:0] READ_ADDRESS_O,
		output logic [6:0] WRITE_ADDRESS_O,		
		output logic [31:0] READ_DATA_A_O [1:0],
		output logic [31:0] READ_DATA_B_O [1:0],
		output logic [31:0] WRITE_DATA_B_O [1:0],
		output logic WRITE_ENABLE_B_O [1:0]	
		
);
	
	
logic M1_start,M1_done,M2_start,M2_done;
logic resetn;

// states fot the state machine
m2_state_type state_m2;
top_state_type top_state;
m1_state_type state;

// For Push button
logic [3:0] PB_pushed;

// For VGA SRAM interface
logic VGA_enable;
logic [17:0] VGA_base_address;
logic [17:0] VGA_SRAM_address;

// For SRAM
logic [17:0] SRAM_address;
logic [15:0] SRAM_write_data;
logic SRAM_we_n;
logic [15:0] SRAM_read_data;
logic SRAM_ready;

// For UART SRAM interface
logic UART_rx_enable;
logic UART_rx_initialize;
logic [17:0] UART_SRAM_address;
logic [15:0] UART_SRAM_write_data;
logic UART_SRAM_we_n;
logic [25:0] UART_timer;

logic[17:0] M1_address;
logic [15:0] M1_write_data; 
logic M1_we_n;

  logic[18:0] M2_address;
    logic M2_enable;
  logic [15:0] M2_write_data;

logic [6:0] value_7_segment [7:0];

// For error detection in UART
logic [3:0] Frame_error;

// For disabling UART transmit
assign UART_TX_O = 1'b1;

assign resetn = ~SWITCH_I[17] && SRAM_ready;
assign VGA_base_address = 18'd146944;

// Push Button unit
PB_Controller PB_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(resetn),
	.PB_signal(PUSH_BUTTON_I),	
	.PB_pushed(PB_pushed)
);

// VGA SRAM interface
VGA_SRAM_interface VGA_unit (
	.Clock(CLOCK_50_I),
	.Resetn(resetn),
	.VGA_enable(VGA_enable),
   
	// For accessing SRAM
	.SRAM_base_address(VGA_base_address),
	.SRAM_address(VGA_SRAM_address),
	.SRAM_read_data(SRAM_read_data),
   
	// To VGA pins
	.VGA_CLOCK_O(VGA_CLOCK_O),
	.VGA_HSYNC_O(VGA_HSYNC_O),
	.VGA_VSYNC_O(VGA_VSYNC_O),
	.VGA_BLANK_O(VGA_BLANK_O),
	.VGA_SYNC_O(VGA_SYNC_O),
	.VGA_RED_O(VGA_RED_O),
	.VGA_GREEN_O(VGA_GREEN_O),
	.VGA_BLUE_O(VGA_BLUE_O)
);

// UART SRAM interface
UART_SRAM_interface UART_unit(
	.Clock(CLOCK_50_I),
	.Resetn(resetn), 
   
	.UART_RX_I(UART_RX_I),
	.Initialize(UART_rx_initialize),
	.Enable(UART_rx_enable),
   
	// For accessing SRAM
	.SRAM_address(UART_SRAM_address),
	.SRAM_write_data(UART_SRAM_write_data),
	.SRAM_we_n(UART_SRAM_we_n),
	.Frame_error(Frame_error)
);

// SRAM unit
SRAM_Controller SRAM_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(~SWITCH_I[17]),
	.SRAM_address(SRAM_address),
	.SRAM_write_data(SRAM_write_data),
	.SRAM_we_n(SRAM_we_n),
	.SRAM_read_data(SRAM_read_data),		
	.SRAM_ready(SRAM_ready),
		
	// To the SRAM pins
	.SRAM_DATA_IO(SRAM_DATA_IO),
	.SRAM_ADDRESS_O(SRAM_ADDRESS_O),
	.SRAM_UB_N_O(SRAM_UB_N_O),
	.SRAM_LB_N_O(SRAM_LB_N_O),
	.SRAM_WE_N_O(SRAM_WE_N_O),
	.SRAM_CE_N_O(SRAM_CE_N_O),
	.SRAM_OE_N_O(SRAM_OE_N_O)
);


logic start_flag;
always @(posedge CLOCK_50_I or negedge resetn) begin
	if (~resetn) begin
		top_state <= S_IDLE;
		start_flag <= 1'b0;
		UART_rx_initialize <= 1'b0;
		UART_rx_enable <= 1'b0;
		UART_timer <= 26'd0;
		M1_start<=1'd0;
		//M1_done<=1'd0;
		M2_start<=1'd0;
		//M2_done<=1'd0;
		
		VGA_enable <= 1'b1;
	end else begin
		UART_rx_initialize <= 1'b0; 
		UART_rx_enable <= 1'b0; 
		
		// Timer for timeout on UART
		// This counter reset itself every time a new data is received on UART
		if (UART_rx_initialize | ~UART_SRAM_we_n) UART_timer <= 26'd0;
		else UART_timer <= UART_timer + 26'd1;

		case (top_state)
		S_IDLE: begin
			VGA_enable <= 1'b1;   
			if (~UART_RX_I | PB_pushed[0]) begin    // adding "|start_flag"
				// UART detected a signal, or PB0 is pressed
				UART_rx_initialize <= 1'b1;
				
				VGA_enable <= 1'b0;
				UART_rx_enable <= 1'b1;				
				top_state <= S_ENABLE_UART_RX;  // change to S_ONE or S_TWO
			end
		end
		S_ENABLE_UART_RX: begin
			// Enable the UART receiver
			UART_rx_enable <= 1'b1;
			top_state <= S_WAIT_UART_RX;
		end
		S_WAIT_UART_RX: begin
			if ((UART_timer == 26'd49999999) && (UART_SRAM_address != 18'h00000)) begin
				// Timeout for 1 sec on UART for detecting if file transmission is finished
				UART_rx_initialize <= 1'b1;
				VGA_enable <= 1'b1;
				//VGA_enable <= 1'b1;
				top_state <= S_TWO;
			end
		end
		S_ONE: begin
			M1_start<=1'd1;
			if(M1_done)begin
				top_state<=S_IDLE;
			end
		end
		
		S_TWO:begin
			M2_start<=1'd1;
			if(M2_done)begin
				top_state<=S_ONE;
			end
		end
		
		default: top_state <= S_IDLE;
		endcase
	end
end

				
always_comb begin
	if((top_state == S_WAIT_UART_RX)|(top_state == S_ENABLE_UART_RX))begin
		SRAM_address=UART_SRAM_address;
	end else if(top_state==S_ONE) begin
		SRAM_address=M1_address;
	end else if(top_state==S_TWO)begin
		SRAM_address=M2_address;
	end else begin
		SRAM_address=VGA_SRAM_address;
	end
end

//assign SRAM_write_data = (top_state==S_ONE)?M1_write_data:UART_SRAM_write_data;

always_comb begin
	
	if(top_state==S_ONE) begin
		SRAM_write_data=M1_write_data;
	end else if(top_state==S_TWO)begin
		SRAM_write_data=M2_write_data;
	end else begin
		SRAM_write_data = UART_SRAM_write_data;
	end
end

			
always_comb begin

	if(top_state==S_ONE) begin
		SRAM_we_n=M1_we_n;
	end else if(top_state==S_TWO)begin
		SRAM_we_n = M2_enable;
	end else if((top_state == S_ENABLE_UART_RX)|(top_state == S_WAIT_UART_RX))begin
		SRAM_we_n=UART_SRAM_we_n;
	end else begin
		SRAM_we_n=1'b1;
	end
end						
						

// Define the offset for U, V and RGB data in the memory		
parameter U_OFFSET = 18'd38400,
	  V_OFFSET = 18'd57600,
	  RGB_OFFSET = 18'd146944;

// Data counter for getting data of a pixel
logic [17:0] data_counter;
logic [7:0] count_line;


logic [15:0] Y;                                              //ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss
logic [7:0] U[5:0];
logic [7:0] Ubuff;
logic [7:0] V[5:0];
logic [7:0] Vbuff;
logic [15:0] Uprime, Vprime;			//U'[j] and  V'[j]
logic [47:0] RGBreg;           //8 bits for each R G B
logic[31:0] op1,op2,op3,op4,op5,op6;

logic[31:0] Multi1,Multi2,Multi3; 
logic [63:0] multi1,multi2,multi3;
logic[31:0] Uodd,Vodd;
logic [31:0] Rreg, Greg, Breg;
logic [17:0] write_address; 
logic [17:0] U_add;
logic [17:0] V_add;
logic [17:0] Y_add;
logic [8:0] pixcount;
logic[7:0] Rout,Gout,Bout;

logic [2:0] rect_row_count;	// Number of rectangles in a row
logic [2:0] rect_col_count;	// Number of rectangles in a column
logic [5:0] rect_width_count;	// Width of each rectangle
logic [4:0] rect_height_count;	// Height of each rectangle
logic [2:0] color;


always_comb begin
	op1=32'd0;
	op2=32'd0;
	op3=32'd0;
	op4=32'd0;
	op5=32'd0;
	op6=32'd0;
	if(state==intial_7|| state ==intial_15 || state==common_0 || state==common_8 || state==end_0 || state== end_8 || state==end_16 || state==end_24)begin
		op1 = 32'd21;
      op2 = U[0];
		op3 = 32'd52; // remember  ttttttttttttttttttttttttttttttttttttttto minus
      op4 = U[1];
		op5 = 32'd159;
		op6 = U[2];
	end else if(state==intial_8 || state==intial_16 || state==common_1 || state==common_9 || state== end_1 || state==end_9 || state==end_17 || state==end_25)begin
		op1 = 32'd159;
      op2 = U[3];
		op3 = 32'd52; // remember  ttttttttttttttttttttttttttttttttttttttto minus
      op4 = U[4];
		op5 = 32'd21;
		op6 = U[5];
	end else if(state==intial_9 || state==intial_17 || state==common_2 || state == common_10 || state == end_2 || state == end_10 || state == end_18 || state == end_26)begin
		op1 = 32'd21;
      op2 = V[0];
		op3 = 32'd52; // remember  ttttttttttttttttttttttttttttttttttttttto minus
      op4 = V[1];
		op5 = 32'd159;
		op6 = V[2];
	end else if(state == intial_10 || state== intial_18 || state ==common_3 || state==common_11 || state == end_3 || state ==end_11 || state == end_19 || state== end_27)begin
		op1 = 32'd159;
      op2 = V[3];
		op3 = 32'd52; // remember  ttttttttttttttttttttttttttttttttttttttto minus
      op4 = V[4];
		op5 = 32'd21;
		op6 = V[5];		
	end else if(state==intial_11 || state == intial_19 || state==common_4 || state==common_12 || state==end_4 || state==end_12 || state ==end_20||state==end_28)begin
		op1 = 32'd76284;
      op2 = Y[15:8]-5'd16; 
		op3 = 32'd104595; // remember  ttttttttttttttttttttttttttttttttttttttto minus
      op4 = Vprime[15:8]-8'd128;
		op5 = 32'd25624;
		op6 = Uprime[15:8]-8'd128;
	end else if(state==intial_12 || state==intial_20 || state== common_5 || state ==common_13 || state == end_5 || state == end_13 || state ==end_21 || state == end_29)begin
		op1 = 32'd76284;
      op2 = Y[15:8]-5'd16; 
		op3 = 32'd53281; // remember  ttttttttttttttttttttttttttttttttttttttto minus
      op4 = Vprime[15:8]-8'd128;
		op5 = 32'd132251;
		op6 = Uprime[15:8]-8'd128;	
	end else if(state==intial_13 || state==intial_21 || state== common_6 || state ==common_14 || state == end_6 || state == end_14 || state ==end_22 || state == end_30)begin
		op1 = 32'd76284;
      op2 = Y[7:0]-5'd16; 
		op3 = 32'd104595; // remember  ttttttttttttttttttttttttttttttttttttttto minus
      op4 = Vprime[7:0]-8'd128;
		op5 = 32'd25624;
		op6 = Uprime[7:0]-8'd128;
	end else if(state==intial_14 || state==intial_22 || state== common_7 || state ==common_15 || state == end_7 || state == end_15 || state ==end_23 || state == end_31)begin
		op1 = 32'd76284;
      op2 = Y[7:0]-5'd16; 
		op3 = 32'd53281; // remember  ttttttttttttttttttttttttttttttttttttttto minus
      op4 = Vprime[7:0]-8'd128;
		op5 = 32'd132251;
		op6 = Uprime[7:0]-8'd128;	
	end
	
end

assign multi3=op5*op6;
assign multi2=op3*op4;
assign multi1=op1*op2;
assign Multi3=multi3[31:0];
assign Multi2=multi2[31:0];
assign Multi1=multi1[31:0];

always_comb begin

	Rout=Rreg[23:16];
	Gout=Greg[23:16];
	Bout=Breg[23:16];


	if (Rreg[30:24]>1'd0)begin
		Rout=8'd255;
	end 
	
	if(Rreg[31]==1)begin
		Rout = 8'd0;
	end 

	if (Greg[30:24]>1'd0)begin
		Gout=8'd255;
	end
	

	if(Greg[31]==1)begin
		Gout = 8'd0;
	end 
	
	if (Breg[30:24]>1'd0)begin
		Bout=8'd255;
	end	
	
	if(Breg[31]==1)begin
		Bout = 8'd0;
	end 

end
 
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		state <= M_IDLE;
		rect_row_count <= 3'd0;
		rect_col_count <= 3'd0;
		rect_width_count <= 6'd0;
		rect_height_count <= 5'd0;
		M1_done<=1'd0;
		
		/*VGA_red <= 10'd0;
		VGA_green <= 10'd0;
		VGA_blue <= 10'd0;				
		*/
		M1_we_n <= 1'b1;
		M1_write_data <= 16'd0;
		M1_address <= 18'd0;
	Y<=16'd0;
    U[5]<=8'd0;
	 U[4]<=8'd0;
	 U[3]<=8'd0;
	 U[2]<=8'd0;
	 U[1]<=8'd0;
	 U[0]<=8'd0;
    
	 V[5]<=8'd0;
	 V[4]<=8'd0;
	 V[3]<=8'd0;
	 V[2]<=8'd0;
	 V[1]<=8'd0;
	 V[0]<=8'd0;
	 Rreg<=32'd0;
	 Greg<=32'd0;
	 Breg<=32'd0;
	 RGBreg<=48'd0;
	 
    Uprime<=16'd0;
    Vprime<=16'd0;
		data_counter <= 18'd0;
		//RED_second_word <= 1'b0;
    Uodd<=16'd0;
	 Vodd<=16'd0;
    write_address<=RGB_OFFSET;
    U_add<= U_OFFSET; 
    V_add<= V_OFFSET;
    Y_add <= 18'd0;
    pixcount<=9'd0;
	end else begin
		case (state)

		M_IDLE: begin
			
		Y<=16'd0;
		U[5]<=8'd0;
		U[4]<=8'd0;
		U[3]<=8'd0;
		U[2]<=8'd0;
		U[1]<=8'd0;
		U[0]<=8'd0;
    
	 V[5]<=8'd0;
	 V[4]<=8'd0;
	 V[3]<=8'd0;
	 V[2]<=8'd0;
	 V[1]<=8'd0;
	 V[0]<=8'd0;
	 Rreg<=32'd0;
	 Greg<=32'd0;
	 Breg<=32'd0;
	 RGBreg<=48'd0;
	 
    Uprime<=16'd0;
    Vprime<=16'd0;

    Uodd<=16'd0;
	 Vodd<=16'd0;			
			M1_we_n <= 1'b1;
			M1_address <= Y_add;
			//data_counter <= 18'd0;
			if(M1_start==1'd1)begin
				state <= intial_0;
			end
			
		end

		intial_0: begin
			//M1_we_n <= 1'b1;
			
			M1_address <= U_add;
			
			state <= intial_1;
		end
		
		
		
		intial_1: begin
			
			M1_address <= V_add;
			
			state <= intial_2;			
		end
		
		
		intial_2: begin
			
			M1_address <= U_add+1'd1;
			Y<=SRAM_read_data;
					
			state <= intial_3;
		end
		
		
		intial_3: begin
		M1_address <= V_add+2'd1;
 
      //U<=SRAM_read_data;
      U[0]<={SRAM_read_data[15:8]};
		U[1]<={SRAM_read_data[15:8]};
		U[2]<={SRAM_read_data[15:8]};
      U[3]<=SRAM_read_data[7:0];					
			state <= intial_4;			
		end
		
		
		intial_4: begin

			//M1_address <= V_OFFSET + 18'd1;
     // V<=SRAM_read_data;
      V[0]<={SRAM_read_data[15:8]};
		V[1]<={SRAM_read_data[15:8]};
		V[2]<={SRAM_read_data[15:8]};
      V[3]<=SRAM_read_data[7:0];				
			state <= intial_5;
		end
      
      
    intial_5: begin

      U[5]<={SRAM_read_data[7:0]};
		U[4]<={SRAM_read_data[15:8]};
		state <= intial_6;			
	end
      
      
    intial_6: begin
      V[5]<={SRAM_read_data[7:0]};
		V[4]<={SRAM_read_data[15:8]};
      Uprime[15:8]<=U[2];
      Vprime[15:8]<=V[2];
      state <= intial_7;
		end
      
      
    intial_7: begin
      Uodd<=Multi1-Multi2+Multi3+8'd128;
      state <= intial_8;			
		end
      
      
    intial_8: begin

		Uodd<=Uodd+Multi1-Multi2+Multi3;
     
      state <= intial_9;			
		end
      
      
      
    intial_9: begin
			Uprime[7:0]<=Uodd>>8;
			Vodd<=Multi1-Multi2+Multi3+32'd128;
      //sel2<=2'd3;
			state <= intial_10;			
		end
      
      
      
    intial_10: begin
			M1_address<=18'd1+Y_add;
			Vodd<=Vodd+Multi1-Multi2+Multi3;
 
			state <= intial_11;
		end
      
      
      
    intial_11: begin
		
		Vprime[7:0]<=Vodd>>8;
      Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
		state <= intial_12;			
		end
      
      
    intial_12: begin
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;
		RGBreg[47:40]<=Rout;
		M1_address<=18'd2+U_add;
     // sel2<=2'd2;
			state <= intial_13;			
		end
      
    intial_13: begin
      
		RGBreg[39:32]<=Gout;
      RGBreg[31:24]<=Bout;
		M1_address<=18'd2+V_add;
		Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
      
      
      U[4:0]<=U[5:1];
      V[4:0]<=V[5:1];
      
      //sel2<=2'd3;
			state <= intial_14;			
		end
      
    intial_14: begin
      RGBreg[23:16]<=Rout;
		
      Y<=SRAM_read_data;
		Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;

     // sel1<=1'd0;
     // sel2<=2'd0;

      
			state <= intial_15;			
		end
      
    intial_15: begin
	   RGBreg[15:8]<=Gout;
      RGBreg[7:0]<=Bout;
      Ubuff<=SRAM_read_data[7:0];
      U[5]<=SRAM_read_data[15:8];
      Uodd<=Multi1-Multi2+Multi3+8'd128;
			//sel2<=2'd1;	
		M1_we_n<=1'b0;
      M1_address<= write_address;	
		M1_write_data<=RGBreg[47:32];
		state <= intial_16;		


	end
      
    intial_16: begin
      
      Uodd<=Uodd+Multi1-Multi2+Multi3;

      Vbuff<=SRAM_read_data[7:0];
      V[5]<=SRAM_read_data[15:8];		
		
		M1_address<= write_address+18'd1;
		M1_write_data<=RGBreg[31:16];
		
		state <= intial_17;			
		end
      
    intial_17: begin
      
		Uprime[15:8]<=U[2];
      Uprime[7:0]<=Uodd[15:8];
		Vprime[15:8]<=V[2];
      Vodd<=Multi1-Multi2+Multi3+8'd128;
			//sel2<=2'd3;	
      M1_write_data<=RGBreg[15:0]; 
      M1_address<=write_address+18'd2;		
		write_address<=write_address+2'd3;
			state <= intial_18;			
		end
      
    intial_18: begin

		Vodd<=Vodd+Multi1-Multi2+Multi3;
      
      //sel1<=1'd1;
    //  sel2<=2'd0;
		M1_we_n<=1'b1;	
			state <= intial_19;			
		end
      
    intial_19: begin
      //M1_write_data<=RGBreg[15:0];
		Vprime[7:0]<=Vodd[15:8];
      Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
 
			//sel2<=2'd1;
		M1_we_n<=1'b1;	
	
	
		state <= intial_20;			
		end
      
    intial_20: begin
		RGBreg[47:40]<=Rout;	
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;
		M1_address<=Y_add+2'd2;
		
				U_add<=U_add+2'd3;
		V_add<=V_add+2'd3;
		Y_add<=Y_add+2'd3;
     // sel2<=2'd2;
      
			state <= intial_21;			
		end
      
    intial_21: begin
	   RGBreg[39:32]<=Gout;
      RGBreg[31:24]<=Bout;
		
      Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
      
      U[4:0]<=U[5:1];
      V[4:0]<=V[5:1];

      U[5]<=Ubuff;
      V[5]<=Vbuff;
    //  sel2<=2'd3;
			state <= intial_22;	
		end
      
    intial_22: begin
		RGBreg[23:16]<=Rout;
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;

		//	sel1<=1'd0;
   //   sel2<=2'd0;
			state <= common_0;
      pixcount<=9'd4;
		end
    
      
    common_0: begin
      RGBreg[15:8]<=Gout;
		
      RGBreg[7:0]<=Bout;	 
	 
	 
      Y<=SRAM_read_data;
      Uodd<=Multi1-Multi2+Multi3+8'd128;
      //Uprime[15:8]<=U[2];
    //  sel2<=2'd1;
      M1_we_n<=1'd0;
      M1_address<=write_address;
		M1_write_data<=RGBreg[47:32];
      state <= common_1;
    end
      
    common_1: begin
      Uodd<=Uodd+Multi1-Multi2+Multi3;
      M1_address<=M1_address+1'd1;
		M1_write_data<=RGBreg[31:16];
      state <= common_2;
    end
      
    common_2: begin
      Vodd<=Multi1-Multi2+Multi3+8'd128;
      Vprime[15:8]<=V[2];
		Uprime[15:8]<=U[2];
		Uprime[7:0]<=Uodd[15:8];
      M1_address<=M1_address+1'd1;
		M1_write_data<=RGBreg[15:0];
      state <= common_3;
    end
      
    common_3: begin
      Vodd<=Vodd+Multi1-Multi2+Multi3;
		
      //M1_write_data<=RGBreg[15:0];
      write_address<=write_address+9'd3;
      M1_we_n<=1'd1;
     // sel2<=2'd0;
     // sel1<=1'd1;
      state <= common_4;
    end
      
      
    common_4: begin
		Vprime[7:0]<=Vodd[15:8];
      M1_address <= U_add;
		Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
      
     // sel2<=2'd1;
      state <= common_5;
    end
      
    common_5: begin
      RGBreg[47:40]<=Rout;
		M1_address <= V_add;
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;

		
     // sel2<=2'd2;  
      U_add<=U_add+18'd1;
      state <= common_6;
    end
      
    common_6: begin
	   RGBreg[39:32]<=Gout;
      RGBreg[31:24]<=Bout;
		V_add<=V_add+18'd1;
		M1_address <= Y_add;
			Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
  
      
      U[4:0]<=U[5:1];
      V[4:0]<=V[5:1];
      V_add<=V_add+18'd1;
      //sel2<=2'd3;
      state <= common_7;
    end
      
    common_7: begin
		RGBreg[23:16]<=Rout;
      
      U[5]<=SRAM_read_data[15:8];
      Ubuff<=SRAM_read_data[7:0];
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;

      Y_add<=Y_add+18'd1;
      state <= common_8;
    end
      
    common_8: begin
	 
      RGBreg[15:8]<=Gout;
      RGBreg[7:0]<=Bout;	 
		
      V[5]<=SRAM_read_data[15:8];
      Vbuff<=SRAM_read_data[7:0];
      Uodd<=Multi1-Multi2+Multi3+8'd128;
      Uprime[15:8]<=U[2];

      state <= common_9;
    end
      
      
    common_9: begin
     	Y<=SRAM_read_data; 
      Uodd<=Uodd+Multi1-Multi2+Multi3;
      Uprime[15:8]<=U[2];

     // sel2<=2'd2;
      M1_we_n<=1'd0;
      M1_address<=write_address;
		M1_write_data<=RGBreg[47:32];
      state <= common_10;
    end
      
      
    common_10: begin
      Uprime[7:0]<=Uodd[15:8];
      Vodd<=Multi1-Multi2+Multi3+8'd128;
      Vprime[15:8]<=V[2];
      M1_address<=M1_address+1'd1;
		M1_write_data<=RGBreg[31:16];
      //sel2<=2'd3;
      state <= common_11;
    end
      
    common_11: begin
      Vodd<=Vodd+Multi1-Multi2+Multi3;

      //sel2=2'd0;
     // sel1<=1'd1;
      M1_address<=M1_address+1'd1;
      M1_write_data<=RGBreg[15:0];
      state <= common_12;
    end
      
    common_12: begin
		Vprime[7:0]<=Vodd[15:8];
	 
      Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
      
      write_address<=write_address+9'd3;
      M1_we_n<=1'd1;
     // sel2<=2'd1;
      
      state <= common_13;
    end
      
    common_13: begin
		RGBreg[47:40]<=Rout;
      M1_address<=Y_add;
		Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;

     // sel2<=2'd2;      
      
      state <= common_14;
    end
      
    common_14: begin
       RGBreg[39:32]<=Gout;
      RGBreg[31:24]<=Bout;
    	
      Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
		U[5]<=Ubuff;
		V[5]<=Vbuff;
      U[4:0]<=U[5:1];
      V[4:0]<=V[5:1]; 
      Y_add<=Y_add+18'd1;
    //  sel2<=2'd3;
      pixcount<=pixcount+3'd4;
      state <= common_15;
    end
      
      
    common_15: begin
		RGBreg[23:16]<=Rout; 
		Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;
   
      
      //data_counter <= data_counter + 18'd1;
     // sel1<=1'd0;
      //sel2<=2'd0;
      
      if(pixcount<9'd312)begin
        state <= common_0;
        
      end
      else begin
        state <= end_0;       
      end
    end
      


      
      
    end_0: begin
		RGBreg[15:8]<=Gout;
		RGBreg[7:0]<=Bout;
      Y<=SRAM_read_data;
      Uodd<=Multi1-Multi2+Multi3+8'd128;
      //Uprime[15:8]<=U[2];
    //  sel2<=2'd1;
      M1_we_n<=1'd0;
      M1_address<=write_address;
		M1_write_data<=RGBreg[47:32];
      state <= end_1;
    end
      
    end_1: begin
      Uodd<=Uodd+Multi1-Multi2+Multi3;
      
      M1_address<=M1_address+1'd1;
		 M1_write_data<=RGBreg[31:16];
      //M1_write_data<=RGBreg[47:32];
    //  sel2<=2'd2;
      state <= end_2;
    end
      
    end_2: begin
      Vodd<=Multi1-Multi2+Multi3+8'd128;
		Uprime[7:0]<=Uodd[15:8];
      Vprime[15:8]<=V[2];
		Uprime[15:8]<=U[2];
     M1_write_data<=RGBreg[15:0];
     // sel2=2'd3;
      M1_address<=M1_address+1'd1;
      state <= end_3;
    end
      
    end_3: begin
      Vodd<=Vodd+Multi1-Multi2+Multi3;
      
      write_address<=write_address+9'd3;
      M1_we_n<=1'd1;
    //  sel2<=2'd0;
     // sel1<=1'd1;
      state <= end_4;
    end

    end_4: begin
		 Vprime[7:0]<=Vodd[15:8];

      Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;

      state <= end_5;
    end
      
    end_5: begin
	   RGBreg[47:40]<=Rout;
		
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;


      state <= end_6;
    end
       
    end_6: begin
		RGBreg[39:32]<=Gout;
      RGBreg[31:24]<=Bout;
      
		M1_address <= Y_add;
		Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;

      
      U[4:0]<=U[5:1];
      V[4:0]<=V[5:1];

      state <= end_7;
    end
      
    end_7: begin
		RGBreg[23:16]<=Rout;
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;

      Y_add<=Y_add+18'd1;
      state <= end_8;
    end
      
    end_8: begin
		RGBreg[15:8]<=Gout;
      RGBreg[7:0]<=Bout;
		
      Uodd<=Multi1-Multi2+Multi3+8'd128;
      Uprime[15:8]<=U[2];

      state <= end_9;
    end
      
    end_9: begin
     	Y<=SRAM_read_data; 
      Uodd<=Uodd+Multi1-Multi2+Multi3;
     // sel2<=2'd2;
      M1_we_n<=1'd0;
      M1_address<=write_address;
		M1_write_data<=RGBreg[47:32];
		Vprime[15:8]<=V[2];
		Uprime[15:8]<=U[2];
      state <= end_10;
    end
      
    end_10: begin
	
      Vodd<=Multi1-Multi2+Multi3+8'd128;
      Uprime[7:0]<=Uodd[15:8];
		
      M1_write_data<=RGBreg[31:16];
      M1_address<=M1_address+1'd1;
    //  sel2<=2'd3;
      state <= end_11;
    end
      
    end_11: begin
      Vodd<=Vodd+Multi1-Multi2+Multi3;

      M1_write_data<=RGBreg[15:0];
		M1_address<=M1_address+1'd1;
   //   sel2=2'd0;
    //  sel1<=1'd1;
      state <= end_12;
    end
      
    end_12: begin
		 Vprime[7:0]<=Vodd[15:8];
				
      Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
   
      write_address<=write_address+9'd3;
      M1_we_n<=1'd1;
   //   sel2<=2'd1;
      
      state <= end_13;
    end
      
    end_13: begin
		   RGBreg[47:40]<=Rout;
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;
		M1_address<=Y_add;
 //     sel2<=2'd2;
      
      state <= end_14;
    end
      
    end_14: begin
	 
		RGBreg[39:32]<=Gout;
      RGBreg[31:24]<=Bout;
		
     	
      Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
      
      U[4:0]<=U[5:1];
      V[4:0]<=V[5:1];
      Y_add<=Y_add+18'd1;
      pixcount<=pixcount+3'd4;
      state <= end_15;
    end
      
    end_15: begin
	 
		RGBreg[23:16]<=Rout; 
			Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;
    
      
      //data_counter <= data_counter + 18'd1;
  //    sel1<=1'd0;
    //  sel2<=2'd0;
      state <= end_16;
    end

    end_16:begin
		RGBreg[15:8]<=Gout;
		RGBreg[7:0]<=Bout;
	 
      Y<=SRAM_read_data;
      Uodd<=Multi1-Multi2+Multi3+8'd128;
      
  //    sel2<=2'd1;
      M1_we_n<=1'd0;
      M1_address<=write_address;
		M1_write_data<=RGBreg[47:32];
      state <= end_17;
    end
      
    end_17: begin
      Uodd<=Uodd+Multi1-Multi2+Multi3;
      M1_write_data<=RGBreg[31:16];
      M1_address<=M1_address+1'd1;

      state <= end_18;
    end
      
      
    end_18: begin
      Vodd<=Multi1-Multi2+Multi3+8'd128;
      Vprime[15:8]<=V[2];
		Uprime[15:8]<=U[2];
		Uprime[7:0]<=Uodd[15:8];
      M1_write_data<=RGBreg[15:0];
   //   sel2=2'd3;
      M1_address<=M1_address+1'd1;
      state <= end_19;
    end

    end_19: begin
      Vodd<=Vodd+Multi1-Multi2+Multi3;
      
      write_address<=write_address+9'd3;
      M1_we_n<=1'd1;
 //     sel2<=2'd0;
  //    sel1<=1'd1;
      state <= end_20;
    end
      
    end_20: begin
      Vprime[7:0]<=Vodd[15:8];
      Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
		//M1_address <= U_add;
  //    sel2<=2'd1;
      state <= end_21;
    end
    
    end_21: begin
		RGBreg[47:40]<=Rout;
		//M1_address <= V_add;
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;
		
		
     // U_add<=U_add+18'd1;
      state <= end_22;
    end
    end_22:begin
		RGBreg[39:32]<=Gout;
      RGBreg[31:24]<=Bout;
      M1_address <= Y_add;
			Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;
		
      U[4:0]<=U[5:1];
      V[4:0]<=V[5:1];
		     // V_add<=V_add+18'd1;
   //   sel2<=2'd3;      
      state <= end_23;
    end
    end_23:begin
		RGBreg[23:16]<=Rout;	 
	 
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;

    	Y_add<=Y_add+18'd1; 
       state <= end_24;
      end
     end_24:begin
      RGBreg[15:8]<=Gout;
      RGBreg[7:0]<=Bout;
		
      Uodd<=Multi1-Multi2+Multi3+8'd128;
      Uprime[15:8]<=U[2];
   
      state <= end_25;
     end
      
    end_25:begin
     	Y<=SRAM_read_data; 
      Uodd<=Uodd+Multi1-Multi2+Multi3;
      
 //     sel2<=2'd2;
      M1_we_n<=1'd0;
      M1_address<=write_address;
		M1_write_data<=RGBreg[47:32];
      state <= end_26;
    end
    end_26:begin
		Uprime[7:0]<=Uodd[15:8];
      Vodd<=Multi1-Multi2+Multi3+8'd128;
      Vprime[15:8]<=V[2];
		Uprime[15:8]<=U[2];
		
      M1_write_data<=RGBreg[31:16];
      M1_address<=M1_address+1'd1;
 //     sel2<=2'd3;
      state <= end_27;
    end
    end_27:begin
      Vodd<=Vodd+Multi1-Multi2+Multi3;
		M1_address<=M1_address+1'd1;
      M1_write_data<=RGBreg[15:0];
 //     sel2=2'd0;
   //   sel1<=1'd1;
      state <= end_28;
     end
    end_28:begin
		Vprime[7:0]<=Vodd[15:8];
		Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
      Breg<=Multi1;

      
      write_address<=write_address+9'd3;
      M1_we_n<=1'd1;

      state <= end_29;    
    end
    
    end_29:begin
		RGBreg[47:40]<=Rout;
      Greg<=Greg-Multi2;
      Breg<=Breg+Multi3;
			
      state <= end_30;
    end
    end_30:begin
	
      RGBreg[39:32]<=Gout;
		RGBreg[31:24]<=Bout;
		
      Rreg<=Multi1+Multi2;
      Greg<=Multi1-Multi3;
		Breg<=Multi1;

      state<=end_31;
    end
    
	 end_31:begin
		
		RGBreg[23:16]<=Rout;
		
	   Greg<=Greg-Multi2;
		Breg<=Breg+Multi3;
		
		 M1_we_n<=1'd0;
		M1_address<=write_address;
		M1_write_data<=RGBreg[47:32]; 		
		state<=end_32;
      end
     
	  end_32:begin
		RGBreg[15:8]<=Gout;
      RGBreg[7:0]<=Bout;
		M1_address<=M1_address+2'd1;
		M1_write_data<=RGBreg[31:16];
      state<=end_33;
     end
	  
	  end_33:begin
		M1_address<=M1_address+2'd1;
		M1_write_data<=RGBreg[15:0];
		write_address<=write_address+9'd3;

		state<=end_34;
	  end
	  
	  end_34:begin
		M1_we_n<=1'd1;
		//M1_done<=1'd1;
		pixcount<=9'd0;
		if(data_counter<8'd239)begin
			data_counter<=data_counter+8'd1;
			M1_address<=Y_add;
			RGBreg<=48'd0;
			Rreg<=32'd0;
			Greg<=32'd0;
			Breg<=32'd0;
			Y<=16'd0;
			U[5]<=8'd0;
			U[4]<=8'd0;
			U[3]<=8'd0;
			U[2]<=8'd0;
			U[1]<=8'd0;
			U[0]<=8'd0;
    
			V[5]<=8'd0;
			V[4]<=8'd0;
			V[3]<=8'd0;
			V[2]<=8'd0;
			V[1]<=8'd0;
			V[0]<=8'd0;
			Rreg<=32'd0;
			Greg<=32'd0;
			Breg<=32'd0;
			RGBreg<=48'd0;
	 
			Uprime<=16'd0;
			Vprime<=16'd0;

		//RED_second_word <= 1'b0;
			Uodd<=16'd0;
			Vodd<=16'd0;
			state<=intial_0;
			//write_address<=RGB_OFFSET;
		end else begin
			M1_done<=1'd1;
			write_address<=RGB_OFFSET;
			state<=M_IDLE;
		end
	  end
      
      
		default: state <= M_IDLE;
		endcase
		
	end
end


//******************************************************milestone 2

 logic write_enable_b [1:0];
  logic write_enable_a [1:0];
  logic [6:0] address_a[1:0],address_b[1:0];
  logic [31:0] write_data_a [1:0];
  logic [31:0] write_data_b [1:0];
  logic [31:0] read_data_a [1:0];
  logic [31:0] read_data_b [1:0];
  logic [6:0] write_count;
  logic [3:0] row_count;
  
 logic [6:0] Ocount;
  
	//assign READ_ADDRESS_O = read_address;
	assign WRITE_ADDRESS_O = write_address;
	assign READ_DATA_A_O = read_data_a;

	assign READ_DATA_B_O = read_data_b;
	assign WRITE_ENABLE_B_O = write_enable_b;
	assign WRITE_DATA_B_O = write_data_b;

// Instantiate RAM1
dual_port_RAM1 dual_port_RAM_inst1 (
  .address_a (  address_a[1]),
  .address_b (  address_b[1] ),
	.clock ( CLOCK_50_I ),
  .data_a ( 32'd0 ),
  .data_b ( 32'd0),
  .wren_a ( 1'b0 ),
	.wren_b ( 1'b0 ),
  .q_a ( read_data_a[1]),
  .q_b ( read_data_b[1])
	);
       
// Instantiate RAM0
dual_port_RAM0 dual_port_RAM_inst0 (
  .address_a ( address_a[0]),
  .address_b ( address_b[0] ),
	.clock ( CLOCK_50_I ),
  .data_a ( {{16{SRAM_read_data[15]}} , SRAM_read_data[15:0]} ),
  .data_b (write_data_b[0]),
	.wren_a ( write_enable_a[0] ),
	.wren_b ( write_enable_b[0]),
	.q_a ( read_data_a[0] ),
	.q_b ( read_data_b[0] )
	);
  
  

  
  logic[31:0] Mult1,Mult2;
  logic [63:0] mult1,mult2;
  logic[31:0] OP1,OP2,OP3,OP4;  
  logic [31:0] Sprime[1:0];
  logic [31:0] S[1:0];
  logic[6:0] Tcount; 
  logic[6:0] Scount;
  logic[31:0] SpBuff[1:0];
  logic[15:0] Sbuff;
  logic [11:0] BlockCount;
  logic [5:0] ROWcount;
  logic [7:0] Numcount;
  logic [2:0] TRcount;
  logic[2:0] changecount;
  logic [7:0] S0,S1;
  
  //for tracking the future address
  logic [18:0] track_read_address;
  logic [18:0] track_write_address;
  
  //tracking the write of S
  //logic [2:0]Scol;
  logic [3:0]Srow;
  
  //*******************************the multplier part
  

  
always_comb begin
	
	OP1=32'd0;
	OP2=32'd0;
	OP3=32'd0;
	OP4=32'd0;

  if(state_m2==T_0 || state_m2==T_1 || state_m2==T_2 ||state_m2==T_3 
    || state_m2==T_4 || state_m2==T_5 || state_m2==T_6 || state_m2==T_7 || state_m2 == Delay_For_waiting_T1)begin
    OP1 = read_data_a[0];
    OP2 = read_data_a[1];
    
    OP3 = read_data_a[0];
    OP4 = read_data_b[1];
  end else if(state_m2==S_0 || state_m2==S_1 || state_m2==S_2 ||state_m2==S_3||state_m2==finish1)begin
    
    OP1 = read_data_a[0];
    OP2 = read_data_a[1];
    
    OP3 = read_data_b[0];
    OP4 = read_data_b[1];
  end
  
end

  	assign Mult1 = OP1*OP2;
  assign Mult2 = OP3*OP4;  
  //assign Mult1 = mult1[31:0];
  //assign Mult2 = mult2[31:0];

always_comb begin
	S0=S[0][23:16];
	S1=S[1][23:16];
	if(S[0][30:24]>1'd0)begin
		S0=8'd255;
	end
	
	if(S[0][31]==1'b1)begin
		S0 =8'b0;
	end
	
	if(S[1][30:24]>1'd0)begin
		S1=8'd255;
	end
	
	if(S[1][31]==1'b1)begin
		S1 =8'b0;
	end
	
end

  
 assign write_data_a[0] = SRAM_read_data;
 
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
	if (resetn == 1'b0) begin
		state_m2 <= M2_IDLE;
		M2_enable <= 1'b1;
		M2_write_data <= 16'd0;
		M2_address <= 18'd0;
		write_count<=7'd0;
		row_count<=4'd0;
		ROWcount<=7'd0;
		Scount<=1'd0;
		Tcount<=1'd0;
		Numcount<=1'd0;
		BlockCount<=1'd0;
		Ocount<=1'b0;
		
		changecount<=1'd0;
		TRcount<=1'd0;
		
		address_a[1]<=7'd0;
		address_a[0]<=7'd0;
		address_b[1]<=7'd0;
		address_b[0]<=7'd0;
		SpBuff[1]<=32'd0;
		SpBuff[0]<=32'd0;
		write_enable_a[0]<=1'b0;

		
		track_read_address<=19'd0;
		track_write_address<=19'd0;
		
		Srow<=4'd0;
		
	end else begin
		case (state_m2)
    
		M2_IDLE: begin
			Scount<=1'd0;
			Tcount<=1'd0;
			BlockCount<=1'd0;
			M2_address<=19'd76800;
			M2_enable<=1'd1;
			M2_write_data<=1'b0;
			write_count<=9'd0;
			ROWcount<=7'd0;
			Numcount<=1'd0;
			SpBuff[0]<=32'd0;
			SpBuff[1]<=32'd0;
			Sprime[0]<=32'd0;
			Sprime[1]<=32'd0;
			Sbuff<=16'd0;
			if(M2_start==1'b1)begin
				state_m2<=delay_0;
			end
		end

		delay_0:begin
			write_count<=write_count+1'b1;
			M2_address<=M2_address+9'd1;
			state_m2<=delay_1;
		end
		
		delay_1: begin
			write_count<=write_count+1'b1;
			write_enable_a[0]<=1'b1;
			M2_address<=M2_address+9'd1;
			state_m2 <= reading;
		end
		
		
    reading: begin
      
      if(row_count==3'd7 && write_count > 3'd5)begin
        if(write_count==3'd7)begin
      		row_count<=4'd0;
				write_count<=4'd0;
       		//write_enable_a[0]<=1'b0;
				address_a[0]<=address_a[0]+1'b1;
				Tcount<=7'd0;
				state_m2<=Delay_For_Reading1;
				track_read_address<=M2_address;
				
        end else begin
          
				address_a[0]<=address_a[0]+1'b1;
				write_count<=write_count+1'b1;
				M2_address<=M2_address+1'b1;
          
        end
      end else begin
			
      	if(write_count==3'd7)begin
				write_count<=4'd0;
				row_count<=row_count+1'b1;
				M2_address<=M2_address+9'd313;
				if(BlockCount>11'd1199)begin
					M2_address<=M2_address+8'd153;
				end
				address_a[0]<=address_a[0]+1'b1;
        
      	end else begin
				write_count<=write_count+1'b1;
				M2_address<=M2_address+1'b1;
				address_a[0]<=address_a[0]+1'b1;  
      	end
        
      end
    end
	 
	 Delay_For_Reading1:begin
		//write_enable_a[0]<=1'b0;
		address_a[0]<=address_a[0]+1'b1; 
		state_m2<=Delay_For_Reading2;
		address_b[0]<=7'd64;
	 end
	
	Delay_For_Reading2:begin
		
		state_m2<=Delay_For_Reading3;
		
		write_enable_a[0]<=1'b0;
		
		address_a[0]<=1'd0;
		address_a[1]<=4'd0;
      address_b[1]<=4'd1;
		
	end
	
	Delay_For_Reading3:begin

		address_a[0]<=address_a[0]+1'd1;
      address_a[1]<=address_a[1]+4'd8;
      address_b[1]<=address_b[1]+4'd8;
		
		state_m2<=T_0;
	end
	


    T_0: begin
	 
      if((TRcount==2'd0 && changecount>1'd0)||TRcount!=2'd0)begin	
      	SpBuff[0]<=Sprime[0];
			SpBuff[1]<=Sprime[1];
      end
      
      Sprime[0]<=Mult1;
      Sprime[1]<=Mult2;
      
		address_a[0]<=address_a[0]+1'd1;
      address_a[1]<=address_a[1]+4'd8;
      address_b[1]<=address_b[1]+4'd8;
      
      Tcount<=Tcount+1'b1;
      state_m2<=T_1;
    end
      
    T_1: begin

      if( (TRcount==2'd0 && changecount>1'd0)||TRcount!=2'd0)begin
			write_enable_b[0]<=1'b1;
			if(SpBuff[0][31]==1'b0)begin
				write_data_b[0]<=SpBuff[0][31:8];
			end else begin
				write_data_b[0]<=({8'd255,SpBuff[0][31:8]}); 
			end
        
      end
      
      Sprime[0]<=Sprime[0]+Mult1;
      Sprime[1]<=Sprime[1]+Mult2;
      
		address_a[0]<=address_a[0]+1'd1;
      address_a[1]<=address_a[1]+4'd8;
      address_b[1]<=address_b[1]+4'd8;
      
      Tcount<=Tcount+1'b1;
      
      state_m2<=T_2;
    end
  
    T_2: begin
      if((TRcount==2'd0 && changecount>1'd0)||TRcount!=2'd0)begin
        if(SpBuff[1][31]==1'b0)begin
				write_data_b[0]<=SpBuff[1][31:8];
			end else begin
				write_data_b[0]<=({8'd255,SpBuff[1][31:8]}); 
			end
        address_b[0]<=address_b[0]+1'b1;
      end
      
      Sprime[0]<=Sprime[0]+Mult1;
      Sprime[1]<=Sprime[1]+Mult2;
      
		address_a[0]<=address_a[0]+1'd1;
      address_a[1]<=address_a[1]+4'd8;
      address_b[1]<=address_b[1]+4'd8;
      
      Tcount<=Tcount+1'b1;
      state_m2<=T_3;
    end

    T_3: begin
      
      write_enable_b[0]<=1'b0;
      
      Sprime[0]<=Sprime[0]+Mult1;
      Sprime[1]<=Sprime[1]+Mult2;
		if((TRcount==2'd0 && changecount>1'd0)||TRcount!=2'd0)begin
		  address_b[0]<=address_b[0]+1'b1;
      end
	
		
		address_a[0]<=address_a[0]+1'd1;
      address_a[1]<=address_a[1]+4'd8;
      address_b[1]<=address_b[1]+4'd8;
      
      Tcount<=Tcount+1'b1;
      state_m2<=T_4;
    end
      
    T_4: begin
      Sprime[0]<=Sprime[0]+Mult1;
      Sprime[1]<=Sprime[1]+Mult2;   
      
		address_a[0]<=address_a[0]+1'd1;
      address_a[1]<=address_a[1]+4'd8;
      address_b[1]<=address_b[1]+4'd8;
      
      Tcount<=Tcount+1'b1;
      
      state_m2<=T_5;
    end
      
    T_5: begin
      Sprime[0]<=Sprime[0]+Mult1;
      Sprime[1]<=Sprime[1]+Mult2;    
      
		address_a[0]<=address_a[0]+1'd1;
      address_a[1]<=address_a[1]+4'd8;
      address_b[1]<=address_b[1]+4'd8;
      
      Tcount<=Tcount+1'b1;
      state_m2<=T_6;
    end
  
    T_6: begin
      Sprime[0]<=Sprime[0]+Mult1;
      Sprime[1]<=Sprime[1]+Mult2;    
		
		changecount<=changecount+1'd1;
		if(changecount==2'd3)begin
			address_a[0]<=address_a[0]+1'd1;
			changecount<=1'd0;
		end else begin
			address_a[0]<=address_a[0]-3'd7;
		end
		
		address_a[1]<=address_a[1]-6'd54;
      address_b[1]<=address_b[1]-6'd54;
		state_m2<=T_7;
		if(changecount==2'd3)begin
			address_a[1]<=4'd0;
			address_b[1]<=4'd1;
			TRcount<=TRcount+1'd1;
			
			if(TRcount==3'd7)begin
				state_m2<=Delay_For_waiting_T1;
				TRcount<=1'd0;
			end
			
		end
      
     // Tcount<=Tcount+1'b1;

    end
      
    T_7: begin
    	Sprime[0]<=Sprime[0]+Mult1;
      Sprime[1]<=Sprime[1]+Mult2;     
      
		address_a[0]<=address_a[0]+1'd1;
      
		address_a[1]<=address_a[1]+4'd8;
		address_b[1]<=address_b[1]+4'd8;
  
      Tcount<=Tcount+1'b1;
      state_m2<=T_0;

    end
    
    Delay_For_waiting_T1:begin
		//SpBuff<={Sprime[0]+Mult1,Sprime[1]+Mult2};
		SpBuff[0]=Sprime[0]+Mult1;
		SpBuff[1]<=Sprime[1]+Mult2;
		//Sprime[0]<=Sprime[0]+Mult1;
      //Sprime[1]<=Sprime[1]+Mult2;     

      state_m2<=Delay_For_writing_T2;
    end
    
    Delay_For_writing_T2:begin
		if(SpBuff[0][31]==1'b0)begin
				write_data_b[0]<=SpBuff[0][31:8];
			end else begin
				write_data_b[0]<=({8'd255,SpBuff[0][31:8]}); 
			end
		write_enable_b[0]<=1'b1; 
      state_m2<=Delay_For_writing_T3;
    end
  
  Delay_For_writing_T3:begin
	   
		 if(SpBuff[1][31]==1'b0)begin
				write_data_b[0]<=SpBuff[1][31:8];
			end else begin
				write_data_b[0]<=({8'd255,SpBuff[1][31:8]}); 
			end
    	address_b[0]<=address_b[0]+1'b1; 
		state_m2<=Delay_For_writing_T4;
		
	end
	
    Delay_For_writing_T4:begin
	 
      

      write_enable_b[0]<=1'b0;
      Scount<=7'd0;
      write_enable_a[1]<=1'b0;
      write_enable_b[1]<=1'b0;
      
      address_a[1]<=1'b0;
      address_b[1]<=4'd8;
      
      address_a[0]<=7'd64;
      address_b[0]<=7'd72;
		
		M2_address<=track_write_address;
		Ocount<=1'b0;
      state_m2<=S_0;
    end
   
	
    S_0: begin
		
	
      if(Scount!=1'd0)begin

			if(Ocount==1'b1)begin
				S[0]<=S[0]+Mult1+S[1]+Mult2;
  			end else if(Ocount==1'b0)begin
				S[1]<=S[1]+Mult2+S[0]+Mult1;
			end
		
		  
      end
      
      address_a[1]<=address_a[1]+7'd16;
      address_b[1]<=address_b[1]+7'd16;
      
      address_a[0]<=address_a[0]+7'd16;
      address_b[0]<=address_b[0]+7'd16;
      
		
      Scount<=Scount+1'd1;
      state_m2<=S_1;
		
    end
      
    S_1: begin
      
      if(Scount!=1'd1)begin
		
        if(Ocount==1'b1)begin
			Sbuff[15:8]<=S0;
		  end else if(Ocount==1'b0)begin
			Sbuff[7:0]<=S1;
		  end

      end
      
      address_a[1]<=address_a[1]+7'd16;
      address_b[1]<=address_b[1]+7'd16;
      
      address_a[0]<=address_a[0]+7'd16;
      address_b[0]<=address_b[0]+7'd16;
      
      Scount<=Scount+1'd1;

		S[0]<=Mult1;
      S[1]<=Mult2;
		
      state_m2<=S_2;
    end
  
    S_2: begin
      
		
		
      if(Scount!=2'd2)begin        
		   if(Ocount==1'b0)begin
			  M2_enable<=1'b0;
		     M2_write_data<=Sbuff;
			end
      end
      
      
      address_a[1]<=address_a[1]+7'd16;
      address_b[1]<=address_b[1]+7'd16;
      
      address_a[0]<=address_a[0]+7'd16;
      address_b[0]<=address_b[0]+7'd16;
      
      Scount<=Scount+1'd1;
      S[0]<=S[0]+Mult1;
      S[1]<=S[1]+Mult2;
      state_m2<=S_3;
    end

    S_3: begin
      
		Scount<=Scount+1'd1;
		Ocount<=Ocount+1'd1;
		
		if(Scount!=2'd3)begin
			if(Ocount==1'b0)begin
				M2_enable<=1'b1;
				if(Scount>3'd7)begin
					
					M2_address<=M2_address+1'b1;

				end
			end
		end
		
		if(Ocount==1'b1)begin
			Ocount<=1'b0;
		end
      
		
		state_m2<=S_0;
      
		if(Scount==7'd31)begin
      	state_m2<=finish1;
			track_write_address<=M2_address+8'd157;
			if(BlockCount>11'd1199)begin
				track_write_address<=M2_address+8'd77;
			end
			Scount<=1'b0;
      end
      
      address_a[1]<=address_a[1]-7'd48;
      address_b[1]<=address_b[1]-7'd48;
      
      address_a[0]<=address_a[0]-7'd47;
      address_b[0]<=address_b[0]-7'd47;
		
		S[0]<=S[0]+Mult1;
      S[1]<=S[1]+Mult2;
      
     
    end
      
	 finish1:begin
      S[1]<=S[1]+Mult2+S[0]+Mult1;
      state_m2<=finish2;
    end
		
    finish2:begin
    	
		Sbuff[7:0]<=S1;
		
      state_m2<=finish3;
      
    end
    finish3:begin
		M2_write_data<=Sbuff;
		M2_enable<=1'b0;
		state_m2<=finish4;
	 end
    finish4:begin
    	
		M2_enable<=1'b1;
		
		if(Numcount<3'd7)begin
			address_a[1]<=address_a[1]+7'd1;
			address_b[1]<=address_b[1]+7'd1;
			
			address_a[0]<=7'd64;
			address_b[0]<=7'd72;
			Scount<=1'b0;
			Numcount<=Numcount+1'b1;
			
			M2_address<=track_write_address;
			
			state_m2<=S_0;
		end else begin
			ROWcount<=ROWcount+1'd1;
			BlockCount<=BlockCount+1'b1;
			Numcount<=1'b0;
			address_a[0]<=1'b0;
			state_m2<=delay_0;
			if(BlockCount==12'd2399)begin
				ROWcount<=6'd0;
				state_m2<=M2_IDLE;
				M2_done<=1'b1;
			end
			
			if(BlockCount<11'd1200)begin
				if(ROWcount==6'd39)begin
					M2_address<=track_read_address+1'd1;
					track_write_address<=M2_address+1'b1;
					//BlockCount<=BlockCount+1'd1;
					ROWcount<=1'd0;
				end else begin
					track_write_address<=M2_address-19'd1119;
					M2_address<=track_read_address-19'd2239; 
					//BlockCount<=BlockCount+1'd1;
				end
			end else begin
				if(ROWcount==6'd19)begin
					M2_address<=track_read_address+1'd1;
					track_write_address<=M2_address+1'b1;
					//BlockCount<=BlockCount+1'd1;
					ROWcount<=1'd0;
				end else begin
					track_write_address<=M2_address-19'd559;
					M2_address<=track_read_address-19'd1119;
					//BlockCount<=BlockCount+1'd1
				end
			end
		end
    end
		
		default: state_m2 <= M2_IDLE;
		endcase
	end
end


endmodule