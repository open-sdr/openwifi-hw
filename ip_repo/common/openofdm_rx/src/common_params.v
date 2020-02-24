//////////////////////////////////////////////////////////////////////////
// PI DEFINITION
//////////////////////////////////////////////////////////////////////////
// localparam PI =             3217;    //  = PI*(1<<`ATAN_LUT_SCALE_SHIFT)
// localparam PI =             3217*2;  //  = PI*(1<<`ATAN_LUT_SCALE_SHIFT)
localparam PI =             1608;       //  = PI*(1<<`ATAN_LUT_SCALE_SHIFT)
localparam DOUBLE_PI =      PI<<1;
localparam PI_2 =           PI>>1;
localparam PI_4 =           PI>>2;
localparam PI_3_4 =         PI_2 + PI_4;


//////////////////////////////////////////////////////////////////////////
// USER REG DEFINITION
//////////////////////////////////////////////////////////////////////////
// power trigger
localparam SR_POWER_THRES   =               3;
localparam SR_POWER_WINDOW =                4;
localparam SR_SKIP_SAMPLE =                 5;

// sync short
localparam SR_MIN_PLATEAU =                 6;

//////////////////////////////////////////////////////////////////////////
// DOT11 STATE MACHINE
//////////////////////////////////////////////////////////////////////////
localparam S_WAIT_POWER_TRIGGER =   0;
localparam S_SYNC_SHORT =           1;
localparam S_SYNC_LONG =            2;
localparam S_DECODE_SIGNAL =        3;
localparam S_CHECK_SIGNAL =         4;
localparam S_DETECT_HT =            5;
localparam S_HT_SIGNAL =            6;
localparam S_CHECK_HT_SIG_CRC =     7;
localparam S_CHECK_HT_SIG =         8;
localparam S_HT_STS =               9;
localparam S_HT_LTS =               10;
localparam S_DECODE_DATA =          11;
localparam S_SIGNAL_ERROR =         12;
localparam S_HT_SIG_ERROR =         13;
localparam S_DECODE_DONE =          14;


//////////////////////////////////////////////////////////////////////////
// DOT11 STATUS CODE
//////////////////////////////////////////////////////////////////////////
// same value may have different meaning depend on the state
localparam E_OK =                   0;

// errors in SIGNAL
localparam E_PARITY_FAIL =          1;
localparam E_UNSUPPORTED_RATE =     2;
localparam E_WRONG_RSVD =           3;
localparam E_WRONG_TAIL =           4;

// erros in HT-SIGNAL
localparam E_UNSUPPORTED_MCS =      1;
localparam E_UNSUPPORTED_CBW =      2;
localparam E_HT_WRONG_RSVD =        3;
localparam E_UNSUPPORTED_STBC =     4;
localparam E_UNSUPPORTED_FEC =      5;
localparam E_UNSUPPORTED_SGI =      6;
localparam E_UNSUPPORTED_SPATIAL =  7;
localparam E_HT_WRONG_TAIL =        8;
localparam E_WRONG_CRC =            9;

// fcs error
localparam E_WRONG_FCS =            1;


localparam EXPECTED_FCS = 32'hc704dd7b;
