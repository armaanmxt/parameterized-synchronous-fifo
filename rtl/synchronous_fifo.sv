module synchronous_fifo #(

    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 16
) (
    input logic clk,
    input logic rst_n,                             //active low reset, resets the FIFO to empty state

    input logic wr_en,                             //requesting to be written, should be rejected if full
    input logic [DATA_WIDTH - 1 : 0] wr_data,

    input logic rd_en,                           //requesting to be read, should be rejected if empty                                                                   
    output logic [DATA_WIDTH - 1 : 0] rd_data,   //this is output because it is the data that is read from the FIFO

    output logic full,                             //full = 1 means every entry is occupied, no more data can be written
    output logic empty,                            // occupancy is zero, so no valid unread data exists
    output logic [$clog2(DEPTH+1)-1:0] occupancy    // gives the exact number of stored entries

);

    // Internal data storage
    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];        // The FIFO memory array, this is the internal storage for the FIFO, it is an array of registers that can hold DEPTH number of entries, each entry is DATA_WIDTH bits wide

    // Calculate the number of bits required for each pointer
    localparam int PTR_WIDTH = (DEPTH <= 1) ? 1 : $clog2(DEPTH);        //pointer width comes from DEPTH 
//basically creates an internal constant that the module calculates on its own
//$clog2, in hardware this is basically a calculation that determines how many bits are needed to count/represent a number, in our case the number we want to count is the variable DEPTH
// so the right side of the ":" is the number of bits needed to calculate DEPTH value
// left side is basically saying that if someone puts the depth as 1 or less, its just a safety check for that


    // Pointers to the next write location and oldest unread location
    logic [PTR_WIDTH-1:0] write_ptr;      //where the next accepted write value will be stored, this is the pointer that points to the next location in the FIFO memory array where a new value can be written
    logic [PTR_WIDTH-1:0] read_ptr;       //where the next read value will be taken from, this is the pointer that points to the next location in the FIFO memory array where a value can be read from


    // Internal signals indicating whether each request is accepted
    logic write_accept;            //these are just internal wires that we are defining to indicate whether a write or read request is accepted, they are not part of the module's interface, they are just used internally to control the behavior of the FIFO
    logic read_accept;             //same with this

    // FIFO status flags
    assign empty = (occupancy == 0);           //empty is high (= 1), when occupancy is zero
    assign full  = (occupancy == DEPTH);       // full is when occupancy is equal to the depth of the FIFO, meaning all entries are occupied

    // Reject writes while full and reads while empty
    assign write_accept = wr_en && !full;          // "!" means NOT, and "&&" means AND. so this accepts the write when a write is requested and it is not full at the same time. 
    assign read_accept  = rd_en && !empty;         // same as above, this accepts the read when a read is requested and it is not empty at the same time

endmodule

