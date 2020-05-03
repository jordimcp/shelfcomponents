library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity uart_rx is
  generic (
    CLK_PERIOD_NS  : time    := 10 ns;
    UART_PERIOD_NS : time    := 8680 ns;
    DATA_WIDTH     : integer := 8;
    N_PARITY_BIT   : integer := 0
  );
  port (
    clk       : in std_logic;
    rstn      : in std_logic;
    recv_word : out std_logic;
    word      : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    parity_rx : out std_logic;
    busy_rx   : out std_logic;
    rx        : in std_logic
  );
end entity;

architecture Behavioral of uart_rx is
  type state_type is (IDLE, RX_START, RCV, RX_PARITY, RX_STOP);

  type reg_type is record
    state      : state_type;
    next_state : state_type;
    recving    : std_logic;
    parity_bit : std_logic;
    count      : integer;
    count_bits : integer;
    recv_word  : std_logic;
    word       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    rx         : std_logic;
  end record;

  constant RST_REG : reg_type := (
  state      => IDLE,
  next_state => IDLE,
  recving    => '0',
  parity_bit => '0',
  count      => 0,
  count_bits => 0,
  recv_word  => '0',
  word => (others => '0'),
  rx         => '1'
  );
  constant COUNT_BARRIER : natural   := UART_PERIOD_NS / CLK_PERIOD_NS;
  constant START_BIT     : std_logic := '0';
  constant STOP_BIT      : std_logic := '1';
  signal r, rin          : reg_type;
begin

  process (rx, r)
    variable v : reg_type;
  begin
    v           := r;
    v.rx        := rx;
    v.recv_word := '0';
    case v.state is
      when IDLE =>
        v.count_bits := 0;
        v.count      := 0;
        if v.rx = '0' then
          v.next_state := RX_START;
        end if;
      when RX_START =>
        v.count := v.count + 1;
        if v.count = COUNT_BARRIER/2 then
          if v.rx = '1' then -- Glitch
            v.next_state := IDLE;
          end if;
        end if;
        if v.count = COUNT_BARRIER then
          v.count_bits := v.count_bits + 1;
          v.count      := 0;
          v.next_state := RCV;
        end if;
      when RCV =>
        v.count := v.count + 1;
        if v.count = COUNT_BARRIER/2 then
          v.word(word'high - 1 downto 0) := v.word(word'high downto 1);
          v.word(word'high)              := v.rx;
        end if;
        if v.count = COUNT_BARRIER then
          v.count_bits := v.count_bits + 1;
          v.count      := 0;
          if v.count_bits = DATA_WIDTH + 1 then
            if N_PARITY_BIT = 0 then
              v.next_state := RX_STOP;
            else
              v.next_state := RX_PARITY;
            end if;
          end if;
        end if;
      when RX_PARITY =>
        v.count := v.count + 1;
        if v.count = COUNT_BARRIER/2 then
          v.parity_bit := v.rx;
        end if;
        if v.count = COUNT_BARRIER then
          v.count      := 0;
          v.next_state := RX_STOP;
        end if;
      when RX_STOP =>
        v.count := v.count + 1;
        if v.count = COUNT_BARRIER then
          v.recv_word  := '1';
          v.count      := 0;
          v.next_state := IDLE;
          -- if tx is not 1 means an error
        end if;
      when others =>
        v.next_state := IDLE;
    end case;
    v.state := v.next_state;

    v.recving := '0';
    if v.state /= IDLE then
      v.recving := '1';
    end if;
    rin       <= v;
    busy_rx   <= r.recving;
    recv_word <= r.recv_word;
    word      <= r.word;
    parity_rx <= r.parity_bit;
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