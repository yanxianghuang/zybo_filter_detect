-makelib ies/xil_defaultlib -sv \
  "/opt/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/opt/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies/xpm \
  "/opt/Xilinx/Vivado/2017.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies/lib_pkg_v1_0_2 \
  "../../../../../src/bd/design_1/ipshared/832a/hdl/lib_pkg_v1_0_rfs.vhd" \
-endlib
-makelib ies/fifo_generator_v13_1_4 \
  "../../../../../src/bd/design_1/ipshared/ebc2/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib ies/fifo_generator_v13_1_4 \
  "../../../../../src/bd/design_1/ipshared/ebc2/hdl/fifo_generator_v13_1_rfs.vhd" \
-endlib
-makelib ies/fifo_generator_v13_1_4 \
  "../../../../../src/bd/design_1/ipshared/ebc2/hdl/fifo_generator_v13_1_rfs.v" \
-endlib
-makelib ies/lib_fifo_v1_0_8 \
  "../../../../../src/bd/design_1/ipshared/c387/hdl/lib_fifo_v1_0_rfs.vhd" \
-endlib
-makelib ies/lib_srl_fifo_v1_0_2 \
  "../../../../../src/bd/design_1/ipshared/6039/hdl/lib_srl_fifo_v1_0_rfs.vhd" \
-endlib
-makelib ies/lib_cdc_v1_0_2 \
  "../../../../../src/bd/design_1/ipshared/52cb/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib ies/axi_datamover_v5_1_15 \
  "../../../../../src/bd/design_1/ipshared/43a6/hdl/axi_datamover_v5_1_vh_rfs.vhd" \
-endlib
-makelib ies/axi_sg_v4_1_6 \
  "../../../../../src/bd/design_1/ipshared/ddc9/hdl/axi_sg_v4_1_rfs.vhd" \
-endlib
-makelib ies/axi_dma_v7_1_14 \
  "../../../../../src/bd/design_1/ipshared/bb0b/hdl/axi_dma_v7_1_vh_rfs.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_axi_dma_0_0/sim/design_1_axi_dma_0_0.vhd" \
-endlib
-makelib ies/axi_lite_ipif_v3_0_4 \
  "../../../../../src/bd/design_1/ipshared/0ba0/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies/interrupt_control_v3_1_4 \
  "../../../../../src/bd/design_1/ipshared/e956/hdl/interrupt_control_v3_1_vh_rfs.vhd" \
-endlib
-makelib ies/axi_gpio_v2_0_15 \
  "../../../../../src/bd/design_1/ipshared/cb07/hdl/axi_gpio_v2_0_vh_rfs.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_axi_gpio_0_0/sim/design_1_axi_gpio_0_0.vhd" \
-endlib
-makelib ies/axi_iic_v2_0_16 \
  "../../../../../src/bd/design_1/ipshared/6bf4/hdl/axi_iic_v2_0_vh_rfs.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_axi_iic_0_0/sim/design_1_axi_iic_0_0.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_d_axi_i2s_audio_0_0/src/fifo_32/sim/fifo_32.v" \
  "../../../bd/design_1/ip/design_1_d_axi_i2s_audio_0_0/src/fifo_4/sim/fifo_4.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../../../src/bd/design_1/ipshared/3bba/src/rst_sync.vhd" \
  "../../../../../src/bd/design_1/ipshared/3bba/src/i2s_ctl.vhd" \
  "../../../../../src/bd/design_1/ipshared/3bba/src/DCM.vhd" \
  "../../../../../src/bd/design_1/ipshared/3bba/src/Sync_ff.vhd" \
  "../../../../../src/bd/design_1/ipshared/3bba/src/i2s_stream.vhd" \
  "../../../../../src/bd/design_1/ipshared/3bba/src/i2s_rx_tx.vhd" \
  "../../../../../src/bd/design_1/ipshared/3bba/src/d_axi_i2s_audio_v2_0_AXI_L.vhd" \
  "../../../../../src/bd/design_1/ipshared/3bba/src/d_axi_i2s_audio_v2_0.vhd" \
  "../../../bd/design_1/ip/design_1_d_axi_i2s_audio_0_0/sim/design_1_d_axi_i2s_audio_0_0.vhd" \
-endlib
-makelib ies/axi_infrastructure_v1_1_0 \
  "../../../../../src/bd/design_1/ipshared/7e3a/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib ies/xil_common_vip_v1_0_0 -sv \
  "../../../../../src/bd/design_1/ipshared/2ad9/hdl/xil_common_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib ies/smartconnect_v1_0 -sv \
  "../../../../../src/bd/design_1/ipshared/39ca/hdl/sc_util_v1_0_vl_rfs.sv" \
-endlib
-makelib ies/axi_protocol_checker_v1_1_14 -sv \
  "../../../../../src/bd/design_1/ipshared/a1b2/hdl/axi_protocol_checker_v1_1_vl_rfs.sv" \
-endlib
-makelib ies/axi_vip_v1_0_2 -sv \
  "../../../../../src/bd/design_1/ipshared/6eb1/hdl/axi_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib ies/axi_vip_v1_0_1 -sv \
  "../../../../../src/bd/design_1/ipshared/1d61/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_processing_system7_0_0/sim/design_1_processing_system7_0_0.v" \
-endlib
-makelib ies/proc_sys_reset_v5_0_11 \
  "../../../../../src/bd/design_1/ipshared/5db7/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_rst_processing_system7_0_100M_0/sim/design_1_rst_processing_system7_0_100M_0.vhd" \
-endlib
-makelib ies/xlconcat_v2_1_1 \
  "../../../../../src/bd/design_1/ipshared/73b7/hdl/xlconcat_v2_1_vl_rfs.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_xlconcat_0_0/sim/design_1_xlconcat_0_0.v" \
-endlib
-makelib ies/xlconstant_v1_1_3 \
  "../../../../../src/bd/design_1/ipshared/45df/hdl/xlconstant_v1_1_vl_rfs.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_xlconstant_0_0/sim/design_1_xlconstant_0_0.v" \
-endlib
-makelib ies/generic_baseblocks_v2_1_0 \
  "../../../../../src/bd/design_1/ipshared/f9c1/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
-endlib
-makelib ies/axi_register_slice_v2_1_13 \
  "../../../../../src/bd/design_1/ipshared/55c0/hdl/axi_register_slice_v2_1_vl_rfs.v" \
-endlib
-makelib ies/axi_data_fifo_v2_1_12 \
  "../../../../../src/bd/design_1/ipshared/95b9/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
-endlib
-makelib ies/axi_crossbar_v2_1_14 \
  "../../../../../src/bd/design_1/ipshared/f582/hdl/axi_crossbar_v2_1_vl_rfs.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_xbar_1/sim/design_1_xbar_1.v" \
  "../../../bd/design_1/ip/design_1_xbar_0/sim/design_1_xbar_0.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/hdl/design_1.vhd" \
  "../../../bd/design_1/ipshared/5ffb/src/FPP_ADD_SUB.vhd" \
  "../../../bd/design_1/ipshared/5ffb/src/FPP_MULT.vhd" \
  "../../../bd/design_1/ipshared/5ffb/src/b_filter_S00_AXI.vhd" \
  "../../../bd/design_1/ipshared/5ffb/src/banddetect.vhd" \
  "../../../bd/design_1/ipshared/5ffb/src/fp_leading_zeros_and_shift.vhd" \
  "../../../bd/design_1/ipshared/5ffb/src/right_shifter.vhd" \
  "../../../bd/design_1/ipshared/5ffb/src/biquad.vhd" \
  "../../../bd/design_1/ipshared/5ffb/src/b_filter.vhd" \
  "../../../bd/design_1/ip/design_1_b_filter_0_0/sim/design_1_b_filter_0_0.vhd" \
  "../../../bd/design_1/ip/design_1_rst_ps7_0_15M_0/sim/design_1_rst_ps7_0_15M_0.vhd" \
-endlib
-makelib ies/util_ds_buf_v2_01_a \
  "../../../../../src/bd/design_1/ipshared/1e84/hdl/vhdl/util_ds_buf.vhd" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_util_ds_buf_0_0/sim/design_1_util_ds_buf_0_0.vhd" \
-endlib
-makelib ies/axi_protocol_converter_v2_1_13 \
  "../../../../../src/bd/design_1/ipshared/f0ae/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_auto_pc_2/sim/design_1_auto_pc_2.v" \
  "../../../bd/design_1/ip/design_1_auto_pc_1/sim/design_1_auto_pc_1.v" \
  "../../../bd/design_1/ip/design_1_auto_pc_0/sim/design_1_auto_pc_0.v" \
-endlib
-makelib ies/axi_clock_converter_v2_1_12 \
  "../../../../../src/bd/design_1/ipshared/80fd/hdl/axi_clock_converter_v2_1_vl_rfs.v" \
-endlib
-makelib ies/blk_mem_gen_v8_3_6 \
  "../../../../../src/bd/design_1/ipshared/4158/simulation/blk_mem_gen_v8_3.v" \
-endlib
-makelib ies/axi_dwidth_converter_v2_1_13 \
  "../../../../../src/bd/design_1/ipshared/3bde/hdl/axi_dwidth_converter_v2_1_vl_rfs.v" \
-endlib
-makelib ies/xil_defaultlib \
  "../../../bd/design_1/ip/design_1_auto_us_1/sim/design_1_auto_us_1.v" \
  "../../../bd/design_1/ip/design_1_auto_us_0/sim/design_1_auto_us_0.v" \
-endlib
-makelib ies/xil_defaultlib \
  glbl.v
-endlib

