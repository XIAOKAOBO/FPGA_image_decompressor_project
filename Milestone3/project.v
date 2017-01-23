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
	
	
logic M1_start,M1_done,M2_start,M2_done,M3_start,M3_done;
logic resetn;

// states fot the state machine
m2_state_type state_m2;
top_state_type top_state;
m1_state_type state;
m3_state_type state_m3;

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
  
    logic[18:0] M3_address;
    logic M3_enable;
  logic [15:0] M3_write_data;

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
			if (~UART_RX_I | PB_pushed[0] | 	 start_flag) begin
				// UART detected a signal, or PB0 is pressed
				UART_rx_initialize <= 1'b1;
				M3_start<=1'b1;
				VGA_enable <= 1'b0;
				UART_rx_enable <= 1'b1;				
				top_state <= S_THR;
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
				top_state <= S_ONE;
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
				top_state<=S_IDLE;
			end
		end
		
		S_THR:begin
			M3_start<=1'b1;
			if(M3_done)begin
				top_state<=S_IDLE;
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
	end else if(top_state==S_THR)begin
		SRAM_address=M3_address;
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
	end else if(top_state==S_THR)begin
		SRAM_write_data=M3_write_data;
	end else begin
		SRAM_write_data = UART_SRAM_write_data;
	end
end

			
always_comb begin

	if(top_state==S_ONE) begin
		SRAM_we_n=M1_we_n;
	end else if(top_state==S_TWO)begin
		SRAM_we_n = M2_enable;
	end else if(top_state==S_THR)begin
		SRAM_we_n=M3_enable;
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



//***************************Milestone3************************************************************************************

  logic [31:0]  write_data_c;
  logic [5:0] factor;
  
  logic[11:0] M3_block_count;
  logic[9:0] M3_row_count;
  
  logic [5:0] bitcount;
  logic scan_enable;
  logic [6:0] COP;
  
  
  logic[5:0] M3_write_count;
     logic [31:0] write_dram_value;
  logic[6:0] address_A,address_B;
  logic write_enable_A;
  logic[31:0] read_data_B,read_data_C;
    logic [6:0] scanAddress;
	 

  
  dual_port_RAM3 dual_port_RAM_inst3 (
  .address_a ( scanAddress),
  .address_b ( scanAddress ),
	.clock ( CLOCK_50_I ),
  .data_a ( write_data_c),
  .data_b (1'b0),
	.wren_a ( write_enable_A ),
	.wren_b ( 1'b0),
	.q_a ( read_data_C ),
	.q_b ( read_data_B )

	
	);
  

  
  

  
  always_comb begin
  	factor=6'd6;
    if(scanAddress==16'd0||scanAddress==16'd2||scanAddress==16'd3||scanAddress==16'd9||scanAddress==16'd10||scanAddress==6'd16||scanAddress==6'd17||scanAddress==6'd24)begin
      factor=6'd3;
    end else if(scanAddress==6'd1||scanAddress==6'd8)begin
    	factor=  6'd2;
    end else if(scanAddress==6'd4||scanAddress==6'd5||scanAddress==6'd11||scanAddress==6'd12||scanAddress==6'd18||scanAddress==6'd19||scanAddress==6'd25||scanAddress==6'd26||scanAddress==6'd32||scanAddress==6'd33||scanAddress==6'd30)begin
      factor=6'd4;
    end else if(scanAddress==6'd6||scanAddress==6'd7||scanAddress==6'd13||scanAddress==6'd14||scanAddress==6'd20||scanAddress==6'd21||scanAddress==6'd27||scanAddress==6'd28||scanAddress==6'd34||scanAddress==6'd35||scanAddress==6'd41||scanAddress==6'd42||scanAddress==6'd48||scanAddress==6'd49||scanAddress==6'd56)begin
     	factor=6'd5; 
    end
  end
  
    logic[2:0] header;
  logic [31:0] bitBuffer;
 
  
  
  
always_ff @ (posedge CLOCK_50_I or negedge resetn) begin
  if (resetn == 1'b0) begin
    
		scanAddress<=6'd0;
    
	end else begin
    if(!scan_enable)begin
      scanAddress<=scanAddress;
    end else begin
    	case(scanAddress)
    		6'd0:begin
					scanAddress<=6'd1;
      	end
    		6'd1:begin
					scanAddress<=6'd8;
      	end
    		6'd8:begin
					scanAddress<=6'd16;
      	end
    		6'd16:begin
					scanAddress<=6'd9;
      	end
    		6'd9:begin
					scanAddress<=6'd2;
      	end
    		6'd2:begin
					scanAddress<=6'd3;
      	end
    		6'd3:begin
					scanAddress<=6'd10;
      	end
    		6'd10:begin
					scanAddress<=6'd17;
      	end
    		6'd17:begin
					scanAddress<=6'd24;
      	end
    		6'd24:begin
					scanAddress<=6'd32;
      	end
    		6'd32:begin
					scanAddress<=6'd25;
      	end
    		6'd25:begin
					scanAddress<=6'd18;
      	end
    		6'd18:begin
					scanAddress<=6'd11;
      	end
    		6'd11:begin
					scanAddress<=6'd4;
      	end
    		6'd4:begin
					scanAddress<=6'd5;
      	end
    		6'd5:begin
					scanAddress<=6'd12;
      	end
        6'd12:begin
					scanAddress<=6'd19;
      	end
    		6'd19:begin
					scanAddress<=6'd26;
      	end
    		6'd26:begin
					scanAddress<=6'd33;
      	end
    		6'd33:begin
					scanAddress<=6'd40;
      	end
      
      	6'd40:begin
					scanAddress<=6'd48;
      	end
      
      	6'd48:begin
					scanAddress<=6'd41;
      	end
      
      	6'd41:begin
					scanAddress<=6'd34;
      	end
      
      	6'd34:begin
					scanAddress<=6'd27;
      	end
      
      	6'd27:begin
					scanAddress<=6'd20;
      	end
      
      	6'd20:begin
					scanAddress<=6'd13;
      	end
     
      	6'd13:begin
					scanAddress<=6'd6;
      	end
      
      	6'd6:begin
					scanAddress<=6'd7;
      	end

      	6'd7:begin
					scanAddress<=6'd14;
      	end
      
      	6'd14:begin
					scanAddress<=6'd21;
      	end

      	6'd21:begin
					scanAddress<=6'd28;
      	end
      
      	6'd28:begin
					scanAddress<=6'd35;
      	end
      
      	6'd35:begin
					scanAddress<=6'd42;
      	end
      
      	6'd42:begin
					scanAddress<=6'd49;
      	end
      
      	6'd49:begin
					scanAddress<=6'd56;
      	end
      
      	6'd56:begin
					scanAddress<=6'd57;
      	end
      
      	6'd57:begin
					scanAddress<=6'd50;
      	end
      
      	6'd50:begin
					scanAddress<=6'd43;
      	end
      
     	 6'd43:begin
					scanAddress<=6'd36;
      	end
      
      	6'd36:begin
					scanAddress<=6'd29;
      	end
      
      	6'd29:begin
					scanAddress<=6'd22;
      	end
      
      	6'd22:begin
					scanAddress<=6'd15;
      	end
      
      	6'd15:begin
					scanAddress<=6'd23;
      	end
      
      	6'd23:begin
					scanAddress<=6'd30;
      	end
      
      	6'd30:begin
					scanAddress<=6'd37;
      	end
      
      	6'd37:begin
					scanAddress<=6'd44;
      	end
      
      	6'd44:begin
					scanAddress<=6'd51;
      	end
      
      	6'd51:begin
					scanAddress<=6'd58;
      	end
      
      	6'd58:begin
					scanAddress<=6'd59;
      	end
      
      	6'd59:begin
					scanAddress<=6'd52;
      	end
      
      	6'd52:begin
					scanAddress<=6'd45;
      	end
      
      	6'd45:begin
					scanAddress<=6'd38;
      	end
      
      	6'd38:begin
					scanAddress<=6'd31;
      	end
      
      	6'd31:begin
					scanAddress<=6'd39;
      	end
      
      	6'd39:begin
					scanAddress<=6'd46;
      	end
      
      	6'd46:begin
					scanAddress<=6'd53;
      	end
      
      	6'd53:begin
					scanAddress<=6'd60;
      	end
      
      	6'd60:begin
					scanAddress<=6'd61;
      	end
			
      	6'd61:begin
					scanAddress<=6'd54;
      	end
      
      	6'd54:begin
					scanAddress<=6'd47;
      	end
      
      	6'd47:begin
					scanAddress<=6'd55;
      	end
      
      	6'd55:begin
					scanAddress<=6'd62;
      	end
      
      	6'd62:begin
					scanAddress<=6'd63;
      	end
      
     	  6'd63:begin
					scanAddress<=6'd0;
      	end
    	endcase
    end
end
end
  
    assign header =bitBuffer[31:29];
  logic[3:0] header_detect;
  
  always_comb begin
    if(header[2:1]==2'b00)begin 
    	header_detect=4'd11;
	 end else if(header[2:1]==2'b01)begin
      header_detect=4'd6;	
    end else if(header==3'b100)begin
      header_detect=4'd5;
    end else if(header==3'b101) begin
      header_detect=4'd5;
    end else if(header==3'b110)begin
      header_detect=4'd6;
    end else begin
      header_detect=4'd0;
    end
  end
  
  logic [18:0] M3_write_track_address;
  logic [18:0] M3_read_track_address;


  
  logic[5:0] track_count;
  logic [4:0] remain_count;
  
  logic [5:0] write_dram_count;

    
always_ff @ (posedge CLOCK_50_I or negedge resetn)begin
      if(resetn==1'b0)begin
			
        M3_address<=19'd0;
        track_count<=6'd0;
        M3_block_count<=12'd0;
         write_dram_count<=6'd0;
        write_dram_value<=32'd0;
        
        M3_write_track_address<=19'd76800;
        M3_row_count<=9'd0;
        bitBuffer<=32'd0;
        scan_enable<=1'b0;
        bitBuffer<=32'd0;
        state_m3<=M3_IDLE;
		  M3_enable<=1'b1;
		  M3_write_data<=1'b0;
        remain_count<=5'd16;
			M3_write_count<=1'b0;
			write_data_c<=32'd0;
			write_enable_A<=1'b0;
      end else begin
        
        case(state_m3)
          M3_IDLE:begin
            
            M3_address<=19'd0;
        		remain_count<=5'd0;
        		track_count<=6'd0;
            write_dram_count<=6'd0;
            M3_done<=1'b0;
        		M3_block_count<=12'd0;
            M3_write_track_address<=19'd76800;
            M3_address<=19'd0;
            state_m3<=Dela_0;
          	
            scan_enable<=1'b0;
            
            bitBuffer<=32'd0;
				if(M3_start)begin
					state_m3<=Dela_s;
				end
          end
          Dela_s:begin
				state_m3<=Dela_0;
			 end
          Dela_0:begin
          	state_m3<=Dela_1;
          end
          
          Dela_1:begin
            bitBuffer<={SRAM_read_data,16'd0};
            remain_count<=5'd16;
            state_m3<=deque;
          end
          
          general_read:begin
           	M3_address<=M3_address+1'b1;
            state_m3<=general_delay_1;
          end
          
          general_delay_1:begin
            state_m3<=general_delay_2;
          end
          
          general_delay_2:begin
          	state_m3<=general_process;
          end
          
          general_process:begin
            bitBuffer[31-remain_count-:16]<=SRAM_read_data;
            
            state_m3<=deque;
          end
          
          deque:begin
            write_enable_A<=1'b1;
            if(header[2:1]==2'b00)begin
              write_dram_count<=1'b1;
              write_dram_value<=bitBuffer[29:21];
             
              remain_count<=remain_count-5'd11;
              bitBuffer <= { bitBuffer[20:0], 11'b0 };
              
            end else if(header[2:1]==2'b01)begin
              write_dram_count<=1'b1;
              write_dram_value<=bitBuffer[29:26];
               //shift the used bits to the left
              bitBuffer <= { bitBuffer[25:0], 6'b0 };
              remain_count<=remain_count-5'd6;
              
              
              
            end else if(header==3'b100)begin
              write_dram_count<= (bitBuffer[28:26]==3'd0)?3'd4:bitBuffer[28:26];
              write_dram_value<=16'hFFFF;
               //shift the used bits to the left
              bitBuffer <= { bitBuffer[26:0], 5'b0 };
              remain_count<=remain_count-5'd5;
              
            end else if(header==3'b101)begin
              write_dram_count<=(bitBuffer[28:26]==3'd0)?3'd4:bitBuffer[28:26];
              write_dram_value<=16'd1;
               //shift the used bits to the left
              bitBuffer <= { bitBuffer[26:0], 5'b0 };
              remain_count<=remain_count-5'd5;
              
            end else if(header==3'b110)begin
              write_dram_count<=(bitBuffer[28:26]==3'd0)?4'd8:bitBuffer[28:26];
              write_dram_value<=16'd0;
               //shift the used bits to the left
              bitBuffer <= { bitBuffer[25:0], 6'b0 };
              remain_count<=remain_count-5'd6;
              
            end else if(header==3'b111)begin  
              write_dram_count<=6'd63-track_count;
              write_dram_value<=16'd0;
              
              //shift the used bits to the left
              bitBuffer <= { bitBuffer[28:0], 3'b0 };
              //count the remainder bits
              remain_count<=remain_count-5'd3;
            	
            end
            //track_count<=6'd0;
            scan_enable<=1'b1;
            state_m3<=write_to_dram;
          end
          
          write_to_dram:begin
            track_count<=track_count+1'd1;
				if(write_dram_count>16'd0)begin
            	write_dram_count<=write_dram_count-1'b1;
              
              //write_data_c<={write_dram_value,factor};
              if(factor==6'd6)begin
					write_data_c<={write_dram_value,6'd0};
				  end else if(factor==6'd5)begin
					write_data_c<={write_dram_value,5'd0};
				  end else if(factor==6'd4)begin
					write_data_c<={write_dram_value,4'd0};
				  end else if(factor==6'd3)begin
					write_data_c<={write_dram_value,3'd0};
				  end else if(factor==6'd2)begin
					write_data_c<={write_dram_value,2'd0};
				  end
				  
            end else begin
					write_enable_A<=1'b1;
              scan_enable<=1'b0;
              if(track_count==6'd63)begin
                M3_read_track_address<=M3_address;
					 scan_enable<=1'b1;
					 write_enable_A<=1'b0;
					
                state_m3<=Delay_last;
                track_count<=6'd0;
                write_dram_count<=6'd0;
              end else begin
                
                if(remain_count<header_detect)begin
                	state_m3<=general_read;
              	end else begin
                  state_m3<=deque;
                end
                
              end
            end
          	
          end
          

          Delay_last:begin
            M3_address<=M3_write_track_address;
            
            scan_enable<=1'b1;
            M3_write_count<=6'd0;
            M3_enable<=1'b0;
            M3_write_data<=read_data_C;
            state_m3<=writeback;
          end
          
          writeback:begin
          	M3_write_count<=M3_write_count+1'b1;
            M3_write_data<=read_data_C;
				
				if(M3_write_count==6'd62)begin
					scan_enable<=1'b0;
				end
				
            if(M3_write_count==6'd63)begin
            	
				  state_m3<=delay_write;
              M3_row_count<=M3_row_count+1'b1;
              M3_write_count<=6'd0;
				  M3_enable<=1'b0;
              M3_block_count<=M3_block_count+1'b1;
              M3_enable<=1'b1;
              
              scan_enable<=1'b0;

              if(M3_block_count<12'd1200)begin
                
					 if(M3_row_count==9'd39)begin
                	M3_write_track_address<=M3_address+1'b1;
                  M3_row_count<=9'd0;
					 end else begin    	
						M3_write_track_address<=M3_address-12'd2239;
					 end
					 
				  end else begin	 
					 
					 if(M3_row_count==9'd19)begin
                	M3_write_track_address<=M3_address+1'b1;
                  M3_row_count<=9'd0;
					 end else begin
						M3_write_track_address<=M3_address-12'd1119;
					 end
					 
					end
				end else begin
				
						
						if(M3_write_count==6'd7||M3_write_count==6'd15||M3_write_count==6'd23||M3_write_count==6'd31||M3_write_count==6'd39||M3_write_count==6'd47||M3_write_count==6'd55)begin
							if(M3_block_count<12'd1200)begin
								M3_address<=M3_address+12'd313;
							end else begin
								M3_address<=M3_address+12'd153;
							end
						end else begin
							M3_address<=M3_address+1'b1;
						end
           end
         end
          
         delay_write:begin
           if(M3_block_count<12'd2400)begin
				 
             M3_address<=M3_read_track_address;
              if(remain_count>header_detect)begin
					 state_m3<=deque;
				  end else begin
					 state_m3<= general_read;
				  end
           end else begin
            	M3_done<=1'b1;
             state_m3<=M3_IDLE;
           end
         end
			//end
			endcase
      end
    end
  

endmodule