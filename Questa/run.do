vlib work
vlog -f src_files.list.txt
vsim -voptargs=+acc work.AHB_tb 
do wave.do
run -all

