module fifo2axi(
	input					aclk,
	input					aresetn,
	//rdata_fifo
	output					rdata_r_en,
	input		[63:0]		axi_rdata,
	input					rdata_fifo_empty,
	//resp_fifo
	output					resp_r_en,
	input		[1:0]		axi_resp,
	input					resp_fifo_empty,
	//id_resp
	output					id_resp_r_en,
	input		[9:0]		axi_id_resp,
	input					id_resp_fifo_empty,
	//b response
	output reg	[7:0]		bid,
	output reg	[1:0]		bresp,
	output reg				bvalid,
	input					bready,
	//r response
	output reg	[7:0]		rid,
	output reg	[63:0]		rdata,
	output reg	[1:0]		rresp,
	output reg				rlast,
	output reg				rvalid,
	input					rready
);//read directly

	wire ready;
	assign ready = bready&rready;

	wire fifo_empty;
	assign fifo_empty = rdata_fifo_empty|resp_fifo_empty|id_resp_fifo_empty;

	wire read_en;
	assign read_en = (!rdata_fifo_empty)&(!resp_fifo_empty)&(!id_resp_fifo_empty)&ready;

	assign rdata_r_en = read_en;
	assign resp_r_en = read_en;
	assign id_resp_r_en = read_en;

	always@(posedge aclk or negedge aresetn)
		if(!aresetn)begin
			bid <= 8'b0;
			bresp <= 2'b0;
			bvalid <= 1'b0;

			rid <= 8'b0;
			rdata <= 64'b0;
			rresp <= 2'b0;
			rlast <= 1'b0;
			rvalid <= 1'b0;
		end
		else if(read_en == 1'b1)begin
			if(axi_id_resp[9] == 1'b1)begin
				bid <= axi_id_resp[7:0];
				bresp <= axi_resp;
				bvalid <= axi_id_resp[8];

				rid <= 8'b0;
				rdata <= 64'b0;
				rresp <= 2'b0;
				rlast <= 1'b0;
				rvalid <= 1'b0;
			end
			else begin
				bid <= 8'b0;
				bresp <= 2'b0;
				bvalid <= 1'b0;

				rid <= axi_id_resp[7:0];
				rdata <= axi_rdata;
				rresp <= axi_resp;
				rlast <= axi_id_resp[8];
				rvalid <= 1'b1;
			end
		end
		else if(rvalid == 1'b1 && rready == 1'b0)begin
			bid <= 8'b0;
			bresp <= 2'b0;
			bvalid <= 1'b0;

			rid <= rid;
			rdata <= rdata;
			rresp <= rresp;
			rlast <= rlast;
			rvalid <= 1'b1;
		end
		else if(bvalid == 1'b1 && bready == 1'b0)begin
			bid <= bid;
			bresp <= bresp;
			bvalid <= 1'b1;

			rid <= 8'b0;
			rdata <= 64'b0;
			rresp <= 2'b0;
			rlast <= 1'b0;
			rvalid <= 1'b0;
		end
		else if(fifo_empty == 1'b1)begin
			bid <= 8'b0;
			bresp <= 2'b0;
			bvalid <= 1'b0;

			rid <= 8'b0;
			rdata <= 64'b0;
			rresp <= 2'b0;
			rlast <= 1'b0;
			rvalid <= 1'b0;
		end


endmodule
