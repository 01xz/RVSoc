# Defination before starting
set PROJECT_DIR ./build
set TOP_MODULE top
set DEVICE xc7a100tcsg324-1


# Create project
create_project -force picosoc $PROJECT_DIR -part $DEVICE


# Add RTL design sources and constraint file
add_files ./../../rtl/bram.v
add_files ./../../rtl/picorv32.v
add_files ./../../rtl/picosoc.v
add_files ./../../rtl/top.v
add_files ./../../rtl/gpio/gpio.v
add_files ./../../rtl/pwm/pwm.v
add_files ./../../rtl/uart/fifo.v
add_files ./../../rtl/uart/uart.v
add_files ./../../rtl/uart/uart_fifo.v
add_files ./../../rtl/uart/uart_top.v

add_files -fileset constrs_1 ./../../constraints/vivado/boards/Nexys-A7-100T.xdc
add_files -fileset constrs_1 ./../../constraints/vivado/bmm.xdc

set_property used_in_synthesis false [get_files -of_objects [get_filesets constrs_1] ./../../constraints/vivado/boards/Nexys-A7-100T.xdc]
set_property used_in_synthesis false [get_files -of_objects [get_filesets constrs_1] ./../../constraints/vivado/bmm.xdc]

set_property top $TOP_MODULE [current_fileset]


# Set threads
set_param general.maxThreads 12


# Mimic GUI behavior of automatically setting top and file compile order
update_compile_order -fileset sources_1
#update_compile_order -fileset sim_1

# Launch Synthesis
launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name netlist_1


# Generate a timing and power reports and write to disk
report_timing_summary -delay_type max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file $PROJECT_DIR/syn_timing.rpt
report_power -file $PROJECT_DIR/syn_power.rpt


# Launch Implementation
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1 


# Generate a timing and power reports and write to disk
# comment out the open_run for batch mode
open_run impl_1
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file $PROJECT_DIR/imp_timing.rpt
report_power -file $PROJECT_DIR/imp_power.rpt


# comment out the for batch mode
start_gui
