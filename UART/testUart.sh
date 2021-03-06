#Script to test UART component
mkdir work
rm work/*
mkdir ./sim/results
rm /sim/results/*
WORK_DIR="./work"
LIBRARY="work"
# PATH to needed Libraries
PATH_OSVVM="/home/joma/CompiledLibraries/osvvm/v08/"
PATH_OSVVM_COMMON="/home/joma/CompiledLibraries/osvvm_common/v08/"
PATH_OSVV_UART="/home/joma/CompiledLibraries/osvvm_uart/v08/"
# SRC
UART_TX="./src/uart_tx.vhd"
UART_RX="./src/uart_rx.vhd"
TOP_UART="./src/top_uart.vhd"
#SIM
TOP_TB="./sim/tbUart.vhd"
TEST_CTRL="./sim/TestCtrl.vhd"
NAME_TB="tbUart"
WAVE_NAME="tbUart.ghw"
#CONFIGURATION: kN1 or kE1 or kO1
CONF="./sim/SendGet_kO1.vhd"

ghdl -i --work=$LIBRARY --workdir=$WORK_DIR --std=08 -P$PATH_OSVVM -P$PATH_OSVV_UART -P$PATH_OSVVM_COMMON \
$UART_TX $UART_RX $TOP_UART $TEST_CTRL $CONF $TOP_TB

ghdl -m --work=$LIBRARY --workdir=$WORK_DIR --std=08 -P$PATH_OSVVM -P$PATH_OSVV_UART -P$PATH_OSVVM_COMMON \
$NAME_TB

ghdl -r --work=$LIBRARY --workdir=$WORK_DIR --std=08 -P$PATH_OSVVM -P$PATH_OSVV_UART -P$PATH_OSVVM_COMMON \
$NAME_TB --wave=$WAVE_NAME