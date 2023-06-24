######################################
#  Read in circuit s27 and synthesis
######################################
read_file -format verilog s27.v  
current_design s27 
create_clock "CLK" -period 10 -waveform {5 10}
set_fix_hold CLK
set_dont_touch_network CLK

# Specofy ATE timing
##############################################
set test_default_period 100
set test_default_strobe 40

#########################################
#  Scan Chain Insertion (one scan chain)
#########################################

# create scan enable, scan chain in/out ports
##############################################
create_port test_se
create_port -direction in {SCAN_IN_1}
create_port -direction out {SCAN_OUT_1}

# Setup the timing of scan clock
##################################
set_dft_signal -view existing_dft -type ScanClock -timing [ list 45 55] -port [find port "CLK"]

# Creat test protocol
######################
create_test_protocol -capture_procedure single_clock

# Check drc rule
#################
dft_drc -verbose


# Specify the number of scan chains and the type of scan cell
##############################################################
set_scan_configuration -chain_count 1
set_scan_configuration -style multiplexed_flip_flop

# Specify the name of scan enable and the names of scan chain in/out ports
###########################################################################
set_dft_signal -view spec -port "SCAN_IN_1" -type ScanDataIn  
set_dft_signal -view spec -port "SCAN_OUT_1" -type ScanDataOut
set_dft_signal -view spec -port "test_se" -type ScanEnable -active_state 1

# Synthesis the circuit s27 by considering the scan insertion
##############################################################
compile -scan
insert_dft

# Estimate the fault coverage of the scan-based design
########################################################
dft_drc -coverage_estimate

change_names -rule verilog -hierarchy

# Check if the scan-based design has errors/warnings or not
#############################################################
check_design

report_area -nosplit > s27_scan_area.log
compile -map_effort medium -area_effort medium -incremental_mapping

write -hierarchy -format verilog -output s27_dft.v 
write_test_protocol -output s27.spf  

exit