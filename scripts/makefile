default :

install-clean :
	rm -rf ./verif-tools/verilog2smv-1.1.2 ./verif-tools/verilog2smv.sh	

install :
	cd verif-tools ; \
	tar -vxjf verilog2smv-1.1.2.tar.bz2 ; \
	cd verilog2smv-1.1.2 ; \
	sh build.sh ; \
	cp verilog2smv.sh ../

timer :
	sh build/run "application/timer" true

gpio :
	sh build/run "application/gpio" true

uart :
	sh build/run "application/uart" true

run :
	sh build/run "application/timer" false

verify :
	sh verif-tools/run

clean :
	rm -rf simv *.mem pmem.inc stimulus.v tmp-build
