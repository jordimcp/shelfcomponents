library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity top_uart is
  generic (
    CLK_PERIOD_NS  : time                 := 10 ns;
    UART_PERIOD_NS : time                 := 8680 ns;
    DATA_WIDTH     : integer range 5 to 8 := 8;
    N_PARITY_BIT   : integer range 0 to 1 := 0;
    PARITY_TYPE    : integer range 0 to 1 := 0
  );
  port (
    clk  : in std_logic;
    rstn : in std_logic;
    -- RX INTERFACE
    new_word_rx : out std_logic;
    word_rx     : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    busy_rx     : out std_logic;
    -- TX INTERFACE
    new_word_tx : in std_logic;
    word_tx     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    busy_tx     : out std_logic;
    parity_rx   : out std_logic;
    -- UART INTERFACE
    rx : in std_logic;
    tx : out std_logic
  );
end entity;

architecture Behavioral of top_uart is

begin

  uart_tx_inst : entity work.uart_tx
    generic map(
      CLK_PERIOD_NS  => CLK_PERIOD_NS,
      UART_PERIOD_NS => UART_PERIOD_NS,
      DATA_WIDTH     => DATA_WIDTH,
      PARITY_TYPE    => PARITY_TYPE,
      N_PARITY_BIT   => N_PARITY_BIT
    )
    port map(
      clk       => clk,
      rstn      => rstn,
      send_word => new_word_tx,
      word      => word_tx,
      busy_tx   => busy_tx,
      tx        => tx
    );

  uart_rx_inst : entity work.uart_rx
    generic map(
      CLK_PERIOD_NS  => CLK_PERIOD_NS,
      UART_PERIOD_NS => UART_PERIOD_NS,
      DATA_WIDTH     => DATA_WIDTH,
      N_PARITY_BIT   => N_PARITY_BIT
    )
    port map(
      clk       => clk,
      rstn      => rstn,
      recv_word => new_word_rx,
      word      => word_rx,
      busy_rx   => busy_rx,
      parity_rx => parity_rx,
      rx        => rx
    );
end architecture;