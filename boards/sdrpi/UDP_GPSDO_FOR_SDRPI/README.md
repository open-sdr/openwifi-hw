# UDP_GPSDO_FOR_SDRPI
Supprting files for UDP/IP stack and GPSDO in SDRPi board.

  
I provide a DCP file and some verilog file and .XDC file .
This DCP file 
A,contain a UDP/IP/ETHER stack ,and support ARP,IP,UDP(MTU as 8100) and can reply PING .
B,contain a GPSDO which provide this 40M clock source for AD9361,FPGA and can connct to external.It accuracy is within 20 PPB .GPS lock time is about 40 seconds ,and OSC lock time is about 20 seconds.
C,Read GPSDO default DAC value ream eeprom when no GPS antter connct.
D,Store GPSDO DAC value to eeprom.
E,Check if a valid SDRPi borad, if not this function listed above will disable about 1 hours running .


These rtl file illstrate the port and function for using DCP file,expescaly it provide a socket like UDP interface more easy for using .

This XDC file it the constain file for pins defination.

This demo_prj.tcl used to generate project.in vivado console,locat at (by type cd command)file of gen_prj.tcl,then type source  demo_prj.tcl .this vivado project will create automaticly reated.



