onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib xfft_1_new_opt

do {wave.do}

view wave
view structure
view signals

do {xfft_1_new.udo}

run -all

quit -force
