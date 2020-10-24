create_property bmm_info_memory_device cell -type string

set_property bmm_info_memory_device {[7:0]   [0:4095]}      [get_cells bram_4k_32bit_0/bram_4k_8bit_0/mem_reg]
set_property bmm_info_memory_device {[15:8]  [0:4095]}      [get_cells bram_4k_32bit_0/bram_4k_8bit_1/mem_reg]
set_property bmm_info_memory_device {[23:16] [0:4095]}      [get_cells bram_4k_32bit_0/bram_4k_8bit_2/mem_reg]
set_property bmm_info_memory_device {[31:24] [0:4095]}      [get_cells bram_4k_32bit_0/bram_4k_8bit_3/mem_reg]
set_property bmm_info_memory_device {[7:0]   [4096:8191]}   [get_cells bram_4k_32bit_1/bram_4k_8bit_0/mem_reg]
set_property bmm_info_memory_device {[15:8]  [4096:8191]}   [get_cells bram_4k_32bit_1/bram_4k_8bit_1/mem_reg]
set_property bmm_info_memory_device {[23:16] [4096:8191]}   [get_cells bram_4k_32bit_1/bram_4k_8bit_2/mem_reg]
set_property bmm_info_memory_device {[31:24] [4096:8191]}   [get_cells bram_4k_32bit_1/bram_4k_8bit_3/mem_reg]
set_property bmm_info_memory_device {[7:0]   [8192:12287]}  [get_cells bram_4k_32bit_2/bram_4k_8bit_0/mem_reg]
set_property bmm_info_memory_device {[15:8]  [8192:12287]}  [get_cells bram_4k_32bit_2/bram_4k_8bit_1/mem_reg]
set_property bmm_info_memory_device {[23:16] [8192:12287]}  [get_cells bram_4k_32bit_2/bram_4k_8bit_2/mem_reg]
set_property bmm_info_memory_device {[31:24] [8192:12287]}  [get_cells bram_4k_32bit_2/bram_4k_8bit_3/mem_reg]
set_property bmm_info_memory_device {[7:0]   [12288:16383]} [get_cells bram_4k_32bit_3/bram_4k_8bit_0/mem_reg]
set_property bmm_info_memory_device {[15:8]  [12288:16383]} [get_cells bram_4k_32bit_3/bram_4k_8bit_1/mem_reg]
set_property bmm_info_memory_device {[23:16] [12288:16383]} [get_cells bram_4k_32bit_3/bram_4k_8bit_2/mem_reg]
set_property bmm_info_memory_device {[31:24] [12288:16383]} [get_cells bram_4k_32bit_3/bram_4k_8bit_3/mem_reg]
