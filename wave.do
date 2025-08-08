onerror {resume}
quietly virtual function -install /AHB_tb/DUT/Register_File_slave -env /AHB_tb/#INITIAL#46 { &{/AHB_tb/DUT/Register_File_slave/Reg_file[23], /AHB_tb/DUT/Register_File_slave/Reg_file[22], /AHB_tb/DUT/Register_File_slave/Reg_file[21], /AHB_tb/DUT/Register_File_slave/Reg_file[20], /AHB_tb/DUT/Register_File_slave/Reg_file[19], /AHB_tb/DUT/Register_File_slave/Reg_file[18], /AHB_tb/DUT/Register_File_slave/Reg_file[17], /AHB_tb/DUT/Register_File_slave/Reg_file[16], /AHB_tb/DUT/Register_File_slave/Reg_file[15], /AHB_tb/DUT/Register_File_slave/Reg_file[14], /AHB_tb/DUT/Register_File_slave/Reg_file[13], /AHB_tb/DUT/Register_File_slave/Reg_file[12], /AHB_tb/DUT/Register_File_slave/Reg_file[11], /AHB_tb/DUT/Register_File_slave/Reg_file[10], /AHB_tb/DUT/Register_File_slave/Reg_file[9], /AHB_tb/DUT/Register_File_slave/Reg_file[8], /AHB_tb/DUT/Register_File_slave/Reg_file[7], /AHB_tb/DUT/Register_File_slave/Reg_file[6], /AHB_tb/DUT/Register_File_slave/Reg_file[5], /AHB_tb/DUT/Register_File_slave/Reg_file[4], /AHB_tb/DUT/Register_File_slave/Reg_file[3], /AHB_tb/DUT/Register_File_slave/Reg_file[2], /AHB_tb/DUT/Register_File_slave/Reg_file[1], /AHB_tb/DUT/Register_File_slave/Reg_file[0] }} Reg_File
quietly WaveActivateNextPane {} 0
add wave -noupdate -group Register_file /AHB_tb/HCLK
add wave -noupdate -group Register_file /AHB_tb/HRESETn
add wave -noupdate -group Register_file /AHB_tb/Register_File_En
add wave -noupdate -group Register_file /AHB_tb/HADDR
add wave -noupdate -group Register_file /AHB_tb/HWRITE
add wave -noupdate -group Register_file /AHB_tb/HSIZE
add wave -noupdate -group Register_file /AHB_tb/HBURST
add wave -noupdate -group Register_file /AHB_tb/HTRANS
add wave -noupdate -group Register_file /AHB_tb/DUT/AHB_Register_file_Interface_block/cs
add wave -noupdate -group Register_file /AHB_tb/HWDATA
add wave -noupdate -group Register_file /AHB_tb/HREADY
add wave -noupdate -group Register_file /AHB_tb/HRESP
add wave -noupdate -group Register_file /AHB_tb/HRDATA
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[23]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[22]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[21]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[20]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[19]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[18]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[17]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[16]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[15]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[14]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[13]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[12]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[11]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[10]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[9]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[8]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[7]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[6]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[5]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[4]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[3]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[2]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[1]}
add wave -noupdate -group Register_file {/AHB_tb/DUT/Register_File_slave/Reg_file[0]}
add wave -noupdate -group GPIO /AHB_tb/HCLK
add wave -noupdate -group GPIO /AHB_tb/HRESETn
add wave -noupdate -group GPIO /AHB_tb/GPIO_En
add wave -noupdate -group GPIO /AHB_tb/HADDR
add wave -noupdate -group GPIO /AHB_tb/HWRITE
add wave -noupdate -group GPIO /AHB_tb/HSIZE
add wave -noupdate -group GPIO /AHB_tb/HBURST
add wave -noupdate -group GPIO /AHB_tb/HTRANS
add wave -noupdate -group GPIO /AHB_tb/DUT/AHB_GPIO_Interface_block/cs
add wave -noupdate -group GPIO /AHB_tb/HWDATA
add wave -noupdate -group GPIO -radix binary /AHB_tb/GPIO_in
add wave -noupdate -group GPIO -radix binary /AHB_tb/GPIO_out
add wave -noupdate -group GPIO /AHB_tb/HRDATA
add wave -noupdate -group GPIO /AHB_tb/HREADY
add wave -noupdate -group GPIO /AHB_tb/HRESP
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {272 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {261 ns} {324 ns}
