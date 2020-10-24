set BIT_STREAM ./top_new.bit

open_hw_manager
connect_hw_server
refresh_hw_server
current_hw_target [get_hw_targets]
open_hw_target

# Program and Refresh the Device
current_hw_device [get_hw_devices xc7a100t_0]
set_property PROGRAM.FILE $BIT_STREAM [get_hw_devices xc7a100t_0]
program_hw_devices [get_hw_devices xc7a100t_0]

exit
