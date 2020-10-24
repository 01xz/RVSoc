# Defination before starting
set NON_PROJECT_DIR ./build
set TOP_MODULE top
set DEVICE xc7a100tcsg324-1
set_param general.maxThreads 12

file mkdir $NON_PROJECT_DIR


# Add RTL design sources and constraint file
read_verilog [ glob ./../../rtl/*.v ]
read_verilog [ glob ./../../rtl/gpio/gpio.v ]
read_verilog [ glob ./../../rtl/pwm/pwm.v ]
read_verilog [ glob ./../../rtl/uart/*.v ]

read_xdc ./../../constraints/vivado/boards/Nexys-A7-100T.xdc
read_xdc ./../../constraints/vivado/bmm.xdc


# Run Synthesis
synth_design -top $TOP_MODULE -part $DEVICE
write_checkpoint -force $NON_PROJECT_DIR/post_synth.dcp


# Run logic optimization, placement and physical logic optimization
opt_design
#reportCriticalPaths $NON_PROJECT_DIR/opt_critpath_report.csv
place_design
#report_clock_utilization -file $NON_PROJECT_DIR/clock_util.rpt

# Optionally run optimization if there are timing violations after placement
if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
    puts "Found setup timing violations => running physical optimization"
    phys_opt_design
}

write_checkpoint -force $NON_PROJECT_DIR/post_place.dcp

report_utilization -file $NON_PROJECT_DIR/place_util.rpt
#report_timing_summary -file $NON_PROJECT_DIR/place_timing_summary.rpt


# Route
route_design
#write_checkpoint -force $NON_PROJECT_DIR/post_route.dcp
#report_route_status -file $NON_PROJECT_DIR/route_status.rpt
report_timing_summary -file $NON_PROJECT_DIR/route_timing_summary.rpt
#report_power -file $NON_PROJECT_DIR/route_power.rpt
#report_drc -file $NON_PROJECT_DIR/imp_drc.rpt

# Generate bitstream
write_bitstream -force $NON_PROJECT_DIR/$TOP_MODULE.bit


# Repoat bram to help create .mmi file
set all_rom_blocks [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ BMEM.bram.*}]
foreach block $all_rom_blocks {
    puts "- NAME:  [get_property NAME $block]"
    puts "  SITE: [get_property SITE $block]"
}


# Generate .mmi file
set_property PART $DEVICE [current_project]
source ./write_mmi.tcl
write_mmi


# Exit
exit
