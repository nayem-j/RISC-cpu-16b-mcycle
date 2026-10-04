# Vivado simulation tools
XVLOG = xvlog
XELAB = xelab
XSIM  = xsim

# Source file list
FILELIST = files.f

# Testbench top module
TOP ?= tb_top

# Build directory
BUILD = build

# XSIM snapshot
SNAPSHOT = $(TOP)

.PHONY: all compile elaborate run gui clean

all: run

compile:
	$(XVLOG) -sv -f $(FILELIST)

elaborate: compile
	$(XELAB) $(TOP) -s $(SNAPSHOT)

run: elaborate
	$(XSIM) $(SNAPSHOT) -runall

gui: elaborate
	$(XSIM) $(SNAPSHOT) -gui

clean:
	rm -rf xsim.dir .Xil *.log *.pb *.jou *.wdb *.vcd 

