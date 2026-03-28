`define SPI_STATUS_IDLE 1'b0
`define SPI_STATUS_CYCLE_BITS 1'b1
 
 module spi_master #(
    parameter integer DATA_WIDTH = 8
 ) (
    input  wire clk,
    input  wire rst_n,
    input  wire start,                      
    input  wire [DATA_WIDTH-1:0] data_in,   
    input  wire                  miso,      
    output wire                  mosi,      
    output reg                   cs_n,      
    output wire                  sclk,
    output reg                   valid,
    output reg                  inactive,        
    output reg  [DATA_WIDTH-1:0] data_out   // Data received from slave
    
 );

    reg [DATA_WIDTH-1:0] data_in_reg;
    reg spi_status, mosi_q;                   
    reg [$clog2(DATA_WIDTH):0] bit_cnt;     
    reg clk_reg, clk_d;                    
    reg first_send;
    wire sclk_rise, sclk_fall;
   
    
    assign sclk = (~cs_n) ? clk_reg : 1'b0;
    assign mosi = (cs_n == 1'b0) ? mosi_q : 1'bz;                 

    // Edge detection for sclk
    assign sclk_rise = clk_reg & ~clk_d; 
    assign sclk_fall = ~clk_reg & clk_d; 

    always @(posedge clk or negedge rst_n) begin
        
        if (!rst_n) begin
            cs_n        <= 1'b1;                                                   
            mosi_q      <= 1'b0;                          
            bit_cnt     <= {($clog2(DATA_WIDTH)){1'b0}}; 
            spi_status  <= `SPI_STATUS_IDLE;         
            data_out    <= {DATA_WIDTH{1'b0}};
            clk_reg     <= 1'b0;
            clk_d       <= 1'b0;
            valid       <= 1'b0;
            inactive    <= 1'b1;
            first_send  <= 1'b1; 
            data_in_reg <= {DATA_WIDTH{1'b0}};     
        end else begin
            clk_d <= clk_reg;
            case(spi_status)
                `SPI_STATUS_IDLE: begin
                    valid <=1'b0;
                    if (start) begin
                        data_in_reg <= data_in;
                        cs_n        <= 1'b0;                  
                        bit_cnt     <= {($clog2(DATA_WIDTH)){1'b0}}; 
                        spi_status  <= `SPI_STATUS_CYCLE_BITS;
                        mosi_q      <= data_in[DATA_WIDTH-1];
                        data_in_reg <= data_in;
                        inactive    <= 1'b0; 
                    end
                end
                `SPI_STATUS_CYCLE_BITS: begin
                    clk_reg <= ~clk_reg;                  
                    if (sclk_rise) begin
                        mosi_q        <= (first_send) ? data_in_reg[DATA_WIDTH-2] : data_in_reg[DATA_WIDTH-1]; 
                        data_in_reg   <= (first_send) ? {data_in_reg[DATA_WIDTH-3:0], 2'b00} : {data_in_reg[DATA_WIDTH-2:0], 1'b0}; // Shift left
                        first_send    <= 1'b0;

                    end 
                    if (sclk_fall) begin
                        data_out <= {data_out[DATA_WIDTH-2:0], miso}; // Shift left and capture MISO
                        bit_cnt <= bit_cnt + 1'b1;
                        if (&bit_cnt[$clog2(DATA_WIDTH)-1:0]) inactive <= 1'b1;   
                    end
                    // if(bit_cnt == {1'b0, {($clog2(DATA_WIDTH)){1'b1}}}) begin
                    //     valid       <= 1'b1;
                    // end
                    if (bit_cnt[$clog2(DATA_WIDTH)]) begin
                        spi_status  <= `SPI_STATUS_IDLE; 
                        cs_n        <= 1'b1;
                        first_send  <= 1'b1;
                        valid       <= 1'b1;
                        inactive    <= 1'b1; 
                    end
                end
            endcase
        end
    end
    
    // assign inactive = (data_in == {DATA_WIDTH{1'b0}} || spi_status == `SPI_STATUS_IDLE) ? 1'b1 : 1'b0;

 endmodule