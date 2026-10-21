# Vivado simulation tools
XVLOG = xvlog
XELAB = xelab
XSIM  = xsim
XCRG  = xcrg

# Source file list
FILELIST = files.f

# Testbench top module
TOP ?= tb_cpu

# Build directory
BUILD = build

# XSIM snapshot
SNAPSHOT = $(TOP)

# Coverage switch (enable with COV=1)
COV ?= 0
COV_DB_DIR ?= .
COV_DB_NAME ?= $(SNAPSHOT)
COV_REPORT_DIR ?= coverage_report
COV_REPORT_FORMAT ?= all
CC_TYPE ?= sbct

ifeq ($(COV),1)
ELAB_COV_FLAGS = --cov_db_dir $(COV_DB_DIR) --cov_db_name $(COV_DB_NAME) --cc_type $(CC_TYPE)
XSIM_COV_FLAGS = --cov_db_dir $(COV_DB_DIR) --cov_db_name $(COV_DB_NAME)
endif

.PHONY: all compile elaborate run gui clean

all: run

compile:
	$(XVLOG) -sv -f $(FILELIST)

elaborate: compile
	$(XELAB) $(TOP) -s $(SNAPSHOT) $(ELAB_COV_FLAGS)

run: elaborate
	$(XSIM) $(SNAPSHOT) -runall $(XSIM_COV_FLAGS)
ifeq ($(COV),1)
	$(XCRG) -cov_db_dir $(COV_DB_DIR) -cov_db_name $(COV_DB_NAME) \
	 -report_dir $(COV_REPORT_DIR) -report_format $(COV_REPORT_FORMAT)
endif

gui: elaborate
	$(XSIM) $(SNAPSHOT) -gui $(XSIM_COV_FLAGS)

clean:
	rm -rf xsim.dir xsim.codeCov xsim.covdb .Xil \
	 *.log *.pb *.jou *.wdb *.vcd 

