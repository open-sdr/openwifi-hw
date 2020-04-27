// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
// board specific definitions

// clock_speed.v has NUM_CLK_PER_US. The value is determined by .tcl (_high.tcl or _low.tcl)
//`define NUM_CLK_PER_US         250 // 250MHz clock for ultrascale+ FPGA
//`define NUM_CLK_PER_US         200 // 200MHz clock for fast FPGA, like -2 and above grade Zynq7000
//`define NUM_CLK_PER_US         100 // 100MHz clock for slow FPGA, like -1 grade Zynq7000

`define SAMPLING_RATE_MHZ       20
`define ASSUMED_COUNTER_CLK_MHZ 10  // 10MHz is assumed in SW/driver for sub us resolutuion FPGA counters
`define NUM_CLK_PER_SAMPLE     ((`NUM_CLK_PER_US)/`SAMPLING_RATE_MHZ)
`define COUNT_TOP_1M           ((`NUM_CLK_PER_US)-1)
`define COUNT_SCALE            ((`NUM_CLK_PER_US)/(`ASSUMED_COUNTER_CLK_MHZ))
