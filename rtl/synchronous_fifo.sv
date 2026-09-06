module synchronous_fifo #(

    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 16
) (
    input logic clk,
    input logic rst_n,

    input logic wr_en,
    input logic [DATA_WIDTH - 1 : 0] wr_data,

    input logic rd_en, 
    output logic [DATA_WIDTH - 1 : 0] rd_data,

    output logic full,
    output logic empty,
    output logic [$clog2(DEPTH+1)-1:0] occupancy

);

    // Internal data storage
    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    // Calculate the number of bits required for each pointer
    localparam int PTR_WIDTH = (DEPTH <= 1) ? 1 : $clog2(DEPTH);

    // Pointers to the next write location and oldest unread location
    logic [PTR_WIDTH-1:0] write_ptr;
    logic [PTR_WIDTH-1:0] read_ptr;

endmodule

