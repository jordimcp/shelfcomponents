# UART component

On sim folder you will find how this component is tested, for that GHDL and OSVVM is needed.
On src folder you will find the src code to be included into your Project.

- RX doesn't make any error checker, the output is a raw reception. 
- TX does the parity calculation and make sure no error is transmitted.


Configurable items in this component through generics:
  - CLK_PERIOD_NS (time ns): Period of the input clock in nanoseconds. 
  - UART_PERIOD_NS (time ns): Period of the desired UART (1/Baud_rate) in nanoseconds
  - Data width (integer): 8,7,6,5
  - N_PARITY_BIT (integer): 0 or 1
  - PARITY_TYPE (integer): 0 or 1 => Odd : 0 , Even : 1

Fixed:
  - Stop bits = 1



On toDo.txt is the things planned to be done.