library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;
use std.textio.all;

library OSVVM;
context OSVVM.OsvvmContext;

library osvvm_uart;
context osvvm_uart.UartContext;

entity TestCtrl is
  generic (
    tperiod_Clk : time := 10 ns
  );
  port (
    -- Record Interface
    UartTxRec : inout UartRecType;
    UartRxRec : inout UartRecType;
    -- Global Signal Interface
    Clk    : in std_logic;
    nReset : in std_logic
  );
end TestCtrl;
