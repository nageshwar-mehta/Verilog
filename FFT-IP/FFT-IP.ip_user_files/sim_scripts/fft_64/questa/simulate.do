onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib fft_64_opt

do {wave.do}

view wave
view structure
view signals

do {fft_64.udo}

run -all

quit -force
