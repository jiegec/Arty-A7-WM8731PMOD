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

# Switches
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports switches[0]]
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports switches[1]]
set_property -dict {PACKAGE_PIN C10 IOSTANDARD LVCMOS33} [get_ports switches[2]]
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports switches[3]]

# SPI Flash
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS33} [get_ports spi_cs]
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports spi_dq0]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports spi_dq1]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports spi_dq2]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports spi_dq3]
set_property -dict {PACKAGE_PIN E9 IOSTANDARD LVCMOS33} [get_ports spi_sck]