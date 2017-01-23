onbreak {resume}
transcript on

set PrefMain(saveLines) 50000
.main clear

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

# load designs

# insert files specific to your design here

vlog -sv -svinputport=var -work rtl_work convert_hex_to_seven_segment.v
vlog -sv -svinputport=var -work rtl_work VGA_Controller.v
vlog -sv -svinputport=var -work rtl_work PB_Controller.v
vlog -sv -svinputport=var -work rtl_work +define+SIMULATION SRAM_Controller.v
vlog -sv -svinputport=var -work rtl_work tb_SRAM_Emulator.v
vlog -sv -svinputport=var -work rtl_work +define+SIMULATION UART_Receive_Controller.v
vlog -sv -svinputport=var -work rtl_work VGA_SRAM_interface.v
vlog -sv -svinputport=var -work rtl_work UART_SRAM_interface.v
vlog -sv -svinputport=var -work rtl_work Clock_100_PLL.v
#vlog -sv -svinputport=var -work rtl_work dual_port_RAM1.v
vlog -sv -svinputport=var -work rtl_work dual_port_RAM3.v
#vlog -sv -svinputport=var -work rtl_work dual_port_RAM0.v
vlog -sv -svinputport=var -work rtl_work project.v
#vlog -sv -svinputport=var -work rtl_work tb_project_v2.v
vlog -sv -svinputport=var -work rtl_work tb_project_v2.v

# specify library for simulation
#vsim -t 100ps -L altera_mf_ver -lib rtl_work tb_project_v2
vsim -t 100ps -L altera_mf_ver -lib rtl_work tb_project_v2

# Clear previous simulation
restart -f

# activate waveform simulation
view wave

# add waveforms
# workaround for no block comments: call another .do file, or as many as you like
# or just add the waveforms here like done the labs
do add_my_waveforms.do
#do add_some_more_waveforms.do

# format signal names in waveform
configure wave -signalnamewidth 1

# run complete simulation
run -all

destroy .structure
destroy .signals
destroy .source



simstats
#mem save -o SRAM.mem -f mti -data hex -addr hex -startaddress 0 -endaddress 262143 -wordsperline 8 /tb_project_v2/SRAM_component/SRAM_data

