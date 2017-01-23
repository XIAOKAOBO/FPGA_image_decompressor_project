

# add waves to waveform
add wave Clock_50
add wave -divider {some label for my divider}
add wave uut/SRAM_we_n
add wave -hexadecimal uut/SRAM_write_data
add wave uut/top_state
add wave -hexadecimal uut/SRAM_read_data
add wave -unsigned uut/SRAM_address
add wave -unsigned uut/M3_address
add wave  uut/state_m3
add wave  -unsigned uut/header_detect
add wave  -unsigned uut/remain_count
add wave  -unsigned uut/track_count
add wave  -unsigned uut/M3_write_count
add wave  -unsigned uut/scanAddress
add wave  -unsigned uut/scan_enable
add wave  -unsigned uut/M3_row_count
add wave  -unsigned uut/write_data_c
add wave  -unsigned uut/read_data_B
add wave  -unsigned uut/read_data_C
add wave  -unsigned uut/write_dram_value
add wave  -unsigned uut/write_enable_A