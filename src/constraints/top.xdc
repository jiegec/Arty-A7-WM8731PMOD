# Clock
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk_in]

# Reset Button
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports resetn]

# PMOD A
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports i2s_lrclk]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports i2s_dacdat]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports i2s_adcdat]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports i2s_bclk]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports speaker_mute]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports mclk]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports i2c_scl_io]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports i2c_sda_io]

# Serial
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports uart_tx]
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS33} [get_ports uart_rx]