# file copy -force ../modelsim.ini modelsim.ini

vlib xil_defaultlib
vmap xil_defaultlib xil_defaultlib

vlog -sv -incr -work xil_defaultlib \
"../testbench.sv" \

vlog -incr +cover -work xil_defaultlib \
-f "../design_ver.f" \

# 不使用任何器件库
vsim -voptargs="+acc" -t ps -quiet -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.testbench

add wave *
log -r /*
run 10ms
