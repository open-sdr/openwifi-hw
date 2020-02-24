
// Xianjun jiao. putaoshu@msn.com; xianjun.jiao@imec.be;

`timescale 1 ns / 1 ps

	module rx_intf_pl_to_m_axis #
	(
    parameter integer GPIO_STATUS_WIDTH = 8,
    parameter integer RSSI_HALF_DB_WIDTH=11,
	  parameter integer IQ_DATA_WIDTH	= 16,
		parameter integer TSF_TIMER_WIDTH = 64,
		parameter integer C_M00_AXIS_TDATA_WIDTH = 64,
		parameter integer MAX_BIT_NUM_DMA_SYMBOL = 14
	)
	(
	    input wire clk,
	    input wire rstn,

	    // port to xpu
	    input wire block_rx_dma_to_ps,
      input wire block_rx_dma_to_ps_valid,
	    input wire [(RSSI_HALF_DB_WIDTH-1):0] rssi_half_db_lock_by_sig_valid,
	    input wire [(GPIO_STATUS_WIDTH-1):0] gpio_status_lock_by_sig_valid,

	    // to m_axis and PS
	    output reg start_1trans_to_m_axis,
	    output wire [(C_M00_AXIS_TDATA_WIDTH-1) : 0] data_to_m_axis_out,
	    output wire data_ready_to_m_axis_out,
	    output reg [(MAX_BIT_NUM_DMA_SYMBOL-1) : 0] monitor_num_dma_symbol_to_ps,
	    output reg m_axis_rst,
      input  wire m_axis_tlast,
      (* mark_debug = "true" *) output reg  m_axis_tlast_auto_recover,

	    // port to xilinx axi dma
	    input wire s2mm_intr,
	    output reg rx_pkt_intr,
	    
      // to byte_to_word_fcs_sn_intert
      output wire rx_pkt_sn_plus_one,

	    // start m_axis trans mode
      input wire m_axis_tlast_auto_recover_enable,
      input wire [12:0] m_axis_tlast_auto_recover_timeout_top,
	    input wire [2:0] start_1trans_mode,
	    input wire start_1trans_ext_trigger,
	    input wire start_1trans_s_axis_tlast_trigger,
	    input wire start_1trans_s_axis_tready_trigger,

	    input wire src_sel,
	    input wire [(TSF_TIMER_WIDTH-1):0]  tsf_runtime_val,
	    input wire [14:0] count_top,
//	    input wire pad_test,
	    
	    // from wifi rx
	    input wire [(C_M00_AXIS_TDATA_WIDTH-1) : 0] data_from_acc,
	    input wire data_ready_from_acc,
      input wire [7:0] pkt_rate,
		  input wire [15:0] pkt_len,
      input wire sig_valid,
      input wire ht_unsupport,
	    input wire fcs_valid,
    
	    // from wifi_rx_iq_intf loop back
	    input wire [(C_M00_AXIS_TDATA_WIDTH-1):0] rf_iq,
	    input wire rf_iq_valid,

      input wire tsf_pulse_1M
	);
	
	  localparam [0:0]   WAIT_S2MM_INTR =                    1'b0,
                       COUNT_TO_TOP  =                     1'b1;
                       
	  localparam [2:0]   WAIT_FOR_PKT =                      3'b000,
                       DMA_HEADER0_INSERT  =               3'b001,
                       DMA_HEADER1_INSERT_AND_START =      3'b010,
                       WAIT_FILTER_FLAG =                  3'b011,
                       WAIT_DMA_TLAST =                    3'b100,
                       WAIT_RST_DONE =                     3'b101;

    (* mark_debug = "true" *) reg [2:0] rx_state;
    (* mark_debug = "true" *) reg [2:0] old_rx_state;
    (* mark_debug = "true" *) reg start_m_axis;
    reg [(C_M00_AXIS_TDATA_WIDTH-1) : 0] data_to_m_axis;
    reg data_ready_to_m_axis;
    reg [2:0] rst_count;
    reg [(TSF_TIMER_WIDTH-1):0] tsf_val_lock_by_sig;

    reg [0:0] delay_intr_state;
    reg [14:0] count;

    (* mark_debug = "true" *) reg [12:0] timeout_timer_1M;
    
	  assign data_to_m_axis_out =       (start_1trans_mode==3'b101)? data_to_m_axis:( (src_sel==1'b0)?data_from_acc:rf_iq );
    assign data_ready_to_m_axis_out = (start_1trans_mode==3'b101)? data_ready_to_m_axis:( (src_sel==1'b0)?data_ready_from_acc:rf_iq_valid );

    assign rx_pkt_sn_plus_one = (rx_state==WAIT_FILTER_FLAG && block_rx_dma_to_ps_valid==1 && block_rx_dma_to_ps==0);
    
    always @( start_1trans_mode,sig_valid,fcs_valid,start_1trans_ext_trigger,start_1trans_s_axis_tlast_trigger,start_m_axis,start_1trans_s_axis_tready_trigger)
    begin
       case (start_1trans_mode)
          3'b000 : begin
                        start_1trans_to_m_axis = fcs_valid;
                   end
          3'b001 : begin
                        start_1trans_to_m_axis = sig_valid;
                   end
          3'b010 : begin
                        start_1trans_to_m_axis = start_1trans_ext_trigger;
                   end
          3'b011 : begin
                        start_1trans_to_m_axis = start_1trans_s_axis_tlast_trigger;
                   end
          3'b100 : begin
                        start_1trans_to_m_axis = start_1trans_s_axis_tready_trigger;
                   end
          3'b101 : begin
                        start_1trans_to_m_axis = start_m_axis;
                   end
          3'b110 : begin
                        start_1trans_to_m_axis = start_1trans_ext_trigger;
                   end
          3'b111 : begin
                        start_1trans_to_m_axis = start_1trans_ext_trigger;
                   end
          default: begin
                        start_1trans_to_m_axis = start_1trans_ext_trigger;
                   end
       endcase
    end

    //lock tsf runtime value by sig_valid
    always @( posedge clk )
    begin
      if (!rstn) begin
        tsf_val_lock_by_sig<=0;
      end 
      else begin
        if (sig_valid)
          tsf_val_lock_by_sig<=tsf_runtime_val;
        else
          tsf_val_lock_by_sig<=tsf_val_lock_by_sig;
      end
    end

    //state machine to control m_axis to ARM
    always @(posedge clk)                                             
    begin
      if (!rstn) begin
          rst_count <= 0;
          monitor_num_dma_symbol_to_ps<=0;
          m_axis_rst<=0;
          m_axis_tlast_auto_recover<=0;
          data_to_m_axis <= 0;
          data_ready_to_m_axis <= 0;
          start_m_axis <= 0;
          rx_state <= WAIT_FOR_PKT;
          old_rx_state <= WAIT_FOR_PKT;
          timeout_timer_1M<=0;
      end
      else begin
        old_rx_state <= rx_state;
        case (rx_state)
          WAIT_FOR_PKT: begin
            timeout_timer_1M<=0;
            rst_count <= 0;
            data_to_m_axis <= 0;
            data_ready_to_m_axis <= 0;
            start_m_axis <= 0;
            m_axis_rst<=0;
            m_axis_tlast_auto_recover<=0;
            if (sig_valid && (ht_unsupport==0)) begin
              monitor_num_dma_symbol_to_ps<=( pkt_len[15:3] + (pkt_len[2:0]!=0) ) + 2; // 2 for tsf, rf_info and rate/len insertion at the beginnig;
              rx_state <= DMA_HEADER0_INSERT;
            end
          end

          DMA_HEADER0_INSERT: begin // data is calculated by calc_phy_header C program
            timeout_timer_1M<=timeout_timer_1M;
            rst_count <= rst_count;
            //data_to_m_axis <= (pad_test==1?64'h0123456789abcdef:tsf_val_lock_by_sig);
            data_to_m_axis <= tsf_val_lock_by_sig;
            data_ready_to_m_axis <= 1;
            start_m_axis <= start_m_axis;
            monitor_num_dma_symbol_to_ps<=monitor_num_dma_symbol_to_ps;
            m_axis_rst<=m_axis_rst;
            m_axis_tlast_auto_recover<=m_axis_tlast_auto_recover;
            rx_state <= DMA_HEADER1_INSERT_AND_START;
          end

          DMA_HEADER1_INSERT_AND_START: begin // data is calculated by calc_phy_header C program
            timeout_timer_1M<=timeout_timer_1M;
            rst_count <= rst_count;
            //data_to_m_axis <= (pad_test==1?64'hfedcba9876543210:{11'd0, pkt_rate[7],pkt_rate[3:0],pkt_len, 8'd0, gpio_status_lock_by_sig_valid, 5'd0, rssi_half_db_lock_by_sig_valid});
            data_to_m_axis <= {11'd0, pkt_rate[7],pkt_rate[3:0],pkt_len, 8'd0, gpio_status_lock_by_sig_valid, 5'd0, rssi_half_db_lock_by_sig_valid};
            data_ready_to_m_axis <= data_ready_to_m_axis;
            start_m_axis <= start_m_axis;
            monitor_num_dma_symbol_to_ps<=monitor_num_dma_symbol_to_ps;
            m_axis_rst<=m_axis_rst;
            m_axis_tlast_auto_recover<=m_axis_tlast_auto_recover;
            rx_state <= WAIT_FILTER_FLAG;
          end

          WAIT_FILTER_FLAG: begin
            rst_count <= rst_count;
            data_to_m_axis <= data_from_acc;
            data_ready_to_m_axis <= data_ready_from_acc;
            monitor_num_dma_symbol_to_ps<=monitor_num_dma_symbol_to_ps;
            if ( (timeout_timer_1M>m_axis_tlast_auto_recover_timeout_top) && m_axis_tlast_auto_recover_enable) begin//tlast timeout, let's generate a fake tlast to release ARM dma and reset our m_axis
              start_m_axis <= start_m_axis;
              timeout_timer_1M<=timeout_timer_1M;
              m_axis_rst<=1;
              m_axis_tlast_auto_recover<=1;
              rx_state <= WAIT_RST_DONE;
            end else begin
              m_axis_tlast_auto_recover<=m_axis_tlast_auto_recover;
              if (block_rx_dma_to_ps_valid==1 && block_rx_dma_to_ps==0) begin
                timeout_timer_1M<=0;
                start_m_axis <= 1;
                m_axis_rst<=m_axis_rst;
                rx_state <= WAIT_DMA_TLAST;
              end else if (block_rx_dma_to_ps_valid==1 && block_rx_dma_to_ps==1) begin
                timeout_timer_1M<=timeout_timer_1M;
                start_m_axis <= start_m_axis;
                m_axis_rst<=1;
                rx_state <= WAIT_RST_DONE;
              end else begin
                timeout_timer_1M<=(tsf_pulse_1M?(timeout_timer_1M+1):timeout_timer_1M);
                start_m_axis <= start_m_axis;
                m_axis_rst<=m_axis_rst;
                rx_state <= rx_state;
              end
            end
          end

          WAIT_DMA_TLAST: begin
            rst_count <= rst_count;
            data_to_m_axis <= data_from_acc;
            data_ready_to_m_axis <= data_ready_from_acc;
            start_m_axis <= 0;
            monitor_num_dma_symbol_to_ps<=monitor_num_dma_symbol_to_ps;
            if ( (timeout_timer_1M>m_axis_tlast_auto_recover_timeout_top) && m_axis_tlast_auto_recover_enable) begin//tlast timeout, let's generate a fake tlast to release ARM dma and reset our m_axis
              timeout_timer_1M<=timeout_timer_1M;
              m_axis_rst<=1;
              m_axis_tlast_auto_recover<=1;
              rx_state <= WAIT_RST_DONE;
            end else begin
              timeout_timer_1M<=(tsf_pulse_1M?(timeout_timer_1M+1):timeout_timer_1M);
              m_axis_rst<=m_axis_rst;
              m_axis_tlast_auto_recover<=m_axis_tlast_auto_recover;
              rx_state <= (m_axis_tlast?WAIT_FOR_PKT:rx_state);
            end
          end

          WAIT_RST_DONE: begin
            timeout_timer_1M<=timeout_timer_1M;
            m_axis_tlast_auto_recover<=0;
            rst_count <= rst_count+1;
            data_to_m_axis <= 0;
            data_ready_to_m_axis <= 0;
            start_m_axis <= start_m_axis;
            monitor_num_dma_symbol_to_ps<=0;
            if (rst_count==7) begin
              m_axis_rst<=0;
              rx_state <= WAIT_FOR_PKT;
            end else begin
              m_axis_rst<=m_axis_rst;
              rx_state <= rx_state;
            end
          end
        endcase
      end
    end

    // process to generate delayed interrupt after receive s2mm_intr
    always @(posedge clk)                                             
    begin                                                                     
      if (!rstn)                                                    
      // Synchronous reset (active low)                                       
        begin
          count    <= 0;    
          rx_pkt_intr<=0;
          delay_intr_state <= WAIT_S2MM_INTR;                                             
        end                                                                   
      else
        case (delay_intr_state)
          WAIT_S2MM_INTR: begin
            count    <= 0;
            rx_pkt_intr<=0;
            delay_intr_state<=(s2mm_intr?COUNT_TO_TOP:WAIT_S2MM_INTR);
          end
          
          COUNT_TO_TOP: begin
            if (count == count_top)                                                      
                begin                                                           
                count    <= 0;            
                rx_pkt_intr <= 1;
                delay_intr_state <= WAIT_S2MM_INTR;
                end                                                             
            else                                                              
                begin                                                           
                count <= count + 1;         
                rx_pkt_intr <= 0;               
                delay_intr_state <= COUNT_TO_TOP;   
                end
          end
        endcase                                                               
    end

	endmodule
