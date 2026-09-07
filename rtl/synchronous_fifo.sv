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


    // Update FIFO state on each rising clock edge
    always_ff @(posedge clk) begin             //because rst_n is not listed in the paranthesis, this is a synchronous reset, meaning that the reset will only take effect on the rising edge of the clock, not immediately when rst_n goes low
        if (!rst_n) begin                    //checks if the reset button is being pressed, if it is, then it resets the fifo to its initial state, which is empty, and all the pointers are set to zero
            write_ptr <= '0;
            read_ptr  <= '0;
            occupancy <= '0;                 //basically resetting all signals to 0, this is a SV shortcut. ('0' means all bits are set to 0)
            rd_data   <= '0;
        end

        else begin
            // Store an accepted write at the current write pointer
            if (write_accept) begin                //only begin if a write is accepted, this means request was made + fifo is not full
                memory[write_ptr] <= wr_data;        //take whatever wr_data (data being written) is and store it in the memory array at the location pointed to by write_ptr. (its doing all this at the next clock edge because of the always_ff block)

                // Wrap back to address zero after the final entry
                if (write_ptr == DEPTH - 1)          //this is if the write pointer is at the last entry of the FIFO, then it wraps back to 0, so that the next write will go to the first entry of the FIFO.
                    write_ptr <= '0;                 //reset the write pointer to 0
                else
                    write_ptr <= write_ptr + 1'b1;         //if the write pointer is not at the last entry, then it just increments the write pointer by 1, so that the next write will go to the next entry in the FIFO.
            end

            //return oldest value when a read is accepted and increment the read pointer to the next oldest value
             if (read_accept) begin                   //only execute this code if a read is accepted.
                rd_data <= memory[read_ptr];          //take the value at the location pointed to by the read pointer and output it to rd_data. (the value being read from the FIFO))

                // Wrap back to address zero after the final entry
                if (read_ptr == DEPTH - 1)             //if the read pointer is at the last entry of the FIFO, then it resets back to 0.
                    read_ptr <= '0;
                else
                    read_ptr <= read_ptr + 1'b1;       //otherwise, normally just increment the read pointer by 1, so that the next read will go to the next entry in the FIFO.
            end


            // Update the number of occupied FIFO entries
            case ({write_accept, read_accept})             //this combines two signals into one 2-bit signal (first bit is write accept and second bit represents read accept)
                2'b10: occupancy <= occupancy + 1'b1;      //this is the write accept case, and this would increase occupancy by +1.
                2'b01: occupancy <= occupancy - 1'b1;      //this is the read acceptance case, and this would decrease occupancy by -1.
                default: occupancy <= occupancy;           //either both are 0 or both are 1, either case the occupancy stays unchanged, so it just assigns occupancy to itself, which means no change.
            endcase
        end
    end



endmodule

