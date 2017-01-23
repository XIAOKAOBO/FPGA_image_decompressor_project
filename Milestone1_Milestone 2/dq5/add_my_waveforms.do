

# add waves to waveform
add wave Clock_50
add wave -divider {some label for my divider}
add wave uut/SRAM_we_n
add wave -hexadecimal uut/SRAM_write_data
add wave uut/top_state
add wave -hexadecimal uut/SRAM_read_data
add wave -decimal uut/S
add wave -unsigned uut/SRAM_address
add wave -unsigned uut/M2_address
add wave -decimal uut/read_data_a
add wave -decimal uut/read_data_b
add wave -decimal uut/write_data_b
add wave uut/state_m2
add wave -unsigned uut/address_a
add wave -unsigned uut/address_b
add wave -decimal uut/Mult1
add wave -decimal uut/Mult2
add wave -unsigned uut/Sbuff
#add wave -unsigned uut/Sprime
add wave -unsigned uut/Scount
add wave -decimal uut/BlockCount



