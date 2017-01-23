`ifndef DEFINE_STATE

// This defines the states

typedef enum logic [3:0] {
 
  	S_IDLE,
	S_ENABLE_UART_RX,
	S_WAIT_UART_RX,
	S_ONE,
	S_TWO,
	S_THR
} top_state_type;


typedef enum logic [6:0] {
	M_IDLE,
	intial_0,
	intial_1,
	intial_2,
	intial_3,
	intial_4,
	intial_5,
	intial_6,
	intial_7,
	intial_8,
	intial_9,
	intial_10,
	intial_11,
	intial_12,
	intial_13,
	intial_14,
	intial_15,
	intial_16,
	intial_17,
	intial_18,
	intial_19,
	intial_20,
	intial_21,
	intial_22,
	common_0,
	common_1,
	common_2,
	common_3,
	common_4,
	common_5,
	common_6,
	common_7,
	common_8,
	common_9,
	common_10,
	common_11,
	common_12,
	common_13,
	common_14,
	common_15,
	end_0,
	end_1,
	end_2,
	end_3,
	end_4,
	end_5,
	end_6,
	end_7,
	end_8,
	end_9,
	end_10,
	end_11,
	end_12,
	end_13,
	end_14,
	end_15,
	end_16,
	end_17,
	end_18,
	end_19,
	end_20,
	end_21,
	end_22,
	end_23,
	end_24,
	end_25,
	end_26,
	end_27,
	end_28,
	end_29,
	end_30,
	end_31,
	end_32,
	end_33,
	end_34
} m1_state_type;


typedef enum logic [6:0] {
	M2_IDLE,
	delay_0,
	delay_1,
	delay_2,
	reading,
	Delay_For_Reading1,
	Delay_For_Reading2,
	Delay_For_Reading3,
	Delay_For_Prefetch,
	T_0,
	T_1,
	T_2,
	T_3,
	T_4,
	T_5,
	T_6,
	T_7,
	Delay_For_waiting_T1,
	Delay_For_writing_T2,
	Delay_For_writing_T3,
	Delay_For_writing_T4,
	prefetch,
	S_0,
	S_1,
	S_2,
	S_3,
	finish1,
	finish2,
	finish3,
	finish4
	
} m2_state_type;

typedef enum logic [6:0]{
	M3_IDLE,
	Dela_s,
	Dela_0,
	Dela_1,
	general_read,
	general_delay_1,
	general_delay_2,
	general_process,
	deque,
	write_to_dram,
	Delay_last,
	writeback,
	delay_write
} m3_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

`define DEFINE_STATE 1
`endif
