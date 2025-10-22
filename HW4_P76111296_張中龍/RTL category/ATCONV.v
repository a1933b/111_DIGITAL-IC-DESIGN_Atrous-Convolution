`timescale 1ns/10ps
module  ATCONV(
	input		clk,
	input		reset,
	output	reg	busy,	
	input		ready,	
			
	output reg	[11:0]	iaddr,
	input signed [12:0]	idata,
	
	output	reg 	cwr,
	output  reg	[11:0]	caddr_wr,
	output reg 	[12:0] 	cdata_wr,
	
	output	reg 	crd,
	output reg	[11:0] 	caddr_rd,
	input 	[12:0] 	cdata_rd,
	
	output reg 	csel
	);

reg [12:0] kernel [0:8];
reg [11:0] tempaxis [0:17];
reg [3:0] state;
reg [12:0] imgcount;
reg [3:0] nextState;
reg [4:0] kdcount;
reg [6:0] row;
reg [6:0] col;
reg[6:0] coltempo;
reg[6:0] rowtempo;
initial begin
	kdcount<=5'd5;
	coltempo<=7'd0;
end
always @(posedge clk or posedge reset ) begin
	
	if(reset)begin
		rowtempo<=7'd0;
		imgcount<=13'd0;
		busy<=1'd0;
		row<=7'd0;
		col<=7'd0;
		state<=4'd0;
		kdcount<=5'd0;

		
	end else
	begin
		state<=nextState;
		case(state)
			4'd0: begin
				if(ready)begin
					busy<=1'b1;
				end else begin
					busy<=1'b0;
				end

			end
			4'd1: begin
				

				tempaxis[0]<=row-12'd2;
				tempaxis[1]<=col-12'd2;
				
				tempaxis[2]<=row-12'd2;
				tempaxis[3]<=col;

				tempaxis[4]<=row-12'd2;
				tempaxis[5]<=col+12'd2;

				tempaxis[6]<=row;
				tempaxis[7]<=col-12'd2;

				tempaxis[8]<=row;
				tempaxis[9]<=col;

				tempaxis[10]<=row;
				tempaxis[11]<=col+12'd2;

				tempaxis[12]<=row+12'd2;
				tempaxis[13]<=col-12'd2;

				tempaxis[14]<=row+12'd2;
				tempaxis[15]<=col;

				tempaxis[16]<=row+12'd2;
				tempaxis[17]<=col+12'd2;
			end
			4'd2: begin
					if(tempaxis[0][11]==1'b1 && tempaxis[1][11]==1'b1  )begin
						tempaxis[1]<=12'd0;
						tempaxis[0]<=12'd0;
					end else if(tempaxis[0][11]==1'b1 && tempaxis[1]<12'd64) begin
						tempaxis[0]<=12'd0;
					end else if(tempaxis[0]<12'd64 && tempaxis[1][11]==1'b1) begin
						tempaxis[1]<=12'd0;
					end else begin

					end


					if(tempaxis[2][11]==1'b1 && tempaxis[3]<12'd64) begin
						tempaxis[2]<=12'd0;
					end else begin

					end


					if(tempaxis[4][11]==1'b1 && tempaxis[5]<12'd64) begin
						tempaxis[4]<=12'd0;
					end else if(tempaxis[4][11]==1'b1 && tempaxis[5]>=12'd64) begin
						tempaxis[4]<=12'd0;
						tempaxis[5]<=12'd63;
					end else if(tempaxis[4]<12'd64 && tempaxis[5]>=12'd64)begin
						tempaxis[5]<=12'd63;
					end else begin

					end

					if(tempaxis[6]<12'd64 && tempaxis[7][11]==1'b1) begin
						tempaxis[7]<=12'd0;
					end else begin

					end

					if(tempaxis[10]<12'd64 && tempaxis[11]>=12'd64)begin
						tempaxis[11]<=12'd63;
					end else begin

					end

					if(tempaxis[12]<12'd64 && tempaxis[13][11]==1'b1) begin
						tempaxis[13]<=12'd0;
					end else if(tempaxis[12]>=12'd64 && tempaxis[13][11]==1'b1) begin
						tempaxis[12]<=12'd63;
						tempaxis[13]<=12'd0;
					end else if(tempaxis[12]>=12'd64 && tempaxis[13]<12'd64) begin
						tempaxis[12]<=12'd63;
					end else begin

					end

					if(tempaxis[14]>=12'd64 && tempaxis[15]<12'd64) begin
						tempaxis[14]<=12'd63;
					end else begin

					end


					if(tempaxis[16]<12'd64 && tempaxis[17]>=12'd64)begin
						tempaxis[17]<=12'd63;
					end else if(tempaxis[16]>=12'd64 && tempaxis[17]<12'd64) begin
						tempaxis[16]<=12'd63;
					end else if(tempaxis[16]>=12'd64 &&tempaxis[17]>=12'd64) begin
						tempaxis[16]<=12'd63;
						tempaxis[17]<=12'd63;
					end else begin

					end
						
			end
			4'd3:begin
				iaddr<=(((tempaxis[kdcount-5'd2] << 6))+tempaxis[((kdcount-5'd2)+12'd1)]);
				kernel[(kdcount >> 1)-5'd2]<=idata;
				kdcount<=kdcount+5'd2;
			end
			4'd4:begin
					csel<=1'b0;
					if(((kernel[4]-(kernel[0] >> 4)-(kernel[1]  >> 3)-(kernel[2]  >> 4)-(kernel[3]  >> 2)-(kernel[5]  >> 2)-(kernel[6]  >> 4)-(kernel[7]  >> 3)-(kernel[8]  >> 4)-14'd12 ))>kernel[4])
					begin
						cwr<=1'b1;
						cdata_wr<=13'd0;
						caddr_wr<=imgcount[11:0];
					end
					else begin
						cwr<=1'b1;
						cdata_wr<=(kernel[4]-(kernel[0] >> 4)-(kernel[1]  >> 3)-(kernel[2]  >> 4) 
									-(kernel[3]  >> 2)-(kernel[5]  >> 2) 
									-(kernel[6]  >> 4)-(kernel[7]  >> 3)-(kernel[8]  >> 4)-13'd12 );
						caddr_wr<=imgcount[11:0];
					end
					imgcount<=imgcount+13'd1;
					kdcount<=5'd0;
					if(col<7'd63)begin
						col<=col+7'd1;
					end
					else begin
						col<=7'd0;
						row<=row+7'd1;
					end
			end
			4'd5:begin
				col<=7'd0;
				row<=7'd0;
				imgcount<=13'd0;
				kdcount<=5'd0;
				

			end
			4'd6:begin
				crd<=1'b1;
				case(kdcount)
					5'd0:begin
						caddr_rd<=((row << 6)+col);
						kdcount<=5'd1;
					end
					5'd1: begin
						kernel[0]<=cdata_rd;
						kdcount<=5'd2;
					end
					5'd2:begin
						caddr_rd<=((row << 6) +col+12'd1);
						kdcount<=5'd3;
					end
					5'd3: begin
						kernel[1]<=cdata_rd;
						kdcount<=5'd4;
					end
					5'd4: begin
						caddr_rd<=( ((row+12'd1) << 6)+col);
						kdcount<=5'd5;
					end
					5'd5: begin
						kernel[2]<=cdata_rd;
						kdcount<=5'd6;
					end
					5'd6: begin
						caddr_rd<=(((row+12'd1) << 6) +col+12'd1);
						kdcount<=5'd7;
					end
					5'd7: begin
						kernel[3]<=cdata_rd;
						kdcount<=5'd8;
						csel<=1'b1;
					end
				endcase
				
			end
			4'd7:begin
				cwr<=1'b1;
				
					if(kernel[0]>=kernel[1])begin
						if(kernel[2]>=kernel[3])begin
							if(kernel[0]>=kernel[2])begin
								if(kernel[0][0]==1'b1||kernel[0][1]==1'b1||kernel[0][2]==1'b1||kernel[0][3]==1'b1)begin
									cdata_wr<=({kernel[0][12:4],4'b0000}+13'd16);
									caddr_wr<=imgcount[11:0];
								end
								else begin
									cdata_wr<=({kernel[0][12:4],4'b0000});
									caddr_wr<=imgcount[11:0];
								end
							end else
							begin
								if(kernel[2][0]==1'b1||kernel[2][1]==1'b1||kernel[2][2]==1'b1||kernel[2][3]==1'b1)begin
									cdata_wr<=({kernel[2][12:4],4'b0000}+13'd16);
									caddr_wr<=imgcount[11:0];
								end
								else begin
									cdata_wr<=({kernel[2][12:4],4'b0000});
									caddr_wr<=imgcount[11:0];
								end
							end

						end else
						begin
							if(kernel[0]>=kernel[3])begin
								if(kernel[0][0]==1'b1||kernel[0][1]==1'b1||kernel[0][2]==1'b1||kernel[0][3]==1'b1)begin
									cdata_wr<=({kernel[0][12:4],4'b0000}+13'd16);
									caddr_wr<=imgcount[11:0];
								end
								else begin
									cdata_wr<=({kernel[0][12:4],4'b0000});
									caddr_wr<=imgcount[11:0];
								end
							end
							else begin
								if(kernel[3][0]==1'b1||kernel[3][1]==1'b1||kernel[3][2]==1'b1||kernel[3][3]==1'b1)begin
									cdata_wr<=({kernel[3][12:4],4'b0000}+13'd16);
									caddr_wr<=imgcount[11:0];
								end
								else begin
									cdata_wr<=({kernel[3][12:4],4'b0000});
									caddr_wr<=imgcount[11:0];
								end

							end

						end
					end else begin
						if(kernel[2]>=kernel[3])begin
							if(kernel[1]>=kernel[2])begin
								if(kernel[1][0]==1'b1||kernel[1][1]==1'b1||kernel[1][2]==1'b1||kernel[1][3]==1'b1)begin
									cdata_wr<=({kernel[1][12:4],4'b0000}+13'd16);
									caddr_wr<=imgcount[11:0];
								end
								else begin
									cdata_wr<=({kernel[1][12:4],4'b0000});
									caddr_wr<=imgcount[11:0];
								end
							end else
							begin
								if(kernel[2][0]==1'b1||kernel[2][1]==1'b1||kernel[2][2]==1'b1||kernel[2][3]==1'b1)begin
									cdata_wr<=({kernel[2][12:4],4'b0000}+13'd16);
									caddr_wr<=imgcount[11:0];
								end
								else begin
									cdata_wr<=({kernel[2][12:4],4'b0000});
									caddr_wr<=imgcount[11:0];
								end
							end

						end else
						begin
							if(kernel[1]>=kernel[3])begin
								if(kernel[1][0]==1'b1||kernel[1][1]==1'b1||kernel[1][2]==1'b1||kernel[1][3]==1'b1)begin
									cdata_wr<=({kernel[1][12:4],4'b0000}+13'd16);
									caddr_wr<=imgcount[11:0];
								end
								else begin
									cdata_wr<=({kernel[1][12:4],4'b0000});
									caddr_wr<=imgcount[11:0];
								end
							end
							else begin
								if(kernel[3][0]==1'b1||kernel[3][1]==1'b1||kernel[3][2]==1'b1||kernel[3][3]==1'b1)begin
									cdata_wr<=({kernel[3][12:4],4'b0000}+13'd16);
									caddr_wr<=imgcount[11:0];
								end
								else begin
									cdata_wr<=({kernel[3][12:4],4'b0000});
									caddr_wr<=imgcount[11:0];
								end

							end

						end

					end
					

					if(col<7'd62)begin
						coltempo<=col+7'd2;
					end
					else begin
						rowtempo<=row+7'd2;
						coltempo<=7'd0;
					end
					kdcount<=4'd0;
					imgcount<=imgcount+12'd1;
			end
			4'd8:begin
				row<=rowtempo;
				col<=coltempo;
				crd<=1'b0;
				csel<=1'b0;
				cwr<=1'b0;
			end
			4'd9:begin
				busy<=1'b0;
			end
			default: begin
				busy<=1'b0;

			end
		
		endcase
	end
end
always @(*) begin
    case(state)
		4'd0:begin
			nextState = (ready)? 4'd1 : 4'd0;
		end
		4'd1:begin
			nextState =4'd2;
		end
		4'd2:begin
             nextState=(kdcount<5'd20)?4'd2:4'd3;
		end
		4'd3:begin
			nextState=(imgcount<13'd4096)?4'd1:4'd4;

		end
		4'd4:begin
			nextState=4'd5;
		end
		4'd5:begin
			nextState = (kdcount<5'd8)? 4'd5 : 4'd6;
		end
		4'd6:begin
			nextState = 4'd7;
		end
		4'd7:begin
			nextState = (imgcount < 13'd1024)? 4'd5 : 4'd8;
		end
		4'd8:begin
			nextState = 4'd8;
		end
		default:begin
			nextState=4'd0;
			
		end
	endcase
end
endmodule