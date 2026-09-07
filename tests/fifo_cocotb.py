import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly


@cocotb.test()                                    #marks the function as a hardware test that cocotb will run
async def test_reset_state(dut):                  #async means function an pause while simulated time advances. dut is the python handle that connects out tests directly to our systemverilog module
    """The FIFO should be empty immediately after reset."""

    dut.rst_n.value = 0            #these are all directly connecting to pins on the systemverilog module. The .value is a cocotb function that allows us to set the value of the pin. 0 is logic low, 1 is logic high
    dut.wr_en.value = 0
    dut.wr_data.value = 0
    dut.rd_en.value = 0               #this basically gives python access to read and write enable pins on the FIFO module

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start(start_high=False)      #This creates a clock with a period of 10 ns (low for 5ns and high for 5ns), equivalent to a 100 MHz clock.
    )

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await ReadOnly()

    assert int(dut.empty.value) == 1, "FIFO was not empty after reset"                 #checks if FIFO is empty 
    assert int(dut.full.value) == 0, "FIFO was full after reset"                       #definetly should not be full after reset
    assert int(dut.occupancy.value) == 0, "Occupancy was not zero after reset"         #checks if occupancy is zero after reset
    assert int(dut.rd_data.value) == 0, "Read data was not cleared by reset"           #checks if read data is cleared by reset