
`timescale 1ns/100ps
`default_nettype none
`include "project.v"
`include "define_state.h"
module MONE;



// For SRAM
logic [17:0] SRAM_address;
logic [15:0] SRAM_write_data;
logic SRAM_we_n;
logic [15:0] SRAM_read_data;
logic SRAM_ready;


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



parameter U_OFFSET = 18'd38400,
	  V_OFFSET = 18'd57600,
	  RGB_OFFSET = 18'd146944;
m1_state_type state;


logic[17:0] M1_address;
logic [15:0] M1_write_data; 
logic M1_we_n;


logic [17:0] data_counter;
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

endmodule