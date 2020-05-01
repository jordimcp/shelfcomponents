library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity top_uart is
  generic (
    CLK_PERIOD_NS  : time := 10 ns;
    UART_PERIOD_NS : time := 8680 ns
  );
  port (
    clk  : in std_logic;
    rstn : in std_logic;
    -- RX INTERFACE
    new_word_rx : out std_logic;
    word_rx     : out std_logic_vector(7 downto 0);
    busy_rx     : out std_logic;
    -- TX INTERFACE
    new_word_tx : in std_logic;
    word_tx     : in std_logic_vector(7 downto 0);
    busy_tx     : out std_logic;
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
      UART_PERIOD_NS => UART_PERIOD_NS
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
      UART_PERIOD_NS => UART_PERIOD_NS
    )
    port map(
      clk       => clk,
      rstn      => rstn,
      recv_word => new_word_rx,
      word      => word_rx,
      busy_rx   => busy_rx,
      rx        => rx
    );
end architecture;