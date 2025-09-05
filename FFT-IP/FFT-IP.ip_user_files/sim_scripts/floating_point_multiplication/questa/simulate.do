onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib floating_point_multiplication_opt

do {wave.do}

view wave
view structure
view signals

do {floating_point_multiplication.udo}

run -all

quit -force
