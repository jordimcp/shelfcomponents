library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

library osvvm;
context osvvm.OsvvmContext;

library osvvm_uart;
context osvvm_uart.UartContext;

library work;
use work.all;

entity tbUart is
end tbUart;

architecture TestHarness of tbUart is

  constant tperiod_Clk       : time    := 10 ns;
  constant tpd               : time    := 2 ns;
  constant tperiod_Uart      : time    := 8680 ns;
  --- TEST PARAMETERS
  constant DATA_WIDTH        : integer := 8;
  constant N_PARITY          : integer := 1; -- 0 None, 1 bit
  constant PARITY_TYPE       : integer := 1; -- 0 Even, 1 Odd
  constant OSSVM_PARITY_TYPE : integer := 1; -- 0 None, 1 Odd, 3 Even
   
  signal Clk    : std_logic := '0';
  signal nReset : std_logic;

  -- Uart Interface
  signal rx          : std_logic;
  signal tx          : std_logic;
  signal busy_tx     : std_logic;
  signal busy_rx     : std_logic;
  signal parity_rx   : std_logic;
  signal new_word_rx : std_logic;
  signal word_rx     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  ------------------------------------------------------------
  -- Stimulus generation and synchronization
  ------------------------------------------------------------
  component TestCtrl
    generic (
      tperiod_Clk : time := 10 ns
    );
    port (
      UartTxRec : inout UartRecType;
      UartRxRec : inout UartRecType;

      Clk    : in std_logic;
      nReset : in std_logic
    );
  end component;

  signal UartTxRec : UartRecType;
  signal UartRxRec : UartRecType;

begin

  ------------------------------------------------------------
  -- create Clock 
  Osvvm.TbUtilPkg.CreateClock (
  ------------------------------------------------------------
  Clk    => Clk,
  Period => tperiod_Clk
  );

  ------------------------------------------------------------
  -- create nReset 
  Osvvm.TbUtilPkg.CreateReset (
  ------------------------------------------------------------
  Reset       => nReset,
  ResetActive => '0',
  Clk         => Clk,
  Period      => 7 * tperiod_Clk,
  tpd         => tpd
  );

  -- DUT
  dut_inst : entity work.top_uart
    generic map(
      CLK_PERIOD_NS  => tperiod_Clk,
      UART_PERIOD_NS => tperiod_Uart,
      DATA_WIDTH     => DATA_WIDTH,
      N_PARITY_BIT   => N_PARITY,
      PARITY_TYPE    => PARITY_TYPE
    )
    port map(
      clk  => Clk,
      rstn => nReset,
      -- RX INTERFACE
      new_word_rx => new_word_rx,
      word_rx     => word_rx,
      busy_rx     => busy_rx,
      parity_rx   => parity_rx,
      -- TX INTERFACE
      new_word_tx => new_word_rx,
      word_tx     => word_rx,
      busy_tx     => busy_tx,
      -- UART INTERFACE
      rx => tx,
      tx => rx
    );
  ------------------------------------------------------------
  UartTx_1 : UartTx
  ------------------------------------------------------------
  generic map(
    DEFAULT_BAUD          => UART_BAUD_PERIOD_115200,
    DEFAULT_NUM_DATA_BITS => DATA_WIDTH,
    DEFAULT_PARITY_MODE   => OSSVM_PARITY_TYPE, --UARTTB_PARITY_EVEN,--UARTTB_PARITY_NONE,
    DEFAULT_NUM_STOP_BITS => UARTTB_STOP_BITS_1
  )
  port map(
    TransactionRec => UartTxRec,
    SerialDataOut  => tx
  );

  ------------------------------------------------------------
  UartRx_1 : UartRx
  ------------------------------------------------------------
  generic map(
    DEFAULT_BAUD          => UART_BAUD_PERIOD_115200,
    DEFAULT_NUM_DATA_BITS => DATA_WIDTH,
    DEFAULT_PARITY_MODE   => OSSVM_PARITY_TYPE, --UARTTB_PARITY_EVEN,--UARTTB_PARITY_NONE,
    DEFAULT_NUM_STOP_BITS => UARTTB_STOP_BITS_1
  )
  port map(
    TransactionRec => UartRxRec,
    SerialDataIn   => rx
  );
  ------------------------------------------------------------
  TestCtrl_1 : TestCtrl
  -- Stimulus generation and synchronization
  ------------------------------------------------------------
  generic map(
    tperiod_Clk => tperiod_Clk
  )
  port map(
    UartTxRec => UartTxRec,
    UartRxRec => UartRxRec,
    Clk       => Clk,
    nReset    => nReset
  );

end TestHarness;