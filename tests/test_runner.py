from pathlib import Path

from cocotb_tools.runner import get_runner


def test_fifo():                             #this is not the actual test, this just enables the environment to run the cocotb test. 
    project_root = Path(__file__).resolve().parents[1]
    rtl_source = project_root / "rtl" / "synchronous_fifo.sv"
    build_dir = project_root / "sim_build"
    test_dir = Path(__file__).resolve().parent

    runner = get_runner("icarus")

    runner.build(
        sources=[rtl_source],
        hdl_toplevel="synchronous_fifo",
        build_dir=build_dir,
        always=True,
        timescale=("1ns", "1ps"),
    )

    runner.test(
        hdl_toplevel="synchronous_fifo",
        test_module="fifo_cocotb",
        test_dir=test_dir,
        build_dir=build_dir,
    )