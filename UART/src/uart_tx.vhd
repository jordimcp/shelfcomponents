library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity uart_tx is
  generic (
    CLK_PERIOD_NS  : time := 10 ns;
    UART_PERIOD_NS : time := 8680 ns
  );
  port (
    clk       : in std_logic;
    rstn      : in std_logic;
    send_word : in std_logic;
    word      : in std_logic_vector(7 downto 0);
    busy_tx   : out std_logic;
    tx        : out std_logic
  );
end entity;

architecture Behavioral of uart_tx is
  type reg_type is record
    sending    : std_logic;
    count      : integer;
    count_bits : integer;
    send_word  : std_logic;
    word       : std_logic_vector(7 downto 0);
    word2send  : std_logic_vector(9 downto 0);
    tx         : std_logic;
  end record;

  constant RST_REG : reg_type := (
  sending    => '0',
  count      => 0,
  count_bits => 0,
  send_word  => '0',
  word => (others => '0'),
  word2send => (others => '0'),
  tx         => '1'
  );
  constant COUNT_BARRIER : natural   := UART_PERIOD_NS / CLK_PERIOD_NS;
  constant START_BIT     : std_logic := '0';
  constant STOP_BIT      : std_logic := '1';
  signal r, rin          : reg_type;

begin

  process (send_word, word, r)
    variable v : reg_type;
  begin
    v           := r;
    v.send_word := send_word;
    v.word      := word;

    if v.send_word = '1' then
      v.sending    := '1';
      v.word2send  := STOP_BIT & v.word & START_BIT;
      v.count_bits := 0;
    end if;
    if v.sending = '1' then
      v.count := v.count + 1;
      if v.count = COUNT_BARRIER then
        v.count_bits            := v.count_bits + 1;
        v.count                 := 0;
        v.tx                    := v.word2send(0);
        v.word2send(8 downto 0) := v.word2send(9 downto 1);
        if v.count_bits = v.word2send'length + 1 then
          v.sending    := '0';
          v.tx         := '1';
          v.count_bits := 0;
        end if;
      end if;
    end if;

    rin     <= v;
    tx      <= r.tx;
    busy_tx <= r.sending;
  end process;

  process (clk, rstn)
  begin
    if rstn = '0' then
      r <= RST_REG;
    elsif rising_edge(clk) then
      r <= rin;
    end if;
  end process;

end architecture;