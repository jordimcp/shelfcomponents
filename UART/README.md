# UART component
On src folder you will find the src code to be included into your Project.
On sim folder you will find how this component is tested, for that GHDL and OSVVM is needed.

On toDo.txt is the things planned to be done.

Configurable items in this component through generics:
  - CLK_PERIOD_NS (time ns): Period of the input clock in nanoseconds. 
  - UART_PERIOD_NS (time ns): Period of the desired UART (1/Baud_rate) in nanoseconds
  - Data width (integer): 8,7,6,5

Fixed:
  - Parity = None
  - Stop bits = 1