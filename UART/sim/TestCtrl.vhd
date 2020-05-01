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

architecture SendGet1 of TestCtrl is

  signal CheckErrors : boolean;
  signal TestActive  : boolean := TRUE;

  signal TestDone : integer_barrier := 1;

  use osvvm_uart.ScoreboardPkg_Uart.all;
  shared variable UartScoreboard : osvvm_uart.ScoreboardPkg_Uart.ScoreboardPType;

begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetAlertLogName("TbUart_SendGet1");
    SetLogEnable(PASSED, TRUE); -- Enable PASSED logs
    UartScoreboard.SetAlertLogID("UART_SB1");

    -- Wait for testbench initialization 
    wait for 0 ns;
    wait for 0 ns;
    TranscriptOpen("./sim/results/TbUart_SendGet1.txt");
    SetTranscriptMirror(TRUE);
    -- Wait for Design Reset
    wait until nReset = '1';
    ClearAlerts;
    -- Wait for test to finish
    WaitForBarrier(TestDone, 10 ms);
    AlertIf(now >= 10 ms, "Test finished due to timeout");
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");

    TranscriptClose;
    print("");
    print("");
    std.env.stop;
    wait;
  end process ControlProc;

  ------------------------------------------------------------
  -- UartTbTxProc
  --   Provides transactions to UartTx via Send
  --   Used to test the UART Receiver in the UUT
  ------------------------------------------------------------
  UartTbTxProc : process
    variable UartTxID                     : AlertLogIDType;
    variable TransactionCount, ErrorCount : integer;
  begin

    GetAlertLogID(UartTxRec, UartTxID);
    SetLogEnable(UartTxID, INFO, TRUE);
    WaitForClock(UartTxRec, 2);

    --  Sequence 1
    Send(UartTxRec, X"50");    
    ------------------------------------------------------------
    -- End of test.  Wait for outputs to propagate and signal TestDone
    wait for 4 * UART_BAUD_PERIOD_115200;
    WaitForBarrier(TestDone);
    wait;
  end process UartTbTxProc;
  ------------------------------------------------------------
  -- UartTbRxProc
  --   Gets transactions from UartRx via UartGet and UartCheck
  --   Used to test the UART Transmitter in the UUT
  ------------------------------------------------------------
  UartTbRxProc : process
    variable RxStim, ExpectStim        : UartStimType;
    variable Available, TryExpectValid : boolean;

    variable UartRxID                     : AlertLogIDType;
    variable TransactionCount, ErrorCount : integer;
  begin
    GetAlertLogID(UartRxRec, UartRxID);
    WaitForClock(UartRxRec, 2);
    ExpectStim := (X"50", UARTTB_NO_ERROR);
    -- Get with one parameter
    Get(UartRxRec, RxStim.Data);
    RxStim.Error := std_logic_vector(UartRxRec.ErrorFromModel);
    AffirmIf(osvvm_UART.UartTbPkg.Match(RxStim, ExpectStim),
    "Received: " & to_string(RxStim),
    ".  Expected: " & to_string(ExpectStim));
    --
    ------------------------------------------------------------
    -- End of test.  Wait for outputs to propagate and signal TestDone
    TestActive <= FALSE;
    wait for 4 * UART_BAUD_PERIOD_115200;
    WaitForBarrier(TestDone);
    wait;
  end process UartTbRxProc;

end SendGet1;