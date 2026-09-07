import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadOnly


@cocotb.test()
async def test_reset_state(dut):
    """The FIFO should be empty immediately after reset."""

    dut.rst_n.value = 0
    dut.wr_en.value = 0
    dut.wr_data.value = 0
    dut.rd_en.value = 0

    cocotb.start_soon(
        Clock(dut.clk, 10, unit="ns").start(start_high=False)
    )

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await ReadOnly()

    assert int(dut.empty.value) == 1, "FIFO was not empty after reset"
    assert int(dut.full.value) == 0, "FIFO was full after reset"
    assert int(dut.occupancy.value) == 0, "Occupancy was not zero after reset"
    assert int(dut.rd_data.value) == 0, "Read data was not cleared by reset"