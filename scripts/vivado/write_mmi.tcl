# Create by liam on 2020/07/20
# Will write bram.mmi file automatically.
# Only support for RAM using 4k x 8bit block ram cell.
# You may change sequence for supporting other size RAM.

proc write_mmi {} {
    set proj [current_project]
    set fileout [open "bram.mmi" "w"]
    set brams [split [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ BMEM.bram.* && NAME =~  "bram_4k_32bit_*" }] " "]
    set bram_numbers [llength $brams]
    set addr_range [ expr {$bram_numbers * 4096 - 1} ]
    set inst_path "dummy"

    puts $fileout "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    puts $fileout "<MemInfo Version=\"1\" Minor=\"0\">"
    puts $fileout "  <Processor Endianness=\"Little\" InstPath=\"$inst_path\">"
    puts $fileout "  <AddressSpace Name=\"bram\" Begin=\"0\" End=\"$addr_range\">"

    set sequence "7 15 23 31"
    set bus_blocks [ expr { $bram_numbers / [llength $sequence]  } ]
    set x 0
    set addr_begin 0
    for {set i 0} {$i < $bus_blocks} {incr i} {
        puts $fileout "      <BusBlock>"
        # Set addr begin and end
        set addr_begin [ expr {$i * 4096} ]
        set addr_end [ expr {$addr_begin + 4095} ]
        
        for {set j 0} {$j < [llength $sequence]} {incr j} {
            # Set bram type
            set bram_type [ get_property REF_NAME [ get_cells [lindex $brams $x] ] ]
            set status [ get_property STATUS [ get_cells [lindex $brams $x] ] ]
            if {$bram_type == "RAMB36E1"} {
                set bram_type "RAMB32"
            }

            # Set bram site
            if {$status == "UNPLACED"} {
                set placed "X0Y0"
            } else {
                set placed [ get_property LOC [ get_cells [lindex $brams $x] ] ]
                set placed_list [split $placed "_"]
                set placed [lindex $placed_list 1]
            }

            # Set msb and lsb
            set bmm_msb [lindex $sequence $j]
            set bmm_lsb [ expr {$bmm_msb - 7} ]

            puts $fileout "        <BitLane MemType=\"$bram_type\" Placement=\"$placed\">"
            puts $fileout "          <DataWidth MSB=\"$bmm_msb\" LSB=\"$bmm_lsb\"/>"
            puts $fileout "          <AddressRange Begin=\"$addr_begin\" End=\"$addr_end\"/>"
            puts $fileout "          <Parity ON=\"false\" NumBits=\"0\"/>"
            puts $fileout "        </BitLane>"
            incr x
        }
        puts $fileout "      </BusBlock>"
    }

    puts $fileout "  </AddressSpace>"
    puts $fileout "  </Processor>"
    puts $fileout "<Config>"
    puts $fileout "  <Option Name=\"Part\" Val=\"[get_property PART [current_project ]]\"/>"
    puts $fileout "</Config>"
    puts $fileout "</MemInfo>"
    close $fileout
    puts "MMI file bram.mmi created successfully."
}
