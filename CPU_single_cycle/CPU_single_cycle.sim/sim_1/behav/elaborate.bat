@echo off
set xv_path=I:\\envirnment\\Xilinx\\Vivado\\2015.3\\bin
call %xv_path%/xelab  -wto 95225f249d924bd1ab09481b7e047e4c -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot CPU_single_cycle_tb_behav xil_defaultlib.CPU_single_cycle_tb xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
