// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;
// board specific definitions

// clock_speed.v has NUM_CLK_PER_US. The value is determined by .tcl (_high.tcl or _low.tcl)
//`define NUM_CLK_PER_US         200 // 200MHz clock for fast FPGA, like -2 and above grade Zynq7000
//`define NUM_CLK_PER_US         100 // 100MHz clock for slow FPGA, like -1 grade Zynq7000

`define NUM_CLK_PER_US_ORIGINAL 200  // 200MHz is used originally and assumed in SW/driver
`define NUM_CLK_PER_SAMPLE     ((`NUM_CLK_PER_US)/20)    // 20MSPS
`define COUNT_TOP_20M          ((`NUM_CLK_PER_SAMPLE)-1)
`define COUNT_TOP_1M           ((`NUM_CLK_PER_US)-1)
`define COUNT_SCALE            ((`NUM_CLK_PER_US_ORIGINAL)/(`NUM_CLK_PER_US))

