module rdata_fifo(
    input                   	wclk,
    input                   	rclk,
    input                   	resetn,
    input       [63:0]      	data_in,
    input                   	write_en,
    input                   	read_en,
    output      [63:0]      	data_out,
    output                  	full,
    output                  	empty
);
    reg     	[63:0]        	ram[15:0];
    reg     	[4:0]        	write_addr_wclk;
    reg     	[4:0]        	read_addr_rclk;

    wire    	[4:0]        	write_addr_gray_wclk;
    reg     	[4:0]        	write_addr_gray_rclk0;
    reg     	[4:0]        	write_addr_gray_rclk1;

    wire    	[4:0]        	read_addr_gray_rclk;
    reg     	[4:0]        	read_addr_gray_wclk0;
    reg     	[4:0]        	read_addr_gray_wclk1;

    always@(posedge wclk or negedge resetn)//write addr wclk operation
        if(!resetn)
            write_addr_wclk <= 5'b0;
        else if(write_en == 1'b1 && full != 1'b1)
            write_addr_wclk <= write_addr_wclk + 1'b1;
        else
            write_addr_wclk <= write_addr_wclk;
    
    always@(posedge rclk or negedge resetn)//read addr read operation
        if(!resetn)
            read_addr_rclk <= 5'b0;
        else if(read_en == 1'b1 && empty != 1'b1)
            read_addr_rclk <= read_addr_rclk + 1'b1;
        else
            read_addr_rclk <= read_addr_rclk;
    
    always@(posedge wclk or negedge resetn)//sync
        if(!resetn)begin
            read_addr_gray_wclk0 <= 5'b0;
            read_addr_gray_wclk1 <= 5'b0;
        end
        else begin
            read_addr_gray_wclk0 <= read_addr_gray_rclk;
            read_addr_gray_wclk1 <= read_addr_gray_wclk0;
        end
    
    always@(posedge rclk or negedge resetn)//sync
        if(!resetn)begin
            write_addr_gray_rclk0 <= 5'b0;
            write_addr_gray_rclk1 <= 5'b0;
        end
        else begin
            write_addr_gray_rclk0 <= write_addr_gray_wclk;
            write_addr_gray_rclk1 <= write_addr_gray_rclk0;
        end

    always@(posedge wclk or negedge resetn)//data out
		if(!resetn)begin
			ram[0] <= 64'b0;
			ram[1] <= 64'b0;
			ram[2] <= 64'b0;
			ram[3] <= 64'b0;
			ram[4] <= 64'b0;
			ram[5] <= 64'b0;
			ram[6] <= 64'b0;
			ram[7] <= 64'b0;
			ram[8] <= 64'b0;
			ram[9] <= 64'b0;
			ram[10] <= 64'b0;
			ram[11] <= 64'b0;
			ram[12] <= 64'b0;
			ram[13] <= 64'b0;
			ram[14] <= 64'b0;
			ram[15] <= 64'b0;
		end
        else if(full == 1'b0 && write_en == 1'b1)
            ram[write_addr_wclk[3:0]] <= data_in;


    assign full = (write_addr_gray_wclk[4] != read_addr_gray_wclk1[4])?
                  (write_addr_gray_wclk[3] != read_addr_gray_wclk1[3])?
                  (write_addr_gray_wclk[2:0] == read_addr_gray_wclk1[2:0])?1'b1:1'b0:1'b0:1'b0;
    assign empty = (write_addr_gray_rclk1 == read_addr_gray_rclk)?1'b1:1'b0;
    
	assign data_out = ((read_en == 1'b1) && (empty != 1'b1))?ram[read_addr_rclk[3:0]]:31'b0;
    
	assign write_addr_gray_wclk = (write_addr_wclk>>1)^write_addr_wclk;
    assign read_addr_gray_rclk = (read_addr_rclk>>1)^read_addr_rclk;

endmodule 
